import 'package:e_commerce_mobile_app/core/theme/remote_theme_config.dart';
import 'package:e_commerce_mobile_app/core/theme/theme_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('writes and reads the last valid app theme', () async {
    SharedPreferences.setMockInitialValues({});
    final cache = ThemeCache(await SharedPreferences.getInstance());
    final fetchedAt = DateTime.parse('2026-06-01T00:00:00Z');

    await cache.write(
      config: RemoteThemeConfig.fallback,
      fetchedAtUtc: fetchedAt,
      etag: '"theme-v1"',
    );

    final cached = cache.read();
    expect(cached?.config.revision, RemoteThemeConfig.fallback.revision);
    expect(cached?.fetchedAtUtc, fetchedAt);
    expect(cached?.etag, '"theme-v1"');
  });

  test('ignores invalid cached data', () async {
    SharedPreferences.setMockInitialValues({
      'app_theme.config': '{"schemaVersion":99}',
      'app_theme.fetched_at_utc': '2026-06-01T00:00:00Z',
    });
    final cache = ThemeCache(await SharedPreferences.getInstance());

    expect(cache.read(), isNull);
  });
}
