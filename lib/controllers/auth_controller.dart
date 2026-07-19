// ignore_for_file: avoid_print

import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/admin_fcm_service.dart';
import '../routes/app_routes.dart';
import '../core/constants/app_constants.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isAuthenticated = false.obs;

  Timer? _keepAliveTimer;

  String get baseUrl => AppConstants.baseUrl;
  String get token => _storage.getAuthToken() ?? '';

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  @override
  void onClose() {
    _keepAliveTimer?.cancel();
    super.onClose();
  }

  void checkAuthStatus() {
    isAuthenticated.value = _storage.isAuthenticated;
    if (isAuthenticated.value) _startKeepAlive();
  }

  void _startKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(const Duration(minutes: 4), (_) {
      _warmPing();
    });
    _warmPing();
  }

  void _warmPing() {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/admin/dashboard');
      final token = _storage.getAuthToken();
      http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 5)).catchError((_) {});
    } catch (_) {}
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiService.adminLogin(email, password);

      final token = response['access_token'];
      if (token != null) {
        await _storage.saveAuthToken(token);
        await _storage.saveUserEmail(email);
        isAuthenticated.value = true;

        // Navigate FIRST — never block on FCM
        Get.offAllNamed(AppRoutes.dashboard);
        initAdminFCM();
        _startKeepAlive();
      } else {
        throw Exception('Invalid response from server');
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> initAdminFCM() async {
    try {
      await AdminFcmService.initialize();
    } catch (_) {
      // FCM init is non-critical — swallow errors silently
    }
  }

  Future<void> logout() async {
    _keepAliveTimer?.cancel();
    await _storage.clearAll();
    isAuthenticated.value = false;
    Get.offAllNamed(AppRoutes.login);
  }
}
