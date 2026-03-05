import 'package:get/get.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';

class DashboardController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Transaction> recentTransactions = <Transaction>[].obs;
  final RxList<Transaction> pendingTransactions = <Transaction>[].obs;
  
  // Stats
  final RxInt totalTransactions = 0.obs;
  final RxInt totalBuyTransactions = 0.obs;
  final RxInt totalSellTransactions = 0.obs;
  final RxInt totalExchangeTransactions = 0.obs;
  final RxInt totalPendingTransactions = 0.obs;
  final RxDouble totalGoldHoldings = 0.0.obs;
  final RxDouble totalRevenue = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get all transactions
      final allTransactionsData = await _apiService.getAdminDashboard();
      final allTransactions = allTransactionsData
          .map((json) => Transaction.fromJson(json))
          .toList();

      // Calculate stats
      totalTransactions.value = allTransactions.length;
      totalBuyTransactions.value = allTransactions
          .where((t) => t.type.contains('BUY'))
          .length;
      totalSellTransactions.value = allTransactions
          .where((t) => t.type.contains('SELL'))
          .length;
      totalExchangeTransactions.value = allTransactions
          .where((t) => t.type.contains('EXCHANGE'))
          .length;
      totalPendingTransactions.value = allTransactions
          .where((t) => t.status.toLowerCase() == 'pending')
          .length;
      
      // Calculate total gold holdings (sum of all buy transactions minus sell/exchange)
      final totalBuyGrams = allTransactions
          .where((t) => t.type.contains('BUY') && t.status.toLowerCase() != 'rejected')
          .fold(0.0, (sum, t) => sum + t.grams);
      final totalSellGrams = allTransactions
          .where((t) => (t.type.contains('SELL') || t.type.contains('EXCHANGE')) 
              && t.status.toLowerCase() != 'rejected' && t.status.toLowerCase() != 'pending')
          .fold(0.0, (sum, t) => sum + t.grams);
      totalGoldHoldings.value = totalBuyGrams - totalSellGrams;
      
      // Calculate total revenue (fee amounts from all approved transactions)
      totalRevenue.value = allTransactions
          .where((t) => t.status.toLowerCase() != 'rejected')
          .fold(0.0, (sum, t) => sum + t.feeAmount);

      // Get recent transactions (last 10)
      recentTransactions.value = allTransactions.take(10).toList();
      
      // Get pending transactions
      pendingTransactions.value = allTransactions
          .where((t) => t.status.toLowerCase() == 'pending')
          .toList();

    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void refresh() {
    loadDashboardData();
  }
}
