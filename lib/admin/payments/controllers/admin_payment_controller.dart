import 'package:get/get.dart';
import '../services/admin_payment_service.dart';

class AdminPaymentController extends GetxController {
  final AdminPaymentService _service;

  AdminPaymentController(this._service);

  final payments = <Map<String, dynamic>>[].obs;
  final stats = Rxn<Map<String, dynamic>>();
  final isLoading = false.obs;
  final currentPage = 1.obs;
  final totalCount = 0.obs;
  final selectedStatus = Rxn<String>();
  final selectedType = Rxn<String>();
  final searchQuery = ''.obs;

  Future<void> loadPayments() async {
    isLoading.value = true;
    try {
      final result = await _service.listPayments(
        status: selectedStatus.value,
        type: selectedType.value,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        page: currentPage.value,
      );
      payments.value = List<Map<String, dynamic>>.from(result['items'] ?? []);
      totalCount.value = result['total'] ?? 0;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStats() async {
    try {
      stats.value = await _service.getStats();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load stats');
    }
  }

  Future<void> markAsPaid(String txId) async {
    try {
      await _service.markAsPaid(txId);
      Get.snackbar('Success', 'Transaction marked as paid');
      await loadPayments();
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark as paid');
    }
  }

  Future<void> reject(String txId, String reason) async {
    try {
      await _service.reject(txId, reason);
      Get.snackbar('Success', 'Transaction rejected');
      await loadPayments();
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject transaction');
    }
  }

  Future<void> requestRefund(String txId, String reason) async {
    try {
      await _service.requestRefund(txId, reason);
      Get.snackbar('Success', 'Refund requested');
      await loadPayments();
    } catch (e) {
      Get.snackbar('Error', 'Failed to request refund');
    }
  }

  Future<void> exportCsv() async {
    try {
      final bytes = await _service.exportCsv(
        status: selectedStatus.value,
        type: selectedType.value,
      );
      // Share file logic here
      Get.snackbar('Success', 'Export downloaded');
    } catch (e) {
      Get.snackbar('Error', 'Failed to export');
    }
  }

  void nextPage() {
    if (currentPage.value * 20 < totalCount.value) {
      currentPage.value++;
      loadPayments();
    }
  }

  void prevPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      loadPayments();
    }
  }
}
