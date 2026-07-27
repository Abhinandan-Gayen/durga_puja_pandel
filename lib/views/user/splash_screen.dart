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
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthController>();

    if (auth.isInitialized) {
      _go(auth);
      return;
    }

    auth.addListener(_onAuthChanged);

    _fallback = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      context.read<AuthController>().removeListener(_onAuthChanged);
      if (!_navigated) {
        _navigated = true;
        context.goNamed(RouteNames.onboarding);
      }
    });
  }

  void _onAuthChanged() {
    if (!mounted || _navigated) return;
    final ctrl = context.read<AuthController>();
    if (ctrl.isInitialized) {
      _fallback?.cancel();
      ctrl.removeListener(_onAuthChanged);
      _go(ctrl);
    }
  }

  void _go(AuthController auth) {
    _navigated = true;
    final target = auth.isLoggedIn
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
