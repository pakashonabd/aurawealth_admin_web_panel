import '../constants/app_constants.dart';

class ApiConfig {
  /// Constructs the WebSocket URL for admin chat with a target user
  /// Admin endpoint: WS /ws/admin/chat/{user_id}?token=<admin_jwt>
  /// [userId] = backend UUID of the user
  /// [adminToken] = admin's bearer token (NOT Firebase token)
  static String adminChatWebSocketUrl(String userId, String adminToken) {
    final baseUrl = AppConstants.baseUrl
        .replaceAll('https://', 'wss://')
        .replaceAll('http://', 'ws://');
    return '$baseUrl/ws/admin/chat/$userId?token=$adminToken';
  }

  /// Get admin chat history — explicit limit=1000 to override server default of 50
  static String adminChatHistoryUrl(String userId) {
    return '${AppConstants.baseUrl}/admin/chat/history/$userId?limit=1000';
  }

  /// Send message to user (REST fallback)
  /// POST /admin/chat/send/{user_id}
  static String adminChatSendUrl(String userId) {
    return '${AppConstants.baseUrl}/admin/chat/send/$userId';
  }

  /// Get admin inbox overview
  /// GET /admin/chat/inbox
  static String adminChatInboxUrl() {
    return '${AppConstants.baseUrl}/admin/chat/inbox';
  }

  /// Mark thread as read
  /// POST /admin/chat/read/{user_id}
  static String adminChatReadUrl(String userId) {
    return '${AppConstants.baseUrl}/admin/chat/read/$userId';
  }
}

