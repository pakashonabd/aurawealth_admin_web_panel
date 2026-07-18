import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/redemption.dart';
import '../../services/api_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class RedemptionScreen extends StatefulWidget {
  const RedemptionScreen({Key? key}) : super(key: key);

  @override
  State<RedemptionScreen> createState() => _RedemptionScreenState();
}

class _RedemptionScreenState extends State<RedemptionScreen> {
  final ApiService _api = ApiService();
  List<Redemption> _redemptions = [];
  bool _isLoading = true;
  String? _error;
  String? _statusFilter;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _loadRedemptions();
  }

  Future<void> _loadRedemptions() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await _api.getRedemptions(
        status: _statusFilter,
        search: _searchQuery,
        limit: 500,
      );
      final list = (res['redemptions'] as List<dynamic>? ?? [])
          .map((j) => Redemption.fromJson(j as Map<String, dynamic>))
          .toList();
      setState(() { _redemptions = list; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING': return AppColors.statusPending;
      case 'APPROVED': return AppColors.statusApproved;
      case 'REJECTED': return AppColors.error;
      default: return AppColors.grey500;
    }
  }

  IconData _deliveryIcon(String? method) {
    if (method == 'delivery') return Icons.local_shipping_rounded;
    if (method == 'store_pickup') return Icons.store_rounded;
    return Icons.help_outline_rounded;
  }

  Future<void> _approve(String txId) async {
    try {
      await _api.approveRedemption(txId);
      Get.snackbar('Approved', 'Redemption approved', backgroundColor: AppColors.success, colorText: Colors.white);
      _loadRedemptions();
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: AppColors.error, colorText: Colors.white);
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
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (noteCtrl.text.trim().isEmpty) {
                Get.snackbar('Error', 'Reason is required', backgroundColor: AppColors.error, colorText: Colors.white);
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
      Get.snackbar('Rejected', 'Redemption rejected', backgroundColor: AppColors.error, colorText: Colors.white);
      _loadRedemptions();
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: AppColors.error, colorText: Colors.white);
    }
  }

  Future<void> _updateDelivery(String txId, String status) async {
    try {
      await _api.updateDeliveryStatus(txId, status);
      Get.snackbar('Updated', 'Delivery status updated', backgroundColor: AppColors.success, colorText: Colors.white);
      _loadRedemptions();
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: AppColors.error, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildFilters(),
          const SizedBox(height: 16),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final pending = _redemptions.where((r) => r.approvalStatus == 'PENDING').length;
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
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          Text(value, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by name or phone...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            onSubmitted: (v) { _searchQuery = v.isEmpty ? null : v; _loadRedemptions(); },
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _statusFilter,
              hint: const Text('All Status', style: TextStyle(fontSize: 13)),
              isDense: true,
              items: const [
                DropdownMenuItem(value: null, child: Text('All Status')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'approved', child: Text('Approved')),
                DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
              ],
              onChanged: (v) { _statusFilter = v; _loadRedemptions(); },
            ),
          ),
        ),
      ],
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
            ElevatedButton(onPressed: _loadRedemptions, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_redemptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 64, color: AppColors.grey300),
            const SizedBox(height: 12),
            Text('No redemption requests', style: TextStyle(color: AppColors.grey500, fontSize: 15)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _redemptions.length,
      itemBuilder: (ctx, i) => _buildRedemptionCard(_redemptions[i]),
    );
  }

  Widget _buildRedemptionCard(Redemption r) {
    final statusColor = _statusColor(r.approvalStatus);
    final isPending = r.approvalStatus.toUpperCase() == 'PENDING';
    final isApproved = r.approvalStatus.toUpperCase() == 'APPROVED';

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
                  child: Icon(_deliveryIcon(r.deliveryMethod), color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.userName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(r.userPhone, style: TextStyle(color: AppColors.grey600, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(r.approvalStatus.toUpperCase(),
                      style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _infoChip(Icons.scale_rounded, '${r.goldAmount}g', Colors.amber),
                const SizedBox(width: 8),
                _infoChip(Icons.payments_rounded, '${r.totalAmount.toStringAsFixed(0)} BDT', AppColors.primary),
                const SizedBox(width: 8),
                _infoChip(
                  r.deliveryMethod == 'delivery' ? Icons.local_shipping : Icons.store,
                  r.deliveryMethod == 'delivery' ? 'Delivery' : 'Pickup',
                  AppColors.grey600,
                ),
                if (r.deliveryStatus != null) ...[
                  const SizedBox(width: 8),
                  _infoChip(Icons.info_outline, r.deliveryStatus!.toUpperCase(), AppColors.info),
                ],
              ],
            ),
            if (r.redemptionAddress != null && r.redemptionAddress!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 14, color: AppColors.grey500),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(r.redemptionAddress!, style: TextStyle(fontSize: 11, color: AppColors.grey600), maxLines: 2, overflow: TextOverflow.ellipsis),
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
                    Icon(Icons.note_alt_outlined, size: 14, color: AppColors.grey600),
                    const SizedBox(width: 6),
                    Expanded(child: Text(r.adminNote!, style: TextStyle(fontSize: 11, color: AppColors.grey700))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Text(_formatDate(r.createdAt), style: TextStyle(fontSize: 11, color: AppColors.grey500)),
                const Spacer(),
                if (isPending) ...[
                  _actionBtn('Reject', AppColors.error, () => _reject(r.txId)),
                  const SizedBox(width: 8),
                  _actionBtn('Approve', AppColors.success, () => _approve(r.txId)),
                ],
                if (isApproved && r.deliveryMethod == 'delivery') ...[
                  if (r.deliveryStatus != 'SHIPPED')
                    _actionBtn('Mark Shipped', AppColors.info, () => _updateDelivery(r.txId, 'SHIPPED')),
                  if (r.deliveryStatus == 'SHIPPED')
                    _actionBtn('Mark Delivered', AppColors.success, () => _updateDelivery(r.txId, 'DELIVERED')),
                ],
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0, duration: 300.ms);
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
          Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
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
        child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
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
