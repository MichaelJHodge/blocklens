class WalletAnalysis {
  WalletAnalysis({
    required this.address,
    required this.transactions,
    this.insightSummary,
  });

  final String address;
  final String? insightSummary;
  final List<WalletTransaction> transactions;
}

class WalletTransaction {
  WalletTransaction({
    required this.summary,
    required this.timestamp,
    required this.direction,
    required this.status,
  });

  final String summary;
  final DateTime timestamp;
  final String direction;
  final String status;
}
