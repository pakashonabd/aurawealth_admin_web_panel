import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/redemption.dart';
import '../../services/api_service.dart';
import '../../core/constants/app_colors.dart';

class RedemptionScreen extends StatefulWidget {
  const RedemptionScreen({super.key});

  @override
  State<RedemptionScreen> createState() => _RedemptionScreenState();
}

class _RedemptionScreenState extends State<RedemptionScreen>
    with TickerProviderStateMixin {
  final ApiService _api = ApiService();
  List<Redemption> _redemptions = [];
  bool _isLoading = true;
  String? _error;
  String? _searchQuery;
  Timer? _pollTimer;

  final Set<String> _expandedStatusCards = {};
  late TabController _deliveryTabController;

  @override
  void initState() {
    super.initState();
    _deliveryTabController = TabController(length: 2, vsync: this);
    _loadRedemptions();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _deliveryTabController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _loadRedemptions(silent: true);
    });
  }

  Future<void> _loadRedemptions({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final res = await _api.getRedemptions(search: _searchQuery, limit: 500);
      final list = (res['redemptions'] as List<dynamic>? ?? [])
          .map((j) => Redemption.fromJson(j as Map<String, dynamic>))
          .toList();
      if (mounted) {
        setState(() {
          _redemptions = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      final msg = e.toString();
      final friendly = msg.contains('Unable to reach') ||
              msg.contains('timed out') ||
              msg.contains('unavailable')
          ? msg
          : 'Something went wrong. Please try again.';
      if (mounted) {
        setState(() {
          _error = friendly;
          _isLoading = false;
        });
      }
    }
  }

  // ── Computed lists ──────────────────────────────────────────────────────

  List<Redemption> get _pendingRedemptions => _redemptions
      .where((r) => r.approvalStatus.toUpperCase() == 'PENDING')
      .toList();

  int get _approvedCount => _redemptions
      .where((r) => r.approvalStatus.toUpperCase() == 'APPROVED')
      .length;

  List<Redemption> get _homeDeliveryRedemptions => _redemptions.where((r) {
    if (r.approvalStatus.toUpperCase() != 'APPROVED') return false;
    final ds = (r.deliveryStatus ?? '').toUpperCase();
    if (ds == 'DELIVERED' || ds == 'PICKED_UP') return false;
    final method = r.deliveryMethod.toUpperCase();
    return method == 'DELIVERY' || method == 'HOME_DELIVERY';
  }).toList();

  List<Redemption> get _storePickupRedemptions => _redemptions.where((r) {
    if (r.approvalStatus.toUpperCase() != 'APPROVED') return false;
    final ds = (r.deliveryStatus ?? '').toUpperCase();
    if (ds == 'DELIVERED' || ds == 'PICKED_UP') return false;
    return r.deliveryMethod.toUpperCase() == 'STORE_PICKUP';
  }).toList();

  int get _homeDeliveryCount => _homeDeliveryRedemptions.length;
  int get _storePickupCount => _storePickupRedemptions.length;

  // ── Helpers ─────────────────────────────────────────────────────────────

  IconData _deliveryIcon(String? method) {
    final m = (method ?? '').toUpperCase();
    if (m == 'DELIVERY' || m == 'HOME_DELIVERY') {
      return Icons.local_shipping_rounded;
    }
    if (m == 'STORE_PICKUP') return Icons.store_rounded;
    return Icons.help_outline_rounded;
  }

  String _deliveryStatusLabel(String? status) {
    if (status == null) return 'Pending';
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pending';
      case 'READY_TO_SHIP':
        return 'Ready to Ship';
      case 'ON_THE_WAY':
        return 'On the Way';
      case 'SHIPPED':
        return 'Shipped';
      case 'READY_FOR_PICKUP':
        return 'Ready for Pickup';
      case 'DELIVERED':
        return 'Delivered';
      case 'PICKED_UP':
        return 'Picked Up';
      default:
        return status.toUpperCase();
    }
  }

  Color _deliveryStatusColor(String? status) {
    if (status == null) return AppColors.grey500;
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppColors.statusPending;
      case 'READY_TO_SHIP':
        return AppColors.info;
      case 'ON_THE_WAY':
        return Colors.orange;
      case 'SHIPPED':
        return const Color(0xFF7C4DFF);
      case 'READY_FOR_PICKUP':
        return AppColors.info;
      case 'DELIVERED':
      case 'PICKED_UP':
        return AppColors.success;
      default:
        return AppColors.grey500;
    }
  }

  /// All statuses for the dropdown. Only future statuses are selectable.
  List<String> _allStatusesForDeliveryType(String deliveryMethod) {
    final m = deliveryMethod.toUpperCase();
    if (m == 'STORE_PICKUP') {
      return ['READY_FOR_PICKUP', 'PICKED_UP'];
    }
    // Home delivery (default)
    return ['READY_TO_SHIP', 'ON_THE_WAY', 'SHIPPED', 'DELIVERED'];
  }

  int _statusIndex(String status, String deliveryMethod) {
    final all = _allStatusesForDeliveryType(deliveryMethod);
    return all.indexOf(status.toUpperCase());
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  Future<void> _approve(String txId) async {
    try {
      await _api.approveRedemption(txId);
      Get.snackbar('Approved', 'Redemption approved',
          backgroundColor: AppColors.success, colorText: Colors.white);
      _loadRedemptions(silent: true);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: AppColors.error, colorText: Colors.white);
    }
  }

  Future<void> _reject(String txId) async {
    final noteCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reject Redemption'),
        content: TextField(
          controller: noteCtrl,
          decoration: InputDecoration(
            hintText: 'Reason (required)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (noteCtrl.text.trim().isEmpty) {
                Get.snackbar('Error', 'Reason is required',
                    backgroundColor: AppColors.error, colorText: Colors.white);
                return;
              }
              Navigator.pop(ctx, true);
            },
            child:
                const Text('Reject', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _api.rejectRedemption(txId, note: noteCtrl.text.trim());
      Get.snackbar('Rejected', 'Redemption rejected',
          backgroundColor: AppColors.error, colorText: Colors.white);
      _loadRedemptions(silent: true);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: AppColors.error, colorText: Colors.white);
    }
  }

  Future<void> _updateDelivery(String txId, String status) async {
    try {
      await _api.updateDeliveryStatus(txId, status);
      Get.snackbar('Updated', 'Status updated to ${_deliveryStatusLabel(status)}',
          backgroundColor: AppColors.success, colorText: Colors.white);
      _loadRedemptions(silent: true);
    } catch (e) {
      final raw = e.toString().replaceFirst('Exception: ', '');
      Get.snackbar('Update Failed', raw,
          backgroundColor: AppColors.error, colorText: Colors.white,
          duration: const Duration(seconds: 5));
    }
  }

  void _toggleStatusPicker(String txId) {
    setState(() {
      if (_expandedStatusCards.contains(txId)) {
        _expandedStatusCards.remove(txId);
      } else {
        _expandedStatusCards.add(txId);
      }
    });
  }

  Widget _buildInlineStatusPicker(Redemption r) {
    final allStatuses = _allStatusesForDeliveryType(r.deliveryMethod);
    final currentIdx = _statusIndex(r.deliveryStatus ?? 'PENDING', r.deliveryMethod);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_rounded, size: 13, color: AppColors.info),
              const SizedBox(width: 4),
              Text('Update Delivery Status',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const Spacer(),
              InkWell(
                onTap: () => _toggleStatusPicker(r.txId),
                child: Icon(Icons.close_rounded, size: 16, color: AppColors.grey500),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: allStatuses.map((s) {
              final sIdx = allStatuses.indexOf(s);
              final isDone = sIdx < currentIdx;
              final isCurrent = sIdx == currentIdx;
              final isFuture = sIdx > currentIdx;
              final color = _deliveryStatusColor(s);

              return InkWell(
                onTap: isFuture
                    ? () {
                        _toggleStatusPicker(r.txId);
                        _updateDelivery(r.txId, s);
                      }
                    : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.success.withOpacity(0.08)
                        : isCurrent
                            ? color.withOpacity(0.12)
                            : isFuture
                                ? color.withOpacity(0.05)
                                : AppColors.grey100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCurrent
                          ? color.withOpacity(0.4)
                          : isFuture
                              ? color.withOpacity(0.15)
                              : AppColors.grey200,
                      width: isCurrent ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDone
                            ? Icons.check_circle_rounded
                            : isCurrent
                                ? Icons.radio_button_checked
                                : Icons.circle_outlined,
                        size: 14,
                        color: isDone
                            ? AppColors.success
                            : isCurrent
                                ? color
                                : AppColors.grey400,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _deliveryStatusLabel(s),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                          color: isDone
                              ? AppColors.success
                              : isCurrent
                                  ? color
                                  : isFuture
                                      ? AppColors.textPrimary
                                      : AppColors.grey400,
                        ),
                      ),
                      if (isDone) ...[
                        const SizedBox(width: 3),
                        Icon(Icons.check_rounded, size: 12, color: AppColors.success),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState()
                    : _buildSplitLayout(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final pending = _pendingRedemptions.length;
    final totalGold = _redemptions.fold(0.0, (s, r) => s + r.goldAmount);

    return Row(
      children: [
        _statChip('Total', '${_redemptions.length}', AppColors.primary),
        const SizedBox(width: 8),
        _statChip('Pending', '$pending', AppColors.statusPending),
        const SizedBox(width: 8),
        _statChip('Approved', '$_approvedCount', AppColors.statusApproved),
        const SizedBox(width: 8),
        _statChip('Delivery', '$_homeDeliveryCount', const Color(0xFF2196F3)),
        const SizedBox(width: 8),
        _statChip('Pickup', '$_storePickupCount', const Color(0xFF673AB7)),
        const SizedBox(width: 8),
        _statChip('Gold', '${totalGold.toStringAsFixed(1)}g', Colors.amber),
        const Spacer(),
        _buildSearchBar(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      width: 220,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search name or phone...',
          prefixIcon: const Icon(Icons.search, size: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          isDense: true,
        ),
        onSubmitted: (v) {
          _searchQuery = v.isEmpty ? null : v;
          _loadRedemptions();
        },
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label,
              style:
                  TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          Text(value,
              style:
                  TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ── Split Layout: Left (Pending) | Right (Delivery tabs) ───────────────

  Widget _buildSplitLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Left Half: Pending Approvals ─────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(
                'Pending Approvals',
                _pendingRedemptions.length,
                AppColors.statusPending,
              ),
              const SizedBox(height: 10),
              Expanded(child: _buildPendingList()),
            ],
          ),
        ),

        // ── Divider ──────────────────────────────────────────
        Container(
          width: 1,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: AppColors.grey200,
        ),

        // ── Right Half: Delivery Management ──────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDeliveryTabs(),
              const SizedBox(height: 10),
              Expanded(
                child: TabBarView(
                  controller: _deliveryTabController,
                  children: [
                    _buildDeliveryList(
                      _homeDeliveryRedemptions,
                      'No home deliveries in progress',
                      Icons.local_shipping_outlined,
                    ),
                    _buildDeliveryList(
                      _storePickupRedemptions,
                      'No store pickups in progress',
                      Icons.store_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('$count',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ),
      ],
    );
  }

  Widget _buildDeliveryTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey200),
      ),
      child: TabBar(
        controller: _deliveryTabController,
        indicator: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.black,
        unselectedLabelColor: AppColors.grey600,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        tabs: [
          Tab(child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_shipping_rounded, size: 14),
              const SizedBox(width: 4),
              const Text('Home Delivery'),
              if (_homeDeliveryCount > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.statusPending,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('$_homeDeliveryCount',
                      style: const TextStyle(fontSize: 10, color: Colors.white)),
                ),
              ],
            ],
          )),
          Tab(child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.store_rounded, size: 14),
              const SizedBox(width: 4),
              const Text('Store Pickup'),
              if (_storePickupCount > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF673AB7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('$_storePickupCount',
                      style: const TextStyle(fontSize: 10, color: Colors.white)),
                ),
              ],
            ],
          )),
        ],
      ),
    );
  }

  // ── Lists ───────────────────────────────────────────────────────────────

  Widget _buildPendingList() {
    if (_pendingRedemptions.isEmpty) {
      return _buildEmptyState('No pending approvals', Icons.check_circle_outline);
    }
    return RefreshIndicator(
      onRefresh: () => _loadRedemptions(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 4),
        itemCount: _pendingRedemptions.length,
        itemBuilder: (ctx, i) => _buildPendingCard(_pendingRedemptions[i]),
      ),
    );
  }

  Widget _buildDeliveryList(
      List<Redemption> items, String emptyMsg, IconData emptyIcon) {
    if (items.isEmpty) return _buildEmptyState(emptyMsg, emptyIcon);
    return RefreshIndicator(
      onRefresh: () => _loadRedemptions(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 4),
        itemCount: items.length,
        itemBuilder: (ctx, i) => _buildDeliveryCard(items[i]),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: AppColors.grey300),
          const SizedBox(height: 10),
          Text(message, style: TextStyle(color: AppColors.grey500, fontSize: 13)),
        ],
      ),
    );
  }

  // ── Pending Card ────────────────────────────────────────────────────────

  Widget _buildPendingCard(Redemption r) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Icon + Name + Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.statusPending.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_deliveryIcon(r.deliveryMethod),
                      color: AppColors.statusPending, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.userName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 1),
                      Text(r.userPhone,
                          style: TextStyle(color: AppColors.grey500, fontSize: 11)),
                    ],
                  ),
                ),
                _statusBadge('PENDING', AppColors.statusPending),
              ],
            ),
            const SizedBox(height: 10),

            // Info grid
            _infoGrid(r),

            // Address
            if (r.redemptionAddress != null && r.redemptionAddress!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _addressRow(r.redemptionAddress!),
            ],

            // Footer: Date + Actions
            const SizedBox(height: 10),
            Row(
              children: [
                Text(_formatDate(r.createdAt),
                    style: TextStyle(fontSize: 10, color: AppColors.grey500)),
                const Spacer(),
                _actionBtn('Reject', AppColors.error, () => _reject(r.txId)),
                const SizedBox(width: 6),
                _actionBtn('Approve', AppColors.success, () => _approve(r.txId)),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.03, end: 0);
  }

  // ── Delivery Card ───────────────────────────────────────────────────────

  Widget _buildDeliveryCard(Redemption r) {
    final ds = r.deliveryStatus;
    final deliveryColor = _deliveryStatusColor(ds);
    final deliveryLabel = _deliveryStatusLabel(ds);
    final allStatuses = _allStatusesForDeliveryType(r.deliveryMethod);
    final currentIdx = _statusIndex(ds ?? 'PENDING', r.deliveryMethod);
    final isComplete = currentIdx >= allStatuses.length - 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Icon + Name + Status badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: deliveryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_deliveryIcon(r.deliveryMethod),
                      color: deliveryColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.userName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 1),
                      Text(r.userPhone,
                          style: TextStyle(color: AppColors.grey500, fontSize: 11)),
                    ],
                  ),
                ),
                _statusBadge(deliveryLabel, deliveryColor),
              ],
            ),
            const SizedBox(height: 10),

            // Info grid
            _infoGrid(r),

            // Address
            if (r.redemptionAddress != null && r.redemptionAddress!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _addressRow(r.redemptionAddress!),
            ],

            // Admin note
            if (r.adminNote != null && r.adminNote!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note_alt_outlined, size: 13, color: AppColors.grey600),
                    const SizedBox(width: 5),
                    Expanded(
                        child: Text(r.adminNote!,
                            style: TextStyle(fontSize: 11, color: AppColors.grey700))),
                  ],
                ),
              ),
            ],

            // Footer: Date + Update Status / Complete
            const SizedBox(height: 10),
            Row(
              children: [
                Text(_formatDate(r.createdAt),
                    style: TextStyle(fontSize: 10, color: AppColors.grey500)),
                const Spacer(),
                if (!isComplete)
                  _actionBtn(
                    _expandedStatusCards.contains(r.txId) ? 'Close' : 'Update Status',
                    AppColors.info,
                    () => _toggleStatusPicker(r.txId),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 13, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text('Complete',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.success,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
              ],
            ),

            // Inline status picker (expanded)
            if (_expandedStatusCards.contains(r.txId))
              _buildInlineStatusPicker(r),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.03, end: 0);
  }

  // ── Shared card widgets ─────────────────────────────────────────────────

  Widget _infoGrid(Redemption r) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        _infoChip(Icons.scale_rounded, '${r.goldAmount}g', Colors.amber),
        _infoChip(Icons.payments_rounded,
            '${r.totalAmount.toStringAsFixed(0)} BDT', AppColors.primary),
        _infoChip(
          _deliveryIcon(r.deliveryMethod),
          r.deliveryMethod.toUpperCase() == 'STORE_PICKUP' ? 'Store Pickup' : 'Home Delivery',
          AppColors.grey600,
        ),
        if (r.userEmail.isNotEmpty)
          _infoChip(Icons.email_outlined, r.userEmail, AppColors.grey600),
        _infoChip(Icons.receipt_long_outlined, 'Fee: ${r.feeAmount.toStringAsFixed(0)}', AppColors.grey600),
        _infoChip(Icons.receipt_long_outlined, 'VAT: ${r.vatAmount.toStringAsFixed(0)}', AppColors.grey600),
      ],
    );
  }

  Widget _addressRow(String address) {
    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 13, color: AppColors.grey500),
        const SizedBox(width: 4),
        Expanded(
          child: Text(address,
              style: TextStyle(fontSize: 11, color: AppColors.grey600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Flexible(
            child: Text(text,
                style: TextStyle(
                    fontSize: 10, color: color, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: AppColors.error)),
          const SizedBox(height: 12),
          ElevatedButton(
              onPressed: _loadRedemptions, child: const Text('Retry')),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}
