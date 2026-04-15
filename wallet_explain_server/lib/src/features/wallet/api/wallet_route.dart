import 'package:serverpod/serverpod.dart';
import 'dart:convert';
import 'dart:io';

import '../domain/wallet_validator.dart';
import '../services/wallet_analysis_service.dart';

class WalletRoute extends Route {
  WalletRoute({required WalletAnalysisService analysisService})
    : _analysisService = analysisService,
      super(method: RouteMethod.get);

  final WalletAnalysisService _analysisService;

  @override
  Future<bool> handleCall(Session session, HttpRequest request) async {
    final address = request.uri.queryParameters['address']?.trim() ?? '';
    if (!WalletValidator.isValidEthereumAddress(address)) {
      await _writeJson(
        request,
        statusCode: 400,
        body: {'error': 'Invalid Ethereum wallet address.'},
      );
      return true;
    }

    try {
      final result = await _analysisService.analyze(address);
      await _writeJson(request, statusCode: 200, body: result.toJson());
      return true;
    } catch (e) {
      await _writeJson(
        request,
        statusCode: 502,
        body: {'error': 'Upstream service failure.', 'details': e.toString()},
      );
      return true;
    }
  }

  Future<void> _writeJson(
    HttpRequest request, {
    required int statusCode,
    required Map<String, dynamic> body,
  }) async {
    request.response.statusCode = statusCode;
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode(body));
    await request.response.close();
  }
}
