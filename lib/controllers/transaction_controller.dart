import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';

class TransactionController extends GetxController {
  final ApiService _apiService = ApiService();
  Timer? _searchDebounce;
  final searchCtrl = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Transaction> transactions         = <Transaction>[].obs;
  final RxList<Transaction> filteredTransactions = <Transaction>[].obs;

  // Filters — stored UPPERCASE to match model
  final RxString selectedStatus = ''.obs;
  final RxString selectedType   = ''.obs;
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate   = Rx<DateTime?>(null);
  final RxString searchQuery    = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  Future<void> loadTransactions({String? status}) async {
    try {
      isLoading.value    = true;
      errorMessage.value = '';

      final raw = await _apiService.getAdminDashboard(status: status);
      final all = raw
          .whereType<Map<String, dynamic>>()
          .map((json) => Transaction.fromJson(json))
          .toList();

      // Sort newest first
      all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      transactions.value = all;
      applyFilters();
    } on SessionExpiredException {
      return;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    var filtered = transactions.toList();

    if (selectedStatus.value.isNotEmpty) {
      filtered = filtered
          .where((t) => t.status == selectedStatus.value.toUpperCase())
          .toList();
    }

    if (selectedType.value.isNotEmpty) {
      filtered = filtered
          .where((t) => t.type == selectedType.value.toUpperCase())
          .toList();
    }

    if (startDate.value != null) {
      filtered = filtered
          .where((t) => !t.createdAt.isBefore(startDate.value!))
          .toList();
    }
    if (endDate.value != null) {
      filtered = filtered
          .where((t) => t.createdAt.isBefore(
              endDate.value!.add(const Duration(days: 1))))
          .toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      filtered = filtered.where((t) =>
          t.id.toLowerCase().contains(q) ||
          t.type.toLowerCase().contains(q) ||
          (t.code?.toLowerCase().contains(q) ?? false) ||
          (t.userName?.toLowerCase().contains(q) ?? false) ||
          (t.userEmail?.toLowerCase().contains(q) ?? false) ||
          (t.userPhone?.toLowerCase().contains(q) ?? false)).toList();
    }

    filteredTransactions.value = filtered;
  }

  void setStatusFilter(String? status) {
    selectedStatus.value = (status ?? '').toUpperCase();
    applyFilters();
  }

  void setTypeFilter(String? type) {
    selectedType.value = (type ?? '').toUpperCase();
    applyFilters();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    startDate.value = start;
    endDate.value   = end;
    applyFilters();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), applyFilters);
  }

  void clearFilters() {
    selectedStatus.value = '';
    selectedType.value   = '';
    startDate.value      = null;
    endDate.value        = null;
    searchQuery.value    = '';
    searchCtrl.clear();
    applyFilters();
  }

  Future<void> approveTransaction(String txId, {String? note}) async {
    try {
      await _apiService.approveTransaction(txId, note: note);
      Get.snackbar('Success', 'Transaction approved successfully',
          snackPosition: SnackPosition.TOP);
      loadTransactions();
    } on SessionExpiredException {
      return;
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.TOP);
    }
  }

  Future<void> rejectTransaction(String txId, {String? note}) async {
    try {
      await _apiService.rejectTransaction(txId, note: note);
      Get.snackbar('Success', 'Transaction rejected successfully',
          snackPosition: SnackPosition.TOP);
      loadTransactions();
    } on SessionExpiredException {
      return;
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.TOP);
    }
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchCtrl.dispose();
    super.onClose();
  }

  void refresh() => loadTransactions();
}
