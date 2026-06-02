import 'package:e_commerce_mobile_app/core/theme/remote_theme_config.dart';
import 'package:e_commerce_mobile_app/core/theme/theme_cache.dart';
import 'package:e_commerce_mobile_app/core/theme/theme_cubit.dart';
import 'package:e_commerce_mobile_app/core/theme/theme_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('keeps built-in fallback when refresh fails', () async {
    SharedPreferences.setMockInitialValues({});
    final cubit = ThemeCubit(
      repository: _FakeThemeRepository(error: Exception('offline')),
      cache: ThemeCache(await SharedPreferences.getInstance()),
    );

    await cubit.refreshIfStale(force: true);

    expect(cubit.state.config.revision, 'built-in-default');
    expect(cubit.state.isRefreshing, isFalse);
    await cubit.close();
  });

  test('does not refresh a fresh cached theme on resume', () async {
    SharedPreferences.setMockInitialValues({});
    final now = DateTime.parse('2026-06-01T00:00:00Z');
    final repository = _FakeThemeRepository(
      result: const ThemeFetchResult.notModified(),
    );
    final cubit = ThemeCubit(
      repository: repository,
      cache: ThemeCache(await SharedPreferences.getInstance()),
      initialTheme: CachedAppTheme(
        config: RemoteThemeConfig.fallback,
        fetchedAtUtc: now.subtract(const Duration(minutes: 4)),
      ),
      now: () => now,
    );

    await cubit.refreshIfStale();

    expect(repository.callCount, 0);
    await cubit.close();
  });

  test('refreshes stale cached theme and persists the update', () async {
    SharedPreferences.setMockInitialValues({});
    final now = DateTime.parse('2026-06-01T00:00:00Z');
    final config = RemoteThemeConfig.fromJson(_themeJson());
    final repository = _FakeThemeRepository(
      result: ThemeFetchResult.updated(config: config, etag: '"theme-v2"'),
    );
    final cache = ThemeCache(await SharedPreferences.getInstance());
    final cubit = ThemeCubit(
      repository: repository,
      cache: cache,
      initialTheme: CachedAppTheme(
        config: RemoteThemeConfig.fallback,
        fetchedAtUtc: now.subtract(const Duration(minutes: 5)),
      ),
      now: () => now,
    );

    await cubit.refreshIfStale();

    expect(repository.callCount, 1);
    expect(cubit.state.config.revision, 'theme-v2');
    expect(cache.read()?.etag, '"theme-v2"');
    await cubit.close();
  });
}

class _FakeThemeRepository implements ThemeRepository {
  _FakeThemeRepository({this.result, this.error});

  final ThemeFetchResult? result;
  final Object? error;
  int callCount = 0;

  @override
  Future<ThemeFetchResult> fetchCurrentTheme({String? etag}) async {
    callCount += 1;
    if (error != null) throw error!;
    return result!;
  }
}

Map<String, dynamic> _themeJson() => {
  'schemaVersion': 1,
  'themeKey': 'khmer_new_year',
  'revision': 'theme-v2',
  'mode': 'light',
  'tokens': {
    'primary': '#123456',
    'onPrimary': '#FFFFFF',
    'secondary': '#654321',
    'surface': '#FFFFFF',
    'onSurface': '#222222',
    'scaffoldBackground': '#F3F3F3',
  },
};
