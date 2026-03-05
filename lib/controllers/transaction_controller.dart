import 'package:get/get.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';

class TransactionController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxList<Transaction> filteredTransactions = <Transaction>[].obs;
  
  // Filters
  final RxString selectedStatus = ''.obs;
  final RxString selectedType = ''.obs;
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  Future<void> loadTransactions({String? status}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = await _apiService.getAdminDashboard(status: status);
      transactions.value = data.map((json) => Transaction.fromJson(json)).toList();
      applyFilters();
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    var filtered = transactions.toList();
    
    // Filter by status
    if (selectedStatus.value.isNotEmpty) {
      filtered = filtered.where((t) => 
          t.status.toLowerCase() == selectedStatus.value.toLowerCase()
      ).toList();
    }
    
    // Filter by type
    if (selectedType.value.isNotEmpty) {
      filtered = filtered.where((t) => t.type == selectedType.value).toList();
    }
    
    // Filter by date range
    if (startDate.value != null) {
      filtered = filtered.where((t) => 
          t.createdAt.isAfter(startDate.value!) || 
          t.createdAt.isAtSameMomentAs(startDate.value!)
      ).toList();
    }
    
    if (endDate.value != null) {
      filtered = filtered.where((t) => 
          t.createdAt.isBefore(endDate.value!.add(Duration(days: 1)))
      ).toList();
    }
    
    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((t) => 
          t.id.toLowerCase().contains(query) ||
          t.type.toLowerCase().contains(query) ||
          (t.code?.toLowerCase().contains(query) ?? false) ||
          (t.userName?.toLowerCase().contains(query) ?? false) ||
          (t.userEmail?.toLowerCase().contains(query) ?? false)
      ).toList();
    }
    
    filteredTransactions.value = filtered;
  }

  void setStatusFilter(String? status) {
    selectedStatus.value = status ?? '';
    applyFilters();
  }

  void setTypeFilter(String? type) {
    selectedType.value = type ?? '';
    applyFilters();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    startDate.value = start;
    endDate.value = end;
    applyFilters();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void clearFilters() {
    selectedStatus.value = '';
    selectedType.value = '';
    startDate.value = null;
    endDate.value = null;
    searchQuery.value = '';
    applyFilters();
  }

  Future<void> approveTransaction(String txId, {String? note}) async {
    try {
      await _apiService.approveTransaction(txId, note: note);
      Get.snackbar('Success', 'Transaction approved successfully');
      loadTransactions();
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> rejectTransaction(String txId, {String? note}) async {
    try {
      await _apiService.rejectTransaction(txId, note: note);
      Get.snackbar('Success', 'Transaction rejected successfully');
      loadTransactions();
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
    }
  }

  void refresh() {
    loadTransactions();
  }
}
