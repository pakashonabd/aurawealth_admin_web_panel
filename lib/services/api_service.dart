import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../core/constants/api_endpoints.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final StorageService _storage = StorageService();

  Map<String, String> _getHeaders({bool isFormData = false}) {
    final headers = <String, String>{};
    
    if (isFormData) {
      headers['Content-Type'] = 'application/x-www-form-urlencoded';
    } else {
      headers['Content-Type'] = 'application/json';
    }
    
    final token = _storage.getAuthToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      return json.decode(response.body);
    } else {
      String errorMessage = 'An error occurred';
      try {
        final errorBody = json.decode(response.body);
        errorMessage = errorBody['detail'] ?? errorBody['message'] ?? errorMessage;
      } catch (e) {
        errorMessage = response.body.isNotEmpty ? response.body : 'HTTP ${response.statusCode}';
      }
      throw Exception(errorMessage);
    }
  }

  // Admin Login
  Future<Map<String, dynamic>> adminLogin(String email, String password) async {
    final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.adminLogin}');
    final body = 'username=$email&password=$password';
    
    final response = await http.post(
      url,
      headers: _getHeaders(isFormData: true),
      body: body,
    ).timeout(Duration(seconds: AppConstants.apiTimeout));

    return _handleResponse(response);
  }

  // Get Admin Dashboard
  Future<List<dynamic>> getAdminDashboard({String? status}) async {
    var url = '${AppConstants.baseUrl}${ApiEndpoints.adminDashboard}';
    if (status != null && status.isNotEmpty) {
      url += '?status=$status';
    }
    
    final response = await http.get(
      Uri.parse(url),
      headers: _getHeaders(),
    ).timeout(Duration(seconds: AppConstants.apiTimeout));

    return await _handleResponse(response) as List<dynamic>;
  }

  // Set Gold Price
  Future<Map<String, dynamic>> setGoldPrice(double price) async {
    final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.setPrice}');
    final body = json.encode({'price': price});
    
    final response = await http.post(
      url,
      headers: _getHeaders(),
      body: body,
    ).timeout(Duration(seconds: AppConstants.apiTimeout));

    return _handleResponse(response);
  }

  // Get Current Gold Price
  Future<Map<String, dynamic>> getGoldPrice() async {
    final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.getPrice}');
    
    final response = await http.get(
      url,
      headers: _getHeaders(),
    ).timeout(Duration(seconds: AppConstants.apiTimeout));

    return _handleResponse(response);
  }

  // Credit Grams (In-Store Purchase)
  Future<Map<String, dynamic>> creditGrams(String userId, double grams) async {
    final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.adminBuyCredit}');
    final body = json.encode({
      'user_id': userId,
      'grams': grams,
    });
    
    final response = await http.post(
      url,
      headers: _getHeaders(),
      body: body,
    ).timeout(Duration(seconds: AppConstants.apiTimeout));

    return _handleResponse(response);
  }

  // Redeem Code
  Future<Map<String, dynamic>> redeemCode(String code) async {
    final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.adminRedeemCode(code)}');
    
    final response = await http.post(
      url,
      headers: _getHeaders(),
    ).timeout(Duration(seconds: AppConstants.apiTimeout));

    return _handleResponse(response);
  }

  // Approve Transaction
  Future<Map<String, dynamic>> approveTransaction(String txId, {String? note}) async {
    final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.adminApprove(txId)}');
    final body = note != null ? json.encode({'note': note}) : json.encode({});

    final response = await http.post(
      url,
      headers: _getHeaders(),
      body: body,
    ).timeout(Duration(seconds: AppConstants.apiTimeout));

    return _handleResponse(response);
  }

  // Reject Transaction
  Future<Map<String, dynamic>> rejectTransaction(String txId, {String? note}) async {
    final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.adminReject(txId)}');
    final body = note != null ? json.encode({'note': note}) : json.encode({});

    final response = await http.post(
      url,
      headers: _getHeaders(),
      body: body,
    ).timeout(Duration(seconds: AppConstants.apiTimeout));

    return _handleResponse(response);
  }

  // Update Paid Status (mark as paid or unpaid)
  Future<Map<String, dynamic>> updatePaidStatus(String txId, bool isPaid) async {
    final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.adminPaidStatus(txId)}');
    final body = json.encode({'is_paid': isPaid});

    final response = await http.put(
      url,
      headers: _getHeaders(),
      body: body,
    ).timeout(Duration(seconds: AppConstants.apiTimeout));

    return _handleResponse(response);
  }

  // Get Message Threads
  Future<List<dynamic>> getMessageThreads() async {
    final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.adminMessages}');
    
    final response = await http.get(
      url,
      headers: _getHeaders(),
    ).timeout(Duration(seconds: AppConstants.apiTimeout));

    return await _handleResponse(response) as List<dynamic>;
  }

  // Get User Messages
  Future<List<dynamic>> getUserMessages(String userId, {int? limit, int? offset}) async {
    var url = '${AppConstants.baseUrl}${ApiEndpoints.adminUserMessages(userId)}';
    final params = <String>[];
    if (limit != null) params.add('limit=$limit');
    if (offset != null) params.add('offset=$offset');
    if (params.isNotEmpty) url += '?${params.join('&')}';
    
    final response = await http.get(
      Uri.parse(url),
      headers: _getHeaders(),
    ).timeout(Duration(seconds: AppConstants.apiTimeout));

    return await _handleResponse(response) as List<dynamic>;
  }

  // Reply to User Message
  Future<Map<String, dynamic>> replyToUser(String userId, String message) async {
    final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.adminReplyMessage(userId)}');
    final body = json.encode({'body': message});
    
    final response = await http.post(
      url,
      headers: _getHeaders(),
      body: body,
    ).timeout(Duration(seconds: AppConstants.apiTimeout));

    return _handleResponse(response);
  }
}
