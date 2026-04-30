import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../controllers/notification_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../core/constants/app_colors.dart';

class TargetedNotificationCard extends StatefulWidget {
  const TargetedNotificationCard({Key? key}) : super(key: key);

  @override
  State<TargetedNotificationCard> createState() =>
      _TargetedNotificationCardState();
}

class _TargetedNotificationCardState extends State<TargetedNotificationCard> {
  final NotificationController _controller =
      Get.find<NotificationController>();
  final UserController _userController = Get.find<UserController>();

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _bodyCtrl = TextEditingController();
  final TextEditingController _imageCtrl = TextEditingController();
  final TextEditingController _dataCtrl = TextEditingController();

  String? _selectedUserId;
  bool _includeImage = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _imageCtrl.dispose();
    _dataCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 13, color: AppColors.grey500),
      prefixIcon: Icon(icon, size: 20, color: AppColors.grey400),
      filled: true,
      fillColor: AppColors.grey100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  // ── BUILD ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section('RECIPIENT'),
                const SizedBox(height: 8),
                _userDropdown(),
                const SizedBox(height: 22),
                _section('CONTENT'),
                const SizedBox(height: 8),
                _field(_titleCtrl, 'Title', Icons.title_rounded,
                    maxLen: 100),
                const SizedBox(height: 12),
                _field(_bodyCtrl, 'Message', Icons.message_outlined,
                    lines: 3, maxLen: 250),
                const SizedBox(height: 22),
                _section('MEDIA & DATA'),
                const SizedBox(height: 8),
                _imageToggle(),
                if (_includeImage) ...[
                  const SizedBox(height: 12),
                  _field(
                      _imageCtrl, 'Image URL', Icons.link_rounded),
                ],
                const SizedBox(height: 12),
                _field(_dataCtrl, 'Custom JSON',
                    Icons.data_object_rounded,
                    lines: 2),
                const SizedBox(height: 24),
                _sendBtn(),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 250.ms, duration: 500.ms)
        .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic);
  }

  // ── HEADER ─────────────────────────────────────────────────────────
  Widget _header() {
    const accent = Color(0xFF0288D1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.04),
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(Icons.person_outline_rounded,
              color: accent, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Targeted Notification',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3)),
              const SizedBox(height: 2),
              Text('Send to specific user(s)',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.grey500)),
            ],
          ),
        ),
      ]),
    );
  }

  // ── HELPERS ────────────────────────────────────────────────────────
  Widget _section(String label) => Text(label,
      style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.grey400,
          letterSpacing: 0.8));

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {int lines = 1, int? maxLen}) {
    return TextField(
      controller: ctrl,
      decoration: _inputDeco(label, icon),
      maxLines: lines,
      maxLength: maxLen,
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget _userDropdown() {
    return Obx(() {
      final users = _userController.filteredUsers;
      return DropdownButtonFormField<String>(
        decoration: _inputDeco('Select User', Icons.person_search_rounded),
        value: _selectedUserId,
        isExpanded: true,
        items: users
            .map((u) => DropdownMenuItem(
                  value: u.id,
                  child: Text(
                    '${u.name ?? u.email ?? "Unknown"} (${u.email ?? ""})',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ))
            .toList(),
        onChanged: (v) => setState(() => _selectedUserId = v),
      );
    });
  }

  Widget _imageToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        value: _includeImage,
        onChanged: (v) => setState(() => _includeImage = v),
        title: const Text('Include Image',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text('Attach an image URL',
            style: TextStyle(fontSize: 12, color: AppColors.grey500)),
        secondary:
            Icon(Icons.image_outlined, color: AppColors.grey400, size: 22),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        dense: true,
      ),
    );
  }

  // ── SEND BUTTON ────────────────────────────────────────────────────
  Widget _sendBtn() {
    const accent = Color(0xFF0288D1);
    return Obx(() {
      final sending = _controller.isSending.value;
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton.icon(
          onPressed: sending ? null : _handleSend,
          icon: sending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.send_rounded, size: 18),
          label: Text(sending ? 'Sending...' : 'Send Notification',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    });
  }

  // ── LOGIC ──────────────────────────────────────────────────────────
  Future<void> _handleSend() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    final imageUrl =
        _includeImage ? _imageCtrl.text.trim() : null;
    final dataJson = _dataCtrl.text.trim();

    if (title.isEmpty || body.isEmpty) {
      Get.snackbar('Error', 'Title and body are required',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
      return;
    }
    if (_selectedUserId == null) {
      Get.snackbar('Error', 'Please select a user',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
      return;
    }

    Map<String, dynamic>? data;
    if (dataJson.isNotEmpty) {
      try {
        data = Map<String, dynamic>.from(jsonDecode(dataJson));
      } catch (_) {
        Get.snackbar('Error', 'Invalid JSON format',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error,
            colorText: Colors.white);
        return;
      }
    }

    final response = await _controller.sendNotification(
      userId: _selectedUserId,
      title: title,
      body: body,
      imageUrl: imageUrl,
      data: data,
    );

    if (response != null && response.success) {
      Get.snackbar('Success', response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white);
      _clearForm();
    } else {
      Get.snackbar(
          'Error',
          _controller.errorMessage.value.isEmpty
              ? 'Failed to send notification'
              : _controller.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
    }
  }

  void _clearForm() {
    _titleCtrl.clear();
    _bodyCtrl.clear();
    _imageCtrl.clear();
    _dataCtrl.clear();
    setState(() {
      _selectedUserId = null;
      _includeImage = false;
    });
  }
}
