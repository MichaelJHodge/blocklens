import 'package:serverpod/serverpod.dart';

import '../features/wallet/domain/wallet_validator.dart';
import '../features/wallet/services/wallet_analysis_service.dart';

class WalletEndpoint extends Endpoint {
  WalletEndpoint(this._analysisService);

  final WalletAnalysisService _analysisService;

  Future<Map<String, dynamic>> analyze(Session session, String address) async {
    if (!WalletValidator.isValidEthereumAddress(address)) {
      throw Exception('Invalid Ethereum wallet address.');
    }

    final result = await _analysisService.analyze(address);
    return result.toJson();
  }
}
