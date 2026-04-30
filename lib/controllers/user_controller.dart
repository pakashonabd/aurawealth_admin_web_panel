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

      print('🔍 UserController: Starting to load users...');
      
      // Get all transactions from admin dashboard
      final transactionsData = await _apiService.getAdminDashboard();
      print('📦 UserController: Received ${transactionsData.length} transactions from API');
      
      // Print first transaction to see structure
      if (transactionsData.isNotEmpty) {
        print('📄 UserController: Sample transaction data: ${transactionsData.first}');
      }
      
      final transactions = transactionsData
          .map((json) => Transaction.fromJson(json))
          .toList();

      // Extract unique users from transactions
      final userMap = <String, User>{};
      final txByUser = <String, List<Transaction>>{};

      for (var tx in transactions) {
        if (tx.userId != null) {
          if (!userMap.containsKey(tx.userId)) {
            print('👤 UserController: Creating user from transaction:');
            print('   - User ID: ${tx.userId}');
            print('   - User Name: ${tx.userName}');
            print('   - User Email: ${tx.userEmail}');
            print('   - User Photo: ${tx.userPhoto}');
            
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
      
      print('✅ UserController: Loaded ${users.length} unique users');
      print('📊 UserController: Sample users:');
      for (var i = 0; i < users.length && i < 3; i++) {
        final user = users[i];
        print('   User $i:');
        print('     - ID: ${user.id}');
        print('     - Name: ${user.name}');
        print('     - Email: ${user.email}');
        print('     - Photo: ${user.photoUrl}');
      }
      
      applyFilters();
    } on SessionExpiredException {
      return;
    } catch (e) {
      print('❌ UserController Error: $e');
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
