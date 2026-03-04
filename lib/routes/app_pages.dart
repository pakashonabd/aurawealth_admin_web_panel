import 'package:get/get.dart';
import '../views/auth/login_screen.dart';
import '../views/dashboard/dashboard_screen.dart';
import '../views/transactions/transactions_screen.dart';
import '../views/users/users_screen.dart';
import '../views/gold_management/gold_management_screen.dart';
import '../views/messages/messages_screen.dart';
import '../views/transactions/credit_grams_screen.dart';
import '../views/transactions/redeem_code_screen.dart';
import '../middleware/auth_middleware.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/gold_controller.dart';
import '../controllers/message_controller.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => DashboardScreen(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
        Get.lazyPut<DashboardController>(() => DashboardController());
      }),
    ),
    GetPage(
      name: AppRoutes.transactions,
      page: () => TransactionsScreen(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
        Get.lazyPut<TransactionController>(() => TransactionController());
      }),
    ),
    GetPage(
      name: AppRoutes.users,
      page: () => UsersScreen(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
        Get.lazyPut<UserController>(() => UserController());
      }),
    ),
    GetPage(
      name: AppRoutes.goldManagement,
      page: () => GoldManagementScreen(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
        Get.lazyPut<GoldController>(() => GoldController());
      }),
    ),
    GetPage(
      name: AppRoutes.messages,
      page: () => MessagesScreen(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
        Get.lazyPut<MessageController>(() => MessageController());
      }),
    ),
    GetPage(
      name: AppRoutes.creditGrams,
      page: () => CreditGramsScreen(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.redeemCode,
      page: () => RedeemCodeScreen(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
  ];
}
