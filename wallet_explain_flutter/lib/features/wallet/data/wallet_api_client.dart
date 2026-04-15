import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';

class WalletApiClient {
  WalletApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<Map<String, dynamic>> analyzeWallet(String address) async {
    final uri = Uri.parse(
      '${AppConstants.apiBaseUrl}/wallet/analyze',
    ).replace(queryParameters: {'address': address});
    final response = await _httpClient.get(uri);

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      final error = json['error']?.toString() ?? 'Failed to analyze wallet.';
      final details = json['details']?.toString();
      if (details != null && details.isNotEmpty) {
        throw Exception('$error\n$details');
      }
      throw Exception(error);
    }

    return json;
  }
}
