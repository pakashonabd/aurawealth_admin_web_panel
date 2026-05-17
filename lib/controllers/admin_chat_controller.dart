import 'dart:async';
import 'package:get/get.dart';
import '../models/message.dart';
import '../services/firestore_admin_chat_service.dart';

/// Admin-side realtime chat controller backed by Cloud Firestore streams.
class AdminChatController extends GetxController {
  AdminChatController({
    required this.targetUserId,
    FirestoreAdminChatService? chatService,
  }) : _chatService = chatService ?? FirestoreAdminChatService();

  final String targetUserId;
  final FirestoreAdminChatService _chatService;

  final messages = <Message>[].obs;
  final isConnected = false.obs;
  final isLoadingHistory = false.obs;
  final isSending = false.obs;
  final messageTypeFilter = 'live'.obs;
  final unreadCount = 0.obs;

  StreamSubscription<List<Message>>? _messagesSub;

  @override
  void onInit() {
    super.onInit();
    _boot();
  }

  @override
  void onClose() {
    _messagesSub?.cancel();
    super.onClose();
  }

  Future<void> _boot() async {
    await reloadHistory();
    _subscribe();
    unawaited(_chatService.markUserMessagesRead(targetUserId));
  }

  Future<void> reloadHistory() async {
    isLoadingHistory.value = true;
    try {
      final loaded = await _chatService.loadRecentMessages(targetUserId, limit: 1000);
      _setMessages(loaded);
      _recomputeUnread();
      _log('Firestore history loaded: ${loaded.length} messages');
    } catch (e, st) {
      _log('Firestore history load failed: $e');
      _log('$st');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  void _subscribe() {
    _messagesSub?.cancel();
    _messagesSub = _chatService.watchMessages(targetUserId).listen(
      (incoming) {
        isConnected.value = true;
        _setMessages(incoming);
        _recomputeUnread();
        unawaited(_chatService.markUserMessagesRead(targetUserId));
      },
      onError: (e) {
        isConnected.value = false;
        _log('Firestore stream error: $e');
      },
    );
  }

  Future<void> sendMessage({
    required String body,
    String messageType = 'live',
    String? subject,
  }) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      Get.snackbar('Validation', 'Message body cannot be empty');
      return;
    }
    if (messageType == 'static' && (subject == null || subject.trim().isEmpty)) {
      Get.snackbar('Validation', 'Subject is required for formal messages');
      return;
    }

    isSending.value = true;
    try {
      await _chatService.sendAdminMessage(
        userId: targetUserId,
        content: trimmed,
        messageType: messageType,
        subject: subject,
      );
    } catch (e) {
      _log('sendMessage failed: $e');
      Get.snackbar('Error', 'Failed to send message: $e',
          duration: const Duration(seconds: 3));
    } finally {
      isSending.value = false;
    }
  }

  void _setMessages(List<Message> loaded) {
    loaded.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    messages.assignAll(loaded);
  }

  void _recomputeUnread() {
    unreadCount.value = messages
        .where((m) => m.direction == 'user_to_admin' && !m.isRead)
        .length;
  }

  List<Message> get filteredMessages {
    final f = messageTypeFilter.value;
    if (f == 'all') return messages.toList();
    return messages.where((m) => m.messageType == f).toList();
  }

  void setMessageTypeFilter(String type) {
    messageTypeFilter.value = type;
  }

  void clearUnreadCount() => unreadCount.value = 0;

  void _log(String msg) {
    final prefix = targetUserId.length >= 8 ? targetUserId.substring(0, 8) : targetUserId;
    // ignore: avoid_print
    print('[AdminChat:$prefix] $msg');
  }
}
