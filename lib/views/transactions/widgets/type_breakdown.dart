import 'package:flutter/material.dart';
import '../../../../models/transaction.dart';
import './transaction_constants.dart';
import 'atoms/transaction_card.dart';

class TypeBreakdownList extends StatelessWidget {
  final List<Transaction> transactions;
  const TypeBreakdownList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final types = [
      ('BUY_IN_APP', colBuyApp),
      ('BUY_IN_STORE', colBuyStore),
      ('SELL_TO_BANK', colSellBank),
      ('SELL_TO_STORE', colSellStore),
    ];
    final total = transactions.length;

    return TransactionCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const CardLabel('By Type'),
        const SizedBox(height: 8),
        ...types.map((e) {
          final cnt = transactions
              .where((tx) => tx.type.toUpperCase() == e.$1)
              .length;
          final pct = total > 0 ? cnt / total : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(children: [
              Container(
                width: 6, height: 6,
                decoration: BoxDecoration(
                    color: e.$2, shape: BoxShape.circle),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(typeLabel(e.$1),
                    style: const TextStyle(fontSize: 10, color: textPri,
                        fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 4,
                    backgroundColor: e.$2.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(e.$2),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 22,
                child: Text('$cnt',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 10,
                        fontWeight: FontWeight.w700, color: e.$2)),
              ),
            ]),
          );
        }),
      ]),
    );
  }
}
