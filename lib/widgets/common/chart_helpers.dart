import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ChartHelpers {
  static List<Color> getGradientColors(Color baseColor) {
    return [
      baseColor,
      baseColor.withOpacity(0.3),
    ];
  }

  static List<Color> primaryGradient = [
    AppColors.primary,
    AppColors.primary.withOpacity(0.3),
  ];

  static List<Color> successGradient = [
    AppColors.success,
    AppColors.success.withOpacity(0.3),
  ];

  static List<Color> warningGradient = [
    AppColors.warning,
    AppColors.warning.withOpacity(0.3),
  ];

  static List<Color> errorGradient = [
    AppColors.error,
    AppColors.error.withOpacity(0.3),
  ];

  static List<Color> chartColors = [
    const Color(0xFF2196F3), // Blue
    const Color(0xFF4CAF50), // Green
    const Color(0xFFFF9800), // Orange
    const Color(0xFFF44336), // Red
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFFFFEB3B), // Yellow
    const Color(0xFFE91E63), // Pink
  ];

  static FlGridData defaultGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: 1,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: AppColors.grey200,
          strokeWidth: 1,
        );
      },
    );
  }

  static FlBorderData defaultBorderData() {
    return FlBorderData(
      show: true,
      border: Border(
        bottom: BorderSide(color: AppColors.grey300, width: 1),
        left: BorderSide(color: AppColors.grey300, width: 1),
      ),
    );
  }

  static FlTitlesData defaultTitlesData({
    required Widget Function(double, TitleMeta) bottomTitles,
    required Widget Function(double, TitleMeta) leftTitles,
  }) {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 1,
          getTitlesWidget: bottomTitles,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 42,
          interval: 1,
          getTitlesWidget: leftTitles,
        ),
      ),
    );
  }

  static Widget defaultAxisTitle(String text, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.grey600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static LineTouchData defaultLineTouchData() {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (touchedSpot) => AppColors.grey800.withOpacity(0.8),
        tooltipRoundedRadius: 8,
        tooltipPadding: const EdgeInsets.all(8),
        getTooltipItems: (List<LineBarSpot> touchedSpots) {
          return touchedSpots.map((spot) {
            return LineTooltipItem(
              spot.y.toStringAsFixed(1),
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          }).toList();
        },
      ),
      handleBuiltInTouches: true,
      getTouchedSpotIndicator: (barData, spotIndexes) {
        return spotIndexes.map((spotIndex) {
          return TouchedSpotIndicatorData(
            FlLine(
              color: AppColors.primary,
              strokeWidth: 2,
              dashArray: [5, 5],
            ),
            FlDotData(
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: Colors.white,
                  strokeWidth: 3,
                  strokeColor: AppColors.primary,
                );
              },
            ),
          );
        }).toList();
      },
    );
  }

  static BarTouchData defaultBarTouchData() {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (group) => AppColors.grey800.withOpacity(0.8),
        tooltipRoundedRadius: 8,
        tooltipPadding: const EdgeInsets.all(8),
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          return BarTooltipItem(
            rod.toY.toStringAsFixed(1),
            const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          );
        },
      ),
    );
  }

  static PieTouchData defaultPieTouchData() {
    return PieTouchData(
      touchCallback: (FlTouchEvent event, pieTouchResponse) {},
    );
  }
}
