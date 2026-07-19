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
    Future<void>.delayed(const Duration(milliseconds: 900), () async {
      if (!mounted) {
        return;
      }
      final auth = context.read<AuthController>();
      await auth.fetchCurrentUserData();
      if (!mounted) {
        return;
      }
      context.goNamed(
        auth.isLoggedIn
            ? auth.isAdmin
                  ? RouteNames.adminDashboard
                  : RouteNames.home
            : RouteNames.onboarding,
      );
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
