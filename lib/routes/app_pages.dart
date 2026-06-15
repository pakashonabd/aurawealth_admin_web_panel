import 'package:get/get.dart';
import '../views/auth/login_screen.dart';
import '../views/main_container.dart';
import '../middleware/auth_middleware.dart';
import '../controllers/auth_controller.dart';
import '../controllers/navigation_controller.dart';
import '../admin/payments/screens/payments_list_screen.dart';
import '../admin/payments/screens/payment_detail_screen.dart';
import '../admin/payments/screens/payment_stats_screen.dart';
import '../admin/payments/screens/webhook_logs_screen.dart';
import '../admin/payments/controllers/admin_payment_controller.dart';
import '../admin/payments/services/admin_payment_service.dart';
import 'app_routes.dart';

// Main binding for all protected routes
class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<NavigationController>(() => NavigationController(), fenix: true);
  }
}

class AppPages {
  static final List<GetPage<dynamic>> routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    // All protected routes now use MainContainer with shared binding
    GetPage(
      name: AppRoutes.dashboard,
      page: () => MainContainer(),
      middlewares: [AuthMiddleware()],
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoutes.transactions,
      page: () => MainContainer(),
      middlewares: [AuthMiddleware()],
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoutes.users,
      page: () => MainContainer(),
      middlewares: [AuthMiddleware()],
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoutes.goldManagement,
      page: () => MainContainer(),
      middlewares: [AuthMiddleware()],
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoutes.messages,
      page: () => MainContainer(),
      middlewares: [AuthMiddleware()],
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoutes.storeOperations,
      page: () => MainContainer(),
      middlewares: [AuthMiddleware()],
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoutes.paymentsList,
      page: () => PaymentsListScreen(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut<AdminPaymentService>(() => AdminPaymentService(
          baseUrl: Get.find<AuthController>().baseUrl,
          tokenProvider: () => Get.find<AuthController>().token,
        ));
        Get.lazyPut<AdminPaymentController>(() => AdminPaymentController(Get.find()));
      }),
    ),
    GetPage(
      name: AppRoutes.paymentDetail,
      page: () => PaymentDetailScreen(txId: Get.arguments ?? ''),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.paymentStats,
      page: () => PaymentStatsScreen(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut<AdminPaymentController>(() => AdminPaymentController(Get.find()));
      }),
    ),
    GetPage(
      name: AppRoutes.webhookLogs,
      page: () => WebhookLogsScreen(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
