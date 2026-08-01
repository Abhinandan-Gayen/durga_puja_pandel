import 'package:durga_puja_pandel/views/Users/bottom_naigation.dart';
import 'package:durga_puja_pandel/views/Users/pndel_details_screen.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';
import '../views/admin/add_pandal_screen.dart';
import '../views/admin/admin_dashboard_screen.dart';
import '../views/admin/edit_pandal_screen.dart';
import '../views/admin/manage_pandals_screen.dart';
import '../views/admin/upload_media_screen.dart';
import '../views/auth/forgot_password_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/signup_screen.dart';
import '../views/Users/onboarding_screen.dart';
import '../views/Users/splash_screen.dart';
import 'route_names.dart';

class AppRoutes {
  const AppRoutes._();

  static GoRouter createRouter(AuthController authController) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authController,
      redirect: (context, state) {
        final isAdminPath = state.matchedLocation.startsWith('/admin');
        final isAuthPath = {
          '/login',
          '/signup',
          '/forgot-password',
        }.contains(state.matchedLocation);

        if (isAdminPath && !authController.isLoggedIn) {
          return '/login';
        }
        if (isAdminPath &&
            authController.currentUserModel == null &&
            authController.isLoading) {
          return null;
        }
        if (isAdminPath && !authController.isAdmin) {
          return '/home';
        }
        if (isAuthPath && authController.isLoggedIn) {
          if (authController.currentUserModel == null &&
              authController.isLoading) {
            return null;
          }
          return authController.isAdmin ? '/admin' : '/home';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          name: RouteNames.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          name: RouteNames.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          name: RouteNames.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          name: RouteNames.signup,
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          name: RouteNames.forgotPassword,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/home',
          name: RouteNames.home,
          builder: (context, state) => const AppShell(),
        ),
       
        GoRoute(
          path: '/admin',
          name: RouteNames.adminDashboard,
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/admin/add-pandal',
          name: RouteNames.addPandal,
          builder: (context, state) => const AddPandalScreen(),
        ),
        GoRoute(
          path: '/admin/edit-pandal/:id',
          name: RouteNames.editPandal,
          builder: (context, state) =>
              EditPandalScreen(pandalId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/admin/manage-pandals',
          name: RouteNames.managePandals,
          builder: (context, state) => const ManagePandalsScreen(),
        ),
        GoRoute(
          path: '/admin/upload-media',
          name: RouteNames.uploadMedia,
          builder: (context, state) => const UploadMediaScreen(),
        ),
        GoRoute(
          path: '/Pandel_details',
          name: RouteNames.pandalDetails,
          builder: (context, state) => const PandalDetailScreen(),
        ),
      ],
    );
  }
}
