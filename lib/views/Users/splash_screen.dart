import 'dart:async';
import 'package:durga_puja_pandel/views/Users/bottom-navigationBar/ui/bottom_naigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goToHomeScreen();
  }

  Future<void> _goToHomeScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Get.off(
      () => const AppShell(),
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 980),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF1),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double availableHeight = constraints.maxHeight;
          final bool isSmallWindow = availableHeight < 700;

          final double loaderBottom = isSmallWindow
              ? (availableHeight * 0.10).clamp(52.0, 75.0)
              : 115.0;

          final double versionBottom = isSmallWindow
              ? (availableHeight * 0.035).clamp(18.0, 30.0)
              : 30.0;

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/splash-screen.webp',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.high,
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: loaderBottom,
                child: const Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Color(0xFFE50914),
                      backgroundColor: Color(0x26E50914),
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 20,
                right: 20,
                bottom: versionBottom,
                child: SafeArea(
                  top: false,
                  child: Text(
                    'V1.0.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.55),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
