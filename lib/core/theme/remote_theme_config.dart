import 'package:flutter/material.dart';

@immutable
class RemoteThemeConfig {
  const RemoteThemeConfig({
    required this.schemaVersion,
    required this.themeKey,
    required this.revision,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.surface,
    required this.onSurface,
    required this.scaffoldBackground,
    this.startsAtUtc,
    this.endsAtUtc,
  });

  static const fallback = RemoteThemeConfig(
    schemaVersion: 1,
    themeKey: 'default',
    revision: 'built-in-default',
    primary: Color(0xFFEC407A),
    onPrimary: Colors.white,
    secondary: Color(0xFFE91E63),
    surface: Colors.white,
    onSurface: Color(0xFF1D1B24),
    scaffoldBackground: Color(0xFFF3F3F3),
  );

  final int schemaVersion;
  final String themeKey;
  final String revision;
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color surface;
  final Color onSurface;
  final Color scaffoldBackground;
  final DateTime? startsAtUtc;
  final DateTime? endsAtUtc;

  factory RemoteThemeConfig.fromJson(Map<String, dynamic> json) {
    final schemaVersion = json['schemaVersion'];
    if (schemaVersion != 1) {
      throw const FormatException('Unsupported app theme schema version');
    }
    if (json['mode'] != 'light') {
      throw const FormatException('Only light mode themes are supported');
    }

    final tokens = _requiredMap(json, 'tokens');
    return RemoteThemeConfig(
      schemaVersion: schemaVersion as int,
      themeKey: _requiredString(json, 'themeKey'),
      revision: _requiredString(json, 'revision'),
      primary: _parseHexColor(tokens, 'primary'),
      onPrimary: _parseHexColor(tokens, 'onPrimary'),
      secondary: _parseHexColor(tokens, 'secondary'),
      surface: _parseHexColor(tokens, 'surface'),
      onSurface: _parseHexColor(tokens, 'onSurface'),
      scaffoldBackground: _parseHexColor(tokens, 'scaffoldBackground'),
      startsAtUtc: _optionalUtcDateTime(json, 'startsAtUtc'),
      endsAtUtc: _optionalUtcDateTime(json, 'endsAtUtc'),
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'themeKey': themeKey,
    'revision': revision,
    'mode': 'light',
    if (startsAtUtc != null) 'startsAtUtc': startsAtUtc!.toIso8601String(),
    if (endsAtUtc != null) 'endsAtUtc': endsAtUtc!.toIso8601String(),
    'tokens': {
      'primary': _toHex(primary),
      'onPrimary': _toHex(onPrimary),
      'secondary': _toHex(secondary),
      'surface': _toHex(surface),
      'onSurface': _toHex(onSurface),
      'scaffoldBackground': _toHex(scaffoldBackground),
    },
  };

  static Map<String, dynamic> _requiredMap(
    Map<String, dynamic> json,
    String key,
  ) {
    final value = json[key];
    if (value is! Map<String, dynamic>) {
      throw FormatException('Missing or invalid $key');
    }
    return value;
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Missing or invalid $key');
    }
    return value;
  }

  static Color _parseHexColor(Map<String, dynamic> json, String key) {
    final value = _requiredString(json, key);
    if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(value)) {
      throw FormatException('Invalid color token $key');
    }
    return Color(int.parse('FF${value.substring(1)}', radix: 16));
  }

  static DateTime? _optionalUtcDateTime(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! String) throw FormatException('Invalid $key');
    final parsed = DateTime.tryParse(value);
    if (parsed == null || !parsed.isUtc) throw FormatException('Invalid $key');
    return parsed;
  }

  static String _toHex(Color color) {
    final value = color.toARGB32() & 0xFFFFFF;
    return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}
