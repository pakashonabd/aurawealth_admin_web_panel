import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/user_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import '../../widgets/common/animated_screen_wrapper.dart';
import '../../widgets/common/user_avatar_image.dart';
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
          0,
          (sum, u) => sum + controller.getUserTransactions(u.id).length,
        );

        return RefreshIndicator(
          onRefresh: () async => controller.refresh(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: AnimatedColumn(
              staggerDelay: 100.ms,
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 500;
                    if (isNarrow) {
                      return Column(
                        children: [
                          AnimatedEntrance(
                            animationType: AnimationType.scaleFade,
                            delay: 300.ms,
                            child: _buildPieChart(controller),
                          ),
                          const SizedBox(height: 12),
                          AnimatedEntrance(
                            animationType: AnimationType.scaleFade,
                            delay: 400.ms,
                            child: _buildBarChart(controller),
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: AnimatedEntrance(
                            animationType: AnimationType.fadeSlideLeft,
                            delay: 300.ms,
                            child: _buildPieChart(controller),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AnimatedEntrance(
                            animationType: AnimationType.fadeSlideRight,
                            delay: 400.ms,
                            child: _buildBarChart(controller),
                          ),
                        ),
                      ],
                    );
                  },
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.refresh_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  // ── Compact Soft Stat Cards ────────────────────────────────────────────────
  Widget _buildStatCards(int total, int active, int txn) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            'Total Users',
            total.toString(),
            Icons.group_rounded,
            const Color(0xFF2196F3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            'Active Now',
            active.toString(),
            Icons.bolt_rounded,
            const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            'Transactions',
            txn.toString(),
            Icons.receipt_rounded,
            const Color(0xFF673AB7),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            'Growth',
            '+12.5%',
            Icons.show_chart_rounded,
            const Color(0xFFFF9800),
          ),
        ),
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
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
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

  // ── Line Chart: User Registrations (last 7 days) ──────────────────────────
  Widget _buildLineChart(UserController controller) {
    // Compute real data: registrations per day for the last 7 days
    final now = DateTime.now();
    final labels = <String>[];
    final counts = <double>[];
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      final count = controller.users.where((u) {
        return u.createdAt.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
            u.createdAt.isBefore(dayEnd);
      }).length;
      labels.add('${day.day}/${day.month}');
      counts.add(count.toDouble());
    }
    final maxY = counts.isEmpty ? 5.0 : (counts.reduce((a, b) => a > b ? a : b) + 2).ceilToDouble();

    return Container(
      height: 240,
      padding: const EdgeInsets.fromLTRB(10, 16, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 8),
            child: Row(
              children: [
                Icon(Icons.show_chart_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'User Registrations',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '(Last 7 days)',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY / 4).ceilToDouble().clamp(1, double.infinity),
                  getDrawingHorizontalLine: (v) =>
                      FlLine(color: Colors.grey.withOpacity(0.08), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: (maxY / 4).ceilToDouble().clamp(1, double.infinity),
                      getTitlesWidget: (v, m) {
                        if (v == v.roundToDouble()) {
                          return Text(
                            v.toInt().toString(),
                            style: const TextStyle(color: Colors.grey, fontSize: 9),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, m) {
                        final idx = v.toInt();
                        if (idx >= 0 && idx < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              labels[idx],
                              style: const TextStyle(color: Colors.grey, fontSize: 9),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      counts.length,
                      (i) => FlSpot(i.toDouble(), counts[i]),
                    ),
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
                    ),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(radius: 4, color: const Color(0xFF2196F3)),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2196F3).withOpacity(0.15),
                          const Color(0xFF2196F3).withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(UserController controller) {
    // Compute real KYC status breakdown
    final verified = controller.users.where((u) => u.kycStatus.toUpperCase() == 'VERIFIED').length;
    final pending = controller.users.where((u) => u.kycStatus.toUpperCase() == 'PENDING').length;
    final rejected = controller.users.where((u) => u.kycStatus.toUpperCase() == 'REJECTED').length;
    final unverified = controller.users.where((u) =>
        u.kycStatus.toUpperCase() != 'VERIFIED' &&
        u.kycStatus.toUpperCase() != 'PENDING' &&
        u.kycStatus.toUpperCase() != 'REJECTED').length;
    final total = controller.users.length;

    final sections = <PieChartSectionData>[];
    final legendItems = <Map<String, dynamic>>[];

    if (verified > 0) {
      sections.add(PieChartSectionData(
        color: const Color(0xFF4CAF50),
        value: verified.toDouble(),
        radius: 35,
        showTitle: false,
      ));
      legendItems.add({'label': 'Verified', 'count': verified, 'color': const Color(0xFF4CAF50)});
    }
    if (pending > 0) {
      sections.add(PieChartSectionData(
        color: const Color(0xFFFF9800),
        value: pending.toDouble(),
        radius: 35,
        showTitle: false,
      ));
      legendItems.add({'label': 'Pending', 'count': pending, 'color': const Color(0xFFFF9800)});
    }
    if (rejected > 0) {
      sections.add(PieChartSectionData(
        color: const Color(0xFFF44336),
        value: rejected.toDouble(),
        radius: 35,
        showTitle: false,
      ));
      legendItems.add({'label': 'Rejected', 'count': rejected, 'color': const Color(0xFFF44336)});
    }
    if (unverified > 0) {
      sections.add(PieChartSectionData(
        color: Colors.grey.shade300,
        value: unverified.toDouble(),
        radius: 35,
        showTitle: false,
      ));
      legendItems.add({'label': 'Unverified', 'count': unverified, 'color': Colors.grey.shade300});
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'KYC Status Distribution',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: total > 0
                      ? PieChart(
                          PieChartData(
                            sections: sections,
                            centerSpaceRadius: 25,
                            sectionsSpace: 2,
                          ),
                        )
                      : Center(
                          child: Text(
                            'No data',
                            style: TextStyle(fontSize: 12, color: AppColors.grey400),
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: legendItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: item['color'] as Color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${item['label']}',
                                style: TextStyle(fontSize: 11, color: AppColors.grey700),
                              ),
                            ),
                            Text(
                              '${item['count']}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(UserController controller) {
    // Compute real transaction type breakdown
    final allTx = controller.userTransactions.values.expand((txs) => txs).toList();
    final typeCounts = <String, int>{};
    for (final tx in allTx) {
      final type = tx.type.isEmpty ? 'UNKNOWN' : tx.type;
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }

    // Sort by count descending, take top 5
    final sorted = typeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();

    final barColors = [
      const Color(0xFF2196F3),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFFF44336),
    ];

    final maxY = top.isEmpty ? 5.0 : (top.first.value + 2).toDouble();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Transaction Types',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '(${allTx.length} total)',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.grey500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: top.isNotEmpty
                ? BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      barGroups: List.generate(top.length, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: top[i].value.toDouble(),
                              color: barColors[i % barColors.length],
                              width: 20,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        );
                      }),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            getTitlesWidget: (v, m) {
                              if (v == v.roundToDouble()) {
                                return Text(
                                  v.toInt().toString(),
                                  style: const TextStyle(color: Colors.grey, fontSize: 9),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, m) {
                              final idx = v.toInt();
                              if (idx >= 0 && idx < top.length) {
                                final label = top[idx].key;
                                // Shorten long type names
                                final short = label
                                    .replaceAll('SELL_TO_BANK', 'Sell')
                                    .replaceAll('SELL_TO_VAULT', 'Vault')
                                    .replaceAll('BUY_GOLD', 'Buy')
                                    .replaceAll('TRANSFER', 'Transfer')
                                    .replaceAll('_', ' ');
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    short.length > 8 ? short.substring(0, 8) : short,
                                    style: const TextStyle(color: Colors.grey, fontSize: 9),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  )
                : Center(
                    child: Text(
                      'No transactions yet',
                      style: TextStyle(fontSize: 12, color: AppColors.grey400),
                    ),
                  ),
          ),
        ],
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
            TextButton(
              onPressed: () {
                _showAllUsersDialog(controller);
              },
              child: const Text('View All', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.filteredUsers.length.clamp(0, 5),
          staggerDelay: 60.ms,
          itemBuilder: (context, index) {
            final user = controller.filteredUsers[index];
            return _buildUserDetailCard(user, controller, compact: true);
          },
        ),
      ],
    );
  }

  void _showAllUsersDialog(UserController controller) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 960,
          height: 680,
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All Users',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Obx(() => Text(
                        '${controller.filteredUsers.length} users found',
                        style: TextStyle(fontSize: 13, color: AppColors.grey500),
                      )),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: AppColors.grey500),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search by name, email, phone...',
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.grey400),
                  prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppColors.grey500),
                  filled: true,
                  fillColor: AppColors.grey50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grey200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grey200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
                style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                onChanged: (value) => controller.setSearchQuery(value),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(
                  () => controller.filteredUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.people_outline, size: 48, color: AppColors.grey300),
                              const SizedBox(height: 12),
                              Text(
                                'No users found',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.grey500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: controller.filteredUsers.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 6),
                          itemBuilder: (context, index) {
                            final user = controller.filteredUsers[index];
                            return _buildUserDetailCard(user, controller);
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserDetailCard(
    User user,
    UserController controller, {
    bool compact = false,
  }) {
    final userTxs = controller.getUserTransactions(user.id);
    final txGrams = userTxs.fold<double>(0, (sum, tx) => sum + tx.grams);

    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 40% User Info ─────────────────────────────────────
            Expanded(
              flex: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: avatar + name + role
                  Row(
                    children: [
                      _buildUserAvatar(user, radius: compact ? 22 : 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    user.displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                _statusChip(user.isAdmin ? 'Admin' : user.role),
                              ],
                            ),
                            const SizedBox(height: 2),
                            if (user.email != null)
                              Text(
                                user.email!,
                                style: TextStyle(fontSize: 11, color: AppColors.grey500),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Info groups inside a light box
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.grey50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grey100),
                    ),
                    child: Column(
                      children: [
                        // Contact & Security row
                        _infoGroupRow(
                          children: [
                            _infoItem(Icons.phone_outlined, 'Phone', user.phoneNumber ?? '—'),
                            _infoItem(Icons.badge_outlined, 'NID', user.nationalId ?? '—'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _infoGroupRow(
                          children: [
                            _infoItem(Icons.account_balance_outlined, 'Bank', user.bankName ?? '—'),
                            _infoItem(Icons.credit_card_outlined, 'Account', user.accountNumber ?? '—'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _infoGroupRow(
                          children: [
                            _infoItem(Icons.savings_outlined, 'Wallet', Formatters.formatGrams(user.totalGrams ?? 0)),
                            _infoItem(Icons.lock_outline, 'Locked', Formatters.formatGrams(user.lockedGrams ?? 0)),
                            _infoItem(Icons.account_balance_wallet_outlined, 'Available', Formatters.formatGrams(user.availableGrams ?? 0)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _infoGroupRow(
                          children: [
                            _infoItem(Icons.receipt_long_outlined, 'Transactions', '${userTxs.length} • ${Formatters.formatGrams(txGrams)}'),
                            _infoItem(Icons.calendar_today_outlined, 'Created', Formatters.formatDate(user.createdAt)),
                          ],
                        ),
                        // Security flags row
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _securityBadge(Icons.fingerprint, 'Fingerprint', user.hasFingerprint),
                            const SizedBox(width: 6),
                            _securityBadge(Icons.pin_outlined, 'Passcode', user.hasPasscode),
                            const SizedBox(width: 6),
                            _securityBadge(Icons.verified_user_outlined, 'OTP', user.otpVerified),
                            if (user.lastLogin != null) ...[
                              const SizedBox(width: 6),
                              _securityBadge(Icons.login_outlined, 'Last login', null),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (!compact) ...[
                    const SizedBox(height: 8),
                    _idLine('UID', user.id),
                    if (user.backendId != null)
                      _idLine('Backend ID', user.backendId!),
                  ],
                ],
              ),
            ),

            // ── 20% NID Front ─────────────────────────────────────
            Expanded(
              flex: 20,
              child: _buildNidImageColumn(
                label: 'NID Front',
                url: user.nidFrontUrl,
              ),
            ),

            // ── 20% NID Back ──────────────────────────────────────
            Expanded(
              flex: 20,
              child: _buildNidImageColumn(
                label: 'NID Back',
                url: user.nidBackUrl,
              ),
            ),

            // ── 20% KYC Column ────────────────────────────────────
            Expanded(
              flex: 20,
              child: _buildKycColumn(user),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoGroupRow({required List<Widget> children}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: children[i]),
        ],
      ],
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 12, color: AppColors.primary),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 9, color: AppColors.grey500, fontWeight: FontWeight.w500),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _securityBadge(IconData icon, String label, bool? value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: (value == true ? AppColors.success : AppColors.grey100).withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: value == true ? AppColors.success : AppColors.grey500),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: value == true ? AppColors.success : AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _idLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 10,
          color: AppColors.grey600,
          fontFamily: 'monospace',
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildNidImageColumn({required String label, required String? url}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: url != null && url.trim().isNotEmpty && !url.toLowerCase().contains('null')
                ? GestureDetector(
                    onTap: () => _showZoomedImage(context, url, label),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: loadingProgress.expectedTotalBytes == null
                                    ? null
                                    : loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.grey200,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.grey400,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.grey200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          color: AppColors.grey400,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'No image',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.grey400,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showZoomedImage(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black87,
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                  errorBuilder: (_, __, ___) => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKycColumn(User user) {
    final status = user.kycStatus.toUpperCase();
    Color color;
    switch (status) {
      case 'VERIFIED':
        color = AppColors.success;
        break;
      case 'PENDING':
        color = AppColors.statusPending;
        break;
      case 'REJECTED':
        color = AppColors.error;
        break;
      default:
        color = AppColors.grey500;
    }

    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: PopupMenuButton<String>(
        onSelected: (newStatus) => _updateKycStatus(user.id, newStatus),
        offset: const Offset(-20, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_rounded, size: 20, color: color),
            const SizedBox(height: 6),
            Text(
              'KYC',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color.withOpacity(0.7),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 6),
            Icon(Icons.arrow_drop_down, size: 16, color: color),
          ],
        ),
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'PENDING', child: Text('Pending')),
          const PopupMenuItem(value: 'VERIFIED', child: Text('Verified')),
          const PopupMenuItem(value: 'REJECTED', child: Text('Rejected')),
          const PopupMenuItem(value: 'UNVERIFIED', child: Text('Unverified')),
        ],
      ),
    );
  }

  Future<void> _updateKycStatus(String userId, String status) async {
    try {
      final fs = FirebaseFirestore.instance;
      final docRef = fs.collection('users').doc(userId);
      final doc = await docRef.get();

      if (!doc.exists) {
        Get.snackbar('Error', 'User not found in Firestore',
            backgroundColor: AppColors.error, colorText: Colors.white);
        return;
      }

      await docRef.update({
        'kycStatus': status.toLowerCase(),
        'kycVerifiedAt': FieldValue.serverTimestamp(),
      });

      final controller = Get.find<UserController>();
      controller.updateKycStatus(userId, status);

      Get.snackbar(
        'KYC Updated',
        'KYC status updated to $status',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  /// Helper widget to display user avatar with proper image loading
  Widget _buildUserAvatar(User user, {double radius = 24}) {
    return UserAvatarImage(user: user, radius: radius);
  }
}
