import 'package:flutter/material.dart';

class AppTheme {
  static const green = Color(0xFF2E7D32);
  static const freshGreen = Color(0xFF66BB6A);
  static const forest = Color(0xFF123524);
  static const brown = Color(0xFF795548);
  static const blue = Color(0xFF42A5F5);
  static const bg = Color(0xFFF5FFF5);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: green, brightness: Brightness.light);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(primary: green, secondary: freshGreen, surface: Colors.white),
      scaffoldBackgroundColor: bg,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0, backgroundColor: Colors.transparent),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.black12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: green, width: 1.5)),
      ),
      cardTheme: CardThemeData(color: Colors.white, elevation: 0, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(seedColor: green, brightness: Brightness.dark);
    return ThemeData(useMaterial3: true, colorScheme: scheme, scaffoldBackgroundColor: const Color(0xFF0D1710), fontFamily: 'Inter');
  }
}
