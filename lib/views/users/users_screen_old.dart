import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import '../../widgets/common/empty_state_widget.dart';
import '../../models/user.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());

    return Obx(() {
      if (controller.isLoading.value) {
        return LoadingWidget(message: 'Loading users...');
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return custom_error.CustomErrorWidget(
          message: controller.errorMessage.value,
          onRetry: controller.refresh,
        );
      }

      if (controller.filteredUsers.isEmpty) {
        return Center(
          child: EmptyStateWidget(
            message: 'No users found',
            icon: Icons.people_outline,
          ),
        );
      }

      return Column(
        children: [
          // Header with stats and search
          _buildDashboardHeader(controller),

          // Users grid - 2 cards per row
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: (controller.filteredUsers.length / 2).ceil(),
              itemBuilder: (context, rowIndex) {
                final startIdx = rowIndex * 2;
                final endIdx = (rowIndex * 2) + 1;
                final user1 = controller.filteredUsers[startIdx];
                final user2 = endIdx < controller.filteredUsers.length
                    ? controller.filteredUsers[endIdx]
                    : null;

                return Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildUserDashboardCard(context, user1, controller),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: user2 != null
                            ? _buildUserDashboardCard(context, user2, controller)
                            : SizedBox.shrink(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildDashboardHeader(UserController controller) {
    final totalUsers = controller.users.length;
    final activeUsers = controller.users.where((u) {
      return controller.getUserTransactions(u.id).isNotEmpty;
    }).length;

    final totalTransactions = controller.users.fold<int>(0, (sum, u) {
      return sum + controller.getUserTransactions(u.id).length;
    });

    return Container(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.grey200, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and quick stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Users Dashboard',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Monitor and manage all users',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // Quick stats
              Row(
                children: [
                  _buildQuickStat('Total', totalUsers.toString(), AppColors.primary),
                  SizedBox(width: 16),
                  _buildQuickStat('Active', activeUsers.toString(), AppColors.success),
                  SizedBox(width: 16),
                  _buildQuickStat('Txns', totalTransactions.toString(), AppColors.info),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by email, phone, or ID...',
              prefixIcon: Icon(Icons.search, color: AppColors.primary),
              suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                  ? GestureDetector(
                      onTap: () => controller.setSearchQuery(''),
                      child: Icon(Icons.clear_rounded, color: AppColors.grey600),
                    )
                  : SizedBox.shrink()),
              isDense: false,
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.grey200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.grey200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            onChanged: controller.setSearchQuery,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.grey600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildUserDashboardCard(BuildContext context, User user, UserController controller) {
    final transactions = controller.getUserTransactions(user.id);

    final totalGrams = transactions.fold<double>(
      0.0,
      (sum, tx) {
        if (tx.type.contains('BUY') && tx.status != 'REJECTED') {
          return sum + tx.grams;
        } else if ((tx.type.contains('SELL') || tx.type.contains('EXCHANGE'))
            && tx.status != 'REJECTED' && tx.status != 'PENDING') {
          return sum - tx.grams;
        }
        return sum;
      },
    );

    final approvedTxs = transactions.where((t) => t.status.toUpperCase() == 'APPROVED').length;
    final pendingTxs = transactions.where((t) => t.status.toUpperCase() == 'PENDING').length;
    final rejectedTxs = transactions.where((t) => t.status.toUpperCase() == 'REJECTED').length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar + Name + Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary.withValues(alpha: 0.8), AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (user.email ?? user.id).substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.email ?? 'User ${user.id.substring(0, 8)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'ID: ${user.id.substring(0, 12)}...',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.grey500,
                          fontFamily: 'Courier',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (pendingTxs > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.statusPending.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$pendingTxs pending',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.statusPending,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12),
            Divider(color: AppColors.grey100, height: 1),
            SizedBox(height: 12),

            // Contact Info
            _buildInfoRow('Phone', user.phoneNumber ?? 'Not provided'),
            _buildInfoRow('Member Since', Formatters.formatDate(user.createdAt)),
            SizedBox(height: 12),
            Divider(color: AppColors.grey100, height: 1),
            SizedBox(height: 12),

            // Gold Holdings Section
            Text(
              'Gold Holdings',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatBox('Total Gold', Formatters.formatGrams(totalGrams), AppColors.warning),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildStatBox('Transactions', transactions.length.toString(), AppColors.info),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Transaction Status
            Text(
              'Transactions Status',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatusBox('Approved', approvedTxs.toString(), AppColors.success),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: _buildStatusBox('Pending', pendingTxs.toString(), AppColors.statusPending),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: _buildStatusBox('Rejected', rejectedTxs.toString(), AppColors.statusRejected),
                ),
              ],
            ),

            if (transactions.isNotEmpty) ...[
              SizedBox(height: 12),
              Divider(color: AppColors.grey100, height: 1),
              SizedBox(height: 12),
              Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              ...List.generate(
                transactions.length > 3 ? 3 : transactions.length,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: _buildTransactionRow(transactions[index]),
                ),
              ),
              if (transactions.length > 3)
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    '+${transactions.length - 3} more transactions',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.grey600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: AppColors.grey600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBox(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              color: AppColors.grey600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(dynamic tx) {
    Color statusColor;
    IconData statusIcon;

    switch (tx.status.toUpperCase()) {
      case 'PENDING':
        statusColor = AppColors.statusPending;
        statusIcon = Icons.schedule;
        break;
      case 'APPROVED':
        statusColor = AppColors.statusApproved;
        statusIcon = Icons.check_circle;
        break;
      case 'PAID':
        statusColor = AppColors.statusPaid;
        statusIcon = Icons.done_all;
        break;
      case 'REJECTED':
        statusColor = AppColors.statusRejected;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppColors.grey600;
        statusIcon = Icons.help;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 12),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Formatters.formatTransactionType(tx.type),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  '${Formatters.formatGrams(tx.grams)} • ${Formatters.formatCurrency(tx.amountBdt)}',
                  style: TextStyle(
                    fontSize: 8,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              tx.status.toUpperCase().substring(0, 3),
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



