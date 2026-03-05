import 'package:get/get.dart';
import '../routes/app_routes.dart';

class NavigationController extends GetxController {
  // Current selected route
  final currentRoute = AppRoutes.dashboard.obs;

  // Navigate to a route without full page transition
  void navigateTo(String route) {
    currentRoute.value = route;
  }

  // Check if route is selected
  bool isSelected(String route) {
    return currentRoute.value == route;
  }
}

