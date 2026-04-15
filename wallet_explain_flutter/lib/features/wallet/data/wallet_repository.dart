import '../domain/wallet_analysis.dart';
import 'wallet_api_client.dart';

class WalletRepository {
  WalletRepository(this._apiClient);

  final WalletApiClient _apiClient;

  Future<WalletAnalysis> analyzeWallet(String address) async {
    final payload = await _apiClient.analyzeWallet(address);
    final txRaw = payload['transactions'] as List<dynamic>? ?? const [];

    final transactions = txRaw.map((item) {
      final tx = item as Map<String, dynamic>;
      final timestampSeconds = (tx['timestamp'] as num?)?.toInt() ?? 0;
      return WalletTransaction(
        summary: tx['summary']?.toString() ?? 'Unknown transaction',
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestampSeconds * 1000),
        direction: tx['direction']?.toString() ?? 'contract',
        status: tx['status']?.toString() ?? 'success',
      );
    }).toList();

    return WalletAnalysis(
      address: payload['address']?.toString() ?? address,
      insightSummary: payload['insightSummary']?.toString(),
      transactions: transactions,
    );
  }
}
