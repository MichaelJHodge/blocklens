import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/wallet_analysis.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({super.key, required this.transaction});

  final WalletTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMMMd().add_jm().format(
      transaction.timestamp.toLocal(),
    );
    final accent = _directionColor(transaction.direction);

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: accent, width: 4)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.summary,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    date,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                _StatusChip(status: transaction.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _directionColor(String direction) {
    switch (direction) {
      case 'in':
        return const Color(0xFF22C55E);
      case 'out':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF38BDF8);
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final failed = status.toLowerCase() == 'failed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: failed ? const Color(0xFF7F1D1D) : const Color(0xFF064E3B),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        failed ? 'Failed' : 'Success',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
