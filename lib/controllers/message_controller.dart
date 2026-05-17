import 'dart:async';
import 'package:get/get.dart';
import '../models/message.dart';
import '../models/message_thread.dart';
import '../models/user.dart';
import '../services/firestore_admin_chat_service.dart';
import 'user_controller.dart';

class MessageController extends GetxController {
  final FirestoreAdminChatService _chatService = FirestoreAdminChatService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<MessageThread> messageThreads = <MessageThread>[].obs;
  final RxList<Message> currentThreadMessages = <Message>[].obs;
  final RxString selectedUserId = ''.obs;
  final RxBool isSendingMessage = false.obs;

  StreamSubscription<List<MessageThread>>? _threadsSub;

  @override
  void onInit() {
    super.onInit();
    _ensureUserController();
    loadMessageThreads();
    _subscribeThreads();
  }

  @override
  void onClose() {
    _threadsSub?.cancel();
    super.onClose();
  }

  UserController? _ensureUserController() {
    if (!Get.isRegistered<UserController>()) {
      Get.lazyPut<UserController>(() => UserController(), fenix: true);
    }
    return Get.find<UserController>();
  }

  User? userForThread(MessageThread thread) {
    final userController = _ensureUserController();
    return userController?.findUser(thread.userId);
  }

  MessageThread _enrichThread(MessageThread thread) {
    final user = userForThread(thread);
    if (user == null) return thread;

    final currentName = thread.userName.trim().toLowerCase();
    final shouldReplaceName =
        currentName.isEmpty ||
        currentName == 'user' ||
        currentName == 'unknown user' ||
        currentName == 'demo user';

    return thread.copyWith(
      userId: user.backendId ?? thread.userId,
      userName: shouldReplaceName ? user.displayName : thread.userName,
      userEmail: thread.userEmail ?? user.email,
      phoneNumber: thread.phoneNumber ?? user.phoneNumber,
      photoUrl: thread.photoUrl ?? user.photoUrl,
    );
  }

  Future<void> _ensureUsersLoaded() async {
    final userController = _ensureUserController();
    if (userController == null) return;
    if (userController.users.isNotEmpty || userController.isLoading.value) {
      return;
    }
    await userController.loadUsers();
  }

  String displayNameForThread(MessageThread thread) {
    final user = userForThread(thread);
    if (user != null) return user.displayName;
    final name = thread.userName.trim();
    if (name.isNotEmpty &&
        name.toLowerCase() != 'unknown user' &&
        name.toLowerCase() != 'demo user') {
      return name;
    }
    return thread.userId.isNotEmpty
        ? 'User ${thread.userId.substring(0, thread.userId.length.clamp(0, 8))}'
        : 'User';
  }

  String? secondaryInfoForThread(MessageThread thread) {
    final user = userForThread(thread);
    return user?.phoneNumber ??
        user?.email ??
        thread.phoneNumber ??
        thread.userEmail;
  }

  String? photoUrlForThread(MessageThread thread) {
    final user = userForThread(thread);
    return user?.photoUrl ?? thread.photoUrl;
  }

  void _subscribeThreads() {
    _threadsSub?.cancel();
    _threadsSub = _chatService.watchThreads().listen(
      (threads) async {
        await _ensureUsersLoaded();
        messageThreads.assignAll(threads.map(_enrichThread).toList());
      },
      onError: (e) {
        errorMessage.value = e.toString().replaceAll('Exception: ', '');
      },
    );
  }

  Future<void> loadMessageThreads() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _ensureUsersLoaded();
      final threads = await _chatService.loadThreads();
      messageThreads.assignAll(threads.map(_enrichThread).toList());
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserMessages(String userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      selectedUserId.value = userId;

      currentThreadMessages.value = await _chatService.loadRecentMessages(userId);
      await _chatService.markUserMessagesRead(userId);
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendReply(String userId, String message) async {
    try {
      isSendingMessage.value = true;
      errorMessage.value = '';

      await _chatService.sendAdminMessage(
        userId: userId,
        content: message,
        messageType: 'live',
      );

      Get.snackbar('Success', 'Reply sent successfully');
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isSendingMessage.value = false;
    }
  }

  void refresh() {
    if (selectedUserId.value.isNotEmpty) {
      loadUserMessages(selectedUserId.value);
    } else {
      loadMessageThreads();
    }
  }
}
