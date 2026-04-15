import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/wallet_models.dart';

class EtherscanService {
  EtherscanService({
    required this.apiKey,
    this.chainId = '1',
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String apiKey;
  final String chainId;
  final http.Client _client;

  Future<List<NormalizedTransaction>> fetchRecentTransactions(
    String address,
  ) async {
    final normalTx = await _fetchByAction(address: address, action: 'txlist');
    if (normalTx.isNotEmpty) return normalTx;

    // Some wallets have mostly ERC-20 activity and no recent native transfers.
    return _fetchByAction(address: address, action: 'tokentx');
  }

  Future<List<NormalizedTransaction>> _fetchByAction({
    required String address,
    required String action,
  }) async {
    final uri = Uri.https('api.etherscan.io', '/v2/api', {
      'chainid': chainId,
      'module': 'account',
      'action': action,
      'address': address,
      'startblock': '0',
      'endblock': '99999999',
      'page': '1',
      'offset': '20',
      'sort': 'desc',
      'apikey': apiKey,
    });

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch transactions from Etherscan.');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final result = payload['result'];
    final message = payload['message']?.toString() ?? '';

    if (result is String) {
      final lower = result.toLowerCase();
      if (lower.contains('no transactions found')) {
        return const [];
      }
      throw Exception('Etherscan $action error: $result');
    }

    if (result is! List) {
      throw Exception(
        'Etherscan $action error: ${payload['result'] ?? payload['message'] ?? 'Unexpected payload.'}',
      );
    }

    if ((payload['status']?.toString() == '0') &&
        result.isEmpty &&
        message.toUpperCase() != 'OK') {
      throw Exception(
        'Etherscan $action error: ${payload['result'] ?? payload['message'] ?? 'Unknown error.'}',
      );
    }

    return result.take(20).map((item) {
      final tx = item as Map<String, dynamic>;
      final method = (tx['functionName'] as String?)?.trim() ?? 'transfer';
      final from = (tx['from'] as String? ?? '').toLowerCase();
      final to = (tx['to'] as String? ?? '').toLowerCase();
      final input = tx['input'] as String? ?? '';
      final valueRaw = double.tryParse(tx['value']?.toString() ?? '0') ?? 0.0;
      final tokenDecimals =
          int.tryParse(tx['tokenDecimal']?.toString() ?? '') ?? 18;
      final divisor = tokenDecimals <= 0 ? 1.0 : _pow10(tokenDecimals);
      final value = valueRaw / divisor;
      final token = (tx['tokenSymbol'] as String?)?.trim();
      final status = (tx['isError']?.toString() == '1') ? 'failed' : 'success';
      final timestamp = int.tryParse(tx['timeStamp']?.toString() ?? '0') ?? 0;
      return NormalizedTransaction(
        type: _inferType(method: method, input: input, valueEth: value),
        from: from,
        to: to,
        value: double.parse(value.toStringAsFixed(6)),
        token: token == null || token.isEmpty ? 'ETH' : token,
        method: method,
        timestamp: timestamp,
        status: status,
        direction: 'contract',
      );
    }).toList();
  }

  double _pow10(int exponent) {
    var result = 1.0;
    for (var i = 0; i < exponent; i++) {
      result *= 10;
    }
    return result;
  }

  String _inferType({
    required String method,
    required String input,
    required double valueEth,
  }) {
    final lower = method.toLowerCase();
    if (lower.contains('swap')) {
      return 'swap';
    }
    if (lower.contains('approve')) {
      return 'approval';
    }
    if (input != '0x' && input.isNotEmpty && valueEth == 0) {
      return 'contract_call';
    }
    return 'transfer';
  }
}
