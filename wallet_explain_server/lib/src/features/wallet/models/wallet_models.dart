class NormalizedTransaction {
  NormalizedTransaction({
    required this.type,
    required this.from,
    required this.to,
    required this.value,
    required this.token,
    required this.method,
    required this.timestamp,
    required this.status,
    required this.direction,
  });

  final String type;
  final String from;
  final String to;
  final double value;
  final String token;
  final String method;
  final int timestamp;
  final String status;
  final String direction;

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'from': from,
      'to': to,
      'value': value,
      'token': token,
      'method': method,
      'timestamp': timestamp,
      'status': status,
      'direction': direction,
    };
  }
}

class ExplainedTransaction {
  ExplainedTransaction({
    required this.summary,
    required this.timestamp,
    required this.direction,
    required this.status,
  });

  final String summary;
  final int timestamp;
  final String direction;
  final String status;

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'timestamp': timestamp,
      'direction': direction,
      'status': status,
    };
  }
}

class WalletAnalysisResult {
  WalletAnalysisResult({
    required this.address,
    required this.transactions,
    this.insightSummary,
  });

  final String address;
  final List<ExplainedTransaction> transactions;
  final String? insightSummary;

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'insightSummary': insightSummary,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
  }
}
