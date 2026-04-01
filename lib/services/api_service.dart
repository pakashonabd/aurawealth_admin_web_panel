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

  // Returns decoded body or throws — NOT async so callers get a real value
  dynamic _parseResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return <String, dynamic>{'success': true};
      return json.decode(response.body);
    } else {
      String errorMessage = 'An error occurred';
      try {
        final errorBody = json.decode(response.body);
        errorMessage = errorBody['detail'] ?? errorBody['message'] ?? errorMessage;
      } catch (_) {
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
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // Get Admin Dashboard – returns a List
  Future<List<dynamic>> getAdminDashboard({String? status}) async {
    var url = '${AppConstants.baseUrl}${ApiEndpoints.adminDashboard}';
    if (status != null && status.isNotEmpty) {
      url += '?status=$status';
    }
    
    print('🌐 API: Fetching admin dashboard from: $url');
    
    final response = await http.get(
      Uri.parse(url),
      headers: _getHeaders(),
    ).timeout(Duration(seconds: AppConstants.apiTimeout));
    
    print('🌐 API: Response status code: ${response.statusCode}');
    print('🌐 API: Response body length: ${response.body.length}');
    
    final decoded = _parseResponse(response);
    
    if (decoded is List) {
      print('🌐 API: Received List with ${decoded.length} items');
      if (decoded.isNotEmpty) {
        print('🌐 API: First item keys: ${(decoded.first as Map).keys.toList()}');
        print('🌐 API: First item sample: ${decoded.first}');
      }
      return decoded;
    }
    // Some backends wrap in a key
    if (decoded is Map && decoded.containsKey('transactions')) {
      final txList = decoded['transactions'] as List<dynamic>;
      print('🌐 API: Received Map with transactions key, count: ${txList.length}');
      return txList;
    }
    
    print('🌐 API: Returning empty list');
    return [];
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
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // Get Current Gold Price
  Future<Map<String, dynamic>> getGoldPrice() async {
    final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.getPrice}');
    final response = await http.get(
      url,
      headers: _getHeaders(),
    ).timeout(Duration(seconds: AppConstants.apiTimeout));
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // Credit Grams (In-Store Purchase)
  Future<Map<String, dynamic>> creditGrams(String userId, double grams) async {
    final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.adminBuyCredit}');
    final body = json.encode({'user_id': userId, 'grams': grams});
    final response = await http.post(
      url,
      headers: _getHeaders(),
      body: body,
    ).timeout(Duration(seconds: AppConstants.apiTimeout));
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // Redeem Code
  Future<Map<String, dynamic>> redeemCode(String code) async {
    final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.adminRedeemCode(code)}');
    final response = await http.post(
      url,
      headers: _getHeaders(),
    ).timeout(Duration(seconds: AppConstants.apiTimeout));
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // Approve Transaction
  Future<Map<String, dynamic>> approveTransaction(String txId, {String? note}) async {
    final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.adminApprove(txId)}');
    final body = json.encode(note != null ? {'note': note} : <String, dynamic>{});
    final response = await http.post(
      url,
      headers: _getHeaders(),
      body: body,
    ).timeout(Duration(seconds: AppConstants.apiTimeout));
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // Reject Transaction
  Future<Map<String, dynamic>> rejectTransaction(String txId, {String? note}) async {
    final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.adminReject(txId)}');
    final body = json.encode(note != null ? {'note': note} : <String, dynamic>{});
    final response = await http.post(
      url,
      headers: _getHeaders(),
      body: body,
    ).timeout(Duration(seconds: AppConstants.apiTimeout));
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // Get Message Threads
  Future<List<dynamic>> getMessageThreads() async {
    final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.adminMessages}');
    final response = await http.get(
      url,
      headers: _getHeaders(),
    ).timeout(Duration(seconds: AppConstants.apiTimeout));
    final decoded = _parseResponse(response);
    if (decoded is List) return decoded;
    if (decoded is Map && decoded.containsKey('messages')) {
      return decoded['messages'] as List<dynamic>;
    }
    return [];
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
    final decoded = _parseResponse(response);
    if (decoded is List) return decoded;
    if (decoded is Map && decoded.containsKey('messages')) {
      return decoded['messages'] as List<dynamic>;
    }
    return [];
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
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // Get All Users
  Future<List<dynamic>> getAllUsers() async {
    final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.getAllUsers}');
    final response = await http.get(
      url,
      headers: _getHeaders(),
    ).timeout(Duration(seconds: AppConstants.apiTimeout));
    final decoded = _parseResponse(response);
    if (decoded is List) return decoded;
    if (decoded is Map && decoded.containsKey('users')) {
      return decoded['users'] as List<dynamic>;
    }
    return [];
  }
}
