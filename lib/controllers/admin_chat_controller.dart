import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/config/api_config.dart';
import '../core/constants/app_constants.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

/// Admin-side real-time chat controller for a specific user conversation.
class AdminChatController extends GetxController {
  AdminChatController({required this.targetUserId})
      : _api = ApiService(),
        _storage = StorageService();

  final String targetUserId;
  final ApiService _api;
  final StorageService _storage;

  // ── Public reactive state ─────────────────────────────────────────────────
  final messages          = <Message>[].obs;
  final isConnected       = false.obs;
  final isLoadingHistory  = false.obs;
  final isSending         = false.obs;
  final messageTypeFilter = 'live'.obs;
  final unreadCount       = 0.obs;

  // ── Internal ─────────────────────────────────────────────────────────────
  WebSocketChannel?            _channel;
  StreamSubscription<dynamic>? _wsSub;
  Timer?                       _reconnectTimer;
  Timer?                       _pollTimer;        // ← polling fallback
  int                          _reconnectDelay = 2;
  bool                         _manualClose    = false;

  /// Polling interval — 2 s feels near-real-time for user→admin messages
  static const Duration _pollInterval = Duration(seconds: 2);

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _log('🆕 Created for user: $targetUserId');
    _boot();
  }

  @override
  void onClose() {
    _log('🗑️  Disposing for user: $targetUserId');
    _manualClose = true;
    _pollTimer?.cancel();
    _reconnectTimer?.cancel();
    _wsSub?.cancel();
    _channel?.sink.close();
    _channel = null;
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Boot
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _boot() async {
    _log('🚀 Boot started');
    await reloadHistory();
    _log('🚀 History done, opening WebSocket + starting poll…');
    unawaited(_connectWs());
    _startPolling();
  }

  // ─────────────────────────────────────────────────────────────
  // Smart polling — runs every 5 s as a guaranteed real-time fallback
  // The WebSocket gives instant delivery when the server supports it;
  // polling guarantees new messages appear within 5 s regardless.
  // ─────────────────────────────────────────────────────────────

  void _startPolling() {
    _pollTimer?.cancel();
    _log('⏱️  Polling started — interval=${_pollInterval.inSeconds}s');
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      if (!_manualClose) unawaited(_pollNewMessages());
    });
  }

  /// Efficient poll: just request offset=current to detect any new message.
  /// Only does a full paginated reload when new data is actually found.
  Future<void> _pollNewMessages() async {
    final knownCount = messages.length;
    if (knownCount == 0) return; // not loaded yet

    try {
      final base = '${AppConstants.baseUrl}/admin/chat/history/$targetUserId';
      // Request 1 message starting at the current count.
      // If we get anything back, new messages exist → do full reload.
      final probeUrl = '$base?limit=1&offset=$knownCount';
      final res = await _api.get(probeUrl);

      List<dynamic> rawList;
      if (res is List) {
        rawList = res;
      } else if (res is Map && res.containsKey('messages')) {
        rawList = res['messages'] as List<dynamic>;
      } else {
        rawList = [];
      }

      if (rawList.isNotEmpty) {
        _log('⏱️  Poll detected ${rawList.length} new message(s) at offset=$knownCount — reloading…');
        await reloadHistory();
      } else {
        // No new messages — silent, no log spam
      }
    } catch (e) {
      _log('⚠️  Poll probe failed (will retry in ${_pollInterval.inSeconds}s): $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REST History — paginated to get ALL messages regardless of server cap
  // ─────────────────────────────────────────────────────────────────────────

  static const int _pageSize = 50; // match server's hard cap

  /// Paginates through ALL pages (offset=0, 50, 100, …) until a page returns
  /// fewer than [_pageSize] records — which signals end-of-data.
  /// This defeats the server's hard cap of 50 messages per call.
  Future<void> reloadHistory() async {
    _log('📥 reloadHistory() PAGINATED — current messages.length=${messages.length}');
    isLoadingHistory.value = true;

    try {
      final base = '${AppConstants.baseUrl}/admin/chat/history/$targetUserId';
      final allMessages = <Message>[];
      int offset = 0;
      int page   = 1;

      while (true) {
        final url = '$base?limit=$_pageSize&offset=$offset';
        _log('📥 Page $page → GET $url');

        final res = await _api.get(url);

        List<dynamic> rawList;
        if (res is List) {
          rawList = res;
        } else if (res is Map && res.containsKey('messages')) {
          rawList = res['messages'] as List<dynamic>;
        } else {
          _log('⚠️  Page $page — unexpected response shape: ${res.runtimeType}');
          break;
        }

        _log('📥 Page $page → ${rawList.length} records (offset=$offset)');

        if (rawList.isNotEmpty) {
          final pageMessages = rawList
              .map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList();
          allMessages.addAll(pageMessages);
          _log('📥 Page $page → cumulative total: ${allMessages.length}');
        }

        // If we got fewer than pageSize, this is the last page
        if (rawList.length < _pageSize) {
          _log('📥 Page $page is the last page (${rawList.length} < $_pageSize) — done');
          break;
        }

        offset += _pageSize;
        page++;

        // Safety: never exceed 2000 messages (40 pages) to prevent runaway
        if (allMessages.length >= 2000) {
          _log('⚠️  Safety cap hit at ${allMessages.length} messages — stopping pagination');
          break;
        }
      }

      _log('📥 Total fetched: ${allMessages.length} messages across $page page(s)');

      if (allMessages.isNotEmpty) {
        _log('📥 First: "${allMessages.first.body.substring(0, allMessages.first.body.length.clamp(0, 60))}" @ ${allMessages.first.createdAt}');
        _log('📥 Last:  "${allMessages.last.body.substring(0, allMessages.last.body.length.clamp(0, 60))}" @ ${allMessages.last.createdAt}');
      }

      _setMessages(allMessages);

      _log('✅ messages.length after set: ${messages.length}');
      _log('✅ live count:   ${messages.where((m) => m.messageType == "live").length}');
      _log('✅ static count: ${messages.where((m) => m.messageType == "static").length}');
    } catch (e, st) {
      _log('❌ reloadHistory FAILED: $e');
      _log('❌ Stack: $st');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // WebSocket
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _connectWs() async {
    if (_manualClose) return;

    final token = _storage.getAuthToken();
    if (token == null || token.isEmpty) {
      _log('❌ WS: No admin bearer token — skipping WebSocket');
      _scheduleReconnect();
      return;
    }

    final wsUrl = ApiConfig.adminChatWebSocketUrl(targetUserId, token);
    _log('🔌 WS connecting → ${wsUrl.replaceAll(token, "***")}');

    try {
      await _wsSub?.cancel();
      _wsSub = null;
      _channel?.sink.close();
      _channel = null;

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _wsSub = _channel!.stream.listen(
        _onEvent,
        onError: (e) {
          _log('❌ WS stream error: $e');
          isConnected.value = false;
          if (!_manualClose) _scheduleReconnect();
        },
        onDone: () {
          _log('⚠️  WS stream closed (closeCode=${_channel?.closeCode})');
          isConnected.value = false;
          if (!_manualClose) _scheduleReconnect();
        },
        cancelOnError: false,
      );

      await _channel!.ready;
      isConnected.value = true;
      _reconnectDelay = 2;
      _log('✅ WS connected — waiting for server events');
    } catch (e) {
      _log('❌ WS connection failed: $e');
      isConnected.value = false;
      _scheduleReconnect();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // WS Event handler
  // ─────────────────────────────────────────────────────────────────────────

  void _onEvent(dynamic raw) {
    _log('📨 WS raw event received (type=${raw.runtimeType}, len=${raw.toString().length})');

    if (raw is! String) {
      _log('⚠️  Non-string WS event ignored');
      return;
    }

    try {
      final data  = jsonDecode(raw) as Map<String, dynamic>;
      final event = data['event'] as String? ?? 'unknown';
      _log('📨 WS event name: "$event"');
      _log('📨 WS full payload: $raw');

      switch (event) {
        case 'init':
          final list = (data['messages'] as List?)
                  ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [];
          _log('📨 [init] ${list.length} messages from WS (server may cap this at 50)');
          _mergeMessages(list);
          _log('📨 [init] messages.length after merge: ${messages.length}');

          // WS init is ALSO server-capped at 50. Always do a REST reload right
          // after init to pick up any messages sent while WS was disconnected.
          _log('📨 [init] Triggering REST reload to fill any gap beyond WS init cap…');
          unawaited(reloadHistory());

        case 'message':
          final msgData = data['message'] as Map<String, dynamic>?;
          if (msgData == null) {
            _log('⚠️  [message] event has no "message" key — payload: $raw');
            break;
          }
          final msg = Message.fromJson(msgData);
          _log('📩 [message] NEW msg → id=${msg.id} type=${msg.messageType} dir=${msg.direction}');
          _log('📩 [message] body="${msg.body.substring(0, msg.body.length.clamp(0, 80))}"');
          _log('📩 [message] messages.length BEFORE insert: ${messages.length}');
          _insertMessage(msg);
          _log('📩 [message] messages.length AFTER  insert: ${messages.length}');
          if (msg.isFromUser) unreadCount.value++;

        case 'sent':
          final msgData = data['message'] as Map<String, dynamic>?;
          if (msgData == null) {
            _log('⚠️  [sent] event has no "message" key');
            break;
          }
          final confirmed = Message.fromJson(msgData);
          _log('✅ [sent] confirmed → id=${confirmed.id}');
          _replaceOldestTemp(confirmed);

        case 'message_read':
          _log('👁️  [message_read] marking all outbound as read');
          _markAllOutboundRead();

        case 'error':
          final detail = (data['meta'] as Map?)?['detail']?.toString() ?? 'Unknown WS error';
          _log('⚠️  [error] server error: $detail');
          Get.snackbar('Chat Error', detail, duration: const Duration(seconds: 3));

        default:
          _log('ℹ️  Unknown WS event: "$event" — full payload: $raw');
      }
    } catch (e, st) {
      _log('❌ Failed to parse WS event: $e');
      _log('❌ Raw was: $raw');
      _log('❌ Stack: $st');
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    final delay = _reconnectDelay;
    _reconnectDelay = (_reconnectDelay * 2).clamp(2, 64);
    _log('⏰ WS reconnect in ${delay}s (next backoff: ${_reconnectDelay}s)');
    _reconnectTimer = Timer(Duration(seconds: delay), () {
      if (!_manualClose) {
        _log('🔄 Attempting WS reconnect…');
        unawaited(_connectWs());
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Send
  // ─────────────────────────────────────────────────────────────────────────

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
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    _log('📤 sendMessage tempId=$tempId type=$messageType isConnected=${isConnected.value}');

    _insertMessage(Message(
      id: tempId,
      direction: 'admin_to_user',
      messageType: messageType,
      subject: subject,
      body: trimmed,
      attachmentUrl: null,
      isRead: false,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    ));

    try {
      if (isConnected.value && _channel != null) {
        _log('📤 Sending via WebSocket');
        _channel!.sink.add(jsonEncode({
          'message_type': messageType,
          'subject': subject,
          'body': trimmed,
          'attachment_url': null,
        }));
      } else {
        _log('📤 WS down — using HTTP fallback');
        final sendUrl = ApiConfig.adminChatSendUrl(targetUserId);
        await _api.post(sendUrl, {
          'message_type': messageType,
          'body': trimmed,
          'subject': subject,
        });
        _log('📤 HTTP fallback sent OK');
      }
    } catch (e) {
      _log('❌ sendMessage failed: $e');
      Get.snackbar('Error', 'Failed to send message: $e',
          duration: const Duration(seconds: 3));
    } finally {
      isSending.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Message list helpers
  // ─────────────────────────────────────────────────────────────────────────

  void _setMessages(List<Message> loaded) {
    loaded.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _log('🔄 _setMessages: replacing ${messages.length} → ${loaded.length} messages');
    messages.assignAll(loaded);
    _log('🔄 _setMessages: messages.length is now ${messages.length}');
  }

  void _insertMessage(Message msg) {
    final idx = messages.indexWhere((m) => m.id == msg.id);
    if (idx == -1) {
      _log('➕ _insertMessage: adding new msg id=${msg.id}');
      messages.add(msg);
    } else {
      _log('♻️  _insertMessage: replacing existing msg at idx=$idx id=${msg.id}');
      messages[idx] = msg;
      messages.refresh();
    }
    _log('➕ messages.length after insert: ${messages.length}');
  }

  void _mergeMessages(List<Message> incoming) {
    if (incoming.isEmpty) {
      _log('⚠️  _mergeMessages: incoming is empty, skipping');
      return;
    }
    _log('🔀 _mergeMessages: merging ${incoming.length} into ${messages.length}');
    final map = <String, Message>{for (final m in messages) m.id: m};
    for (final m in incoming) map[m.id] = m;
    final sorted = map.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    messages.assignAll(sorted);
    _log('🔀 _mergeMessages: result=${messages.length} messages');
  }

  void _replaceOldestTemp(Message confirmed) {
    final tempIdx = messages.indexWhere(
        (m) => m.id.startsWith('temp_') || m.id.startsWith('img_'));
    if (tempIdx != -1) {
      _log('♻️  _replaceOldestTemp: replacing temp at $tempIdx with confirmed id=${confirmed.id}');
      messages[tempIdx] = confirmed;
    } else {
      final idx = messages.indexWhere((m) => m.id == confirmed.id);
      if (idx != -1) {
        messages[idx] = confirmed;
      } else {
        messages.add(confirmed);
      }
    }
  }

  void _markAllOutboundRead() {
    final updated = messages.map((m) {
      if (m.direction == 'admin_to_user' && !m.isRead) {
        return Message(
          id: m.id,
          direction: m.direction,
          messageType: m.messageType,
          subject: m.subject,
          body: m.body,
          attachmentUrl: m.attachmentUrl,
          isRead: true,
          createdAt: m.createdAt,
        );
      }
      return m;
    }).toList();
    messages.assignAll(updated);
  }

  List<Message> get filteredMessages {
    final f = messageTypeFilter.value;
    if (f == 'all') return messages.toList();
    return messages.where((m) => m.messageType == f).toList();
  }

  void setMessageTypeFilter(String type) {
    _log('🔍 setMessageTypeFilter: $type');
    messageTypeFilter.value = type;
  }

  void clearUnreadCount() => unreadCount.value = 0;

  // ─────────────────────────────────────────────────────────────────────────
  // Logging helper
  // ─────────────────────────────────────────────────────────────────────────
  void _log(String msg) {
    // ignore: avoid_print
    print('[AdminChat:${targetUserId.substring(0, 8)}] $msg');
  }
}
