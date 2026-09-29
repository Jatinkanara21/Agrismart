import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2E7D32);
  static const primaryDark = Color(0xFF174D1B);
  static const secondary = Color(0xFF8BC34A);
  static const surface = Color(0xFFF5F8F2);
  static const card = Color(0xFFFFFFFF);
  static const text = Color(0xFF172117);
  static const muted = Color(0xFF647064);
  static const mint = Color(0xFFE1F2D8);
  static const warm = Color(0xFFFFF3D6);
  static const error = Color(0xFFB3261E);
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class AppRadius {
  static const card = 20.0;
  static const button = 14.0;
}

class AppTheme {
  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.surface,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.text,
          elevation: 0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.button)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.button)),
            borderSide: BorderSide(color: Color(0xFFE1E8DF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.button)),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          color: AppColors.card,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.card)),
          ),
        ),
      );
