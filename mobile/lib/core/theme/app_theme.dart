import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2E7D32);
  static const primaryDark = Color(0xFF1B5E20);
  static const secondary = Color(0xFF81C784);
  static const surface = Color(0xFFF7FBF6);
  static const text = Color(0xFF172117);
  static const mint = Color(0xFFA5D6A7);
  static const error = Color(0xFFB3261E);
}
class AppSpacing { static const xs=4.0, sm=8.0, md=16.0, lg=24.0, xl=32.0; }
class AppRadius { static const card=18.0, button=12.0; }
class AppTheme { static ThemeData light() => ThemeData(useMaterial3:true,colorScheme:ColorScheme.fromSeed(seedColor:AppColors.primary),scaffoldBackgroundColor:AppColors.surface,fontFamily:'sans-serif',cardTheme:const CardThemeData(elevation:0,margin:EdgeInsets.zero)); }
