// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../routes/app_routes.dart';
import 'storage_service.dart';

/// Registers the admin panel's FCM token so the backend can notify admins when
/// users write new Firestore chat messages.
class AdminFcmService {
  AdminFcmService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final StorageService _storage = StorageService();

  static Future<void> initialize() async {
    try {
      print('[AdminFCM] initialize() started');
      print(
        '[AdminFCM] Firebase apps initialized count: ${Firebase.apps.length}',
      );
      print(
        '[AdminFCM] Firebase default app available before FCM init: '
        '${Firebase.apps.isNotEmpty}',
      );
      final currentUri = Uri.base;
      final isSecureFcmOrigin =
          currentUri.scheme == 'https' ||
          currentUri.host == 'localhost' ||
          currentUri.host == '127.0.0.1';
      print('[AdminFCM] Current page URL for Web FCM: $currentUri');
      print(
        '[AdminFCM] Web FCM secure origin check: '
        'scheme=${currentUri.scheme}, host=${currentUri.host}, '
        'allowed=$isSecureFcmOrigin '
        '(must be HTTPS or localhost/127.0.0.1)',
      );
      final authToken = _storage.getAuthToken();
      print(
        '[AdminFCM] Auth token available before FCM registration: '
        '${authToken != null && authToken.isNotEmpty}',
      );

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      print('[AdminFCM] Permission: ${settings.authorizationStatus}');

      String? token;
      try {
        token = await FirebaseMessaging.instance.getToken(
          vapidKey:
              'BDUiGW559E7LUJ5PZMIcvJxBAmwpPEpCRfu3Emj8Xg6B5SfJNL5Yt667Ms3qubMzA8lrMbcnQ5yhHaYb60Imnfw',
        );
        print('[AdminFCM] Raw FCM getToken() value: $token');
      } catch (e, stackTrace) {
        print('[AdminFCM] getToken() error: $e');
        print('[AdminFCM] getToken() stack trace: $stackTrace');
        rethrow;
      }
      print(
        '[AdminFCM] Device token adding decision: '
        '${token != null && token.isNotEmpty ? 'will add/send token to backend' : 'will NOT add/send token because token is null/empty'}',
      );
      if (token == null || token.isEmpty) {
        print('[AdminFCM] No FCM token available');
        return;
      }

      print('[AdminFCM] About to send/add device token to backend');
      await _registerToken(token);
      FirebaseMessaging.instance.onTokenRefresh.listen(
        (refreshedToken) {
          print('[AdminFCM] Token refreshed: $refreshedToken');
          _registerToken(refreshedToken);
        },
        onError: (Object error, StackTrace stackTrace) {
          print('[AdminFCM] Token refresh listener error: $error');
          print('[AdminFCM] Token refresh listener stack trace: $stackTrace');
        },
      );

      FirebaseMessaging.onMessage.listen((message) {
        _showAdminMessagePopup(message);
      });
      print('[AdminFCM] initialize() completed');
    } catch (e, stackTrace) {
      print('[AdminFCM] Initialization skipped/failed: $e');
      print('[AdminFCM] Initialization stack trace: $stackTrace');
    }
  }

  static void _showAdminMessagePopup(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    final userName = _firstNonEmpty(data, const [
      'userName',
      'user_name',
      'senderName',
      'sender_name',
      'name',
      'displayName',
      'display_name',
      'title',
    ], fallback: notification?.title ?? 'Customer');
    final phoneNumber = _firstNonEmpty(data, const [
      'phoneNumber',
      'phone_number',
      'phone',
      'mobile',
      'mobileNumber',
      'mobile_number',
      'contact',
      'number',
    ]);
    final body = _firstNonEmpty(data, const [
      'message',
      'body',
      'content',
      'text',
      'lastMessage',
      'last_message',
    ], fallback: notification?.body ?? 'New message received');

    final cleanUserName = _cleanGenericTitle(userName);
    final displayName = cleanUserName.isEmpty ? 'Customer' : cleanUserName;
    final displayPhone = phoneNumber.isEmpty
        ? 'No number provided'
        : phoneNumber;
    final displayBody = body.isEmpty ? 'New message received' : body;

    if (Get.isDialogOpen == true) {
      Get.back<void>();
    }

    Get.dialog<void>(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460, minWidth: 360),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            elevation: 24,
            shadowColor: Colors.black.withValues(alpha: 0.22),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE8EEF8)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF4FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.chat_bubble_rounded,
                          color: Color(0xFF1565C0),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'New customer message',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Get.back<void>(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.phone_rounded,
                          color: Color(0xFF2563EB),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            displayPhone,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Message',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    displayBody,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 15.5,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back<void>(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                          child: const Text('Dismiss'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.back<void>();
                            Get.toNamed(AppRoutes.messages);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.open_in_new_rounded, size: 18),
                          label: const Text('Open chat'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.26),
    );
  }

  static String _firstNonEmpty(
    Map<String, dynamic> data,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = data[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return fallback.trim();
  }

  static String _cleanGenericTitle(String value) {
    final trimmed = value.trim();
    final lower = trimmed.toLowerCase();
    if (lower == 'message from user' ||
        lower == 'new message' ||
        lower == 'aurawealth') {
      return '';
    }
    return trimmed;
  }

  static Future<void> _registerToken(String token) async {
    final url = Uri.parse('${AppConstants.baseUrl}/admin/fcm-token');
    final authToken = _storage.getAuthToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (authToken != null && authToken.isNotEmpty)
        'Authorization': 'Bearer $authToken',
    };
    final body = <String, dynamic>{
      'token': token,
      'device_name': 'admin_panel',
    };
    final encodedBody = json.encode(body);

    try {
      print('[AdminFCM] POST /admin/fcm-token request URL: $url');
      print(
        '[AdminFCM] POST /admin/fcm-token request headers: '
        '${_redactSensitiveHeaders(headers)}',
      );
      print('[AdminFCM] POST /admin/fcm-token request body: $encodedBody');

      print('[AdminFCM] HTTP POST is being made now');
      final response = await http
          .post(url, headers: headers, body: encodedBody)
          .timeout(Duration(seconds: AppConstants.apiTimeout));
      print('[AdminFCM] HTTP POST completed');

      print(
        '[AdminFCM] POST /admin/fcm-token response status: '
        '${response.statusCode}',
      );
      print(
        '[AdminFCM] POST /admin/fcm-token response headers: '
        '${response.headers}',
      );
      print(
        '[AdminFCM] POST /admin/fcm-token response body: '
        '${response.body}',
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'POST /admin/fcm-token failed with HTTP ${response.statusCode}: '
          '${response.body}',
        );
      }

      print('[AdminFCM] Admin FCM token registered: $token');
    } catch (e, stackTrace) {
      print('[AdminFCM] Token registration failed: $e');
      print('[AdminFCM] Token registration stack trace: $stackTrace');
    }
  }

  static Map<String, String> _redactSensitiveHeaders(
    Map<String, String> headers,
  ) {
    return headers.map((key, value) {
      if (key.toLowerCase() == 'authorization') {
        return MapEntry(key, _redactBearerToken(value));
      }
      return MapEntry(key, value);
    });
  }

  static String _redactBearerToken(String value) {
    const prefix = 'Bearer ';
    if (!value.startsWith(prefix)) return '[redacted]';

    final token = value.substring(prefix.length);
    if (token.length <= 12) return 'Bearer [redacted]';

    return 'Bearer ${token.substring(0, 6)}...${token.substring(token.length - 4)}';
  }
}
