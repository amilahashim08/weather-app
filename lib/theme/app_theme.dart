import 'package:flutter/material.dart';

/// Google Weather–inspired colors and surfaces.
abstract final class AppColors {
  static const skyTop = Color(0xFF4A90D9);
  static const skyMid = Color(0xFF5BA3E8);
  static const skyBottom = Color(0xFF87CEEB);
  static const googleBlue = Color(0xFF1A73E8);

  static const surface = Color(0xFFFFFFFF);
  static const surfaceDim = Color(0xFFF8F9FA);
  static const onSurface = Color(0xFF202124);
  static const onSurfaceVariant = Color(0xFF5F6368);
  static const outline = Color(0xFFDADCE0);
  static const divider = Color(0xFFE8EAED);
}

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

ThemeData buildAppTheme() {
  const seed = AppColors.googleBlue;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
    primary: AppColors.googleBlue,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.skyMid,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.5,
        color: Colors.white,
        height: 1.1,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: AppColors.googleBlue, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.googleBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
