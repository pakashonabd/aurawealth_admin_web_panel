import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/gold_controller.dart';
import '../controllers/message_controller.dart';
import '../services/storage_service.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/responsive.dart';
import '../routes/app_routes.dart';
import '../widgets/layout/sidebar_menu.dart';
import 'dashboard/dashboard_screen.dart';
import 'transactions/transactions_screen.dart';
import 'users/users_screen.dart';
import 'gold_management/gold_management_screen.dart';
import 'messages/messages_screen.dart';
import 'transactions/credit_grams_screen.dart';
import 'transactions/redeem_code_screen.dart';

class MainContainer extends StatelessWidget {
  MainContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get controllers from bindings (don't use Get.put)
    final navigationController = Get.find<NavigationController>();
    final authController = Get.find<AuthController>();
    final storage = StorageService();

    // Set initial route based on current route
    final currentRoute = Get.currentRoute;
    if (currentRoute != navigationController.currentRoute.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigationController.navigateTo(currentRoute);
      });
    }

    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(_getTitle(navigationController.currentRoute.value))),
        leading: isMobile
            ? null
            : (isTablet
                ? Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  )
                : null),
        actions: [
          // Profile & Logout
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: PopupMenuButton(
              icon: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Icon(Icons.person, color: AppColors.primary),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        storage.getUserEmail() != null && storage.getUserEmail()!.isNotEmpty
                            ? storage.getUserEmail()!
                            : 'admin@aurawealth.com',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'logout') {
                  authController.logout();
                }
              },
            ),
          ),
        ],
      ),
      drawer: isMobile || isTablet ? Drawer(child: SidebarMenu()) : null,
      body: Row(
        children: [
          // Sidebar for Desktop
          if (!isMobile && !isTablet)
            Container(
              width: Responsive.getSidebarWidth(context),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  right: BorderSide(color: AppColors.grey200, width: 1),
                ),
              ),
              child: SidebarMenu(),
            ),

          // Main Content Area
          Expanded(
            child: Container(
              color: AppColors.background,
              child: Obx(() => _getScreen(navigationController.currentRoute.value)),
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle(String route) {
    switch (route) {
      case AppRoutes.dashboard:
        return 'Dashboard';
      case AppRoutes.transactions:
        return 'Transactions';
      case AppRoutes.users:
        return 'Users';
      case AppRoutes.goldManagement:
        return 'Gold Management';
      case AppRoutes.messages:
        return 'Messages';
      case AppRoutes.creditGrams:
        return 'Credit Grams';
      case AppRoutes.redeemCode:
        return 'Redeem Code';
      default:
        return 'Dashboard';
    }
  }

  Widget _getScreen(String route) {
    switch (route) {
      case AppRoutes.dashboard:
        // Initialize controller if not exists
        if (!Get.isRegistered<DashboardController>()) {
          Get.lazyPut<DashboardController>(() => DashboardController());
        }
        return DashboardScreen();

      case AppRoutes.transactions:
        if (!Get.isRegistered<TransactionController>()) {
          Get.lazyPut<TransactionController>(() => TransactionController());
        }
        return TransactionsScreen();

      case AppRoutes.users:
        if (!Get.isRegistered<UserController>()) {
          Get.lazyPut<UserController>(() => UserController());
        }
        return UsersScreen();

      case AppRoutes.goldManagement:
        if (!Get.isRegistered<GoldController>()) {
          Get.lazyPut<GoldController>(() => GoldController());
        }
        return GoldManagementScreen();

      case AppRoutes.messages:
        if (!Get.isRegistered<MessageController>()) {
          Get.lazyPut<MessageController>(() => MessageController());
        }
        return MessagesScreen();

      case AppRoutes.creditGrams:
        return CreditGramsScreen();

      case AppRoutes.redeemCode:
        return RedeemCodeScreen();

      default:
        if (!Get.isRegistered<DashboardController>()) {
          Get.lazyPut<DashboardController>(() => DashboardController());
        }
        return DashboardScreen();
    }
  }
}

