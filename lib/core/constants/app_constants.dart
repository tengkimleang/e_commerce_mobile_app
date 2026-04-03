import 'package:flutter/foundation.dart';

class ApiUrl {
  static const _backendPort = 5058;
  static const _localhost = 'http://localhost:$_backendPort';
  static const _androidEmulatorHost = 'http://10.0.2.2:$_backendPort';

  // Optional override for physical devices or custom environments:
  // flutter run --dart-define=API_BASE_URL=http://<your-lan-ip>:5058
  static const _overrideBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) return _overrideBaseUrl;
    if (kIsWeb) return _localhost;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidEmulatorHost;
    }
    return _localhost;
  }

  static const promtionGetAll = "/promotion/getAll";
  static const promotionGetById = "/promotion/";
  static const newsGetAll = "/news";
  static const newsGetById = "/news/";
  static const requestOtp = "/auth/login/request-otp";
  static const verifyOtp = "/auth/login/verify-otp";
}
