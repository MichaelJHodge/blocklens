import 'package:flutter/material.dart';

import '../../domain/wallet_analysis.dart';
import '../widgets/transaction_card.dart';

class WalletResultsScreen extends StatelessWidget {
  const WalletResultsScreen({super.key, required this.result});

  final WalletAnalysis result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet Analysis')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: result.transactions.isEmpty
              ? const Center(child: Text('No recent transactions found'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (result.insightSummary != null &&
                        result.insightSummary!.isNotEmpty)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          result.insightSummary!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: result.transactions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final tx = result.transactions[index];
                          return TweenAnimationBuilder<double>(
                            duration: Duration(
                              milliseconds: 260 + (index * 70),
                            ),
                            tween: Tween(begin: 24, end: 0),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, value),
                                child: Opacity(
                                  opacity: 1 - (value / 24),
                                  child: child,
                                ),
                              );
                            },
                            child: TransactionCard(transaction: tx),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
