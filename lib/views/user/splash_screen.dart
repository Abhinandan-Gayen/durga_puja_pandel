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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    final auth = context.read<AuthController>();

    try {
      await auth.fetchCurrentUserData().timeout(const Duration(seconds: 10));
    } catch (error) {
      debugPrint('Splash initialization error: $error');
    }

    if (!mounted) return;

    if (!auth.isLoggedIn) {
      context.goNamed(RouteNames.onboarding);
      return;
    }

    if (auth.isAdmin) {
      context.goNamed(RouteNames.adminDashboard);
      return;
    }

    context.goNamed(RouteNames.home);
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
