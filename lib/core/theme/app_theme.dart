import 'package:flutter/material.dart';

/// Centralized app colors — single source of truth.
abstract final class AppColors {
  static const Color primary = Color(0xFFEC407A);
  static const Color primaryDark = Color.fromARGB(255, 227, 179, 195);
  static const Color accent = Color(0xFFE91E63);
  static const Color background = Color(0xFFF3F3F3);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1D1B24);
  static const Color textSecondary = Colors.grey;
}

/// Centralized ThemeData for [MaterialApp].
abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Battambang',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
