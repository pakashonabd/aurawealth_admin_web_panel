import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/redemption.dart';
import '../../services/api_service.dart';
import '../../core/constants/app_colors.dart';

class RedemptionScreen extends StatefulWidget {
  const RedemptionScreen({Key? key}) : super(key: key);

  @override
  State<RedemptionScreen> createState() => _RedemptionScreenState();
}

class _RedemptionScreenState extends State<RedemptionScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  List<Redemption> _redemptions = [];
  bool _isLoading = true;
  String? _error;
  String? _searchQuery;
  Timer? _pollTimer;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRedemptions();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _loadRedemptions(silent: true);
    });
  }

  Future<void> _loadRedemptions({bool silent = false}) async {
    if (!silent) setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await _api.getRedemptions(
        search: _searchQuery,
        limit: 500,
      );
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

  List<Redemption> get _pendingRedemptions =>
      _redemptions.where((r) => r.approvalStatus.toUpperCase() == 'PENDING').toList();

  List<Redemption> get _approvedRedemptions =>
      _redemptions.where((r) =>
          r.approvalStatus.toUpperCase() == 'APPROVED' ||
          (r.deliveryStatus != null &&
              r.deliveryStatus!.toUpperCase() != 'DELIVERED' &&
              r.deliveryStatus!.toUpperCase() != 'PICKED_UP')).toList();

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppColors.statusPending;
      case 'APPROVED':
        return AppColors.statusApproved;
      case 'REJECTED':
        return AppColors.error;
      default:
        return AppColors.grey500;
    }
  }

  IconData _deliveryIcon(String? method) {
    if (method == 'home_delivery' || method == 'delivery') return Icons.local_shipping_rounded;
    if (method == 'store_pickup') return Icons.store_rounded;
    return Icons.help_outline_rounded;
  }

  String _deliveryStatusLabel(String? status) {
    if (status == null) return '';
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pending';
      case 'APPROVED':
        return 'Approved';
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
      case 'APPROVED':
        return AppColors.statusApproved;
      case 'READY_TO_SHIP':
      case 'READY_FOR_PICKUP':
        return AppColors.info;
      case 'ON_THE_WAY':
      case 'SHIPPED':
        return Colors.orange;
      case 'DELIVERED':
      case 'PICKED_UP':
        return AppColors.success;
      default:
        return AppColors.grey500;
    }
  }

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
        title: const Text('Reject Redemption'),
        content: TextField(
          controller: noteCtrl,
          decoration: const InputDecoration(hintText: 'Reason (required)'),
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
            child: const Text('Reject', style: TextStyle(color: AppColors.error)),
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
      Get.snackbar('Updated', 'Delivery status updated',
          backgroundColor: AppColors.success, colorText: Colors.white);
      _loadRedemptions(silent: true);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: AppColors.error, colorText: Colors.white);
    }
  }

  void _showDeliveryStatusDialog(String txId, String currentStatus) {
    final statuses = _getAvailableDeliveryStatuses(currentStatus);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Delivery Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses.map((s) => ListTile(
            title: Text(_deliveryStatusLabel(s)),
            leading: Icon(
              Icons.radio_button_checked,
              color: s == currentStatus ? AppColors.primary : AppColors.grey300,
            ),
            onTap: () {
              Navigator.pop(ctx);
              _updateDelivery(txId, s);
            },
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  List<String> _getAvailableDeliveryStatuses(String current) {
    switch (current.toUpperCase()) {
      case 'PENDING':
        return ['PENDING', 'APPROVED'];
      case 'APPROVED':
        return ['APPROVED', 'READY_TO_SHIP', 'READY_FOR_PICKUP'];
      case 'READY_TO_SHIP':
        return ['READY_TO_SHIP', 'ON_THE_WAY'];
      case 'ON_THE_WAY':
        return ['ON_THE_WAY', 'SHIPPED', 'DELIVERED'];
      case 'SHIPPED':
        return ['SHIPPED', 'DELIVERED'];
      case 'READY_FOR_PICKUP':
        return ['READY_FOR_PICKUP', 'PICKED_UP'];
      case 'DELIVERED':
      case 'PICKED_UP':
        return [current];
      default:
        return [current];
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _pendingRedemptions.length;
    final deliveryCount = _approvedRedemptions.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildTabBar(pendingCount, deliveryCount),
          const SizedBox(height: 12),
          _buildSearchBar(),
          const SizedBox(height: 12),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final pending = _pendingRedemptions.length;
    final approved = _redemptions.where((r) => r.approvalStatus == 'APPROVED').length;
    final totalGold = _redemptions.fold(0.0, (s, r) => s + r.goldAmount);

    return Row(
      children: [
        _statChip('Total', '${_redemptions.length}', AppColors.primary),
        const SizedBox(width: 8),
        _statChip('Pending', '$pending', AppColors.statusPending),
        const SizedBox(width: 8),
        _statChip('Approved', '$approved', AppColors.statusApproved),
        const SizedBox(width: 8),
        _statChip('Gold', '${totalGold.toStringAsFixed(1)}g', Colors.amber),
      ],
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 13, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildTabBar(int pendingCount, int deliveryCount) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedColor: AppColors.grey600,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        tabs: [
          Tab(child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Pending Approvals'),
              if (pendingCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.statusPending,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$pendingCount', style: const TextStyle(fontSize: 11, color: Colors.white)),
                ),
              ],
            ],
          )),
          Tab(child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Delivery'),
              if (deliveryCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.info,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$deliveryCount', style: const TextStyle(fontSize: 11, color: Colors.white)),
                ),
              ],
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search by name or phone...',
        prefixIcon: const Icon(Icons.search, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
      onSubmitted: (v) {
        _searchQuery = v.isEmpty ? null : v;
        _loadRedemptions();
      },
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
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

    return TabBarView(
      controller: _tabController,
      children: [
        _buildPendingList(),
        _buildDeliveryList(),
      ],
    );
  }

  Widget _buildPendingList() {
    if (_pendingRedemptions.isEmpty) {
      return _buildEmptyState('No pending approvals', Icons.check_circle_outline);
    }
    return RefreshIndicator(
      onRefresh: () => _loadRedemptions(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: _pendingRedemptions.length,
        itemBuilder: (ctx, i) =>
            _buildPendingCard(_pendingRedemptions[i]),
      ),
    );
  }

  Widget _buildDeliveryList() {
    if (_approvedRedemptions.isEmpty) {
      return _buildEmptyState('No deliveries in progress', Icons.local_shipping_outlined);
    }
    return RefreshIndicator(
      onRefresh: () => _loadRedemptions(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: _approvedRedemptions.length,
        itemBuilder: (ctx, i) =>
            _buildDeliveryCard(_approvedRedemptions[i]),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AppColors.grey300),
          const SizedBox(height: 12),
          Text(message,
              style:
                  TextStyle(color: AppColors.grey500, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildPendingCard(Redemption r) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_deliveryIcon(r.deliveryMethod),
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.userName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(r.userPhone,
                          style: TextStyle(
                              color: AppColors.grey600, fontSize: 12)),
                    ],
                  ),
                ),
                _statusBadge('PENDING', AppColors.statusPending),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _infoChip(Icons.scale_rounded, '${r.goldAmount}g', Colors.amber),
                const SizedBox(width: 8),
                _infoChip(Icons.payments_rounded,
                    '${r.totalAmount.toStringAsFixed(0)} BDT', AppColors.primary),
                const SizedBox(width: 8),
                _infoChip(
                  _deliveryIcon(r.deliveryMethod),
                  r.deliveryMethod == 'home_delivery' ? 'Delivery' : 'Pickup',
                  AppColors.grey600,
                ),
              ],
            ),
            if (r.redemptionAddress != null && r.redemptionAddress!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 14, color: AppColors.grey500),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(r.redemptionAddress!,
                        style:
                            TextStyle(fontSize: 11, color: AppColors.grey600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Text(_formatDate(r.createdAt),
                    style: TextStyle(fontSize: 11, color: AppColors.grey500)),
                const Spacer(),
                _actionBtn('Reject', AppColors.error, () => _reject(r.txId)),
                const SizedBox(width: 8),
                _actionBtn('Approve', AppColors.success, () => _approve(r.txId)),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.05, end: 0, duration: 300.ms);
  }

  Widget _buildDeliveryCard(Redemption r) {
    final deliveryColor = _deliveryStatusColor(r.deliveryStatus);
    final deliveryLabel = _deliveryStatusLabel(r.deliveryStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_deliveryIcon(r.deliveryMethod),
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.userName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(r.userPhone,
                          style: TextStyle(
                              color: AppColors.grey600, fontSize: 12)),
                    ],
                  ),
                ),
                _statusBadge(deliveryLabel, deliveryColor),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _infoChip(Icons.scale_rounded, '${r.goldAmount}g', Colors.amber),
                const SizedBox(width: 8),
                _infoChip(Icons.payments_rounded,
                    '${r.totalAmount.toStringAsFixed(0)} BDT', AppColors.primary),
                const SizedBox(width: 8),
                _infoChip(
                  _deliveryIcon(r.deliveryMethod),
                  r.deliveryMethod == 'home_delivery' ? 'Delivery' : 'Pickup',
                  AppColors.grey600,
                ),
              ],
            ),
            if (r.redemptionAddress != null && r.redemptionAddress!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 14, color: AppColors.grey500),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(r.redemptionAddress!,
                        style:
                            TextStyle(fontSize: 11, color: AppColors.grey600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ],
            if (r.adminNote != null && r.adminNote!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note_alt_outlined,
                        size: 14, color: AppColors.grey600),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text(r.adminNote!,
                            style: TextStyle(
                                fontSize: 11, color: AppColors.grey700))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Text(_formatDate(r.createdAt),
                    style: TextStyle(fontSize: 11, color: AppColors.grey500)),
                const Spacer(),
                _actionBtn('Update Status', AppColors.info,
                    () => _showDeliveryStatusDialog(r.txId, r.deliveryStatus ?? 'APPROVED')),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.05, end: 0, duration: 300.ms);
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.w600)),
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
