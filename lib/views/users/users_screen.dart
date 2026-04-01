import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/user_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import '../../models/user.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);
  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Analyzing Data...');
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return custom_error.CustomErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.refresh,
          );
        }

        final totalUsers = controller.users.length;
        final activeUsers = controller.users
            .where((u) => controller.getUserTransactions(u.id).isNotEmpty)
            .length;
        final totalTransactions = controller.users.fold<int>(
            0, (sum, u) => sum + controller.getUserTransactions(u.id).length);

        return RefreshIndicator(
          onRefresh: () async => controller.refresh(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(controller),
                const SizedBox(height: 20),

                // Compact Soft Stat Cards
                _buildStatCards(totalUsers, activeUsers, totalTransactions),

                const SizedBox(height: 24),
                _buildSectionTitle('Performance Trends'),
                const SizedBox(height: 12),
                _buildLineChart(controller),

                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildPieChart(activeUsers, totalUsers)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildBarChart(controller)),
                  ],
                ),

                const SizedBox(height: 28),
                _buildUsersSection(controller),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary.withOpacity(0.8),
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildHeader(UserController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -0.8,
              ),
            ),
            Text(
              'System health and user activity',
              style: TextStyle(fontSize: 13, color: AppColors.grey500),
            ),
          ],
        ),
        GestureDetector(
          onTap: controller.refresh,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Icon(Icons.refresh_rounded, color: AppColors.primary, size: 22),
          ),
        ),
      ],
    );
  }

  // ── Compact Soft Stat Cards ────────────────────────────────────────────────
  Widget _buildStatCards(int total, int active, int txn) {
    return Row(
      children: [
        Expanded(child: _statCard('Total Users', total.toString(), Icons.group_rounded, const Color(0xFF2196F3))),
        const SizedBox(width: 10),
        Expanded(child: _statCard('Active Now', active.toString(), Icons.bolt_rounded, const Color(0xFF4CAF50))),
        const SizedBox(width: 10),
        Expanded(child: _statCard('Transactions', txn.toString(), Icons.receipt_rounded, const Color(0xFF673AB7))),
        const SizedBox(width: 10),
        Expanded(child: _statCard('Growth', '+12.5%', Icons.show_chart_rounded, const Color(0xFFFF9800))),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), // Soft background
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color)
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scaleXY(duration: 1200.ms, begin: 1.0, end: 1.1)
                .then()
                .scaleXY(duration: 1200.ms, begin: 1.1, end: 1.0),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color.withOpacity(0.9),
                  ),
                ).animate().fadeIn(duration: 400.ms),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1);
  }

  // ── Line Chart (Enhanced with more values) ────────────────────────────────
  Widget _buildLineChart(UserController controller) {
    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.withOpacity(0.05), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, m) {
                  const days = ['1 Mar', '2 Mar', '3 Mar', '4 Mar', '5 Mar', '6 Mar', '7 Mar'];
                  return Text(days[v.toInt() % 7], style: const TextStyle(color: Colors.grey, fontSize: 9));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [FlSpot(0, 2), FlSpot(1, 1.5), FlSpot(2, 4), FlSpot(3, 3), FlSpot(4, 5), FlSpot(5, 4), FlSpot(6, 6)],
              isCurved: true,
              gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF00BCD4)]),
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [const Color(0xFF2196F3).withOpacity(0.15), const Color(0xFF2196F3).withOpacity(0)])),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(int active, int total) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(color: const Color(0xFF4CAF50), value: active.toDouble(), radius: 35, showTitle: false),
            PieChartSectionData(color: Colors.grey.shade100, value: (total - active).toDouble(), radius: 30, showTitle: false),
          ],
          centerSpaceRadius: 25,
        ),
      ),
    );
  }

  Widget _buildBarChart(UserController controller) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 10,
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 7, color: const Color(0xFF4CAF50), width: 10, borderRadius: BorderRadius.circular(4))]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 4, color: Colors.orange, width: 10, borderRadius: BorderRadius.circular(4))]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 2, color: Colors.red, width: 10, borderRadius: BorderRadius.circular(4))]),
          ],
          titlesData: FlTitlesData(show: false),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildUsersSection(UserController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Recent Users'),
            TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(fontSize: 13))),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.filteredUsers.length.clamp(0, 5),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final user = controller.filteredUsers[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text((user.email?.isNotEmpty ?? false) ? user.email![0].toUpperCase() : 'U', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('Joined ${Formatters.formatDate(user.createdAt)}', style: TextStyle(color: AppColors.grey500, fontSize: 11)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}