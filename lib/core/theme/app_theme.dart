import 'package:flutter/cupertino.dart';
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

/// App-wide typography tokens.
///
/// Inter is the primary Latin UI font. Khmer fonts stay in the fallback list
/// so mixed English/Khmer content can render consistently.
abstract final class AppTypography {
  static const String primaryFontFamily = 'Inter';
  static const List<String> fontFamilyFallback = [
    'Battambang',
    'KhmerOSSiemreap',
  ];

  static const TextStyle pageTitle = TextStyle(
    fontFamily: primaryFontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: primaryFontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: primaryFontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
  );

  static const TextStyle body = TextStyle(
    fontFamily: primaryFontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: primaryFontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: 0,
  );

  static const TextStyle smallMeta = TextStyle(
    fontFamily: primaryFontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.35,
    letterSpacing: 0,
  );

  static TextTheme textTheme(ColorScheme colorScheme) {
    final primary = AppColors.textPrimary;
    final secondary = AppColors.textSecondary;

    return TextTheme(
      displaySmall: pageTitle.copyWith(color: primary),
      headlineMedium: pageTitle.copyWith(color: primary),
      headlineSmall: sectionTitle.copyWith(color: primary),
      titleLarge: sectionTitle.copyWith(color: primary),
      titleMedium: cardTitle.copyWith(color: primary),
      titleSmall: caption.copyWith(color: primary, fontWeight: FontWeight.w600),
      bodyLarge: body.copyWith(color: primary),
      bodyMedium: body.copyWith(color: primary),
      bodySmall: smallMeta.copyWith(color: secondary),
      labelLarge: body.copyWith(
        color: colorScheme.onPrimary,
        fontWeight: FontWeight.w700,
      ),
      labelMedium: caption.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: smallMeta.copyWith(color: secondary),
    );
  }
}

/// Centralized ThemeData for [MaterialApp].
abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
    );
    final textTheme = AppTypography.textTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.primaryFontFamily,
      fontFamilyFallback: AppTypography.fontFamilyFallback,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      cupertinoOverrideTheme: const CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: AppTypography.primaryFontFamily,
            fontFamilyFallback: AppTypography.fontFamilyFallback,
            letterSpacing: 0,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.primaryFontFamily,
          fontFamilyFallback: AppTypography.fontFamilyFallback,
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.25,
          letterSpacing: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
        ),
        labelStyle: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
