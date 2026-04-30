import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../routes/app_routes.dart';
import '../../controllers/navigation_controller.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final String route;
  final IconData? badge;
  MenuItem({
    required this.title,
    required this.icon,
    required this.route,
    this.badge,
  });
}

class SidebarMenu extends StatefulWidget {
  const SidebarMenu({Key? key}) : super(key: key);

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> with SingleTickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    super.dispose();
  }

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
      title: 'Notifications',
      icon: Icons.notifications_active_outlined,
      route: AppRoutes.notifications,
    ),
    // MenuItem(
    //   title: 'Store Operations',
    //   icon: Icons.store_outlined,
    //   route: AppRoutes.storeOperations,
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Animated Header
          _buildAnimatedHeader()
              .animate()
              .fadeIn(duration: 600.ms, curve: Curves.easeOut)
              .slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),

          // Menu Items
          Expanded(
            child: _buildMenuList(context),
          ),

          // Animated Footer
          _buildAnimatedFooter()
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.grey200.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Animated Icon with subtle glow
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(
              Icons.diamond,
              color: AppColors.primary,
              size: 28,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .shimmer(
                duration: 2500.ms,
                color: AppColors.primary.withOpacity(0.3),
              )
              .scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.02, 1.02),
                duration: 2000.ms,
              ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.grey200.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.grey100.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.grey200.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_outlined,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'v${AppConstants.appVersion}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            final isSelected = currentRoute == item.route;
            final isHovered = _hoveredIndex == index;

            return _buildModernMenuItem(
              context: context,
              item: item,
              isSelected: isSelected,
              isHovered: isHovered,
              index: index,
              onTap: () {
                navigationController.navigateTo(item.route);
                if (Responsive.isMobile(context) || Responsive.isTablet(context)) {
                  Navigator.of(context).pop();
                }
              },
            )
                .animate(delay: Duration(milliseconds: 50 * index))
                .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                .slideX(begin: -0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
          },
        );
      });
    } catch (e) {
      // Fallback if NavigationController not found
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          final isSelected = Get.currentRoute == item.route;
          final isHovered = _hoveredIndex == index;

          return _buildModernMenuItem(
            context: context,
            item: item,
            isSelected: isSelected,
            isHovered: isHovered,
            index: index,
            onTap: () {
              Get.toNamed(item.route);
              if (Responsive.isMobile(context) || Responsive.isTablet(context)) {
                Navigator.of(context).pop();
              }
            },
          )
              .animate(delay: Duration(milliseconds: 50 * index))
              .fadeIn(duration: 400.ms, curve: Curves.easeOut)
              .slideX(begin: -0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
        },
      );
    }
  }

  Widget _buildModernMenuItem({
    required BuildContext context,
    required MenuItem item,
    required bool isSelected,
    required bool isHovered,
    required int index,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : isHovered
                  ? AppColors.grey100.withOpacity(0.7)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.15)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            splashColor: AppColors.primary.withOpacity(0.1),
            highlightColor: AppColors.primary.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  // Animated Icon Container
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : isHovered
                              ? AppColors.primary.withOpacity(0.08)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item.icon,
                      size: 22,
                      color: isSelected
                          ? Colors.white
                          : isHovered
                              ? AppColors.primary
                              : AppColors.grey600,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Title with animation
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 14.5,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        letterSpacing: -0.2,
                      ),
                      child: Text(
                        item.title,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  // Selection Indicator
                  if (isSelected)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .scale(
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.3, 1.3),
                          duration: 1000.ms,
                        )
                        .then()
                        .scale(
                          begin: const Offset(1.3, 1.3),
                          end: const Offset(1.0, 1.0),
                          duration: 1000.ms,
                        ),
                  // Hover Indicator
                  if (!isSelected && isHovered)
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.primary.withOpacity(0.6),
                    )
                        .animate()
                        .slideX(begin: -0.5, end: 0, duration: 300.ms)
                        .fadeIn(duration: 300.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
