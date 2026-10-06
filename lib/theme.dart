import 'package:flutter/material.dart';

class AppColors {
  static const navy = Color(0xFF091540);
  static const blue = Color(0xFF1B2CC1);
  static const softBlue = Color(0xFF7692FF);
  static const tint = Color(0xFFABD2FA);
  static const darkSurface = Color(0xFF111F63);
}

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.blue,
      onPrimary: Colors.white,
      secondary: AppColors.softBlue,
      onSecondary: AppColors.navy,
      surface: Colors.white,
      onSurface: AppColors.navy,
      secondaryContainer: const Color(0xFFCFE0FF),
      onSecondaryContainer: AppColors.navy,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.tint,
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.softBlue,
      onPrimary: AppColors.navy,
      secondary: AppColors.softBlue,
      onSecondary: AppColors.navy,
      surface: AppColors.darkSurface,
      onSurface: Colors.white,
      secondaryContainer: AppColors.blue,
      onSecondaryContainer: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.navy,
    );
  }
}
