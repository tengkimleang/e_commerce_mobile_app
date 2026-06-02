import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/constants/app_constants.dart';
import 'package:e_commerce_mobile_app/core/theme/theme_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sends cache validator and parses an updated theme', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.path, ApiUrl.currentAppTheme);
          expect(options.queryParameters['platform'], 'android');
          expect(options.queryParameters['appVersion'], '1.2.3');
          expect(options.headers['If-None-Match'], '"old-theme"');
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              headers: Headers.fromMap({
                'etag': ['"new-theme"'],
              }),
              data: {'success': true, 'data': _themeJson()},
            ),
          );
        },
      ),
    );

    final result = await HttpThemeRepository(
      dio,
      platform: 'android',
      appVersion: '1.2.3',
    ).fetchCurrentTheme(etag: '"old-theme"');

    expect(result.config?.revision, '2026-kny-v3');
    expect(result.etag, '"new-theme"');
  });

  test('returns not modified for 304 responses', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response<dynamic>(requestOptions: options, statusCode: 304),
          );
        },
      ),
    );

    final result = await HttpThemeRepository(dio).fetchCurrentTheme();

    expect(result.isNotModified, isTrue);
  });
}

Map<String, dynamic> _themeJson() => {
  'schemaVersion': 1,
  'themeKey': 'khmer_new_year',
  'revision': '2026-kny-v3',
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
