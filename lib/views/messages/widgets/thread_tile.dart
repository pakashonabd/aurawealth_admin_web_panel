import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/admin_chat_controller.dart';
import '../../../controllers/message_controller.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/message_thread.dart';
import 'design_tokens.dart';
import 'user_avatar.dart';

class ThreadTile extends StatelessWidget {
  final MessageThread thread;
  final MessageController controller;

  const ThreadTile({super.key, required this.thread, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedUserId.value == thread.userId;
      final displayName = controller.displayNameForThread(thread);
      final secondaryInfo = controller.secondaryInfoForThread(thread);
      final photoUrl = controller.photoUrlForThread(thread);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected
              ? liveAccent.withValues(alpha: 0.08)
              : Colors.transparent,
          border: Border(
            left: isSelected
                ? BorderSide(color: liveAccent, width: 3)
                : const BorderSide(color: Colors.transparent, width: 3),
          ),
        ),
        child: InkWell(
          onTap: () => _onTap(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Avatar
                UserAvatar(name: displayName, size: 44, imageUrl: photoUrl),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: thread.unreadCount > 0
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: const Color(0xFF1A1D26),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            Formatters.formatRelativeTime(thread.lastMessageAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              secondaryInfo != null
                                  ? '$secondaryInfo • ${thread.lastMessage}'
                                  : thread.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: thread.unreadCount > 0
                                    ? const Color(0xFF1A1D26)
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ),
                          if (thread.unreadCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: liveAccent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${thread.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _onTap() {
    // Always set selected user first so the pane shows immediately
    controller.selectedUserId.value = thread.userId;

    final isNew = !Get.isRegistered<AdminChatController>(tag: thread.userId);

    if (isNew) {
      // First visit: create controller — onInit() will load history and attach the Firestore stream
      Get.put(
        AdminChatController(targetUserId: thread.userId),
        tag: thread.userId,
        permanent: false,
      );
    } else {
      // Returning visit: controller already alive but history may be stale.
      // Refresh from Firestore so chat body is as fresh as the thread card.
      final adminChat = Get.find<AdminChatController>(tag: thread.userId);
      adminChat.reloadHistory();
    }
  }
}
