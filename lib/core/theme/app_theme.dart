import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        scaffoldBg: AppColors.ivory,
        surfaceColor: AppColors.white,
        primary: AppColors.deepRed,
        onPrimary: AppColors.white,
        secondary: AppColors.festiveOrange,
        tertiary: AppColors.gold,
        inputFill: AppColors.white,
        inputBorder: const Color(0xFFE6D9CC),
        inputFocus: AppColors.festiveOrange,
        cardColor: AppColors.white,
        cardElevation: 1.0,
      );

  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        scaffoldBg: AppColors.darkBackground,
        surfaceColor: AppColors.darkSurface,
        primary: AppColors.deepRedDark,
        onPrimary: AppColors.charcoal,
        secondary: AppColors.festiveOrangeDark,
        tertiary: AppColors.goldDark,
        inputFill: AppColors.darkInputBg,
        inputBorder: AppColors.darkBorder,
        inputFocus: AppColors.festiveOrangeDark,
        cardColor: AppColors.darkCard,
        cardElevation: 2.0,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color scaffoldBg,
    required Color surfaceColor,
    required Color primary,
    required Color onPrimary,
    required Color secondary,
    required Color tertiary,
    required Color inputFill,
    required Color inputBorder,
    required Color inputFocus,
    required Color cardColor,
    required double cardElevation,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.deepRed,
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      tertiary: tertiary,
      surface: surfaceColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: inputFocus, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: cardElevation,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(
        color: brightness == Brightness.dark
            ? AppColors.darkBorder
            : const Color(0xFFE6D9CC),
      ),
    );
  }
}
