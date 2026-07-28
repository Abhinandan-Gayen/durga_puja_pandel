import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../routes/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('SplashScreen: initState called');
    Future<void>.delayed(const Duration(milliseconds: 900), () async {
      debugPrint('SplashScreen: 900ms timer triggered');
      if (!mounted) {
        debugPrint('SplashScreen: Not mounted, returning');
        return;
      }
      final auth = context.read<AuthController>();
      debugPrint('SplashScreen: auth.isLoggedIn = ${auth.isLoggedIn}');
      debugPrint('SplashScreen: Calling fetchCurrentUserData()');
      try {
        await auth.fetchCurrentUserData();
        debugPrint('SplashScreen: fetchCurrentUserData() completed');
      } catch (e) {
        debugPrint('SplashScreen: Error fetching current user data: $e');
      }
      if (!mounted) {
        debugPrint('SplashScreen: Not mounted after fetch, returning');
        return;
      }
      final targetRoute = auth.isLoggedIn
          ? auth.isAdmin
              ? RouteNames.adminDashboard
              : RouteNames.home
          : RouteNames.onboarding;
      debugPrint('SplashScreen: Navigating to route: $targetRoute');
      context.goNamed(targetRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.temple_hindu, size: 76),
            SizedBox(height: 16),
            Text(AppConstants.appName),
          ],
        ),
      ),
    );
  }
}
