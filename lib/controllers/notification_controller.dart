import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/device.dart';

class NotificationController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<Device> devices = <Device>[].obs;
  final Rx<DeviceStats?> deviceStats = Rx<DeviceStats?>(null);
  final RxInt totalDevices = 0.obs;
  final RxBool activeOnly = true.obs;

  final RxString searchQuery = ''.obs;
  final RxString selectedDeviceType = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadDevices();
    loadDeviceStats();
  }

  List<Device> get filteredDevices {
    var filtered = devices.toList();

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((device) {
        return (device.userName?.toLowerCase().contains(query) ?? false) ||
            (device.userEmail?.toLowerCase().contains(query) ?? false) ||
            device.deviceType.toLowerCase().contains(query) ||
            (device.deviceName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (selectedDeviceType.value != 'all') {
      filtered = filtered.where((device) {
        return device.deviceType.toLowerCase() == selectedDeviceType.value.toLowerCase();
      }).toList();
    }

    return filtered;
  }

  Future<void> loadDevices() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiService.getAllDevices(
        activeOnly: activeOnly.value,
        limit: 500,
      );

      final deviceList = response['devices'] as List<dynamic>? ?? [];
      totalDevices.value = response['total'] ?? deviceList.length;

      devices.value = deviceList.map((json) => Device.fromJson(json)).toList();
    } on SessionExpiredException {
      return;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDeviceStats() async {
    try {
      final response = await _apiService.getDeviceStats();
      deviceStats.value = DeviceStats.fromJson(response);
    } on SessionExpiredException {
      return;
    } catch (e) {
    }
  }

  Future<NotificationResponse?> sendNotification({
    String? userId,
    List<String>? userIds,
    required String title,
    required String body,
    String? imageUrl,
    Map<String, dynamic>? data,
  }) async {
    try {
      isSending.value = true;
      errorMessage.value = '';

      final response = imageUrl != null
          ? await _apiService.sendNotificationWithImage(
              userId: userId,
              userIds: userIds,
              title: title,
              body: body,
              imageUrl: imageUrl,
              data: data,
            )
          : await _apiService.sendNotification(
              userId: userId,
              userIds: userIds,
              title: title,
              body: body,
              data: data,
            );

      return NotificationResponse.fromJson(response);
    } on SessionExpiredException {
      return null;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      isSending.value = false;
    }
  }

  Future<NotificationResponse?> sendBroadcast({
    required String title,
    required String body,
    String? imageUrl,
    Map<String, dynamic>? data,
  }) async {
    try {
      isSending.value = true;
      errorMessage.value = '';

      final response = imageUrl != null
          ? await _apiService.broadcastWithImage(
              title: title,
              body: body,
              imageUrl: imageUrl,
              data: data,
            )
          : await _apiService.sendBroadcast(
              title: title,
              body: body,
              data: data,
            );

      return NotificationResponse.fromJson(response);
    } on SessionExpiredException {
      return null;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      isSending.value = false;
    }
  }

  Future<bool> deleteDevice(String deviceId) async {
    try {
      await _apiService.deleteDevice(deviceId);
      devices.removeWhere((d) => d.id == deviceId);
      await loadDeviceStats();
      return true;
    } on SessionExpiredException {
      return false;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      return false;
    }
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setDeviceTypeFilter(String type) {
    selectedDeviceType.value = type;
  }

  void toggleActiveOnly() {
    activeOnly.value = !activeOnly.value;
    loadDevices();
  }

  void refresh() {
    loadDevices();
    loadDeviceStats();
  }
}
