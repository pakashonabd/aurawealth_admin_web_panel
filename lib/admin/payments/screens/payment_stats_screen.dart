import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_payment_controller.dart';

class PaymentStatsScreen extends StatefulWidget {
  @override
  _PaymentStatsScreenState createState() => _PaymentStatsScreenState();
}

class _PaymentStatsScreenState extends State<PaymentStatsScreen> {
  final controller = Get.find<AdminPaymentController>();

  @override
  void initState() {
    super.initState();
    controller.loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Statistics')),
      body: Obx(() {
        if (controller.stats.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = controller.stats.value!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewCard(stats),
              const SizedBox(height: 16),
              _buildBreakdownCard('By Payment Method', stats['breakdown_by_method']),
              const SizedBox(height: 16),
              _buildBreakdownCard('By Transaction Type', stats['breakdown_by_type']),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOverviewCard(Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Total Volume', '${stats['total_volume_bdt'] ?? 0} BDT'),
            _buildStatRow('Total Grams Traded', '${stats['total_grams_traded'] ?? 0}g'),
            _buildStatRow('Success Rate', '${stats['success_rate'] ?? 0}%'),
            _buildStatRow('Pending', '${stats['pending_count'] ?? 0}'),
            _buildStatRow('Failed', '${stats['failed_count'] ?? 0}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(String title, Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...data.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key.toUpperCase()),
                  Text('${e.value} BDT'),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
