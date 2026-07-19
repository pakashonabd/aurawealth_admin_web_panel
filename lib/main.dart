import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'services/storage_service.dart';
import 'services/admin_fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service
  await StorageService().init();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    rethrow;
  }

  runApp(const MyApp());

  // Init FCM in background — never block app launch for this
  if (StorageService().isAuthenticated) {
    AdminFcmService.initialize();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = StorageService();
    final initialRoute = storage.isAuthenticated
        ? AppRoutes.dashboard
        : AppRoutes.login;

    return GetMaterialApp(
      title: 'AuraWealth Admin',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
    );
  }
}
