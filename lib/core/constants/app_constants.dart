class AppConstants {
  // App Info
  static const String appName = 'AuraWealth Admin';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  // TODO: Update this with your actual API URL before running the app
  // Example: 'https://api.aurawealth.com' or 'http://localhost:8000'
  static const String baseUrl = 'https://aurawelath-fast-api-backend-576ef7ef3e27.herokuapp.com'; // Update with actual URL
  static const int apiTimeout = 15; // seconds
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Gold Constants
  static const double minGrams = 0.5;
  static const double gramsIncrement = 0.5;
  static const String goldType = '24 Carat';
  
  // Fee Percentages
  static const double buyFeePercent = 8.0;
  static const double vatPercent = 7.5;
  static const double bankSellFeePercent = 2.0;
  static const double storeSellFeePercent = 17.0;
  
  // UI Constants
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double defaultPadding = 16.0;
  
  // Breakpoints for Responsive Design
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
}
