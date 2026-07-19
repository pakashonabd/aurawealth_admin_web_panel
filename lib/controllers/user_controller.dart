import 'package:get/get.dart';
import '../models/user.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';

class UserController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<User> users = <User>[].obs;
  final RxMap<String, List<Transaction>> userTransactions =
      <String, List<Transaction>>{}.obs;
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

      final usersData = await _apiService.getAllUsers(
        skip: 0,
        limit: 500,
        includeFirestore: true,
      );

      final loadedUsers = usersData
          .whereType<Map>()
          .map((json) => User.fromJson(Map<String, dynamic>.from(json)))
          .where((user) => user.id.isNotEmpty)
          .toList();

      users.value = loadedUsers;
      await _loadUserTransactions();
      applyFilters();
    } on SessionExpiredException {
      return;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadUserTransactions() async {
    try {
      final transactionsData = await _apiService.getAdminDashboard();
      final transactions = transactionsData
          .whereType<Map>()
          .map((json) => Transaction.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      final txByUser = <String, List<Transaction>>{};
      for (final tx in transactions) {
        final userId = tx.userId;
        if (userId == null || userId.isEmpty) continue;
        txByUser.putIfAbsent(userId, () => <Transaction>[]).add(tx);
      }
      userTransactions.value = txByUser;
    } catch (_) {
      userTransactions.value = <String, List<Transaction>>{};
    }
  }

  void applyFilters() {
    var filtered = users.toList();

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((u) {
        return u.id.toLowerCase().contains(query) ||
            (u.backendId?.toLowerCase().contains(query) ?? false) ||
            (u.firebaseUid?.toLowerCase().contains(query) ?? false) ||
            (u.name?.toLowerCase().contains(query) ?? false) ||
            (u.email?.toLowerCase().contains(query) ?? false) ||
            (u.phoneNumber?.toLowerCase().contains(query) ?? false) ||
            (u.bankName?.toLowerCase().contains(query) ?? false) ||
            (u.accountNumber?.toLowerCase().contains(query) ?? false) ||
            (u.nationalId?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    filteredUsers.value = filtered;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  List<Transaction> getUserTransactions(String userId) {
    final user = findUser(userId);
    final ids = <String>{userId};
    final backendId = user?.backendId;
    final firebaseUid = user?.firebaseUid;
    if (backendId != null) ids.add(backendId);
    if (firebaseUid != null) ids.add(firebaseUid);
    return ids
        .expand((id) => userTransactions[id] ?? const <Transaction>[])
        .toList();
  }

  User? findUser(String userId) {
    return users.firstWhereOrNull(
      (u) => u.id == userId || u.backendId == userId || u.firebaseUid == userId,
    );
  }

  void updateKycStatus(String userId, String newStatus) {
    final index = users.indexWhere(
      (u) => u.id == userId || u.backendId == userId || u.firebaseUid == userId,
    );
    if (index == -1) return;

    final old = users[index];
    final updated = User(
      id: old.id,
      backendId: old.backendId,
      firebaseUid: old.firebaseUid,
      role: old.role,
      isAdmin: old.isAdmin,
      name: old.name,
      email: old.email,
      phoneNumber: old.phoneNumber,
      photoUrl: old.photoUrl,
      accountNumber: old.accountNumber,
      bankName: old.bankName,
      nationalId: old.nationalId,
      nidFrontUrl: old.nidFrontUrl,
      nidBackUrl: old.nidBackUrl,
      createdAt: old.createdAt,
      lastLogin: old.lastLogin,
      hasFingerprint: old.hasFingerprint,
      hasPasscode: old.hasPasscode,
      otpVerified: old.otpVerified,
      phoneVerified: old.phoneVerified,
      kycStatus: newStatus.toLowerCase(),
      totalGrams: old.totalGrams,
      lockedGrams: old.lockedGrams,
      availableGrams: old.availableGrams,
      walletUpdatedAt: old.walletUpdatedAt,
    );

    users[index] = updated;
    applyFilters();
  }

  void refresh() {
    loadUsers();
  }
}
