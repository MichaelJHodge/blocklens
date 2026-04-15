import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/wallet_analysis_controller.dart';
import 'wallet_results_screen.dart';

class WalletLoadingScreen extends ConsumerStatefulWidget {
  const WalletLoadingScreen({super.key, required this.address});

  final String address;

  @override
  ConsumerState<WalletLoadingScreen> createState() =>
      _WalletLoadingScreenState();
}

class _WalletLoadingScreenState extends ConsumerState<WalletLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fade;
  late final ProviderSubscription<WalletAnalysisState> _subscription;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _fade = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    Future.microtask(_analyze);

    _subscription = ref.listenManual(walletAnalysisControllerProvider, (
      previous,
      next,
    ) async {
      if (!mounted) return;

      if (next.status == WalletAnalysisStatus.success && next.data != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => WalletResultsScreen(result: next.data!),
          ),
        );
      }

      if (next.status == WalletAnalysisStatus.error && next.error != null) {
        final retry = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Analysis Failed'),
              content: Text(next.error!),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Back'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Retry'),
                ),
              ],
            );
          },
        );

        if (!mounted) return;
        if (retry == true) {
          await _analyze();
        } else {
          Navigator.of(context).pop();
        }
      }
    });
  }

  Future<void> _analyze() {
    return ref
        .read(walletAnalysisControllerProvider.notifier)
        .analyze(widget.address);
  }

  @override
  void dispose() {
    _subscription.close();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 18),
              Text('Analyzing wallet activity...'),
            ],
          ),
        ),
      ),
    );
  }
}
