import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
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

      return Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                bottom: BorderSide(color: AppColors.grey200, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search users...',
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
                ),
                SizedBox(width: 12),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: controller.refresh,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),

          // Users List
          Expanded(
            child: controller.filteredUsers.isEmpty
                ? EmptyStateWidget(
                    message: 'No users found',
                    icon: Icons.people_outline,
                  )
                : _buildUsersList(context, controller),
          ),
        ],
      );
    });
  }

  Widget _buildUsersList(BuildContext context, UserController controller) {
    final isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return ListView.builder(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: controller.filteredUsers.length,
        itemBuilder: (context, index) {
          return _buildUserCard(
            context,
            controller.filteredUsers[index],
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
              DataColumn(label: Text('User ID')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Total Transactions')),
              DataColumn(label: Text('Total Grams')),
              DataColumn(label: Text('Joined')),
              DataColumn(label: Text('Actions')),
            ],
            rows: controller.filteredUsers.map((user) {
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

              return DataRow(
                cells: [
                  DataCell(
                    Tooltip(
                      message: user.id,
                      child: Text(user.id.substring(0, 8) + '...'),
                    ),
                  ),
                  DataCell(Text(user.email ?? 'N/A')),
                  DataCell(Text(transactions.length.toString())),
                  DataCell(Text(Formatters.formatGrams(totalGrams))),
                  DataCell(Text(Formatters.formatDate(user.createdAt))),
                  DataCell(
                    TextButton(
                      onPressed: () => _showUserDetails(context, user, controller),
                      child: Text('View Details'),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, User user, UserController controller) {
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

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(user.email ?? 'User ${user.id.substring(0, 8)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text('ID: ${user.id.substring(0, 8)}...'),
            Text('${transactions.length} transactions • ${Formatters.formatGrams(totalGrams)}'),
            Text('Joined: ${Formatters.formatDate(user.createdAt)}'),
          ],
        ),
        isThreeLine: true,
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showUserDetails(context, user, controller),
      ),
    );
  }

  void _showUserDetails(BuildContext context, User user, UserController controller) {
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

    Get.dialog(
      Dialog(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(AppConstants.defaultPadding),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(color: AppColors.grey200),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      radius: 24,
                      child: Icon(Icons.person, color: Colors.white, size: 28),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.email ?? 'User Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'ID: ${user.id}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),

              // User Info
              Padding(
                padding: EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Email', user.email ?? 'N/A'),
                    _buildInfoRow('Phone', user.phoneNumber ?? 'N/A'),
                    _buildInfoRow('Joined', Formatters.formatDate(user.createdAt)),
                    _buildInfoRow('Total Gold', Formatters.formatGrams(totalGrams)),
                    _buildInfoRow('Total Transactions', transactions.length.toString()),
                  ],
                ),
              ),

              Divider(),

              // Transactions List
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
                child: Row(
                  children: [
                    Text(
                      'Transaction History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: transactions.isEmpty
                    ? Center(
                        child: Text(
                          'No transactions',
                          style: TextStyle(color: AppColors.grey600),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(AppConstants.defaultPadding),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          return ListTile(
                            leading: _buildStatusIcon(tx.status),
                            title: Text(Formatters.formatTransactionType(tx.type)),
                            subtitle: Text(
                              '${Formatters.formatGrams(tx.grams)} • ${Formatters.formatCurrency(tx.amountBdt)}',
                            ),
                            trailing: Text(
                              Formatters.formatDate(tx.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grey600,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.grey600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    Color color;
    IconData icon;

    switch (status.toUpperCase()) {
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

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
