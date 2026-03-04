import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/transaction_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/layout/main_layout.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import '../../widgets/common/empty_state_widget.dart';
import '../../models/transaction.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionController>();

    return MainLayout(
      title: 'Transactions',
      child: Obx(() {
        if (controller.isLoading.value) {
          return LoadingWidget(message: 'Loading transactions...');
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return custom_error.ErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.refresh,
          );
        }

        return Column(
          children: [
            // Filters Bar
            _buildFiltersBar(context, controller),
            
            // Transactions List
            Expanded(
              child: controller.filteredTransactions.isEmpty
                  ? EmptyStateWidget(
                      message: 'No transactions found',
                      icon: Icons.receipt_long_outlined,
                    )
                  : _buildTransactionsList(context, controller),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFiltersBar(BuildContext context, TransactionController controller) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.grey200, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              prefixIcon: Icon(Icons.search),
              suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => controller.setSearchQuery(''),
                    )
                  : SizedBox.shrink()),
            ),
            onChanged: controller.setSearchQuery,
          ),
          SizedBox(height: 12),

          // Filter Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Status Filter
              Obx(() => FilterChip(
                label: Text('Status: ${controller.selectedStatus.value.isEmpty ? "All" : controller.selectedStatus.value}'),
                selected: controller.selectedStatus.value.isNotEmpty,
                onSelected: (selected) {
                  _showStatusFilterDialog(context, controller);
                },
              )),

              // Type Filter
              Obx(() => FilterChip(
                label: Text('Type: ${controller.selectedType.value.isEmpty ? "All" : controller.selectedType.value.replaceAll("_", " ")}'),
                selected: controller.selectedType.value.isNotEmpty,
                onSelected: (selected) {
                  _showTypeFilterDialog(context, controller);
                },
              )),

              // Clear Filters
              Obx(() {
                final hasFilters = controller.selectedStatus.value.isNotEmpty ||
                    controller.selectedType.value.isNotEmpty ||
                    controller.startDate.value != null ||
                    controller.endDate.value != null ||
                    controller.searchQuery.value.isNotEmpty;

                return hasFilters
                    ? ActionChip(
                        label: Text('Clear Filters'),
                        avatar: Icon(Icons.clear, size: 16),
                        onPressed: controller.clearFilters,
                      )
                    : SizedBox.shrink();
              }),

              // Refresh Button
              ActionChip(
                label: Text('Refresh'),
                avatar: Icon(Icons.refresh, size: 16),
                onPressed: controller.refresh,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context, TransactionController controller) {
    final isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return ListView.builder(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: controller.filteredTransactions.length,
        itemBuilder: (context, index) {
          return _buildTransactionCard(
            context,
            controller.filteredTransactions[index],
            controller,
          );
        },
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      child: Card(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('User')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Grams')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Fee')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Actions')),
            ],
            rows: controller.filteredTransactions.map((tx) {
              return DataRow(
                cells: [
                  DataCell(
                    Tooltip(
                      message: tx.id,
                      child: Text(tx.id.substring(0, 8) + '...'),
                    ),
                  ),
                  DataCell(Text(tx.userName ?? tx.userEmail ?? 'N/A')),
                  DataCell(_buildTypeChip(tx.type)),
                  DataCell(_buildStatusChip(tx.status)),
                  DataCell(Text(Formatters.formatGrams(tx.grams))),
                  DataCell(Text(Formatters.formatCurrency(tx.amountBdt))),
                  DataCell(Text(Formatters.formatCurrency(tx.feeAmount))),
                  DataCell(Text(Formatters.formatDate(tx.createdAt))),
                  DataCell(_buildActionButtons(context, tx, controller)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
      BuildContext context, Transaction tx, TransactionController controller) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTypeChip(tx.type),
                      SizedBox(height: 8),
                      Text(
                        tx.userName ?? tx.userEmail ?? 'N/A',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'ID: ${tx.id.substring(0, 8)}...',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(tx.status),
              ],
            ),
            Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem('Grams', Formatters.formatGrams(tx.grams)),
                _buildInfoItem('Amount', Formatters.formatCurrency(tx.amountBdt)),
                _buildInfoItem('Fee', Formatters.formatCurrency(tx.feeAmount)),
              ],
            ),
            SizedBox(height: 8),
            Text(
              Formatters.formatDateTime(tx.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey600,
              ),
            ),
            if (tx.status == 'PENDING') ...[
              SizedBox(height: 12),
              _buildActionButtons(context, tx, controller),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.grey600,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
      BuildContext context, Transaction tx, TransactionController controller) {
    if (tx.status != 'PENDING' && tx.status != 'APPROVED') {
      return SizedBox.shrink();
    }

    final buttons = <Widget>[];

    // Mark as Paid (only for APPROVED SELL_TO_BANK)
    if (tx.status == 'APPROVED' && tx.type == 'SELL_TO_BANK') {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _confirmMarkAsPaid(context, tx, controller),
          icon: Icon(Icons.payment, size: 16),
          label: Text('Mark as Paid'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      );
    }

    // Reject (only for PENDING)
    if (tx.status == 'PENDING') {
      buttons.add(
        OutlinedButton.icon(
          onPressed: () => _confirmReject(context, tx, controller),
          icon: Icon(Icons.close, size: 16),
          label: Text('Reject'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: BorderSide(color: AppColors.error),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      );
    }

    if (buttons.isEmpty) return SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: buttons,
    );
  }

  void _confirmMarkAsPaid(
      BuildContext context, Transaction tx, TransactionController controller) {
    Get.defaultDialog(
      title: 'Confirm Payment',
      middleText: 'Mark this transaction as paid?\n\nAmount: ${Formatters.formatCurrency(tx.amountBdt)}',
      textConfirm: 'Confirm',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        controller.markAsPaid(tx.id);
      },
    );
  }

  void _confirmReject(
      BuildContext context, Transaction tx, TransactionController controller) {
    final noteController = TextEditingController();

    Get.defaultDialog(
      title: 'Reject Transaction',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Are you sure you want to reject this transaction?'),
          SizedBox(height: 16),
          TextField(
            controller: noteController,
            decoration: InputDecoration(
              labelText: 'Rejection Note (Optional)',
              hintText: 'Enter reason for rejection',
            ),
            maxLines: 3,
          ),
        ],
      ),
      textConfirm: 'Reject',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        Get.back();
        controller.rejectTransaction(
          tx.id,
          note: noteController.text.trim().isEmpty
              ? null
              : noteController.text.trim(),
        );
      },
    );
  }

  void _showStatusFilterDialog(
      BuildContext context, TransactionController controller) {
    Get.defaultDialog(
      title: 'Filter by Status',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilterOption('All', '', controller),
          _buildFilterOption('Pending', 'pending', controller),
          _buildFilterOption('Approved', 'approved', controller),
          _buildFilterOption('Paid', 'paid', controller),
          _buildFilterOption('Rejected', 'rejected', controller),
        ],
      ),
    );
  }

  void _showTypeFilterDialog(
      BuildContext context, TransactionController controller) {
    Get.defaultDialog(
      title: 'Filter by Type',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilterOption('All', '', controller, isType: true),
          _buildFilterOption('Buy In App', 'BUY_IN_APP', controller, isType: true),
          _buildFilterOption('Buy In Store', 'BUY_IN_STORE', controller, isType: true),
          _buildFilterOption('Sell to Bank', 'SELL_TO_BANK', controller, isType: true),
          _buildFilterOption('Sell to Store', 'SELL_TO_STORE', controller, isType: true),
          _buildFilterOption('Exchange', 'EXCHANGE_TO_JEWELLERY', controller, isType: true),
        ],
      ),
    );
  }

  Widget _buildFilterOption(
      String label, String value, TransactionController controller,
      {bool isType = false}) {
    return Obx(() {
      final isSelected = isType
          ? controller.selectedType.value == value
          : controller.selectedStatus.value == value;

      return ListTile(
        title: Text(label),
        trailing: isSelected ? Icon(Icons.check, color: AppColors.primary) : null,
        onTap: () {
          if (isType) {
            controller.setTypeFilter(value.isEmpty ? null : value);
          } else {
            controller.setStatusFilter(value.isEmpty ? null : value);
          }
          Get.back();
        },
      );
    });
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'PENDING':
        color = AppColors.statusPending;
        break;
      case 'APPROVED':
        color = AppColors.statusApproved;
        break;
      case 'PAID':
        color = AppColors.statusPaid;
        break;
      case 'REJECTED':
        color = AppColors.statusRejected;
        break;
      default:
        color = AppColors.grey600;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    Color color = _getTypeColor(type);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.replaceAll('_', ' '),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    if (type.contains('BUY')) return AppColors.success;
    if (type.contains('SELL')) return AppColors.error;
    if (type.contains('EXCHANGE')) return AppColors.info;
    return AppColors.grey600;
  }
}
