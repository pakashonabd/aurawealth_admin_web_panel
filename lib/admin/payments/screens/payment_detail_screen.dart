import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/admin_payment_service.dart';
import '../widgets/payment_status_badge.dart';
import '../widgets/gateway_json_viewer.dart';
import '../widgets/audit_log_timeline.dart';
import '../widgets/confirm_action_dialog.dart';

class PaymentDetailScreen extends StatefulWidget {
  final String txId;
  const PaymentDetailScreen({super.key, required this.txId});

  @override
  _PaymentDetailScreenState createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  final AdminPaymentService _service = Get.find<AdminPaymentService>();
  Map<String, dynamic>? detail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      detail = await _service.getPaymentDetail(widget.txId);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment Detail')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (detail == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment Detail')),
        body: const Center(child: Text('Transaction not found')),
      );
    }

    final status = detail!['status'] ?? '';
    final type = detail!['type'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment ${(detail!['id'] ?? '').toString().substring(0, 8)}...'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 16),
            _buildActionButtons(status, type),
            const SizedBox(height: 16),
            _buildGatewayResponse(),
            const SizedBox(height: 16),
            _buildAuditLog(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Status: '),
                PaymentStatusBadge(detail!['status'] ?? ''),
              ],
            ),
            const Divider(),
            _buildDetailRow('Transaction ID', detail!['id']),
            _buildDetailRow('User', detail!['user_email'] ?? detail!['user_name']),
            _buildDetailRow('Type', detail!['type']),
            _buildDetailRow('Grams', '${detail!['grams']}g'),
            _buildDetailRow('Amount', '${detail!['amount_bdt']} BDT'),
            _buildDetailRow('Price/g', '${detail!['price_per_g_bdt']} BDT'),
            _buildDetailRow('Payment Method', detail!['payment_method'] ?? 'N/A'),
            _buildDetailRow('Gateway Txn ID', detail!['gateway_txn_id']),
            _buildDetailRow('Gateway Session', detail!['gateway_session_id']),
            _buildDetailRow('Created At', detail!['created_at']),
            _buildDetailRow('Paid At', detail!['paid_at']),
            if (detail!['admin_note'] != null)
              _buildDetailRow('Admin Note', detail!['admin_note']),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value?.toString() ?? 'N/A'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String status, String type) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (status == 'pending' && type == 'sell_to_bank') ...[
                  ElevatedButton.icon(
                    onPressed: () => _showApproveDialog(),
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showRejectDialog(),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
                if (status == 'paid')
                  ElevatedButton.icon(
                    onPressed: () => _showRefundDialog(),
                    icon: const Icon(Icons.money_off),
                    label: const Text('Refund'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGatewayResponse() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gateway Response',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GatewayJsonViewer(data: detail!['gateway_response']),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditLog() {
    final auditLogs = List<Map<String, dynamic>>.from(detail!['audit_log'] ?? []);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit Log',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            AuditLogTimeline(logs: auditLogs),
          ],
        ),
      ),
    );
  }

  void _showApproveDialog() {
    showDialog(
      context: context,
      builder: (context) => ConfirmActionDialog(
        title: 'Approve Transaction',
        message: 'Mark this transaction as paid?',
        confirmText: 'Approve',
        confirmColor: Colors.green,
        onConfirm: (reason) async {
          await _service.markAsPaid(widget.txId);
          Navigator.pop(context);
          _loadDetail();
        },
      ),
    );
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (context) => ConfirmActionDialog(
        title: 'Reject Transaction',
        message: 'Reject this transaction?',
        confirmText: 'Reject',
        confirmColor: Colors.red,
        onConfirm: (reason) async {
          await _service.reject(widget.txId, reason);
          Navigator.pop(context);
          _loadDetail();
        },
      ),
    );
  }

  void _showRefundDialog() {
    showDialog(
      context: context,
      builder: (context) => ConfirmActionDialog(
        title: 'Request Refund',
        message: 'Initiate a refund for this transaction?',
        confirmText: 'Refund',
        confirmColor: Colors.orange,
        onConfirm: (reason) async {
          await _service.requestRefund(widget.txId, reason);
          Navigator.pop(context);
          _loadDetail();
        },
      ),
    );
  }
}
