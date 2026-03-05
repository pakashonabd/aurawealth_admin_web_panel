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

  // Messaging
  static const String adminMessages = '/admin/messages';
  static String adminUserMessages(String userId) => '/admin/messages/$userId';
  static String adminReplyMessage(String userId) => '/admin/messages/$userId';
}
