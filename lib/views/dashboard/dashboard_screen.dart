import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common/stats_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import '../../models/transaction.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return LoadingWidget(message: 'Loading dashboard...');
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return custom_error.CustomErrorWidget(
          message: controller.errorMessage.value,
          onRetry: controller.refresh,
        );
      }

      return RefreshIndicator(
        onRefresh: () async => controller.refresh(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Grid
              _buildStatsGrid(context, controller),
              SizedBox(height: 24),

              // Pending Transactions
              _buildPendingTransactions(context, controller),
              SizedBox(height: 24),

              // Recent Transactions
              _buildRecentTransactions(context, controller),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatsGrid(BuildContext context, DashboardController controller) {
    final columns = Responsive.getGridColumnCount(context, maxColumns: 4);

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            StatsCard(
              title: 'Total Transactions',
              value: controller.totalTransactions.value.toString(),
              icon: Icons.receipt_long,
              iconColor: AppColors.primary,
            ),
            StatsCard(
              title: 'Pending',
              value: controller.totalPendingTransactions.value.toString(),
              icon: Icons.pending_actions,
              iconColor: AppColors.warning,
            ),
            StatsCard(
              title: 'Total Gold Holdings',
              value: Formatters.formatGrams(controller.totalGoldHoldings.value),
              icon: Icons.diamond,
              iconColor: Color(0xFFFFD700),
            ),
            StatsCard(
              title: 'Total Revenue',
              value: Formatters.formatCurrency(controller.totalRevenue.value),
              icon: Icons.monetization_on,
              iconColor: AppColors.success,
            ),
            StatsCard(
              title: 'Buy Transactions',
              value: controller.totalBuyTransactions.value.toString(),
              icon: Icons.shopping_cart,
              iconColor: AppColors.success,
            ),
            StatsCard(
              title: 'Sell Transactions',
              value: controller.totalSellTransactions.value.toString(),
              icon: Icons.sell,
              iconColor: AppColors.error,
            ),
            StatsCard(
              title: 'Exchange Transactions',
              value: controller.totalExchangeTransactions.value.toString(),
              icon: Icons.swap_horiz,
              iconColor: AppColors.info,
            ),
            StatsCard(
              title: 'Gold Type',
              value: AppConstants.goldType,
              icon: Icons.star,
              iconColor: Color(0xFFFFD700),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPendingTransactions(
      BuildContext context, DashboardController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.pending_actions,
                    color: AppColors.warning,
                    size: 22,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Pending Transactions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${controller.pendingTransactions.length}',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildTransactionsList(controller.pendingTransactions),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(
      BuildContext context, DashboardController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.history,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                TextButton.icon(
                  onPressed: () => Get.toNamed('/transactions'),
                  icon: Icon(Icons.arrow_forward, size: 16),
                  label: Text('View All'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildTransactionsList(controller.recentTransactions),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return Container(
        padding: EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Text(
          'No transactions found',
          style: TextStyle(color: AppColors.grey600),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < AppConstants.mobileBreakpoint;

        if (isMobile) {
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              return _buildTransactionCard(transactions[index]);
            },
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Transaction ID')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Grams')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Date')),
            ],
            rows: transactions.map((tx) {
              return DataRow(
                cells: [
                  DataCell(Text(tx.id.substring(0, 8) + '...')),
                  DataCell(_buildTypeChip(tx.type)),
                  DataCell(_buildStatusChip(tx.status)),
                  DataCell(Text(Formatters.formatGrams(tx.grams))),
                  DataCell(Text(Formatters.formatCurrency(tx.amountBdt))),
                  DataCell(Text(Formatters.formatDate(tx.createdAt))),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildTransactionCard(Transaction tx) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(tx.type).withValues(alpha: 0.1),
          child: Icon(_getTypeIcon(tx.type), color: _getTypeColor(tx.type)),
        ),
        title: Text(Formatters.formatTransactionType(tx.type)),
        subtitle: Text('${Formatters.formatGrams(tx.grams)} • ${Formatters.formatDate(tx.createdAt)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildStatusChip(tx.status),
            SizedBox(height: 4),
            Text(
              Formatters.formatCurrency(tx.amountBdt),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    final statusUpper = status.toUpperCase();

    switch (statusUpper) {
      case 'PENDING':
        color = AppColors.statusPending;
        icon = Icons.pending;
        break;
      case 'APPROVED':
        color = AppColors.statusApproved;
        icon = Icons.check_circle;
        break;
      case 'PAID':
        color = AppColors.statusPaid;
        icon = Icons.payment;
        break;
      case 'REJECTED':
        color = AppColors.statusRejected;
        icon = Icons.cancel;
        break;
      default:
        color = AppColors.grey600;
        icon = Icons.help;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            statusUpper,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    final color = _getTypeColor(type);
    final icon = _getTypeIcon(type);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            type.replaceAll('_', ' '),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    if (type.contains('BUY')) return AppColors.success;
    if (type.contains('SELL')) return AppColors.error;
    if (type.contains('EXCHANGE')) return AppColors.info;
    return AppColors.grey600;
  }

  IconData _getTypeIcon(String type) {
    if (type.contains('BUY')) return Icons.shopping_cart;
    if (type.contains('SELL')) return Icons.sell;
    if (type.contains('EXCHANGE')) return Icons.swap_horiz;
    return Icons.receipt;
  }
}
