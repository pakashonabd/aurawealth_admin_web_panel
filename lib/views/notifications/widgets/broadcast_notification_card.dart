import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../controllers/notification_controller.dart';
import '../../../core/constants/app_colors.dart';

class BroadcastNotificationCard extends StatefulWidget {
  const BroadcastNotificationCard({Key? key}) : super(key: key);

  @override
  State<BroadcastNotificationCard> createState() =>
      _BroadcastNotificationCardState();
}

class _BroadcastNotificationCardState
    extends State<BroadcastNotificationCard> {
  static const _accent = Color(0xFFE53935);

  final NotificationController _controller =
      Get.find<NotificationController>();

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _bodyCtrl = TextEditingController();
  final TextEditingController _imageCtrl = TextEditingController();
  final TextEditingController _dataCtrl = TextEditingController();

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
        borderSide: const BorderSide(color: _accent, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

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
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _warningBanner(),
                const SizedBox(height: 22),
                _section('CONTENT'),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleCtrl,
                  decoration: _inputDeco('Title', Icons.title_rounded),
                  maxLength: 100,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bodyCtrl,
                  decoration:
                      _inputDeco('Message', Icons.message_outlined),
                  maxLines: 3,
                  maxLength: 250,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 22),
                _section('MEDIA & DATA'),
                const SizedBox(height: 8),
                _imageToggle(),
                if (_includeImage) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _imageCtrl,
                    decoration:
                        _inputDeco('Image URL', Icons.link_rounded),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: _dataCtrl,
                  decoration: _inputDeco(
                      'Custom JSON', Icons.data_object_rounded),
                  maxLines: 2,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
                _broadcastBtn(),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 350.ms, duration: 500.ms)
        .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.04),
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(Icons.campaign_outlined,
              color: _accent, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Broadcast Notification',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3)),
              const SizedBox(height: 2),
              Text('Send to all active users',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.grey500)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _warningBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFFFF9800).withValues(alpha: 0.25)),
      ),
      child: Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFFF9800).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFFF9800), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'This will send to ALL active users. Use carefully!',
            style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500),
          ),
        ),
      ]),
    );
  }

  Widget _section(String label) => Text(label,
      style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.grey400,
          letterSpacing: 0.8));

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
        secondary: Icon(Icons.image_outlined,
            color:
                _includeImage ? _accent : AppColors.grey400,
            size: 22),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        dense: true,
      ),
    );
  }

  Widget _broadcastBtn() {
    return Obx(() {
      final sending = _controller.isSending.value;
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: sending ? null : _handleBroadcast,
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: sending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.campaign_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Send Broadcast',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
        ),
      );
    });
  }

  Future<void> _handleBroadcast() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    final imageUrl = _includeImage ? _imageCtrl.text.trim() : null;
    final dataJson = _dataCtrl.text.trim();

    if (title.isEmpty || body.isEmpty) {
      Get.snackbar('Error', 'Title and body are required',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Broadcast'),
        content: const Text(
            'This will send a notification to ALL active users. Are you sure?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: _accent),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

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

    final response = await _controller.sendBroadcast(
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
              ? 'Failed to send broadcast'
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
    setState(() => _includeImage = false);
  }
}
