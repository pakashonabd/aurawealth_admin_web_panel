import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_payment_controller.dart';
import '../widgets/payment_status_badge.dart';
import 'payment_detail_screen.dart';

class PaymentsListScreen extends StatefulWidget {
  @override
  _PaymentsListScreenState createState() => _PaymentsListScreenState();
}

class _PaymentsListScreenState extends State<PaymentsListScreen> {
  final controller = Get.find<AdminPaymentController>();
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.loadPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: controller.exportCsv,
            tooltip: 'Export CSV',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildPaymentsList()),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by ID, email, name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (value) {
                controller.searchQuery.value = value;
                controller.loadPayments();
              },
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            hint: const Text('Status'),
            value: controller.selectedStatus.value,
            items: const [
              DropdownMenuItem(value: null, child: Text('All')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'paid', child: Text('Paid')),
              DropdownMenuItem(value: 'failed', child: Text('Failed')),
              DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
            ],
            onChanged: (value) {
              controller.selectedStatus.value = value;
              controller.loadPayments();
            },
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            hint: const Text('Type'),
            value: controller.selectedType.value,
            items: const [
              DropdownMenuItem(value: null, child: Text('All')),
              DropdownMenuItem(value: 'buy_in_app', child: Text('Buy')),
              DropdownMenuItem(value: 'sell_to_bank', child: Text('Sell')),
            ],
            onChanged: (value) {
              controller.selectedType.value = value;
              controller.loadPayments();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.payments.isEmpty) {
        return const Center(child: Text('No payments found'));
      }

      return ListView.builder(
        itemCount: controller.payments.length,
        itemBuilder: (context, index) {
          final payment = controller.payments[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      'ID: ${(payment['id'] ?? '').toString().substring(0, 8)}...',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                  PaymentStatusBadge(payment['status'] ?? 'UNKNOWN'),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('User: ${payment['user_email'] ?? 'Unknown'}'),
                  Text('${payment['grams'] ?? 0}g - ${payment['amount_bdt'] ?? 0} BDT'),
                  Text('${payment['type'] ?? ''} • ${payment['payment_method'] ?? 'N/A'}'),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Get.to(() => PaymentDetailScreen(txId: payment['id']));
              },
            ),
          );
        },
      );
    });
  }

  Widget _buildPagination() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total: ${controller.totalCount.value}'),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: controller.currentPage.value > 1
                    ? controller.prevPage
                    : null,
              ),
              Text('Page ${controller.currentPage.value}'),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: controller.currentPage.value * 20 < controller.totalCount.value
                    ? controller.nextPage
                    : null,
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
