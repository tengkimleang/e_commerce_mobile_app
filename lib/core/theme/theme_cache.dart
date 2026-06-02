import 'dart:convert';

import 'package:e_commerce_mobile_app/core/theme/remote_theme_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CachedAppTheme {
  const CachedAppTheme({
    required this.config,
    required this.fetchedAtUtc,
    this.etag,
  });

  final RemoteThemeConfig config;
  final DateTime fetchedAtUtc;
  final String? etag;
}

class ThemeCache {
  ThemeCache(this._prefs);

  static const _configKey = 'app_theme.config';
  static const _etagKey = 'app_theme.etag';
  static const _fetchedAtKey = 'app_theme.fetched_at_utc';

  final SharedPreferences _prefs;

  CachedAppTheme? read() {
    final rawConfig = _prefs.getString(_configKey);
    final rawFetchedAt = _prefs.getString(_fetchedAtKey);
    if (rawConfig == null || rawFetchedAt == null) return null;

    try {
      final fetchedAt = DateTime.parse(rawFetchedAt);
      if (!fetchedAt.isUtc) return null;
      final json = jsonDecode(rawConfig);
      if (json is! Map<String, dynamic>) return null;
      return CachedAppTheme(
        config: RemoteThemeConfig.fromJson(json),
        fetchedAtUtc: fetchedAt,
        etag: _prefs.getString(_etagKey),
      );
    } on FormatException {
      return null;
    }
  }

  Future<void> write({
    required RemoteThemeConfig config,
    required DateTime fetchedAtUtc,
    String? etag,
  }) async {
    await _prefs.setString(_configKey, jsonEncode(config.toJson()));
    await _prefs.setString(_fetchedAtKey, fetchedAtUtc.toIso8601String());
    if (etag == null || etag.isEmpty) {
      await _prefs.remove(_etagKey);
    } else {
      await _prefs.setString(_etagKey, etag);
    }
  }

  Future<void> touch(DateTime fetchedAtUtc) =>
      _prefs.setString(_fetchedAtKey, fetchedAtUtc.toIso8601String());
}
