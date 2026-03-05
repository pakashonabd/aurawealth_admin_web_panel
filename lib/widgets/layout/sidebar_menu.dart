import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../routes/app_routes.dart';
import '../../controllers/navigation_controller.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final String route;

  MenuItem({
    required this.title,
    required this.icon,
    required this.route,
  });
}

class SidebarMenu extends StatelessWidget {
  SidebarMenu({Key? key}) : super(key: key);

  final List<MenuItem> menuItems = [
    MenuItem(
      title: 'Dashboard',
      icon: Icons.dashboard_outlined,
      route: AppRoutes.dashboard,
    ),
    MenuItem(
      title: 'Transactions',
      icon: Icons.receipt_long_outlined,
      route: AppRoutes.transactions,
    ),
    MenuItem(
      title: 'Users',
      icon: Icons.people_outline,
      route: AppRoutes.users,
    ),
    MenuItem(
      title: 'Gold Management',
      icon: Icons.trending_up_outlined,
      route: AppRoutes.goldManagement,
    ),
    MenuItem(
      title: 'Messages',
      icon: Icons.message_outlined,
      route: AppRoutes.messages,
    ),
    MenuItem(
      title: 'Credit Grams',
      icon: Icons.add_card_outlined,
      route: AppRoutes.creditGrams,
    ),
    MenuItem(
      title: 'Redeem Code',
      icon: Icons.qr_code_scanner_outlined,
      route: AppRoutes.redeemCode,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.grey200, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.diamond, color: AppColors.primary, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: _buildMenuList(context),
          ),

          // Footer
          Container(
            padding: EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.grey200, width: 1),
              ),
            ),
            child: Text(
              'Version ${AppConstants.appVersion}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    // Try to get NavigationController
    try {
      final navigationController = Get.find<NavigationController>();

      return Obx(() {
        // Access the observable inside Obx
        final currentRoute = navigationController.currentRoute.value;

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            final isSelected = currentRoute == item.route;

            return Container(
              margin: EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: Icon(
                  item.icon,
                  color: isSelected ? AppColors.primary : AppColors.grey600,
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  // Use NavigationController instead of Get.toNamed
                  navigationController.navigateTo(item.route);
                  // Close drawer on mobile/tablet
                  if (Responsive.isMobile(context) || Responsive.isTablet(context)) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            );
          },
        );
      });
    } catch (e) {
      // Fallback if NavigationController not found
      return ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          final isSelected = Get.currentRoute == item.route;

          return Container(
            margin: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Icon(
                item.icon,
                color: isSelected ? AppColors.primary : AppColors.grey600,
              ),
              title: Text(
                item.title,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              onTap: () {
                Get.toNamed(item.route);
                // Close drawer on mobile/tablet
                if (Responsive.isMobile(context) || Responsive.isTablet(context)) {
                  Navigator.of(context).pop();
                }
              },
            ),
          );
        },
      );
    }
  }
}
