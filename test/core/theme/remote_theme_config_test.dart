import 'package:e_commerce_mobile_app/core/theme/remote_theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the approved light theme payload', () {
    final config = RemoteThemeConfig.fromJson(_themeJson());

    expect(config.themeKey, 'khmer_new_year');
    expect(config.revision, '2026-kny-v3');
    expect(config.primary, const Color(0xFF123456));
    expect(config.onSurface, const Color(0xFF222222));
    expect(config.startsAtUtc, DateTime.parse('2026-04-12T17:00:00Z'));
  });

  test('rejects dark mode until it is supported by the mobile app', () {
    expect(
      () => RemoteThemeConfig.fromJson(_themeJson(mode: 'dark')),
      throwsFormatException,
    );
  });

  test('rejects invalid color tokens', () {
    final json = _themeJson();
    (json['tokens'] as Map<String, dynamic>)['primary'] = 'pink';

    expect(() => RemoteThemeConfig.fromJson(json), throwsFormatException);
  });
}

Map<String, dynamic> _themeJson({String mode = 'light'}) => {
  'schemaVersion': 1,
  'themeKey': 'khmer_new_year',
  'revision': '2026-kny-v3',
  'mode': mode,
  'startsAtUtc': '2026-04-12T17:00:00Z',
  'endsAtUtc': '2026-04-16T17:00:00Z',
  'tokens': {
    'primary': '#123456',
    'onPrimary': '#FFFFFF',
    'secondary': '#654321',
    'surface': '#FFFFFF',
    'onSurface': '#222222',
    'scaffoldBackground': '#F3F3F3',
  },
};
