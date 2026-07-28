import 'dart:async';

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
  Timer? _fallback;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthController>();

    auth.addListener(_onAuthChanged);

    _fallback = Timer(const Duration(seconds: 5), () {
      if (!mounted || _hasNavigated) return;
      _navigate(context.read<AuthController>(), forceOnboarding: true);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasNavigated) return;
      _navigate(context.read<AuthController>());
    });
  }

  void _onAuthChanged() {
    if (!mounted || _hasNavigated) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasNavigated) return;
      _navigate(context.read<AuthController>());
    });
  }

  void _navigate(AuthController auth, {bool forceOnboarding = false}) {
    if (_hasNavigated) return;

    if (!forceOnboarding && !auth.isInitialized) return;

    _hasNavigated = true;
    _fallback?.cancel();
    auth.removeListener(_onAuthChanged);

    final target = forceOnboarding
        ? RouteNames.onboarding
        : auth.isLoggedIn
        ? (auth.isAdmin ? RouteNames.adminDashboard : RouteNames.home)
        : RouteNames.onboarding;

    context.goNamed(target);
  }

  @override
  void dispose() {
    _fallback?.cancel();
    try {
      context.read<AuthController>().removeListener(_onAuthChanged);
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.temple_hindu, size: 76),
            const SizedBox(height: 16),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
