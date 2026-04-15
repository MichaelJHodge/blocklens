import 'package:serverpod/serverpod.dart';

import 'core/environment.dart';
import 'features/wallet/api/wallet_route.dart';
import 'features/wallet/services/etherscan_service.dart';
import 'features/wallet/services/llm_summarizer_service.dart';
import 'features/wallet/services/wallet_analysis_service.dart';
import 'generated/endpoints.dart';
import 'generated/protocol.dart';

Future<void> run(List<String> args) async {
  final env = Environment.load();

  final analysisService = WalletAnalysisService(
    etherscanService: EtherscanService(
      apiKey: env.require('ETHERSCAN_API_KEY'),
      chainId: env.get('ETHERSCAN_CHAIN_ID') ?? '1',
    ),
    llmService: LlmSummarizerService(apiKey: env.require('OPENAI_API_KEY')),
  );

  final pod = Serverpod(args, Protocol(), Endpoints());

  pod.webServer.addRoute(
    WalletRoute(analysisService: analysisService),
    '/wallet/analyze',
  );

  await pod.start();
}
