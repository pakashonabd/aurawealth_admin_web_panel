import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminPaymentService {
  final String baseUrl;
  final String Function() tokenProvider;

  AdminPaymentService({required this.baseUrl, required this.tokenProvider});

  Map<String, String> get _headers => {
    'Authorization': 'Bearer ${tokenProvider()}',
    'Content-Type': 'application/json',
  };

  Future<Map<String, dynamic>> listPayments({
    String? status,
    String? type,
    String? method,
    String? dateFrom,
    String? dateTo,
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (status != null) params['status'] = status;
    if (type != null) params['type'] = type;
    if (method != null) params['payment_method'] = method;
    if (dateFrom != null) params['date_from'] = dateFrom;
    if (dateTo != null) params['date_to'] = dateTo;
    if (search != null) params['search'] = search;

    final uri = Uri.parse('$baseUrl/admin/payments').replace(queryParameters: params);
    final r = await http.get(uri, headers: _headers);
    return jsonDecode(r.body);
  }

  Future<Map<String, dynamic>> getPaymentDetail(String txId) async {
    final r = await http.get(
      Uri.parse('$baseUrl/admin/payments/$txId'),
      headers: _headers,
    );
    return jsonDecode(r.body);
  }

  Future<Map<String, dynamic>> getStats({String? dateFrom, String? dateTo}) async {
    final params = <String, String>{};
    if (dateFrom != null) params['date_from'] = dateFrom;
    if (dateTo != null) params['date_to'] = dateTo;

    final uri = Uri.parse('$baseUrl/admin/payments/stats').replace(queryParameters: params);
    final r = await http.get(uri, headers: _headers);
    return jsonDecode(r.body);
  }

  Future<void> markAsPaid(String txId) async {
    await http.post(
      Uri.parse('$baseUrl/admin/payments/$txId/mark-as-paid'),
      headers: _headers,
    );
  }

  Future<void> reject(String txId, String reason) async {
    await http.post(
      Uri.parse('$baseUrl/admin/payments/$txId/reject?reason=${Uri.encodeComponent(reason)}'),
      headers: _headers,
    );
  }

  Future<void> requestRefund(String txId, String reason) async {
    await http.post(
      Uri.parse('$baseUrl/admin/payments/$txId/refund'),
      headers: _headers,
      body: jsonEncode({'reason': reason}),
    );
  }

  Future<List<int>> exportCsv({
    String? status,
    String? type,
    String? method,
    String? dateFrom,
    String? dateTo,
  }) async {
    final params = <String, String>{};
    if (status != null) params['status'] = status;
    if (type != null) params['type'] = type;
    if (method != null) params['payment_method'] = method;
    if (dateFrom != null) params['date_from'] = dateFrom;
    if (dateTo != null) params['date_to'] = dateTo;

    final uri = Uri.parse('$baseUrl/admin/payments/export').replace(queryParameters: params);
    final r = await http.get(uri, headers: _headers);
    return r.bodyBytes;
  }

  Future<Map<String, dynamic>> listWebhookLogs({
    String? provider,
    bool? processed,
    int page = 1,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
    };
    if (provider != null) params['provider'] = provider;
    if (processed != null) params['processed'] = processed.toString();

    final uri = Uri.parse('$baseUrl/admin/payments/webhook-logs/list').replace(queryParameters: params);
    final r = await http.get(uri, headers: _headers);
    return jsonDecode(r.body);
  }
}
