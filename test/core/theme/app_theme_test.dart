import 'package:e_commerce_mobile_app/core/theme/app_theme.dart';
import 'package:e_commerce_mobile_app/core/theme/remote_theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('light theme uses the app typography standard', () {
    final theme = AppTheme.light;

    expect(
      theme.textTheme.bodyMedium?.fontFamily,
      AppTypography.primaryFontFamily,
    );
    expect(
      theme.textTheme.bodyMedium?.fontFamilyFallback,
      AppTypography.fontFamilyFallback,
    );
    expect(theme.textTheme.displaySmall?.fontSize, 32);
    expect(theme.textTheme.displaySmall?.fontWeight, FontWeight.w700);
    expect(theme.textTheme.headlineSmall?.fontSize, 24);
    expect(theme.textTheme.headlineSmall?.fontWeight, FontWeight.w600);
    expect(theme.textTheme.titleMedium?.fontSize, 18);
    expect(theme.textTheme.bodyMedium?.fontSize, 16);
    expect(theme.textTheme.bodySmall?.fontSize, 12);
    expect(AppTypography.input.fontFamily, 'Battambang');
    expect(AppTypography.input.fontFamilyFallback, [
      'KhmerOSSiemreap',
      AppTypography.primaryFontFamily,
    ]);
  });

  test('builds runtime colors without changing the typography standard', () {
    final theme = AppTheme.fromConfig(
      RemoteThemeConfig.fromJson({
        'schemaVersion': 1,
        'themeKey': 'holiday',
        'revision': 'holiday-v1',
        'mode': 'light',
        'tokens': {
          'primary': '#123456',
          'onPrimary': '#FFFFFF',
          'secondary': '#654321',
          'surface': '#FFFFFF',
          'onSurface': '#222222',
          'scaffoldBackground': '#F3F3F3',
        },
      }),
    );

    expect(theme.colorScheme.primary, const Color(0xFF123456));
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF3F3F3));
    expect(
      theme.textTheme.bodyMedium?.fontFamily,
      AppTypography.primaryFontFamily,
    );
    expect(AppTypography.input.fontFamily, 'Battambang');
  });
}
