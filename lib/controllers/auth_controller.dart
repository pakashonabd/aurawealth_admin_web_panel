import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/admin_fcm_service.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isAuthenticated = false.obs;

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
        await AdminFcmService.initialize();
        
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        throw Exception('Invalid response from server');
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
    isAuthenticated.value = false;
    Get.offAllNamed(AppRoutes.login);
  }
}
