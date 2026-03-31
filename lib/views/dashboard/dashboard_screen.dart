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
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.grey200),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.grey200),
                  ),
                  child: Icon(
                    Icons.pending_actions,
                    color: AppColors.warning,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Pending Transactions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.grey200),
                  ),
                  child: Text(
                    '${controller.pendingTransactions.length}',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // "Ghost Border" - 10% opacity border for subtle definition
        border: Border.all(color: const Color(0xFFACB3B7).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3437).withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3437),
                    letterSpacing: -0.5,
                  ),
                ),
                Row(
                  children: [
                    _TransactionIconButton(icon: Icons.filter_list),
                    const SizedBox(width: 8),
                    _TransactionIconButton(
                      icon: Icons.download,
                      onTap: () {
                        // TODO: Implement download functionality
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Data Table
          _buildTransactionsList(controller.recentTransactions),
          
          // Pagination Footer
          if (controller.recentTransactions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing 1-${controller.recentTransactions.length} of ${controller.totalTransactions.value} transactions',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF596064),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Row(
                    children: [
                      _TransactionPageButton(icon: Icons.chevron_left, isEnabled: false),
                      const SizedBox(width: 8),
                      _TransactionPageButton(text: '1', isActive: true),
                      const SizedBox(width: 8),
                      _TransactionPageButton(text: '2'),
                      const SizedBox(width: 8),
                      _TransactionPageButton(text: '3'),
                      const SizedBox(width: 8),
                      _TransactionPageButton(icon: Icons.chevron_right),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: const Text(
          'No transactions found',
          style: TextStyle(color: Color(0xFF596064)),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < AppConstants.mobileBreakpoint;

        if (isMobile) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              return _buildTransactionCard(transactions[index]);
            },
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 48,
            dataRowHeight: 64,
            horizontalMargin: 24,
            columnSpacing: 32,
            // Tonal background for header
            headingRowColor: MaterialStateProperty.all(
              const Color(0xFFF0F4F7).withOpacity(0.3)
            ),
            columns: const [
              DataColumn(label: _TransactionColumnHeader('TRANSACTION ID')),
              DataColumn(label: _TransactionColumnHeader('TYPE')),
              DataColumn(label: _TransactionColumnHeader('STATUS')),
              DataColumn(label: _TransactionColumnHeader('GRAMS')),
              DataColumn(label: _TransactionColumnHeader('AMOUNT')),
              DataColumn(label: _TransactionColumnHeader('DATE')),
            ],
            rows: transactions.map((tx) => _buildDataRow(tx)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildTransactionCard(Transaction tx) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
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
            const SizedBox(height: 4),
            Text(
              Formatters.formatCurrency(tx.amountBdt),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(Transaction tx) {
    final String displayId = tx.id.length > 10 
        ? '#${tx.id.substring(0, 9)}...' 
        : '#${tx.id}';
    
    return DataRow(
      cells: [
        DataCell(Text(
          displayId,
          style: const TextStyle(
            color: Color(0xFF3856C4),
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
            fontSize: 13,
          ),
        )),
        DataCell(Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _getTypeColor(tx.type).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getTypeIcon(tx.type), 
                size: 16, 
                color: _getTypeColor(tx.type),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              Formatters.formatTransactionType(tx.type),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2C3437),
              ),
            ),
          ],
        )),
        DataCell(_buildStatusChip(tx.status)),
        DataCell(Align(
          alignment: Alignment.centerRight,
          child: Text(
            Formatters.formatGrams(tx.grams),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3437),
            ),
          ),
        )),
        DataCell(Align(
          alignment: Alignment.centerRight,
          child: Text(
            Formatters.formatCurrency(tx.amountBdt),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2C3437),
            ),
          ),
        )),
        DataCell(Align(
          alignment: Alignment.centerRight,
          child: Text(
            Formatters.formatDate(tx.createdAt),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF596064),
              letterSpacing: 0.5,
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;
    final statusUpper = status.toUpperCase();

    switch (statusUpper) {
      case 'APPROVED':
        bgColor = const Color(0xFF91FEEF);
        textColor = const Color(0xFF006D64);
        break;
      case 'PENDING':
        bgColor = const Color(0xFFD3E4FE);
        textColor = const Color(0xFF314055);
        break;
      case 'REJECTED':
        bgColor = const Color(0xFFFA746F).withOpacity(0.2);
        textColor = const Color(0xFFA83836);
        break;
      case 'PAID':
        bgColor = const Color(0xFF91FEEF);
        textColor = const Color(0xFF006D64);
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusUpper,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    if (type.contains('BUY')) return const Color(0xFF3856C4);
    if (type.contains('SELL')) return const Color(0xFF506076);
    if (type.contains('EXCHANGE')) return const Color(0xFFA83836);
    return const Color(0xFF506076);
  }

  IconData _getTypeIcon(String type) {
    if (type.contains('BUY')) return Icons.shopping_cart;
    if (type.contains('SELL')) return Icons.payments;
    if (type.contains('EXCHANGE')) return Icons.error_outline;
    return Icons.receipt;
  }
}

// Helper Widgets for Transaction Table

class _TransactionColumnHeader extends StatelessWidget {
  final String title;
  const _TransactionColumnHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Color(0xFF596064),
        letterSpacing: 2.0,
      ),
    );
  }
}

class _TransactionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _TransactionIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: const Color(0xFF596064)),
      ),
    );
  }
}

class _TransactionPageButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final bool isActive;
  final bool isEnabled;

  const _TransactionPageButton({
    this.text,
    this.icon,
    this.isActive = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFACB3B7).withOpacity(0.1)),
        boxShadow: isActive ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ] : null,
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, size: 16, color: isEnabled ? const Color(0xFF596064) : const Color(0xFFACB3B7))
            : Text(
                text!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.black : FontWeight.bold,
                  color: isActive ? const Color(0xFF3856C4) : const Color(0xFF2C3437),
                ),
              ),
      ),
    );
  }
}
