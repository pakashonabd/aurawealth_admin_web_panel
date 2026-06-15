import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/admin_payment_service.dart';
import '../widgets/gateway_json_viewer.dart';

class WebhookLogsScreen extends StatefulWidget {
  @override
  _WebhookLogsScreenState createState() => _WebhookLogsScreenState();
}

class _WebhookLogsScreenState extends State<WebhookLogsScreen> {
  final AdminPaymentService _service = Get.find<AdminPaymentService>();
  List<Map<String, dynamic>> logs = [];
  int currentPage = 1;
  int totalCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => isLoading = true);
    try {
      final result = await _service.listWebhookLogs(page: currentPage);
      logs = List<Map<String, dynamic>>.from(result['items'] ?? []);
      totalCount = result['total'] ?? 0;
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Webhook Logs')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : logs.isEmpty
              ? const Center(child: Text('No webhook logs'))
              : ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ExpansionTile(
                        title: Row(
                          children: [
                            Icon(
                              log['signature_valid'] == true
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: log['signature_valid'] == true
                                  ? Colors.green
                                  : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(log['event_type'] ?? 'Unknown'),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          log['created_at'] ?? '',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Provider: ${log['provider']}'),
                                Text('Processed: ${log['processed']}'),
                                if (log['error_message'] != null)
                                  Text('Error: ${log['error_message']}'),
                                const SizedBox(height: 8),
                                const Text('Payload:'),
                                GatewayJsonViewer(data: log['payload']),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
