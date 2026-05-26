import 'package:e_commerce_mobile_app/core/theme/app_theme.dart';
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
  });
}
