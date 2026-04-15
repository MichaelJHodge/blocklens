import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/wallet_api_client.dart';
import '../../data/wallet_repository.dart';
import '../../domain/wallet_analysis.dart';

final walletApiClientProvider = Provider<WalletApiClient>((ref) {
  return WalletApiClient();
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.watch(walletApiClientProvider));
});

final walletAnalysisControllerProvider =
    StateNotifierProvider<WalletAnalysisController, WalletAnalysisState>((ref) {
      return WalletAnalysisController(ref.watch(walletRepositoryProvider));
    });

class WalletAnalysisController extends StateNotifier<WalletAnalysisState> {
  WalletAnalysisController(this._repository)
    : super(const WalletAnalysisState.idle());

  final WalletRepository _repository;

  Future<void> analyze(String address) async {
    state = const WalletAnalysisState.loading();
    try {
      final result = await _repository.analyzeWallet(address);
      state = WalletAnalysisState.success(result);
    } catch (e) {
      state = WalletAnalysisState.error(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

class WalletAnalysisState {
  const WalletAnalysisState._({required this.status, this.data, this.error});

  const WalletAnalysisState.idle() : this._(status: WalletAnalysisStatus.idle);
  const WalletAnalysisState.loading()
    : this._(status: WalletAnalysisStatus.loading);
  const WalletAnalysisState.success(WalletAnalysis data)
    : this._(status: WalletAnalysisStatus.success, data: data);
  const WalletAnalysisState.error(String error)
    : this._(status: WalletAnalysisStatus.error, error: error);

  final WalletAnalysisStatus status;
  final WalletAnalysis? data;
  final String? error;
}

enum WalletAnalysisStatus { idle, loading, success, error }
