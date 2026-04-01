import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/gold_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import '../../widgets/common/modern_stat_card.dart';
import '../../widgets/common/modern_card.dart';
import '../../widgets/common/chart_card.dart';
import '../../widgets/common/info_box.dart';
import '../../widgets/common/chart_helpers.dart';

class GoldManagementScreen extends StatelessWidget {
  const GoldManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GoldController>();

    return Obx(() {
      if (controller.isLoading.value && controller.currentPrice.value == null) {
        return LoadingWidget(message: 'Loading gold prices...');
      }

      if (controller.errorMessage.value.isNotEmpty && controller.currentPrice.value == null) {
        return custom_error.CustomErrorWidget(
          message: controller.errorMessage.value,
          onRetry: controller.refresh,
        );
      }

      final compactPadding = AppConstants.defaultPadding * 0.5; // Even tighter padding

      return SingleChildScrollView(
        padding: EdgeInsets.all(compactPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gold Management',
                        style: TextStyle(
                          fontSize: 16, // Smaller
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Monitor and update gold prices',
                        style: TextStyle(
                          fontSize: 10, // Smaller
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  iconSize: 16,
                  icon: Icon(Icons.refresh_rounded, color: AppColors.primary),
                  onPressed: controller.refresh,
                ),
              ],
            ),
            SizedBox(height: 8),

            _buildMainPriceCard(controller),
            SizedBox(height: 8),

            // Ultra-compact Stat Cards (3 columns)
            _buildPriceStatsSection(controller),
            SizedBox(height: 8),

            // Ultra-compact Charts (Reduced height to 130-140)
            _buildChartsSection(controller),
            SizedBox(height: 8),

            _buildUpdatePriceCard(context, controller),
            SizedBox(height: 8),

            // Ultra-compact Trading Info (The 4 cards)
            _buildFeeStructure(),
          ],
        ),
      );
    });
  }

  Widget _buildMainPriceCard(GoldController controller) {
    final price = controller.currentPrice.value;
    if (price == null) return SizedBox.shrink();

    return ModernCard(
      padding: EdgeInsets.all(8),
      color: AppColors.surface,
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.diamond_outlined, color: AppColors.primary, size: 16),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Current Market Price (${AppConstants.goldType})',
                  style: TextStyle(fontSize: 10, color: AppColors.grey700, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                Formatters.formatRelativeTime(price.createdAt),
                style: TextStyle(fontSize: 8, color: AppColors.grey500),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                Formatters.formatCurrency(price.price),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
              SizedBox(width: 4),
              Text('per gram', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceStatsSection(GoldController controller) {
    final price = controller.currentPrice.value;
    if (price == null) return SizedBox.shrink();

    return SizedBox(
      height: 80,
      child: GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1.5, // Reduced from 2.0
        children: [
          _buildCompactStat('Bank Sell', price.bankSellPrice, AppColors.success, '${AppConstants.bankSellFeePercent}%'),
          _buildCompactStat('Store Sell', price.storeSellPrice, AppColors.error, '${AppConstants.storeSellFeePercent}%'),
          _buildCompactStat('Exchange', price.exchangePrice, Color(0xFF9C27B0), '${AppConstants.exchangeFeePercent}%'),
        ],
      ),
    );
  }

  Widget _buildCompactStat(String title, double value, Color color, String fee) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.grey600)),
          Text(Formatters.formatCurrency(value), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          Text(fee, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildChartsSection(GoldController controller) {
    final price = controller.currentPrice.value;
    if (price == null) return SizedBox.shrink();

    return Row(
      children: [
        Expanded(child: _buildPriceComparisonChart(price, height: 100)),
        SizedBox(width: 8),
        Expanded(child: _buildFeeBreakdownChart(height: 100)),
      ],
    );
  }

  Widget _buildPriceComparisonChart(dynamic price, {double height = 130}) {
    final data = [
      _BarData(0, 'Mkt', price.price, AppColors.primary),
      _BarData(1, 'Bnk', price.bankSellPrice, AppColors.success),
      _BarData(2, 'Str', price.storeSellPrice, AppColors.error),
      _BarData(3, 'Exc', price.exchangePrice, Color(0xFF9C27B0)),
    ];

    return ChartCard(
      title: 'Comparison',
      padding: EdgeInsets.all(6),
      chart: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: price.price * 1.1,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text(data[v.toInt()].label, style: TextStyle(fontSize: 7)))),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 25, getTitlesWidget: (v, m) => Text('${(v / 1000).toStringAsFixed(0)}k', style: TextStyle(fontSize: 6)))),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: data.map((d) => BarChartGroupData(x: d.x, barRods: [BarChartRodData(toY: d.value, color: d.color, width: 12, borderRadius: BorderRadius.circular(2))])).toList(),
        ),
      ),
      height: height,
    );
  }

  Widget _buildFeeBreakdownChart({double height = 130}) {
    final fees = [
      _PieData('Bank', AppConstants.bankSellFeePercent, AppColors.success),
      _PieData('Store', AppConstants.storeSellFeePercent, AppColors.error),
      _PieData('Exc', AppConstants.exchangeFeePercent, Color(0xFF9C27B0)),
      _PieData('Buy', AppConstants.buyFeePercent, AppColors.warning),
    ];

    return ChartCard(
      title: 'Fees %',
      padding: EdgeInsets.all(6),
      chart: PieChart(
        PieChartData(
          sections: fees.map((f) => PieChartSectionData(value: f.value, title: '${f.value.toInt()}%', color: f.color, radius: 30, titleStyle: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.white))).toList(),
          centerSpaceRadius: 15,
          sectionsSpace: 1,
        ),
      ),
      height: height,
    );
  }

  Widget _buildUpdatePriceCard(BuildContext context, GoldController controller) {
    final priceController = TextEditingController();
    return ModernCard(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 32,
              child: TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 11),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  hintText: 'New Price',
                  prefixIcon: Icon(Icons.attach_money, size: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ),
          ),
          SizedBox(width: 6),
          SizedBox(
            height: 32,
            child: Obx(() => ElevatedButton(
              onPressed: controller.isUpdatingPrice.value ? null : () {
                final price = double.tryParse(priceController.text);
                if (price != null) controller.updatePrice(price);
              },
              child: controller.isUpdatingPrice.value ? SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2)) : Text('Update', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeStructure() {
    return ModernCard(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(child: _buildInfoItem('GOLD', AppConstants.goldType, Icons.diamond_outlined)),
          const SizedBox(width: 4),
          Expanded(child: _buildInfoItem('MIN', '${AppConstants.minGrams}g', Icons.balance_rounded)),
          const SizedBox(width: 4),
          Expanded(child: _buildInfoItem('INC', '${AppConstants.gramsIncrement}g', Icons.add_circle_outline_rounded)),
          const SizedBox(width: 4),
          Expanded(child: _buildInfoItem('EXC', '${AppConstants.minExchangeGrams}g', Icons.swap_horiz_rounded)),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFF1F5F9), width: 1)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF3B82F6), size: 14),
          Text(label, style: TextStyle(fontSize: 6, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8))),
          Text(value, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B))),
        ],
      ),
    );
  }
}

class _BarData {
  final int x; final String label; final double value; final Color color;
  _BarData(this.x, this.label, this.value, this.color);
}

class _PieData {
  final String label; final double value; final Color color;
  _PieData(this.label, this.value, this.color);
}