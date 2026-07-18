import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/user_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/utils/formatters.dart';
import '../../services/api_service.dart';
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
                            child: _buildPieChart(activeUsers, totalUsers),
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
                            child: _buildPieChart(activeUsers, totalUsers),
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

  // ── Line Chart (Enhanced with more values) ────────────────────────────────
  Widget _buildLineChart(UserController controller) {
    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (v) =>
                FlLine(color: Colors.grey.withOpacity(0.05), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, m) {
                  const days = [
                    '1 Mar',
                    '2 Mar',
                    '3 Mar',
                    '4 Mar',
                    '5 Mar',
                    '6 Mar',
                    '7 Mar',
                  ];
                  return Text(
                    days[v.toInt() % 7],
                    style: const TextStyle(color: Colors.grey, fontSize: 9),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 2),
                FlSpot(1, 1.5),
                FlSpot(2, 4),
                FlSpot(3, 3),
                FlSpot(4, 5),
                FlSpot(5, 4),
                FlSpot(6, 6),
              ],
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
              ),
              barWidth: 3,
              dotData: FlDotData(show: true),
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
    );
  }

  Widget _buildPieChart(int active, int total) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: const Color(0xFF4CAF50),
              value: active.toDouble(),
              radius: 35,
              showTitle: false,
            ),
            PieChartSectionData(
              color: Colors.grey.shade100,
              value: (total - active).toDouble(),
              radius: 30,
              showTitle: false,
            ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 10,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: 7,
                  color: const Color(0xFF4CAF50),
                  width: 10,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: 4,
                  color: Colors.orange,
                  width: 10,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: 2,
                  color: Colors.red,
                  width: 10,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
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
          width: 600,
          height: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Users',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => controller.setSearchQuery(value),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(
                  () => ListView.separated(
                    itemCount: controller.filteredUsers.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserAvatar(user, radius: compact ? 24 : 30),
          const SizedBox(width: 14),
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
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _detailChip(Icons.email_outlined, user.email ?? 'No email'),
                    _detailChip(
                      Icons.phone_outlined,
                      user.phoneNumber ?? 'No phone',
                    ),
                    _detailChip(
                      Icons.fingerprint,
                      'Fingerprint: ${_yesNo(user.hasFingerprint)}',
                    ),
                    _detailChip(
                      Icons.pin_outlined,
                      'Passcode: ${_yesNo(user.hasPasscode)}',
                    ),
                    _detailChip(
                      Icons.verified_user_outlined,
                      'OTP: ${_yesNo(user.otpVerified)}',
                    ),
                    _buildKycStatusChip(user),
                    _detailChip(
                      Icons.account_balance_outlined,
                      user.bankName ?? 'No bank',
                    ),
                    _detailChip(
                      Icons.credit_card_outlined,
                      user.accountNumber ?? 'No account',
                    ),
                    _detailChip(
                      Icons.badge_outlined,
                      user.nationalId ?? 'No NID',
                    ),
                    _detailChip(
                      Icons.savings_outlined,
                      'Wallet: ${Formatters.formatGrams(user.totalGrams ?? 0)}',
                    ),
                    _detailChip(
                      Icons.lock_outline,
                      'Locked: ${Formatters.formatGrams(user.lockedGrams ?? 0)}',
                    ),
                    _detailChip(
                      Icons.account_balance_wallet_outlined,
                      'Available: ${Formatters.formatGrams(user.availableGrams ?? 0)}',
                    ),
                    _detailChip(
                      Icons.receipt_long_outlined,
                      '${userTxs.length} txs • ${Formatters.formatGrams(txGrams)}',
                    ),
                    _detailChip(
                      Icons.calendar_today_outlined,
                      'Created: ${Formatters.formatDate(user.createdAt)}',
                    ),
                    if (user.lastLogin != null)
                      _detailChip(
                        Icons.login_outlined,
                        'Last login: ${Formatters.formatDateTime(user.lastLogin!)}',
                      ),
                  ],
                ),
                if (!compact) ...[
                  const SizedBox(height: 8),
                  _idLine('UID', user.id),
                  if (user.backendId != null)
                    _idLine('Backend ID', user.backendId!),
                  if (user.nidFrontUrl != null)
                    _idLine('NID Front', user.nidFrontUrl!),
                  if (user.nidBackUrl != null)
                    _idLine('NID Back', user.nidBackUrl!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.grey600),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, color: AppColors.grey700)),
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

  String _yesNo(bool? value) =>
      value == null ? 'Unknown' : (value ? 'Yes' : 'No');

  Widget _buildKycStatusChip(User user) {
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

    return PopupMenuButton<String>(
      onSelected: (newStatus) => _updateKycStatus(user.id, newStatus),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_user_outlined, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              'KYC: $status',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, size: 14, color: color),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'PENDING', child: Text('Pending')),
        const PopupMenuItem(value: 'VERIFIED', child: Text('Verified')),
        const PopupMenuItem(value: 'REJECTED', child: Text('Rejected')),
        const PopupMenuItem(value: 'UNVERIFIED', child: Text('Unverified')),
      ],
    );
  }

  Future<void> _updateKycStatus(String userId, String status) async {
    try {
      final api = ApiService();
      await api.updateKycStatus(userId, status);
      Get.snackbar(
        'KYC Updated',
        'KYC status updated to $status',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
      // Refresh user data
      final controller = Get.find<UserController>();
      controller.refresh();
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
