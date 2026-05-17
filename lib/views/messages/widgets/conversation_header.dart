import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/admin_chat_controller.dart';
import '../../../controllers/message_controller.dart';
import '../../../models/message_thread.dart';
import '../../../core/utils/responsive.dart';
import 'design_tokens.dart';
import 'user_avatar.dart';

class ConversationHeader extends StatelessWidget {
  final MessageThread? thread;
  final AdminChatController adminChat;
  final MessageController controller;

  const ConversationHeader({
    super.key,
    required this.thread,
    required this.adminChat,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final displayName = thread != null
        ? controller.displayNameForThread(thread!)
        : 'User';
    final secondaryInfo = thread != null
        ? controller.secondaryInfoForThread(thread!)
        : null;
    final photoUrl = thread != null
        ? controller.photoUrlForThread(thread!)
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => controller.selectedUserId.value = '',
            ),
          UserAvatar(name: displayName, size: 40, imageUrl: photoUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1D26),
                  ),
                ),
                const SizedBox(height: 2),
                Obx(
                  () => Row(
                    children: [
                      if (secondaryInfo != null) ...[
                        Flexible(
                          child: Text(
                            secondaryInfo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: adminChat.isConnected.value
                              ? const Color(0xFF4CAF50)
                              : Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        adminChat.isConnected.value
                            ? 'Connected'
                            : 'Connecting…',
                        style: TextStyle(
                          fontSize: 11,
                          color: adminChat.isConnected.value
                              ? const Color(0xFF4CAF50)
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Refresh',
            style: IconButton.styleFrom(
              backgroundColor: surfaceBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => adminChat.reloadHistory(),
          ),
        ],
      ),
    );
  }
}
