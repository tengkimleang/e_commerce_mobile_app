import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce_mobile_app/core/theme/remote_theme_config.dart';
import 'package:google_fonts/google_fonts.dart';

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
/// Inter is the primary Latin UI font. Battambang is the primary Khmer font,
/// bundled locally so the google_fonts package never needs HTTP fetching.
abstract final class AppTypography {
  static const String primaryFontFamily = 'Inter';
  static const String khmerFontFamily = 'Battambang';
  static const List<String> fontFamilyFallback = [
    'Battambang',
    'KhmerOSSiemreap',
  ];

  /// Returns a [TextStyle] using [GoogleFonts.battambang] (from bundled assets).
  /// Defaults to Light (w300) — pass [fontWeight] to override per call-site.
  static TextStyle battambangTextStyle({
    TextStyle? textStyle,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
  }) =>
      GoogleFonts.battambang(
        textStyle: textStyle,
        fontSize: fontSize,
        fontWeight: fontWeight ?? FontWeight.w300,
        height: height,
        letterSpacing: letterSpacing ?? 0,
        color: color,
      );

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

  /// Returns the correct input [TextStyle] for the active language.
  ///
  /// Khmer → Battambang Light (w300) via [GoogleFonts.battambang].
  /// English → Inter w400 with Battambang as a glyph-level fallback only.
  static TextStyle inputStyle({bool isKhmer = false}) {
    if (isKhmer) {
      return GoogleFonts.battambang(
        textStyle: const TextStyle(
          fontFamilyFallback: ['KhmerOSSiemreap', primaryFontFamily],
          fontSize: 16,
          fontWeight: FontWeight.w300,
          letterSpacing: 0,
        ),
      );
    }
    return const TextStyle(
      fontFamily: primaryFontFamily,
      fontFamilyFallback: ['Battambang', 'KhmerOSSiemreap'],
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    );
  }

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

  /// Builds the [TextTheme] for the current language.
  ///
  /// When [isKhmer] is true, every style is produced via
  /// [GoogleFonts.battambang] so Khmer script renders with correct metrics.
  /// For Latin text the Inter styles remain as-is with Battambang as fallback.
  static TextTheme textTheme(
    ColorScheme colorScheme, {
    Color primary = AppColors.textPrimary,
    bool isKhmer = false,
  }) {
    final secondary = AppColors.textSecondary;

    TextStyle resolve(TextStyle base) {
      if (!isKhmer) return base;
      // Always render Khmer text at Light (w300) for the clean, airy look.
      return GoogleFonts.battambang(
        textStyle: base,
        fontWeight: FontWeight.w300,
        letterSpacing: 0,
      );
    }

    return TextTheme(
      displaySmall: resolve(pageTitle.copyWith(color: primary)),
      headlineMedium: resolve(pageTitle.copyWith(color: primary)),
      headlineSmall: resolve(sectionTitle.copyWith(color: primary)),
      titleLarge: resolve(sectionTitle.copyWith(color: primary)),
      titleMedium: resolve(cardTitle.copyWith(color: primary)),
      titleSmall: resolve(caption.copyWith(color: primary, fontWeight: FontWeight.w600)),
      bodyLarge: resolve(body.copyWith(color: primary)),
      bodyMedium: resolve(body.copyWith(color: primary)),
      bodySmall: resolve(smallMeta.copyWith(color: secondary)),
      labelLarge: resolve(body.copyWith(
        color: colorScheme.onPrimary,
        fontWeight: FontWeight.w700,
      )),
      labelMedium: resolve(caption.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
      )),
      labelSmall: resolve(smallMeta.copyWith(color: secondary)),
    );
  }
}

@immutable
class AppBrandTheme extends ThemeExtension<AppBrandTheme> {
  const AppBrandTheme({required this.primaryDark, required this.textSecondary});

  final Color primaryDark;
  final Color textSecondary;

  @override
  AppBrandTheme copyWith({Color? primaryDark, Color? textSecondary}) =>
      AppBrandTheme(
        primaryDark: primaryDark ?? this.primaryDark,
        textSecondary: textSecondary ?? this.textSecondary,
      );

  @override
  AppBrandTheme lerp(covariant AppBrandTheme? other, double t) {
    if (other == null) return this;
    return AppBrandTheme(
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}

extension AppBrandThemeContext on BuildContext {
  AppBrandTheme get brandTheme =>
      Theme.of(this).extension<AppBrandTheme>() ??
      const AppBrandTheme(
        primaryDark: AppColors.primaryDark,
        textSecondary: AppColors.textSecondary,
      );
}

/// Centralized ThemeData for [MaterialApp].
abstract final class AppTheme {
  static ThemeData get light => fromConfig(RemoteThemeConfig.fallback);

  static ThemeData fromConfig(RemoteThemeConfig config, {bool isKhmer = false}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: config.primary,
      primary: config.primary,
      onPrimary: config.onPrimary,
      secondary: config.secondary,
      surface: config.surface,
      onSurface: config.onSurface,
    );
    final textTheme = AppTypography.textTheme(
      colorScheme,
      primary: config.onSurface,
      isKhmer: isKhmer,
    );

    // Determine primary font family for this locale
    final activeFontFamily = isKhmer
        ? AppTypography.khmerFontFamily
        : AppTypography.primaryFontFamily;
    final activeFallback = isKhmer
        ? <String>[AppTypography.primaryFontFamily, 'KhmerOSSiemreap']
        : AppTypography.fontFamilyFallback;

    return ThemeData(
      useMaterial3: true,
      fontFamily: activeFontFamily,
      fontFamilyFallback: activeFallback,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: config.scaffoldBackground,
      extensions: [
        const AppBrandTheme(
          primaryDark: AppColors.primaryDark,
          textSecondary: AppColors.textSecondary,
        ),
      ],
      cupertinoOverrideTheme: const CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: AppTypography.primaryFontFamily,
            fontFamilyFallback: AppTypography.fontFamilyFallback,
            letterSpacing: 0,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: config.primary,
        foregroundColor: config.onPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: isKhmer
            ? GoogleFonts.battambang(
                textStyle: TextStyle(
                  color: config.onPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                  height: 1.4,
                  letterSpacing: 0,
                ),
              )
            : TextStyle(
                fontFamily: AppTypography.primaryFontFamily,
                fontFamilyFallback: AppTypography.fontFamilyFallback,
                color: config.onPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                height: 1.25,
                letterSpacing: 0,
              ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: (isKhmer
            ? GoogleFonts.battambang(
                textStyle: AppTypography.caption,
                fontWeight: FontWeight.w300,
              )
            : AppTypography.caption)
            .copyWith(color: AppColors.textSecondary),
        labelStyle: (isKhmer
            ? GoogleFonts.battambang(
                textStyle: AppTypography.caption,
                fontWeight: FontWeight.w300,
              )
            : AppTypography.caption)
            .copyWith(color: AppColors.textSecondary),
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
