class ApiEndpoints {
  // Admin Authentication
  static const String adminLogin = '/admin/login';

  // Admin Dashboard
  static const String adminDashboard = '/admin/dashboard';

  // Gold Price Management
  static const String setPrice = '/admin/set-price';
  static const String getPrice = '/admin/get-price';

  // Transaction Management
  static String adminBuyCredit = '/admin/buy/credit';
  static String adminRedeemCode(String code) => '/admin/redeem-code?code=$code';
  static String adminApprove(String txId) => '/admin/$txId/approve';
  static String adminReject(String txId) => '/admin/$txId/reject';
  static String adminPaidStatus(String txId) => '/admin/$txId/paid-status';

  // Redemption Management
  static const String adminRedemptions = '/admin/redeem-coin';
  static String adminApproveRedemption(String txId) => '/admin/redeem-coin/$txId/approve';
  static String adminRejectRedemption(String txId) => '/admin/redeem-coin/$txId/reject';
  static String adminUpdateDeliveryStatus(String txId) => '/admin/redeem-coin/$txId/status';

  // User Management
  static const String getAllUsers = '/admin/users';

  // Notifications & Device Management
  static const String sendNotification = '/admin/send-notification';
  static const String sendNotificationWithImage =
      '/admin/send-notification-with-image';
  static const String sendBroadcast = '/admin/send-broadcast';
  static const String broadcastWithImage = '/admin/broadcast-with-image';
  static const String devicesAll = '/admin/devices/all';
  static String devicesUser(String userId) => '/admin/devices/user/$userId';
  static String deleteDevice(String deviceId) => '/admin/devices/$deviceId';
  static const String registerDevice = '/admin/devices/register';
  static const String deviceStats = '/admin/devices/stats';
}
