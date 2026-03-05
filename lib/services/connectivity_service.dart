import 'package:http/http.dart' as http;
import 'dart:async';
import '../core/constants/app_constants.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  /// Check if the API server is reachable
  Future<bool> checkApiConnection() async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/health');
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => http.Response('Timeout', 408),
      );

      // Consider any response (even error) as connected
      // We just want to know if we can reach the server
      return response.statusCode != 408;
    } catch (e) {
      return false;
    }
  }

  /// Get a user-friendly connectivity status message
  Future<String> getConnectionStatus() async {
    final isConnected = await checkApiConnection();
    if (isConnected) {
      return 'Connected to API server';
    } else {
      return 'Cannot reach API server at ${AppConstants.baseUrl}';
    }
  }
}

