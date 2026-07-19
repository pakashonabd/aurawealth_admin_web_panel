import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../core/constants/api_endpoints.dart';
import '../routes/app_routes.dart';
import 'storage_service.dart';

class SessionExpiredException implements Exception {
  final String message;
  const SessionExpiredException([this.message = 'Session expired']);
  @override
  String toString() => message;
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final StorageService _storage = StorageService();
  bool _isLoggingOut = false;

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

  Future<void> _handleSessionExpired() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;
    try {
      await _storage.clearAll();
      Get.offAllNamed(AppRoutes.login);
      Get.snackbar(
        'Session Expired',
        'Your session has expired. Please log in again.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isLoggingOut = false;
    }
  }

  dynamic _parseResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return <String, dynamic>{'success': true};
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      _handleSessionExpired();
      throw SessionExpiredException();
    } else {
      String errorMessage = 'An error occurred';
      try {
        final errorBody = json.decode(response.body);
        errorMessage =
            errorBody['detail'] ?? errorBody['message'] ?? errorMessage;
      } catch (_) {
        errorMessage = response.body.isNotEmpty
            ? response.body
            : 'HTTP ${response.statusCode}';
      }
      throw Exception(errorMessage);
    }
  }

  /// Wraps a network call to provide user-friendly error messages
  /// for common failure modes (no internet, timeout, server unreachable).
  Future<T> _safeNetworkCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on http.ClientException catch (_) {
      throw Exception(
        'Unable to reach the server. Please check your internet connection and try again.',
      );
    } on TimeoutException catch (_) {
      throw Exception(
        'Request timed out. The server may be starting up — please try again in a moment.',
      );
    } on SessionExpiredException {
      rethrow;
    } catch (e) {
      if (e.toString().contains('Failed to fetch') ||
          e.toString().contains('ClientException')) {
        throw Exception(
          'Unable to connect to the server. It may be temporarily unavailable — please try again.',
        );
      }
      rethrow;
    }
  }

  // Admin Login
  Future<Map<String, dynamic>> adminLogin(String email, String password) async {
    final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.adminLogin}');
    final body = 'username=$email&password=$password';
    final response = await http
        .post(url, headers: _getHeaders(isFormData: true), body: body)
        .timeout(Duration(seconds: AppConstants.apiTimeout));
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // Get Admin Dashboard – returns a List
  Future<List<dynamic>> getAdminDashboard({String? status}) async {
    var url = '${AppConstants.baseUrl}${ApiEndpoints.adminDashboard}';
    if (status != null && status.isNotEmpty) {
      url += '?status=$status';
    }

    print('🌐 API: Fetching admin dashboard from: $url');

    final response = await http
        .get(Uri.parse(url), headers: _getHeaders())
        .timeout(Duration(seconds: AppConstants.apiTimeout));

    print('🌐 API: Response status code: ${response.statusCode}');
    print('🌐 API: Response body length: ${response.body.length}');

    final decoded = _parseResponse(response);

    if (decoded is List) {
      print('🌐 API: Received List with ${decoded.length} items');
      if (decoded.isNotEmpty) {
        print(
          '🌐 API: First item keys: ${(decoded.first as Map).keys.toList()}',
        );
        print('🌐 API: First item sample: ${decoded.first}');
      }
      return decoded;
    }
    // Some backends wrap in a key
    if (decoded is Map && decoded.containsKey('transactions')) {
      final txList = decoded['transactions'] as List<dynamic>;
      print(
        '🌐 API: Received Map with transactions key, count: ${txList.length}',
      );
      return txList;
    }

    print('🌐 API: Returning empty list');
    return [];
  }

  // Set Gold Price
  Future<Map<String, dynamic>> setGoldPrice(double price) async {
    final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.setPrice}');
    final body = json.encode({'price': price});
    final response = await http
        .post(url, headers: _getHeaders(), body: body)
        .timeout(Duration(seconds: AppConstants.apiTimeout));
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // Get Current Gold Price
  Future<Map<String, dynamic>> getGoldPrice() async {
    final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.getPrice}');
    final response = await http
        .get(url, headers: _getHeaders())
        .timeout(Duration(seconds: AppConstants.apiTimeout));
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // Credit Grams (In-Store Purchase)
  Future<Map<String, dynamic>> creditGrams(String userId, double grams) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}${ApiEndpoints.adminBuyCredit}',
    );
    final body = json.encode({'user_id': userId, 'grams': grams});
    final response = await http
        .post(url, headers: _getHeaders(), body: body)
        .timeout(Duration(seconds: AppConstants.apiTimeout));
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // Redeem Code
  Future<Map<String, dynamic>> redeemCode(String code) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}${ApiEndpoints.adminRedeemCode(code)}',
    );
    final response = await http
        .post(url, headers: _getHeaders())
        .timeout(Duration(seconds: AppConstants.apiTimeout));
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // Approve Transaction
  Future<Map<String, dynamic>> approveTransaction(
    String txId, {
    String? note,
  }) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}${ApiEndpoints.adminApprove(txId)}',
    );
    final body = json.encode(
      note != null ? {'note': note} : <String, dynamic>{},
    );
    final response = await http
        .post(url, headers: _getHeaders(), body: body)
        .timeout(Duration(seconds: AppConstants.apiTimeout));
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // Reject Transaction
  Future<Map<String, dynamic>> rejectTransaction(
    String txId, {
    String? note,
  }) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}${ApiEndpoints.adminReject(txId)}',
    );
    final body = json.encode(
      note != null ? {'note': note} : <String, dynamic>{},
    );
    final response = await http
        .post(url, headers: _getHeaders(), body: body)
        .timeout(Duration(seconds: AppConstants.apiTimeout));
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // Get All Users
  Future<List<dynamic>> getAllUsers({
    int skip = 0,
    int limit = 500,
    String? search,
    bool includeFirestore = true,
  }) async {
    final queryParams = <String, String>{
      'skip': skip.toString(),
      'limit': limit.toString(),
      'include_firestore': includeFirestore.toString(),
    };
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final uri = Uri.parse(
      '${AppConstants.baseUrl}${ApiEndpoints.getAllUsers}',
    ).replace(queryParameters: queryParams);
    final response = await http
        .get(uri, headers: _getHeaders())
        .timeout(Duration(seconds: AppConstants.apiTimeout));
    final decoded = _parseResponse(response);
    if (decoded is List) return decoded;
    if (decoded is Map && decoded.containsKey('users')) {
      return decoded['users'] as List<dynamic>;
    }
    return [];
  }

  // ============================
  // NOTIFICATION & DEVICE MANAGEMENT
  // ============================

  // Send Basic Notification
  Future<Map<String, dynamic>> sendNotification({
    String? userId,
    List<String>? userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}${ApiEndpoints.sendNotification}',
    );
    final payload = <String, dynamic>{'title': title, 'body': body};
    if (userId != null) payload['user_id'] = userId;
    if (userIds != null) payload['user_ids'] = userIds;
    if (data != null) payload['data'] = data;

    final response = await http
        .post(url, headers: _getHeaders(), body: json.encode(payload))
        .timeout(Duration(seconds: AppConstants.apiTimeout));
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // Send Notification with Image
  Future<Map<String, dynamic>> sendNotificationWithImage({
    String? userId,
    List<String>? userIds,
    required String title,
    required String body,
    String? imageUrl,
    Map<String, dynamic>? data,
  }) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}${ApiEndpoints.sendNotificationWithImage}',
    );
    final payload = <String, dynamic>{'title': title, 'body': body};
    if (userId != null) payload['user_id'] = userId;
    if (userIds != null) payload['user_ids'] = userIds;
    if (imageUrl != null) payload['image_url'] = imageUrl;
    if (data != null) payload['data'] = data;

    final response = await http
        .post(url, headers: _getHeaders(), body: json.encode(payload))
        .timeout(Duration(seconds: AppConstants.apiTimeout));
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // Send Broadcast
  Future<Map<String, dynamic>> sendBroadcast({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}${ApiEndpoints.sendBroadcast}',
    );
    final payload = <String, dynamic>{'title': title, 'body': body};
    if (data != null) payload['data'] = data;

    final response = await http
        .post(url, headers: _getHeaders(), body: json.encode(payload))
        .timeout(Duration(seconds: AppConstants.apiTimeout));
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // Broadcast with Image
  Future<Map<String, dynamic>> broadcastWithImage({
    required String title,
    required String body,
    String? imageUrl,
    Map<String, dynamic>? data,
  }) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}${ApiEndpoints.broadcastWithImage}',
    );
    final payload = <String, dynamic>{'title': title, 'body': body};
    if (imageUrl != null) payload['image_url'] = imageUrl;
    if (data != null) payload['data'] = data;

    final response = await http
        .post(url, headers: _getHeaders(), body: json.encode(payload))
        .timeout(Duration(seconds: AppConstants.apiTimeout));
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // Get All Devices
  Future<Map<String, dynamic>> getAllDevices({
    bool activeOnly = true,
    int skip = 0,
    int limit = 100,
  }) async {
    final queryParams = <String, String>{
      'active_only': activeOnly.toString(),
      'skip': skip.toString(),
      'limit': limit.toString(),
    };
    final uri = Uri.parse(
      '${AppConstants.baseUrl}${ApiEndpoints.devicesAll}',
    ).replace(queryParameters: queryParams);

    final response = await http
        .get(uri, headers: _getHeaders())
        .timeout(Duration(seconds: AppConstants.apiTimeout));
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // Get User Devices
  Future<Map<String, dynamic>> getUserDevices(String userId) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}${ApiEndpoints.devicesUser(userId)}',
    );
    final response = await http
        .get(url, headers: _getHeaders())
        .timeout(Duration(seconds: AppConstants.apiTimeout));
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // Delete Device
  Future<Map<String, dynamic>> deleteDevice(String deviceId) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}${ApiEndpoints.deleteDevice(deviceId)}',
    );
    final response = await http
        .delete(url, headers: _getHeaders())
        .timeout(Duration(seconds: AppConstants.apiTimeout));
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // Register Device (Admin)
  Future<Map<String, dynamic>> registerDevice({
    required String userId,
    required String token,
    required String deviceType,
    String? deviceName,
  }) async {
    final uri = Uri.parse(
      '${AppConstants.baseUrl}${ApiEndpoints.registerDevice}',
    ).replace(queryParameters: {'user_id': userId});
    final payload = <String, dynamic>{
      'token': token,
      'device_type': deviceType,
    };
    if (deviceName != null) payload['device_name'] = deviceName;

    final response = await http
        .post(uri, headers: _getHeaders(), body: json.encode(payload))
        .timeout(Duration(seconds: AppConstants.apiTimeout));
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // Get Device Statistics
  Future<Map<String, dynamic>> getDeviceStats() async {
    final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.deviceStats}');
    final response = await http
        .get(url, headers: _getHeaders())
        .timeout(Duration(seconds: AppConstants.apiTimeout));
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // Generic POST helper
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse(endpoint);
    final response = await http
        .post(url, headers: _getHeaders(), body: json.encode(body))
        .timeout(Duration(seconds: AppConstants.apiTimeout));
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // Generic GET helper
  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse(endpoint);
    final response = await http
        .get(url, headers: _getHeaders())
        .timeout(Duration(seconds: AppConstants.apiTimeout));
    return _parseResponse(response);
  }

  // ============================
  // REDEMPTION MANAGEMENT
  // ============================

  Future<Map<String, dynamic>> getRedemptions({
    String? status,
    String? search,
    int skip = 0,
    int limit = 100,
  }) async {
    return _safeNetworkCall(() async {
      final queryParams = <String, String>{
        'skip': skip.toString(),
        'limit': limit.toString(),
      };
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final uri = Uri.parse(
              '${AppConstants.baseUrl}${ApiEndpoints.adminRedemptions}')
          .replace(queryParameters: queryParams);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(Duration(seconds: AppConstants.apiTimeout));
      return _parseResponse(response) as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> approveRedemption(String txId, {String? note}) async {
    return _safeNetworkCall(() async {
      final url = Uri.parse(
          '${AppConstants.baseUrl}${ApiEndpoints.adminApproveRedemption(txId)}');
      final body = json.encode(
          note != null ? {'note': note} : <String, dynamic>{});
      final response = await http
          .put(url, headers: _getHeaders(), body: body)
          .timeout(Duration(seconds: AppConstants.apiTimeout));
      return _parseResponse(response) as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> rejectRedemption(String txId, {required String note}) async {
    return _safeNetworkCall(() async {
      final url = Uri.parse(
          '${AppConstants.baseUrl}${ApiEndpoints.adminRejectRedemption(txId)}');
      final body = json.encode({'note': note});
      final response = await http
          .put(url, headers: _getHeaders(), body: body)
          .timeout(Duration(seconds: AppConstants.apiTimeout));
      return _parseResponse(response) as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> updateDeliveryStatus(String txId, String deliveryStatus) async {
    // Retry up to 2 times on network errors (Heroku cold-start / transient)
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        return await _safeNetworkCall(() async {
          final url = Uri.parse(
              '${AppConstants.baseUrl}${ApiEndpoints.adminUpdateDeliveryStatus(txId)}');
          final body = json.encode({'delivery_status': deliveryStatus});
          final response = await http
              .put(url, headers: _getHeaders(), body: body)
              .timeout(Duration(seconds: AppConstants.apiTimeout));
          return _parseResponse(response) as Map<String, dynamic>;
        });
      } on Exception catch (e) {
        final msg = e.toString();
        final isNetworkError = msg.contains('Unable to reach') ||
            msg.contains('Failed to fetch') ||
            msg.contains('ClientException') ||
            msg.contains('timed out');
        if (isNetworkError && attempt == 0) {
          // Wait briefly then retry once for transient network errors
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
        rethrow;
      }
    }
    throw Exception('Unable to reach the server. Please try again.');
  }

}
