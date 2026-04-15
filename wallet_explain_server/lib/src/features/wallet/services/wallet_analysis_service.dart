import '../../../core/in_memory_cache.dart';
import '../models/wallet_models.dart';
import 'etherscan_service.dart';
import 'llm_summarizer_service.dart';

class WalletAnalysisService {
  WalletAnalysisService({
    required EtherscanService etherscanService,
    required LlmSummarizerService llmService,
    Duration cacheTtl = const Duration(minutes: 5),
  }) : _etherscanService = etherscanService,
       _llmService = llmService,
       _cache = InMemoryCache<WalletAnalysisResult>(ttl: cacheTtl);

  final EtherscanService _etherscanService;
  final LlmSummarizerService _llmService;
  final InMemoryCache<WalletAnalysisResult> _cache;

  Future<WalletAnalysisResult> analyze(String address) async {
    final cacheKey = address.toLowerCase();
    final cached = _cache.get(cacheKey);
    if (cached != null) return cached;

    final normalized = await _etherscanService.fetchRecentTransactions(
      cacheKey,
    );
    final limited = normalized.take(10).toList();

    List<String> summaries;
    try {
      summaries = await _llmService.summarizeTransactions(limited);
    } catch (_) {
      summaries = limited.map(_fallbackSummary).toList();
    }

    final explained = <ExplainedTransaction>[];
    for (var i = 0; i < limited.length; i++) {
      final tx = limited[i];
      explained.add(
        ExplainedTransaction(
          summary: i < summaries.length ? summaries[i] : _fallbackSummary(tx),
          timestamp: tx.timestamp,
          direction: _directionFromTx(address: cacheKey, tx: tx),
          status: tx.status,
        ),
      );
    }

    String? insight;
    try {
      insight = await _llmService.summarizeInsights(limited);
    } catch (_) {
      insight = _fallbackInsight(limited);
    }

    final result = WalletAnalysisResult(
      address: cacheKey,
      transactions: explained,
      insightSummary: insight,
    );

    _cache.put(cacheKey, result);
    return result;
  }

  String _directionFromTx({
    required String address,
    required NormalizedTransaction tx,
  }) {
    if (tx.to == address) return 'in';
    if (tx.from == address) return 'out';
    return 'contract';
  }

  String _fallbackSummary(NormalizedTransaction tx) {
    switch (tx.type) {
      case 'swap':
        return 'Swap transaction involving ${tx.value} ${tx.token}.';
      case 'approval':
        return 'Approved a contract interaction.';
      case 'contract_call':
        return 'Interacted with a smart contract.';
      default:
        return 'Transferred ${tx.value} ${tx.token}.';
    }
  }

  String? _fallbackInsight(List<NormalizedTransaction> txs) {
    if (txs.isEmpty) return null;
    final swaps = txs.where((t) => t.type == 'swap').length;
    final approvals = txs.where((t) => t.type == 'approval').length;
    if (swaps > approvals && swaps > 0) {
      return 'Mostly swap activity with active DeFi usage.';
    }
    if (approvals > 0) {
      return 'Frequent contract approvals suggest recurring dApp usage.';
    }
    return 'Recent activity is mostly transfers and contract interactions.';
  }
}
