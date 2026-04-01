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

      final compactPadding = AppConstants.defaultPadding * 0.75;

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
                          fontSize: 18, // Slightly smaller
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Monitor and update gold prices',
                        style: TextStyle(
                          fontSize: 11, // Slightly smaller
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  iconSize: 18,
                  icon: Icon(Icons.refresh_rounded, color: AppColors.primary),
                  onPressed: controller.refresh,
                  tooltip: 'Refresh',
                ),
              ],
            ),
            SizedBox(height: 10),

            _buildMainPriceCard(controller),
            SizedBox(height: 10),

            // Ultra-compact Stat Cards
            _buildPriceStatsSection(controller),
            SizedBox(height: 10),

            // Ultra-compact Charts
            _buildChartsSection(controller),
            SizedBox(height: 10),

            _buildUpdatePriceCard(context, controller),
            SizedBox(height: 10),

            _buildFeeStructure(),
          ],
        ),
      );
    });
  }

  Widget _buildMainPriceCard(GoldController controller) {
    final price = controller.currentPrice.value;

    if (price == null) {
      return ModernCard(
        padding: EdgeInsets.all(10),
        color: AppColors.background,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.diamond_outlined, size: 20, color: AppColors.primary),
            SizedBox(width: 10),
            Text(
              'No price has been set yet',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return ModernCard(
      padding: EdgeInsets.all(10),
      color: AppColors.surface,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.diamond_outlined, color: AppColors.primary, size: 18),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Current Market Price (${AppConstants.goldType})',
                  style: TextStyle(fontSize: 11, color: AppColors.grey700, fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                Formatters.formatRelativeTime(price.createdAt),
                style: TextStyle(fontSize: 9, color: AppColors.grey500),
              ),
            ],
          ),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                Formatters.formatCurrency(price.price),
                style: TextStyle(
                  fontSize: 24, // Reduced
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1,
                ),
              ),
              SizedBox(width: 4),
              Text(
                'per gram',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceStatsSection(GoldController controller) {
    final price = controller.currentPrice.value;
    if (price == null) return SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          // Increased aspect ratio makes cards shorter (flatter)
          childAspectRatio: Responsive.isMobile(context) ? 1.8 : 2.4,
          children: [
            ModernStatCard(
              title: 'Bank Sell',
              value: Formatters.formatCurrency(price.bankSellPrice),
              icon: Icons.account_balance_rounded,
              color: AppColors.success,
              subtitle: '${AppConstants.bankSellFeePercent}%',
            ),
            ModernStatCard(
              title: 'Store Sell',
              value: Formatters.formatCurrency(price.storeSellPrice),
              icon: Icons.store_rounded,
              color: AppColors.error,
              subtitle: '${AppConstants.storeSellFeePercent}%',
            ),
            ModernStatCard(
              title: 'Exchange',
              value: Formatters.formatCurrency(price.exchangePrice),
              icon: Icons.swap_horiz_rounded,
              color: Color(0xFF9C27B0),
              subtitle: '${AppConstants.exchangeFeePercent}%',
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartsSection(GoldController controller) {
    final price = controller.currentPrice.value;
    if (price == null) return SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Further reduced heights
        if (Responsive.isMobile(context)) {
          return Column(
            children: [
              _buildPriceComparisonChart(price, height: 150),
              SizedBox(height: 10),
              _buildFeeBreakdownChart(height: 150),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: _buildPriceComparisonChart(price, height: 165)),
            SizedBox(width: 10),
            Expanded(child: _buildFeeBreakdownChart(height: 165)),
          ],
        );
      },
    );
  }

  Widget _buildPriceComparisonChart(dynamic price, {double height = 165}) {
    final data = [
      _BarData(0, 'Mkt', price.price, AppColors.primary),
      _BarData(1, 'Bnk', price.bankSellPrice, AppColors.success),
      _BarData(2, 'Str', price.storeSellPrice, AppColors.error),
      _BarData(3, 'Exc', price.exchangePrice, Color(0xFF9C27B0)),
    ];

    return ChartCard(
      title: 'Comparison',
      padding: EdgeInsets.all(8),
      chart: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: price.price * 1.1,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, m) => Text(data[v.toInt()].label, style: TextStyle(fontSize: 8)),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (v, m) => Text('৳${(v / 1000).toStringAsFixed(0)}k', style: TextStyle(fontSize: 7)),
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: data.map((d) => BarChartGroupData(
            x: d.x,
            barRods: [BarChartRodData(toY: d.value, color: d.color, width: 16, borderRadius: BorderRadius.circular(3))],
          )).toList(),
        ),
      ),
      height: height,
    );
  }

  Widget _buildFeeBreakdownChart({double height = 165}) {
    final fees = [
      _PieData('Bank', AppConstants.bankSellFeePercent, AppColors.success),
      _PieData('Store', AppConstants.storeSellFeePercent, AppColors.error),
      _PieData('Exc', AppConstants.exchangeFeePercent, Color(0xFF9C27B0)),
      _PieData('Buy', AppConstants.buyFeePercent, AppColors.warning),
    ];

    return ChartCard(
      title: 'Fees %',
      padding: EdgeInsets.all(8),
      chart: PieChart(
        PieChartData(
          sections: fees.map((f) => PieChartSectionData(
            value: f.value,
            title: '${f.value.toInt()}%',
            color: f.color,
            radius: 35, // Reduced
            titleStyle: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
          )).toList(),
          centerSpaceRadius: 20, // Reduced
          sectionsSpace: 1,
        ),
      ),
      height: height,
    );
  }

  Widget _buildUpdatePriceCard(BuildContext context, GoldController controller) {
    final priceController = TextEditingController();

    return ModernCard(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Update Price', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36, // Reduced height
                  child: TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      hintText: 'New Price (BDT)',
                      prefixIcon: Icon(Icons.attach_money, size: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                height: 36,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isUpdatingPrice.value ? null : () {
                    final price = double.tryParse(priceController.text);
                    if (price != null) controller.updatePrice(price);
                  },
                  child: controller.isUpdatingPrice.value
                      ? SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text('Update', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeeStructure() {
    return ModernCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.textPrimary.withOpacity(0.4), size: 18),
              const SizedBox(width: 8),
              Text(
                'TRADING INFORMATION',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary.withOpacity(0.8),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInfoItem('GOLD TYPE', AppConstants.goldType, Icons.diamond_outlined)),
              const SizedBox(width: 6),
              Expanded(child: _buildInfoItem('MIN TRADE', '${AppConstants.minGrams} g', Icons.balance_rounded)),
              const SizedBox(width: 6),
              Expanded(child: _buildInfoItem('INCREMENT', '${AppConstants.gramsIncrement} g', Icons.add_circle_outline_rounded)),
              const SizedBox(width: 6),
              Expanded(child: _buildInfoItem('MIN EXCHANGE', '${AppConstants.minExchangeGrams} g', Icons.swap_horiz_rounded)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF3B82F6), size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8)),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarData {
  final int x;
  final String label;
  final double value;
  final Color color;
  _BarData(this.x, this.label, this.value, this.color);
}

class _PieData {
  final String label;
  final double value;
  final Color color;
  _PieData(this.label, this.value, this.color);
}