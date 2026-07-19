// ignore_for_file: avoid_print

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

  String get baseUrl => AppConstants.baseUrl;
  String get token => _storage.getAuthToken() ?? '';

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  void checkAuthStatus() {
    isAuthenticated.value = _storage.isAuthenticated;
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

        // Navigate FIRST — FCM init runs in background, never blocks login
        Get.offAllNamed(AppRoutes.dashboard);
        initAdminFCM();
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
    await _storage.clearAll();
    isAuthenticated.value = false;
    Get.offAllNamed(AppRoutes.login);
  }
}
