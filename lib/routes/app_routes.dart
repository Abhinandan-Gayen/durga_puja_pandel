import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../views/admin/add_pandal_screen.dart';
import '../views/admin/admin_dashboard_screen.dart';
import '../views/admin/edit_pandal_screen.dart';
import '../views/admin/manage_pandals_screen.dart';
import '../views/admin/upload_media_screen.dart';
import '../views/auth/forgot_password_screen.dart';
import '../views/auth/login_screen.dart';
// import '../views/auth/signup_screen.dart';
import '../views/Users/onboarding_screen.dart';
import '../views/Users/splash_screen.dart';
import '../views/Users/bottom-navigationBar/ui/bottom_naigation.dart';
import '../views/Users/pandel_details.dart';
import '../views/Users/map.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (route == null) return null;

    final context = Get.context;
    if (context == null) return null;

    try {
      final authController = Provider.of<AuthController>(context, listen: false);

      final isAdminPath = route.startsWith('/admin');
      final isAuthPath = {
        '/login',
        '/signup',
        '/forgot-password',
      }.contains(route);

      if (isAdminPath && !authController.isLoggedIn) {
        return const RouteSettings(name: '/login');
      }
      if (isAdminPath &&
          authController.currentUserModel == null &&
          authController.isLoading) {
        return null;
      }
      if (isAdminPath && !authController.isAdmin) {
        return const RouteSettings(name: '/home');
      }
      if (isAuthPath && authController.isLoggedIn) {
        if (authController.currentUserModel == null &&
            authController.isLoading) {
          return null;
        }
        return RouteSettings(name: authController.isAdmin ? '/admin' : '/home');
      }
    } catch (_) {
      // If AuthController is not ready yet, continue navigation
    }
    return null;
  }
}

class AppRoutes {
  const AppRoutes._();

  static final pages = [
    GetPage(
      name: '/',
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: '/onboarding',
      page: () => const OnboardingScreen(),
    ),
    GetPage(
      name: '/login',
      page: () => const LoginScreen(),
      middlewares: [AuthMiddleware()],
    ),
    // GetPage(
    //   name: '/signup',
    //   page: () => const SignupScreen(),
    //   middlewares: [AuthMiddleware()],
    // ),
    GetPage(
      name: '/forgot-password',
      page: () => const ForgotPasswordScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/home',
      page: () => const AppShell(),
    ),
    GetPage(
      name: '/map',
      page: () => const CardScreen(),
    ),
    GetPage(
      name: '/pandal/:id',
      page: () => const PandalDetailScreen(),
    ),
    GetPage(
      name: '/admin',
      page: () => const AdminDashboardScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/admin/add-pandal',
      page: () => const AddPandalScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/admin/edit-pandal/:id',
      page: () => EditPandalScreen(
        pandalId: Get.parameters['id'] ?? '',
      ),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/admin/manage-pandals',
      page: () => const ManagePandalsScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/admin/upload-media',
      page: () => const UploadMediaScreen(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
