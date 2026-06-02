import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/constants/app_constants.dart';
import 'package:e_commerce_mobile_app/core/theme/remote_theme_config.dart';
import 'package:flutter/foundation.dart';

class ThemeFetchResult {
  const ThemeFetchResult.notModified() : config = null, etag = null;

  const ThemeFetchResult.updated({required this.config, this.etag});

  final RemoteThemeConfig? config;
  final String? etag;

  bool get isNotModified => config == null;
}

abstract interface class ThemeRepository {
  Future<ThemeFetchResult> fetchCurrentTheme({String? etag});
}

class HttpThemeRepository implements ThemeRepository {
  HttpThemeRepository(this._dio, {this.appVersion = '1.0.0', String? platform})
    : platform = platform ?? _currentPlatform;

  final Dio _dio;
  final String appVersion;
  final String platform;

  @override
  Future<ThemeFetchResult> fetchCurrentTheme({String? etag}) async {
    final response = await _dio.get<dynamic>(
      ApiUrl.currentAppTheme,
      queryParameters: {'platform': platform, 'appVersion': appVersion},
      options: Options(
        headers: {if (etag != null && etag.isNotEmpty) 'If-None-Match': etag},
        validateStatus: (status) =>
            status != null &&
            ((status >= 200 && status < 300) || status == 304),
      ),
    );

    if (response.statusCode == 304) {
      return const ThemeFetchResult.notModified();
    }

    final body = response.data;
    if (body is! Map<String, dynamic> ||
        body['success'] != true ||
        body['data'] is! Map<String, dynamic>) {
      throw const FormatException('Invalid app theme response envelope');
    }

    return ThemeFetchResult.updated(
      config: RemoteThemeConfig.fromJson(body['data'] as Map<String, dynamic>),
      etag: response.headers.value('etag'),
    );
  }

  static String get _currentPlatform {
    if (kIsWeb) return 'web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.windows => 'windows',
      TargetPlatform.linux => 'linux',
      TargetPlatform.fuchsia => 'fuchsia',
    };
  }
}
