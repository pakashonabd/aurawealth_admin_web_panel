import 'package:get/get.dart';
import '../models/gold_price.dart';
import '../services/api_service.dart';

class GoldController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<GoldPrice?> currentPrice = Rx<GoldPrice?>(null);
  final RxBool isUpdatingPrice = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentPrice();
  }

  Future<void> loadCurrentPrice() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = await _apiService.getGoldPrice();
      currentPrice.value = GoldPrice.fromJson(data);
    } on SessionExpiredException {
      return;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePrice(double newPrice) async {
    try {
      isUpdatingPrice.value = true;
      errorMessage.value = '';

      final data = await _apiService.setGoldPrice(newPrice);
      currentPrice.value = GoldPrice.fromJson(data);
      
      Get.snackbar('Success', 'Gold price updated successfully');
    } on SessionExpiredException {
      return;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Error', errorMessage.value);
      rethrow;
    } finally {
      isUpdatingPrice.value = false;
    }
  }

  void refresh() {
    loadCurrentPrice();
  }
}
