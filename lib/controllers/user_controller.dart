import 'package:get/get.dart';
import '../models/user.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';

class UserController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<User> users = <User>[].obs;
  final RxMap<String, List<Transaction>> userTransactions = <String, List<Transaction>>{}.obs;
  final RxString searchQuery = ''.obs;
  final RxList<User> filteredUsers = <User>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get all transactions from admin dashboard
      final transactionsData = await _apiService.getAdminDashboard();
      final transactions = transactionsData
          .map((json) => Transaction.fromJson(json))
          .toList();

      // Extract unique users from transactions
      final userMap = <String, User>{};
      final txByUser = <String, List<Transaction>>{};

      for (var tx in transactions) {
        if (tx.userId != null) {
          if (!userMap.containsKey(tx.userId)) {
            userMap[tx.userId!] = User(
              id: tx.userId!,
              name: tx.userName,
              email: tx.userEmail,
              photoUrl: tx.userPhoto,
              firebaseUid: null,
              phoneNumber: null,
              createdAt: tx.createdAt,
              phoneVerified: true,
              kycStatus: 'active',
            );
          }
          
          if (!txByUser.containsKey(tx.userId)) {
            txByUser[tx.userId!] = [];
          }
          txByUser[tx.userId]!.add(tx);
        }
      }

      users.value = userMap.values.toList();
      userTransactions.value = txByUser;
      applyFilters();
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    var filtered = users.toList();

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((u) =>
          u.id.toLowerCase().contains(query) ||
          (u.name?.toLowerCase().contains(query) ?? false) ||
          (u.email?.toLowerCase().contains(query) ?? false) ||
          (u.phoneNumber?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    filteredUsers.value = filtered;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  List<Transaction> getUserTransactions(String userId) {
    return userTransactions[userId] ?? [];
  }

  void refresh() {
    loadUsers();
  }
}
