import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/message_controller.dart';
import '../../controllers/admin_chat_controller.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import '../../widgets/common/empty_state_widget.dart';
import '../../models/message.dart';
import '../../models/message_thread.dart';


// ─────────────────────────────────────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────────────────────────────────────
const _kSidebarWidth = 320.0;
const _kRadius = 16.0;
const _kBubbleRadius = 18.0;

final _liveAccent = const Color(0xFF4F8EF7);     // bright blue
final _mailAccent = const Color(0xFF7C5CBF);     // soft purple
final _surfaceBg  = const Color(0xFFF6F7FB);     // page background
final _sidebarBg  = const Color(0xFFFFFFFF);
final _chatBg     = const Color(0xFFF0F2F8);
final _headerBg   = const Color(0xFFFFFFFF);

// ─────────────────────────────────────────────────────────────────────────────
// MessagesScreen — root widget
// ─────────────────────────────────────────────────────────────────────────────
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    final isMobile = Responsive.isMobile(context);

    return Obx(() {
      if (controller.isLoading.value && controller.messageThreads.isEmpty) {
        return const LoadingWidget(message: 'Loading conversations…');
      }

      if (controller.errorMessage.value.isNotEmpty &&
          controller.messageThreads.isEmpty) {
        return custom_error.CustomErrorWidget(
          message: controller.errorMessage.value,
          onRetry: controller.refresh,
        );
      }

      if (isMobile) {
        return controller.selectedUserId.value.isEmpty
            ? _ConversationList(controller: controller)
            : _ConversationPane(controller: controller);
      }

      return Row(
        children: [
          // ── Left sidebar ──────────────────────────────────────────────────
          Container(
            width: _kSidebarWidth,
            color: _sidebarBg,
            child: _ConversationList(controller: controller),
          ),

          // ── Right pane ───────────────────────────────────────────────────
          Expanded(
            child: controller.selectedUserId.value.isEmpty
                ? _EmptyConversation()
                : _ConversationPane(controller: controller),
          ),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Left sidebar — list of conversation threads
// ─────────────────────────────────────────────────────────────────────────────
class _ConversationList extends StatelessWidget {
  const _ConversationList({required this.controller});
  final MessageController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SidebarHeader(controller: controller),
        Expanded(child: _ThreadListBody(controller: controller)),
      ],
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({required this.controller});
  final MessageController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
      decoration: BoxDecoration(
        color: _sidebarBg,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conversations',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1D26)),
                ),
                Obx(() {
                  final count = controller.messageThreads.length;
                  return Text(
                    '$count ${count == 1 ? "thread" : "threads"}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  );
                }),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Refresh',
            style: IconButton.styleFrom(
              backgroundColor: _surfaceBg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: controller.loadMessageThreads,
          ),
        ],
      ),
    );
  }
}

class _ThreadListBody extends StatelessWidget {
  const _ThreadListBody({required this.controller});
  final MessageController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.messageThreads.isEmpty) {
        return const EmptyStateWidget(
          message: 'No conversations yet',
          icon: Icons.inbox_outlined,
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: controller.messageThreads.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 72,
          endIndent: 16,
          color: Colors.grey.shade100,
        ),
        itemBuilder: (context, index) {
          return _ThreadTile(
            thread: controller.messageThreads[index],
            controller: controller,
          );
        },
      );
    });
  }
}

class _ThreadTile extends StatelessWidget {
  const _ThreadTile({required this.thread, required this.controller});
  final MessageThread thread;
  final MessageController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedUserId.value == thread.userId;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected
              ? _liveAccent.withValues(alpha: 0.08)
              : Colors.transparent,
          border: Border(
            left: isSelected
                ? BorderSide(color: _liveAccent, width: 3)
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
                _UserAvatar(name: thread.userName, size: 44),
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
                              thread.userName,
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
                            Formatters.formatRelativeTime(
                                thread.lastMessageAt),
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
                              thread.lastMessage,
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
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: _liveAccent,
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
      // First visit: create controller — onInit() will load history + open WS
      Get.put(
        AdminChatController(targetUserId: thread.userId),
        tag: thread.userId,
        permanent: false,
      );
    } else {
      // Returning visit: controller already alive but history may be stale.
      // Always reload from HTTP so chat body is as fresh as the thread card.
      final adminChat = Get.find<AdminChatController>(tag: thread.userId);
      adminChat.reloadHistory();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Right pane — conversation (with Live/Mail tabs inside the panel)
// ─────────────────────────────────────────────────────────────────────────────
class _ConversationPane extends StatelessWidget {
  const _ConversationPane({required this.controller});
  final MessageController controller;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Obx(() {
      final userId = controller.selectedUserId.value;
      if (userId.isEmpty) return _EmptyConversation();

      // Ensure AdminChatController exists
      if (!Get.isRegistered<AdminChatController>(tag: userId)) {
        Get.put(
          AdminChatController(targetUserId: userId),
          tag: userId,
          permanent: false,
        );
      }

      final adminChat = Get.find<AdminChatController>(tag: userId);
      final thread = controller.messageThreads.firstWhereOrNull(
        (t) => t.userId == userId,
      );

      return Container(
        color: _surfaceBg,
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            _ConversationHeader(
              thread: thread,
              adminChat: adminChat,
              controller: controller,
              isMobile: isMobile,
            ),

            // ── Tab bar (Live Chat | Mail) — placed in conversation block ─
            _ChatTabBar(adminChat: adminChat),

            // ── Message area ──────────────────────────────────────────────
            // ValueKey = fresh State (scroll + worker) per user conversation
            Expanded(
              child: _ChatBody(
                key: ValueKey(adminChat.targetUserId),
                adminChat: adminChat,
              ),
            ),

            // ── Reply box ─────────────────────────────────────────────────
            _ReplyBox(adminChat: adminChat),
          ],
        ),
      );
    });
  }
}

// ── Conversation header ───────────────────────────────────────────────────────
class _ConversationHeader extends StatelessWidget {
  const _ConversationHeader({
    required this.thread,
    required this.adminChat,
    required this.controller,
    required this.isMobile,
  });

  final MessageThread? thread;
  final AdminChatController adminChat;
  final MessageController controller;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: _headerBg,
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
          _UserAvatar(name: thread?.userName ?? 'User', size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  thread?.userName ?? 'User',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1D26),
                  ),
                ),
                const SizedBox(height: 2),
                Obx(() => Row(
                      children: [
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
                    )),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Refresh',
            style: IconButton.styleFrom(
              backgroundColor: _surfaceBg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () =>
                controller.loadUserMessages(controller.selectedUserId.value),
          ),
        ],
      ),
    );
  }
}

// ── Chat tab bar (Live / Mail toggle) ────────────────────────────────────────
class _ChatTabBar extends StatelessWidget {
  const _ChatTabBar({required this.adminChat});
  final AdminChatController adminChat;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLive = adminChat.messageTypeFilter.value == 'live';
      return Container(
        color: _headerBg,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Row(
          children: [
            _TabChip(
              label: 'Live Chat',
              icon: Icons.chat_bubble_rounded,
              isActive: isLive,
              activeColor: _liveAccent,
              onTap: () => adminChat.setMessageTypeFilter('live'),
            ),
            const SizedBox(width: 8),
            _TabChip(
              label: 'Mail',
              icon: Icons.mail_rounded,
              isActive: !isLive,
              activeColor: _mailAccent,
              onTap: () => adminChat.setMessageTypeFilter('static'),
            ),
            Obx(() {
              final liveCount = adminChat.messages
                  .where((m) => m.messageType == 'live')
                  .length;
              final mailCount = adminChat.messages
                  .where((m) => m.messageType == 'static')
                  .length;
              return Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  isLive
                      ? '$liveCount message${liveCount == 1 ? "" : "s"}'
                      : '$mailCount email${mailCount == 1 ? "" : "s"}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isActive ? activeColor : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive ? Colors.white : Colors.grey.shade500,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? Colors.white : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chat body — message list ──────────────────────────────────────────────────
class _ChatBody extends StatefulWidget {
  // Key is required! The parent passes ValueKey(userId) so Flutter creates a
  // FRESH _ChatBodyState for every new conversation — scroll + worker reset.
  const _ChatBody({super.key, required this.adminChat});
  final AdminChatController adminChat;

  @override
  State<_ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<_ChatBody> {
  final ScrollController _scroll = ScrollController();

  /// GetX worker — fires every time [messages] list mutates.
  /// Driving scroll from here is reliable because it runs OUTSIDE the build.
  Worker? _messagesWorker;

  @override
  void initState() {
    super.initState();
    _wireWorker();
    // Jump to bottom after the first frame (history is already loaded)
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
  }

  @override
  void dispose() {
    _messagesWorker?.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _wireWorker() {
    _messagesWorker?.dispose();
    final uid = widget.adminChat.targetUserId.substring(0, 8);
    print('[ChatBody:$uid] 🔗 _wireWorker: wiring ever() to messages RxList');
    _messagesWorker = ever<List<Message>>(
      widget.adminChat.messages,
      (list) {
        print('[ChatBody:$uid] 🔔 ever() fired — messages.length=${list.length} filter=${widget.adminChat.messageTypeFilter.value}');
        _scheduleJump();
      },
    );
  }

  void _scheduleJump() {
    print('[ChatBody] ⏬ _scheduleJump called — scheduling postFrameCallback');
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
  }

  void _jumpToBottom() {
    if (!_scroll.hasClients) {
      print('[ChatBody] ⚠️  _jumpToBottom: scroll has no clients yet');
      return;
    }
    try {
      final pos = _scroll.position;
      if (pos.hasContentDimensions) {
        print('[ChatBody] ⏬ jumping to bottom: maxExtent=${pos.maxScrollExtent.toStringAsFixed(0)}');
        _scroll.jumpTo(pos.maxScrollExtent);
      } else {
        print('[ChatBody] ⚠️  _jumpToBottom: no content dimensions yet');
      }
    } catch (e) {
      print('[ChatBody] ⚠️  _jumpToBottom exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _chatBg,
      child: Obx(() {
        final filter = widget.adminChat.messageTypeFilter.value;
        final all   = widget.adminChat.messages;
        final uid   = widget.adminChat.targetUserId.substring(0, 8);

        final displayed = (filter == 'all' || filter == 'live')
            ? all.where((m) => m.messageType == 'live').toList()
            : all.where((m) => m.messageType == 'static').toList();

        print('[ChatBody:$uid] 🔄 Obx rebuild — all=${all.length} filter=$filter displayed=${displayed.length}');

        if (widget.adminChat.isLoadingHistory.value && all.isEmpty) {
          print('[ChatBody:$uid] ⏳ showing loading spinner');
          return const Center(child: CircularProgressIndicator());
        }

        if (displayed.isEmpty) {
          print('[ChatBody:$uid] 📭 displayed is empty — showing empty state');
          return _EmptyChatState(isLive: filter != 'static');
        }

        print('[ChatBody:$uid] 📋 rendering ${displayed.length} bubbles (last: "${displayed.last.body.substring(0, displayed.last.body.length.clamp(0, 50))}")');

        return ListView.builder(
          controller: _scroll,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: displayed.length,
          itemBuilder: (context, index) {
            final msg  = displayed[index];
            final prev = index > 0 ? displayed[index - 1] : null;

            return Column(
              children: [
                if (_shouldShowDate(prev, msg))
                  _DateChip(date: msg.parsedCreatedAt),
                if (msg.isStaticMessage)
                  _MailBubble(msg: msg)
                else
                  _LiveBubble(msg: msg),
              ],
            );
          },
        );
      }),
    );
  }

  bool _shouldShowDate(Message? prev, Message curr) {
    if (prev == null) return true;
    final p = prev.parsedCreatedAt;
    final c = curr.parsedCreatedAt;
    return p.day != c.day || p.month != c.month || p.year != c.year;
  }
}

// ── Date chip separator ───────────────────────────────────────────────────────
class _DateChip extends StatelessWidget {
  const _DateChip({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label;
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      label = 'Today';
    } else if (date.day == now.day - 1 &&
        date.month == now.month &&
        date.year == now.year) {
      label = 'Yesterday';
    } else {
      label =
          '${date.day} ${_monthName(date.month)} ${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }

  String _monthName(int m) => const [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][m];
}

// ── Live chat bubble ──────────────────────────────────────────────────────────
class _LiveBubble extends StatelessWidget {
  const _LiveBubble({required this.msg});
  final Message msg;

  @override
  Widget build(BuildContext context) {
    final isUser = msg.isFromUser;

    return Align(
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                color: isUser ? Colors.white : _liveAccent,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(_kBubbleRadius),
                  topRight: const Radius.circular(_kBubbleRadius),
                  bottomLeft:
                      Radius.circular(isUser ? 4 : _kBubbleRadius),
                  bottomRight:
                      Radius.circular(isUser ? _kBubbleRadius : 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? Colors.black.withValues(alpha: 0.06)
                        : _liveAccent.withValues(alpha: 0.30),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (msg.attachmentUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          msg.attachmentUrl!,
                          width: 220,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 220,
                            height: 60,
                            color: Colors.grey.shade200,
                            child: const Center(
                                child: Text('Image failed to load',
                                    style: TextStyle(fontSize: 12))),
                          ),
                        ),
                      ),
                    ),
                  Text(
                    msg.body,
                    style: TextStyle(
                      color: isUser
                          ? const Color(0xFF1A1D26)
                          : Colors.white,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Formatters.formatRelativeTime(msg.parsedCreatedAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
                if (!isUser) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.isRead
                        ? Icons.done_all_rounded
                        : Icons.done_rounded,
                    size: 13,
                    color: msg.isRead ? _liveAccent : Colors.grey.shade400,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

// ── Mail bubble (static/email style) ─────────────────────────────────────────
class _MailBubble extends StatelessWidget {
  const _MailBubble({required this.msg});
  final Message msg;

  @override
  Widget build(BuildContext context) {
    final isUser = msg.isFromUser;

    return Align(
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_kRadius),
          border: Border.all(
            color: isUser
                ? Colors.grey.shade200
                : _mailAccent.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: _mailAccent.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Mail header bar ────────────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? Colors.grey.shade50
                    : _mailAccent.withValues(alpha: 0.06),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(_kRadius),
                  topRight: Radius.circular(_kRadius),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Colors.grey.shade200
                          : _mailAccent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mail_rounded,
                      size: 15,
                      color: isUser ? Colors.grey.shade600 : _mailAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Colors.grey.shade300
                                    : _mailAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isUser ? 'USER' : 'ADMIN',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: isUser
                                      ? Colors.grey.shade700
                                      : _mailAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          msg.subject ?? '(No Subject)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1D26),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Mail body ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              child: Text(
                msg.body,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Color(0xFF3B3F4E),
                ),
              ),
            ),

            // ── Mail footer ────────────────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(_kRadius),
                  bottomRight: Radius.circular(_kRadius),
                ),
                border: Border(
                  top: BorderSide(color: Colors.grey.shade100),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 12, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(
                    Formatters.formatRelativeTime(msg.parsedCreatedAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const Spacer(),
                  if (msg.isRead)
                    Row(
                      children: [
                        Icon(Icons.done_all_rounded,
                            size: 13, color: _mailAccent),
                        const SizedBox(width: 4),
                        Text(
                          'Read',
                          style: TextStyle(
                            fontSize: 10,
                            color: _mailAccent,
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
    );
  }
}

// ── Reply input box ───────────────────────────────────────────────────────────
class _ReplyBox extends StatefulWidget {
  const _ReplyBox({required this.adminChat});
  final AdminChatController adminChat;

  @override
  State<_ReplyBox> createState() => _ReplyBoxState();
}

class _ReplyBoxState extends State<_ReplyBox> {
  final _bodyCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _bodyCtrl.dispose();
    _subjectCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _bodyCtrl.text.trim();
    if (text.isEmpty) return;
    final isLive =
        widget.adminChat.messageTypeFilter.value == 'live';

    widget.adminChat
        .sendMessage(
          body: text,
          messageType: isLive ? 'live' : 'static',
          subject: isLive ? null : _subjectCtrl.text.trim(),
        )
        .then((_) {
      _bodyCtrl.clear();
      _subjectCtrl.clear();
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLive =
          widget.adminChat.messageTypeFilter.value == 'live';
      final accent = isLive ? _liveAccent : _mailAccent;

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: _headerBg,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subject row — only for mail
            if (!isLive)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _mailAccent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Subject',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _mailAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _subjectCtrl,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Enter email subject…',
                          hintStyle: TextStyle(
                              color: Colors.grey.shade400, fontSize: 13),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: accent, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Message row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    decoration: BoxDecoration(
                      color: _surfaceBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _bodyCtrl,
                      focusNode: _focusNode,
                      maxLines: null,
                      maxLength: 1000,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: isLive
                            ? 'Send a live message…'
                            : 'Compose email body…',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        counterText: '',
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Obx(() => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: widget.adminChat.isSending.value
                            ? Colors.grey.shade300
                            : accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: widget.adminChat.isSending.value
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : IconButton(
                              icon: const Icon(Icons.send_rounded,
                                  size: 20, color: Colors.white),
                              onPressed: _send,
                              padding: EdgeInsets.zero,
                            ),
                    )),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyConversation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: _surfaceBg,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _liveAccent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chat_bubble_outline_rounded,
                  size: 48, color: _liveAccent.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select a conversation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose a thread from the left panel to start',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState({required this.isLive});
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (isLive ? _liveAccent : _mailAccent)
                  .withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLive
                  ? Icons.chat_bubble_outline_rounded
                  : Icons.mail_outline_rounded,
              size: 40,
              color: (isLive ? _liveAccent : _mailAccent)
                  .withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isLive ? 'No live messages yet' : 'No emails yet',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isLive
                ? 'Messages will appear here in real-time'
                : 'Formal emails will show here',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.name, required this.size});
  final String name;
  final double size;

  static const _palette = [
    Color(0xFF4F8EF7),
    Color(0xFF7C5CBF),
    Color(0xFF43C6AC),
    Color(0xFFFF6B6B),
    Color(0xFFFFB347),
  ];

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    final color = _palette[name.codeUnitAt(0) % _palette.length];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: size * 0.38,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}
