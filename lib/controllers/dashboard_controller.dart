import 'package:get/get.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';

class DashboardController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Transaction> recentTransactions    = <Transaction>[].obs;
  final RxList<Transaction> pendingTransactions   = <Transaction>[].obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 10.obs;
  List<Transaction> _allTransactions = [];

  // Stats
  final RxInt    totalTransactions         = 0.obs;
  final RxInt    totalBuyTransactions      = 0.obs;
  final RxInt    totalSellTransactions     = 0.obs;
  final RxInt    totalExchangeTransactions = 0.obs;
  final RxInt    totalPendingTransactions  = 0.obs;
  final RxDouble totalGoldHoldings         = 0.0.obs;
  final RxDouble totalRevenue              = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Fetch all transactions (no status filter = all)
      final raw = await _apiService.getAdminDashboard();
      final all = raw
          .whereType<Map<String, dynamic>>()
          .map((json) => Transaction.fromJson(json))
          .toList();

      // ── counts ─────────────────────────────────────────────────────────
      totalTransactions.value         = all.length;
      totalBuyTransactions.value      = all.where((t) => t.type.contains('BUY')).length;
      totalSellTransactions.value     = all.where((t) => t.type.contains('SELL')).length;
      totalExchangeTransactions.value = all.where((t) => t.type.contains('EXCHANGE')).length;
      totalPendingTransactions.value  = all.where((t) => t.status == 'PENDING').length;

      // ── gold holdings ──────────────────────────────────────────────────
      // Grams added = all BUY transactions that are NOT rejected
      final buyGrams = all
          .where((t) => t.type.contains('BUY') && t.status != 'REJECTED')
          .fold(0.0, (sum, t) => sum + t.grams);

      // Grams removed = all SELL/EXCHANGE that are APPROVED or PAID
      final sellGrams = all
          .where((t) =>
              (t.type.contains('SELL') || t.type.contains('EXCHANGE')) &&
              (t.status == 'APPROVED' || t.status == 'PAID'))
          .fold(0.0, (sum, t) => sum + t.grams);

      totalGoldHoldings.value = (buyGrams - sellGrams).clamp(0.0, double.infinity);

      // ── revenue = sum of all fees from non-rejected transactions ───────
      totalRevenue.value = all
          .where((t) => t.status != 'REJECTED')
          .fold(0.0, (sum, t) => sum + t.feeAmount);

      // ── lists ──────────────────────────────────────────────────────────
      // Sort by newest first
      all.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _allTransactions = all;
      _updatePagedTransactions();
      pendingTransactions.value = all.where((t) => t.status == 'PENDING').toList();

    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void _updatePagedTransactions() {
    final startIndex = (currentPage.value - 1) * itemsPerPage.value;
    final endIndex = (startIndex + itemsPerPage.value).clamp(0, _allTransactions.length);
    
    if (startIndex < _allTransactions.length) {
      recentTransactions.value = _allTransactions.sublist(startIndex, endIndex);
    } else {
      recentTransactions.value = [];
    }
  }

  int get totalPages => (_allTransactions.length / itemsPerPage.value).ceil();

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
      _updatePagedTransactions();
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages) {
      goToPage(currentPage.value + 1);
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      goToPage(currentPage.value - 1);
    }
  }

  void refresh() => loadDashboardData();
}
