import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../models/transaction.dart';
import './transaction_constants.dart';
import 'atoms/transaction_card.dart';

class VolumeByTypeChart extends StatelessWidget {
  final List<Transaction> transactions;
  const VolumeByTypeChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final types = [
      'BUY_IN_APP', 'BUY_IN_STORE',
      'SELL_TO_BANK', 'SELL_TO_STORE',
    ];
    final colors = [
      colBuyApp, colBuyStore, colSellBank, colSellStore,
    ];
    final labels = ['App', 'Store', 'Bank', 'Sell'];

    final counts = types
        .map((t) => transactions.where((tx) => tx.type.toUpperCase() == t).length)
        .toList();
    final maxC = counts.reduce((a, b) => a > b ? a : b);

    return TransactionCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const CardLabel('Volume by Type'),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (maxC + 1).toDouble(),
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, meta) {
                      final i = v.toInt();
                      if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(labels[i],
                            style: const TextStyle(fontSize: 8.5, color: textSec)),
                      );
                    },
                    reservedSize: 20,
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (_) => FlLine(
                    color: border, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(
                types.length,
                    (i) => BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: counts[i].toDouble(),
                      color: colors[i],
                      width: 18,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4)),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: (maxC + 1).toDouble(),
                        color: colors[i].withOpacity(0.06),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
