import 'dart:async' show TimeoutException;
import 'dart:convert' show jsonDecode, utf8;
import 'dart:io' show File;
import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/constants/app_constants.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static const _refreshEndpoint = '/auth/refresh';
  static const _logoutEndpoint = '/auth/logout';
  static const _setPinEndpoint = '/auth/pin/set';
  static const _resetPinEndpoint = '/auth/pin/reset';
  static const _forgotPinRequestOtpEndpoint = '/auth/pin/forgot/request-otp';
  static const _forgotPinVerifyOtpEndpoint = '/auth/pin/forgot/verify-otp';
  static const _verifyPinEndpoint = '/auth/login/verify-pin';
  static const _checkLoginPhoneEndpoint = '/auth/login/check-phone';
  static const _mallMembershipQrEndpoint = '/user/me/mall-qr';
  static const _avatarUploadEndpoint = '/user/me/profile';
  static const _avatarUploadLegacyEndpoint = '/user/me/avatar';
  static const _loyaltyRewardsEndpoint = '/loyalty/rewards';
  static const _loyaltyExchangesEndpoint = '/loyalty/exchanges';
  static const _loyaltyPointsHistoryEndpoint = '/loyalty/points/history';
  static const _loyaltyPointsExpiryEndpoint = '/loyalty/points/expiry';

  static String get _baseUrl => ApiUrl.baseUrl;
  static Future<bool>? _refreshInFlight;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      headers: {'Content-Type': 'application/json'},
      responseType: ResponseType.plain,
      receiveDataWhenStatusError: true,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      // Backend contract: business errors may come with any status.
      // We always parse payload fields like errorCode/sent/success.
      validateStatus: (status) => status != null,
    ),
  );

  String _asCleanString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  String _readStringField(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = _asCleanString(data[key]);
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  bool _readBoolField(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final raw = data[key];
      if (raw is bool) return raw;
      if (raw is num) return raw != 0;
      if (raw is String) {
        final value = raw.trim().toLowerCase();
        if (value == 'true' || value == '1') return true;
        if (value == 'false' || value == '0') return false;
      }
    }
    return false;
  }

  int _readIntField(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final raw = data[key];
      if (raw is int) return raw;
      if (raw is num) return raw.toInt();
      if (raw is String) {
        final value = int.tryParse(raw.trim());
        if (value != null) return value;
      }
    }
    return 0;
  }

  Map<String, dynamic> _toResponseMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    if (data is List<int>) {
      final decodedText = utf8.decode(data, allowMalformed: true).trim();
      if (decodedText.isEmpty) return const {};
      try {
        final decoded = jsonDecode(decodedText);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) {
          return decoded.map((key, value) => MapEntry(key.toString(), value));
        }
      } catch (_) {
        return {'message': decodedText};
      }
    }
    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) {
        return const {};
      }
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) {
          return decoded.map((key, value) => MapEntry(key.toString(), value));
        }
      } catch (_) {
        return {'message': trimmed};
      }
    }
    return const {};
  }

  Map<String, dynamic> _extractNestedDataMap(Map<String, dynamic> payload) {
    final nested = payload['data'];
    if (nested is Map<String, dynamic>) return nested;
    if (nested is Map) {
      return nested.map((key, value) => MapEntry(key.toString(), value));
    }
    return payload;
  }

  Map<String, dynamic> _normalizeProfileResponse(dynamic raw) {
    final payload = _toResponseMap(raw);
    if (payload.isEmpty) {
      return const {
        'success': false,
        'errorCode': 'EMPTY_RESPONSE',
        'errorMsg': 'Unexpected empty response from server.',
        'data': <String, dynamic>{},
      };
    }
    final data = _extractNestedDataMap(payload);
    final errorCode = _readStringField(payload, ['errorCode', 'ErrorCode']);
    final errorMsg = _readStringField(payload, [
      'errorMsg',
      'ErrorMsg',
      'message',
    ]);
    final hasExplicitSuccess =
        payload.containsKey('success') || payload.containsKey('Success');
    final success = hasExplicitSuccess
        ? _readBoolField(payload, ['success', 'Success'])
        : errorCode.isEmpty;

    return {
      ...payload,
      'errorCode': errorCode,
      'errorMsg': errorMsg,
      'success': success,
      'data': data,
    };
  }

  Map<String, dynamic> _normalizeProfileResponseWithStatus(Response response) {
    final normalized = _normalizeProfileResponse(response.data);
    final status = response.statusCode ?? 0;
    if (status >= 200 && status < 300) return normalized;

    final code = _asCleanString(normalized['errorCode']);
    final message = _asCleanString(normalized['errorMsg']);
    return {
      ...normalized,
      'success': false,
      'errorCode': code.isNotEmpty ? code : 'HTTP$status',
      'errorMsg': message.isNotEmpty
          ? message
          : 'Request failed (HTTP $status).',
    };
  }

  bool _hasSerializerBodyError(dynamic raw) {
    final payload = _toResponseMap(raw);
    final errors = payload['errors'];
    if (errors is! Map) return false;

    final serializerErrors =
        errors['serializerErrors'] ??
        errors['SerializerErrors'] ??
        errors['serializerError'];
    if (serializerErrors is List && serializerErrors.isNotEmpty) {
      return serializerErrors.any(
        (item) =>
            item.toString().toLowerCase().contains('json tokens') ||
            item.toString().toLowerCase().contains(
              'lineNumber: 0'.toLowerCase(),
            ),
      );
    }
    final text = serializerErrors?.toString().toLowerCase() ?? '';
    return text.contains('json tokens') || text.contains('linenumber: 0');
  }

  Map<String, dynamic> _authHeaders({String? accessToken}) {
    final token = (accessToken ?? UserSession.token ?? '').trim();
    if (token.isEmpty) return const {};
    return {'Authorization': 'Bearer $token'};
  }

  Map<String, dynamic> _englishAuthHeaders({String? accessToken}) {
    return {..._authHeaders(accessToken: accessToken), 'Accept-Language': 'en'};
  }

  String _readStringFromPayloadAndData(
    Map<String, dynamic> payload,
    List<String> keys,
  ) {
    final direct = _readStringField(payload, keys);
    if (direct.isNotEmpty) return direct;
    final nested = _extractNestedDataMap(payload);
    if (identical(nested, payload)) return '';
    return _readStringField(nested, keys);
  }

  int _readIntFromPayloadAndData(
    Map<String, dynamic> payload,
    List<String> keys,
  ) {
    final direct = _readIntField(payload, keys);
    if (direct > 0) return direct;
    final nested = _extractNestedDataMap(payload);
    if (identical(nested, payload)) return 0;
    return _readIntField(nested, keys);
  }

  bool _isUnauthorizedResponse(Response<dynamic> response) {
    if (response.statusCode == 401) return true;
    final payload = _toResponseMap(response.data);
    final errorCode = _readStringFromPayloadAndData(payload, [
      'errorCode',
      'ErrorCode',
    ]).toUpperCase();
    return errorCode == 'AUTH401' || errorCode == 'UNAUTHORIZED';
  }

  bool _isRefreshFailureCode(String code) {
    final normalized = code.trim().toUpperCase();
    return normalized == 'REFRESH_INVALID' ||
        normalized == 'REFRESH_EXPIRED' ||
        normalized == 'AUTH401';
  }

  bool _isMissingEndpoint(Map<String, dynamic> payload) {
    final code = _asCleanString(payload['errorCode']).toUpperCase();
    if (code == 'HTTP404' || code == 'HTTP405') return true;
    final message = _asCleanString(payload['errorMsg']).toLowerCase();
    return message.contains('not found') || message.contains('no endpoint');
  }

  Future<bool> _refreshAccessTokenWithLock() async {
    final inFlight = _refreshInFlight;
    if (inFlight != null) {
      return inFlight;
    }

    final future = _refreshAccessToken();
    _refreshInFlight = future;
    try {
      return await future;
    } finally {
      if (identical(_refreshInFlight, future)) {
        _refreshInFlight = null;
      }
    }
  }

  Future<Response<dynamic>> _sendWithAuthRetry({
    required bool useEnglishHeaders,
    required Future<Response<dynamic>> Function(Map<String, dynamic> headers)
    send,
  }) async {
    Map<String, dynamic> buildHeaders() =>
        useEnglishHeaders ? _englishAuthHeaders() : _authHeaders();

    var response = await send(buildHeaders());
    if (!_isUnauthorizedResponse(response)) return response;

    final currentAccessToken = (UserSession.token ?? '').trim();
    if (currentAccessToken.isEmpty) return response;

    debugPrint(
      '[AuthService] AUTH401 detected. Attempting token refresh before retry.',
    );
    final refreshed = await _refreshAccessTokenWithLock();
    if (!refreshed) return response;

    response = await send(buildHeaders());
    return response;
  }

  Future<bool> _refreshAccessToken() async {
    final refreshToken = (UserSession.refreshToken ?? '').trim();
    if (refreshToken.isEmpty) {
      debugPrint('[AuthService] refresh skipped: no refresh token');
      return false;
    }

    try {
      final refreshResult = await refreshAuthToken(refreshToken: refreshToken);
      final success = refreshResult['success'] == true;
      final errorCode = _asCleanString(refreshResult['errorCode']);
      if (!success || errorCode.isNotEmpty) {
        if (_isRefreshFailureCode(errorCode) ||
            errorCode.trim().toUpperCase() == 'HTTP401') {
          await UserSession.markGuest();
        }
        return false;
      }

      final newAccessToken = _readStringFromPayloadAndData(refreshResult, [
        'accessToken',
        'AccessToken',
        'token',
        'Token',
        'jwt',
        'Jwt',
        'jwtToken',
        'JwtToken',
      ]);
      if (newAccessToken.isEmpty) {
        return false;
      }

      final newRefreshToken = _readStringFromPayloadAndData(refreshResult, [
        'refreshToken',
        'RefreshToken',
      ]);
      final accessTokenExpiresInSeconds =
          _readIntFromPayloadAndData(refreshResult, [
            'accessTokenExpiresInSeconds',
            'AccessTokenExpiresInSeconds',
            'accessTokenExpiresInSecond',
            'AccessTokenExpiresInSecond',
            'expiresInSeconds',
            'ExpiresInSeconds',
          ]);
      final refreshTokenExpiresInSeconds =
          _readIntFromPayloadAndData(refreshResult, [
            'refreshTokenExpiresInSeconds',
            'RefreshTokenExpiresInSeconds',
            'refreshExpiresInSeconds',
            'RefreshExpiresInSeconds',
          ]);

      await UserSession.markAuthenticated(
        token: newAccessToken,
        refreshToken: newRefreshToken.isEmpty ? null : newRefreshToken,
        accessTokenExpiresInSeconds: accessTokenExpiresInSeconds > 0
            ? accessTokenExpiresInSeconds
            : null,
        refreshTokenExpiresInSeconds: refreshTokenExpiresInSeconds > 0
            ? refreshTokenExpiresInSeconds
            : null,
      );
      return true;
    } catch (e) {
      debugPrint('[AuthService] refresh failed with exception: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> refreshAuthToken({String? refreshToken}) async {
    final tokenToUse = (refreshToken ?? UserSession.refreshToken ?? '').trim();
    if (tokenToUse.isEmpty) {
      return const {
        'success': false,
        'errorCode': 'REFRESH_INVALID',
        'errorMsg': 'Refresh token is missing.',
        'data': <String, dynamic>{},
      };
    }

    debugPrint('[AuthService] refreshAuthToken → $_baseUrl$_refreshEndpoint');

    final response = await _dio
        .post(
          _refreshEndpoint,
          data: {'refreshToken': tokenToUse},
          options: Options(headers: {'Content-Type': 'application/json'}),
        )
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw TimeoutException('Refresh token timed out'),
        );

    debugPrint(
      '[AuthService] refreshAuthToken response: ${response.statusCode} → ${response.data}',
    );

    return _normalizeProfileResponseWithStatus(response);
  }

  Future<Map<String, dynamic>> logout({String? refreshToken}) async {
    final resolvedRefreshToken =
        (refreshToken ?? UserSession.refreshToken ?? '').trim();
    final payload = <String, dynamic>{};
    if (resolvedRefreshToken.isNotEmpty) {
      payload['refreshToken'] = resolvedRefreshToken;
    }

    debugPrint('[AuthService] logout → $_baseUrl$_logoutEndpoint');
    final response = await _dio
        .post(
          _logoutEndpoint,
          data: payload,
          options: Options(
            headers: {
              ..._authHeaders(),
              'Accept-Language': 'en',
              'Content-Type': 'application/json',
            },
          ),
        )
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw TimeoutException('Logout request timed out'),
        );

    debugPrint(
      '[AuthService] logout response: ${response.statusCode} → ${response.data}',
    );
    return _normalizeProfileResponseWithStatus(response);
  }

  Future<Map<String, dynamic>> requestSignupOtp({
    required String fullName,
    required String phoneNumber,
  }) async {
    debugPrint(
      '[AuthService] requestSignupOtp → $phoneNumber to $_baseUrl/auth/signup/request-otp',
    );

    final response = await _dio
        .post(
          '/auth/signup/request-otp',
          data: {'fullName': fullName, 'phoneNumber': phoneNumber},
        )
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw TimeoutException('OTP request timed out'),
        );

    debugPrint(
      '[AuthService] requestSignupOtp response: ${response.statusCode} → ${response.data}',
    );

    final data = _toResponseMap(response.data);

    final errorCode = _readStringField(data, ['errorCode', 'ErrorCode']);
    final errorMsg = _readStringField(data, [
      'errorMsg',
      'ErrorMsg',
      'message',
    ]);
    final sent = _readBoolField(data, ['sent', 'Sent']);

    return {
      ...data,
      'errorCode': errorCode,
      'errorMsg': errorMsg,
      'sent': sent,
    };
  }

  Future<Map<String, dynamic>> verifySignupOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    debugPrint(
      '[AuthService] verifySignupOtp → $phoneNumber to $_baseUrl/auth/signup/verify-otp',
    );

    final response = await _dio
        .post(
          '/auth/signup/verify-otp',
          data: {'phoneNumber': phoneNumber, 'otpCode': otpCode},
        )
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw TimeoutException('OTP verification timed out'),
        );

    debugPrint(
      '[AuthService] verifySignupOtp response: ${response.statusCode} → ${response.data}',
    );

    final data = _toResponseMap(response.data);

    final errorCode = _readStringField(data, ['errorCode', 'ErrorCode']);
    final errorMsg = _readStringField(data, [
      'errorMsg',
      'ErrorMsg',
      'message',
    ]);
    final success = _readBoolField(data, ['success', 'Success']);

    return {
      ...data,
      'errorCode': errorCode,
      'errorMsg': errorMsg,
      'success': success,
    };
  }

  Future<Map<String, dynamic>> requestOtp(String phoneNumber) async {
    debugPrint(
      '[AuthService] requestOtp → $phoneNumber to $_baseUrl/auth/login/request-otp',
    );

    final response = await _dio
        .post('/auth/login/request-otp', data: {'phoneNumber': phoneNumber})
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw TimeoutException('OTP request timed out'),
        );

    debugPrint(
      '[AuthService] requestOtp response: ${response.statusCode} → ${response.data}',
    );

    final data = _toResponseMap(response.data);

    final errorCode = _readStringField(data, ['errorCode', 'ErrorCode']);
    final errorMsg = _readStringField(data, [
      'errorMsg',
      'ErrorMsg',
      'message',
    ]);
    final sent = _readBoolField(data, ['sent', 'Sent']);

    return {
      ...data,
      'errorCode': errorCode,
      'errorMsg': errorMsg,
      'sent': sent,
    };
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    debugPrint('[AuthService] verifyOtp → $phoneNumber');

    final response = await _dio
        .post(
          '/auth/login/verify-otp',
          data: {'phoneNumber': phoneNumber, 'otpCode': otpCode},
        )
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw TimeoutException('OTP verification timed out'),
        );

    debugPrint(
      '[AuthService] verifyOtp response: ${response.statusCode} → ${response.data}',
    );

    final data = _toResponseMap(response.data);

    final errorCode = _readStringField(data, ['errorCode', 'ErrorCode']);
    final errorMsg = _readStringField(data, [
      'errorMsg',
      'ErrorMsg',
      'message',
    ]);
    final success = _readBoolField(data, ['success', 'Success']);

    return {
      ...data,
      'errorCode': errorCode,
      'errorMsg': errorMsg,
      'success': success,
    };
  }

  Future<Map<String, dynamic>> verifyPin({
    required String phoneNumber,
    required String pinCode,
  }) async {
    debugPrint('[AuthService] verifyPin → $phoneNumber');

    final response = await _dio
        .post(
          _verifyPinEndpoint,
          data: {'phoneNumber': phoneNumber, 'pinCode': pinCode},
        )
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw TimeoutException('PIN verification timed out'),
        );

    debugPrint(
      '[AuthService] verifyPin response: ${response.statusCode} → ${response.data}',
    );

    return _normalizeProfileResponseWithStatus(response);
  }

  bool? _parsePhoneRegisteredFlag(Map<String, dynamic> payload) {
    final errorCode = _asCleanString(payload['errorCode']).toUpperCase();
    if (errorCode == 'USR404') return false;

    final data = _extractNestedDataMap(payload);
    final flagKeys = <String>[
      'isRegistered',
      'registered',
      'exists',
      'isExist',
      'hasAccount',
      'isActive',
    ];
    for (final key in flagKeys) {
      if (data.containsKey(key)) {
        return _readBoolField(data, [key]);
      }
      if (payload.containsKey(key)) {
        return _readBoolField(payload, [key]);
      }
    }

    if (payload['success'] == true && errorCode.isEmpty) {
      return true;
    }
    return null;
  }

  Future<Map<String, dynamic>> _checkPhoneViaGet({
    required String endpoint,
    required String phoneNumber,
  }) async {
    final response = await _dio
        .get(endpoint, queryParameters: {'phoneNumber': phoneNumber})
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw TimeoutException('Check phone timed out'),
        );
    return _normalizeProfileResponseWithStatus(response);
  }

  Future<Map<String, dynamic>> _checkPhoneViaPost({
    required String endpoint,
    required String phoneNumber,
  }) async {
    final response = await _dio
        .post(endpoint, data: {'phoneNumber': phoneNumber})
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw TimeoutException('Check phone timed out'),
        );
    return _normalizeProfileResponseWithStatus(response);
  }

  Future<bool?> checkLoginPhoneRegistered({required String phoneNumber}) async {
    final endpoints = <String>[
      _checkLoginPhoneEndpoint,
      '/auth/login/check-user',
    ];

    for (final endpoint in endpoints) {
      debugPrint(
        '[AuthService] checkLoginPhoneRegistered GET → $_baseUrl$endpoint',
      );
      final getResult = await _checkPhoneViaGet(
        endpoint: endpoint,
        phoneNumber: phoneNumber,
      );
      final parsedGet = _parsePhoneRegisteredFlag(getResult);
      if (parsedGet != null) return parsedGet;
      if (!_isMissingEndpoint(getResult)) {
        final code = _asCleanString(getResult['errorCode']).toUpperCase();
        if (code == 'USR404') return false;
      }

      debugPrint(
        '[AuthService] checkLoginPhoneRegistered POST → $_baseUrl$endpoint',
      );
      final postResult = await _checkPhoneViaPost(
        endpoint: endpoint,
        phoneNumber: phoneNumber,
      );
      final parsedPost = _parsePhoneRegisteredFlag(postResult);
      if (parsedPost != null) return parsedPost;
      if (!_isMissingEndpoint(postResult)) {
        final code = _asCleanString(postResult['errorCode']).toUpperCase();
        if (code == 'USR404') return false;
      }
    }

    return null;
  }

  Future<Map<String, dynamic>> requestForgotPinOtp({
    required String phoneNumber,
  }) async {
    debugPrint(
      '[AuthService] requestForgotPinOtp → $phoneNumber to $_baseUrl$_forgotPinRequestOtpEndpoint',
    );

    final response = await _dio
        .post(_forgotPinRequestOtpEndpoint, data: {'phoneNumber': phoneNumber})
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () =>
              throw TimeoutException('Forgot PIN OTP request timed out'),
        );

    debugPrint(
      '[AuthService] requestForgotPinOtp response: ${response.statusCode} → ${response.data}',
    );

    final normalized = _normalizeProfileResponseWithStatus(response);
    if (_isMissingEndpoint(normalized)) {
      debugPrint(
        '[AuthService] requestForgotPinOtp fallback to /auth/login/request-otp',
      );
      return requestOtp(phoneNumber);
    }
    return normalized;
  }

  Future<Map<String, dynamic>> verifyForgotPinOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    debugPrint('[AuthService] verifyForgotPinOtp → $phoneNumber');

    final response = await _dio
        .post(
          _forgotPinVerifyOtpEndpoint,
          data: {'phoneNumber': phoneNumber, 'otpCode': otpCode},
        )
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () =>
              throw TimeoutException('Forgot PIN OTP verification timed out'),
        );

    debugPrint(
      '[AuthService] verifyForgotPinOtp response: ${response.statusCode} → ${response.data}',
    );

    final normalized = _normalizeProfileResponseWithStatus(response);
    if (_isMissingEndpoint(normalized)) {
      debugPrint(
        '[AuthService] verifyForgotPinOtp fallback to /auth/login/verify-otp',
      );
      return verifyOtp(phoneNumber: phoneNumber, otpCode: otpCode);
    }
    return normalized;
  }

  Future<Map<String, dynamic>> setPin({
    required String pinCode,
    String? confirmPinCode,
    String? accessToken,
  }) async {
    final payload = <String, dynamic>{
      'pinCode': pinCode,
      'confirmPinCode': _asCleanString(confirmPinCode).isEmpty
          ? pinCode
          : confirmPinCode,
    };

    debugPrint('[AuthService] setPin → $_baseUrl$_setPinEndpoint');

    final explicitToken = (accessToken ?? '').trim();
    final response = explicitToken.isNotEmpty
        ? await _dio
              .post(
                _setPinEndpoint,
                data: payload,
                options: Options(
                  headers: _authHeaders(accessToken: explicitToken),
                ),
              )
              .timeout(
                const Duration(seconds: 20),
                onTimeout: () => throw TimeoutException('Set PIN timed out'),
              )
        : await _sendWithAuthRetry(
            useEnglishHeaders: false,
            send: (headers) => _dio
                .post(
                  _setPinEndpoint,
                  data: payload,
                  options: Options(headers: headers),
                )
                .timeout(
                  const Duration(seconds: 20),
                  onTimeout: () => throw TimeoutException('Set PIN timed out'),
                ),
          );

    debugPrint(
      '[AuthService] setPin response: ${response.statusCode} → ${response.data}',
    );

    return _normalizeProfileResponseWithStatus(response);
  }

  Future<Map<String, dynamic>> resetPin({
    required String pinCode,
    String? confirmPinCode,
    String? resetToken,
    String? phoneNumber,
  }) async {
    final payload = <String, dynamic>{
      'pinCode': pinCode,
      'confirmPinCode': _asCleanString(confirmPinCode).isEmpty
          ? pinCode
          : confirmPinCode,
    };
    if (_asCleanString(phoneNumber).isNotEmpty) {
      payload['phoneNumber'] = phoneNumber;
    }
    if (_asCleanString(resetToken).isNotEmpty) {
      payload['resetToken'] = resetToken;
    }

    debugPrint('[AuthService] resetPin → $_baseUrl$_resetPinEndpoint');

    final response = await _sendWithAuthRetry(
      useEnglishHeaders: false,
      send: (headers) => _dio
          .post(
            _resetPinEndpoint,
            data: payload,
            options: Options(headers: headers),
          )
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () => throw TimeoutException('Reset PIN timed out'),
          ),
    );

    debugPrint(
      '[AuthService] resetPin response: ${response.statusCode} → ${response.data}',
    );

    return _normalizeProfileResponseWithStatus(response);
  }

  Future<Map<String, dynamic>> getSignupUser({required int userId}) async {
    debugPrint('[AuthService] getSignupUser → $userId');

    final response = await _dio
        .get('/auth/signup/user/$userId')
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw TimeoutException('Get user timed out'),
        );

    debugPrint(
      '[AuthService] getSignupUser response: ${response.statusCode} → ${response.data}',
    );

    final data = _toResponseMap(response.data);

    final errorCode = _readStringField(data, ['errorCode', 'ErrorCode']);
    final errorMsg = _readStringField(data, [
      'errorMsg',
      'ErrorMsg',
      'message',
    ]);
    final success = _readBoolField(data, ['success', 'Success']);
    final normalizedUserId = _readIntField(data, ['userId', 'UserId']);
    final fullName = _readStringField(data, ['fullName', 'FullName']);
    final phoneNumber = _readStringField(data, [
      'phoneNumber',
      'PhoneNumber',
      'phone',
      'Phone',
    ]);
    final isVerified = _readBoolField(data, ['isVerified', 'IsVerified']);

    return {
      ...data,
      'errorCode': errorCode,
      'errorMsg': errorMsg,
      'success': success,
      'userId': normalizedUserId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'isVerified': isVerified,
    };
  }

  Future<Map<String, dynamic>> getUserProfile({String? accessToken}) async {
    debugPrint('[AuthService] getUserProfile → $_baseUrl/user/me');

    final explicitToken = (accessToken ?? '').trim();
    final response = explicitToken.isNotEmpty
        ? await _dio
              .get(
                '/user/me',
                options: Options(
                  headers: _authHeaders(accessToken: explicitToken),
                ),
              )
              .timeout(
                const Duration(seconds: 20),
                onTimeout: () =>
                    throw TimeoutException('Get profile timed out'),
              )
        : await _sendWithAuthRetry(
            useEnglishHeaders: false,
            send: (headers) => _dio
                .get('/user/me', options: Options(headers: headers))
                .timeout(
                  const Duration(seconds: 20),
                  onTimeout: () =>
                      throw TimeoutException('Get profile timed out'),
                ),
          );

    debugPrint(
      '[AuthService] getUserProfile response: ${response.statusCode} → ${response.data}',
    );

    return _normalizeProfileResponseWithStatus(response);
  }

  Future<Map<String, dynamic>> getMallMembershipQrProfile() async {
    debugPrint(
      '[AuthService] getMallMembershipQrProfile → $_baseUrl$_mallMembershipQrEndpoint',
    );

    final response = await _sendWithAuthRetry(
      useEnglishHeaders: true,
      send: (headers) => _dio
          .get(_mallMembershipQrEndpoint, options: Options(headers: headers))
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () =>
                throw TimeoutException('Get mall QR data timed out'),
          ),
    );

    debugPrint(
      '[AuthService] getMallMembershipQrProfile response: ${response.statusCode} → ${response.data}',
    );

    return _normalizeProfileResponseWithStatus(response);
  }

  Future<Map<String, dynamic>> updateUserProfile({
    required String fullName,
    required String dateOfBirth,
    required String address,
  }) async {
    final payload = <String, dynamic>{'fullName': fullName, 'address': address};
    if (dateOfBirth.isNotEmpty) {
      payload['dateOfBirth'] = dateOfBirth;
    }

    debugPrint('[AuthService] updateUserProfile payload: $payload');

    final response = await _sendWithAuthRetry(
      useEnglishHeaders: false,
      send: (headers) => _dio
          .put(
            '/user/me',
            data: payload,
            options: Options(headers: headers),
          )
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () => throw TimeoutException('Update profile timed out'),
          ),
    );

    debugPrint(
      '[AuthService] updateUserProfile response: ${response.statusCode} → ${response.data}',
    );

    return _normalizeProfileResponseWithStatus(response);
  }

  Future<Map<String, dynamic>> uploadUserAvatar({
    required String filePath,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Selected profile image was not found.');
    }

    final candidateEndpoints = <String>[
      _avatarUploadEndpoint,
      _avatarUploadLegacyEndpoint,
    ];

    for (var i = 0; i < candidateEndpoints.length; i++) {
      final endpoint = candidateEndpoints[i];
      debugPrint('[AuthService] uploadUserAvatar → $_baseUrl$endpoint');

      final response = await _sendWithAuthRetry(
        useEnglishHeaders: false,
        send: (headers) async {
          final formData = FormData.fromMap({
            'avatar': await MultipartFile.fromFile(
              file.path,
              filename: file.uri.pathSegments.isEmpty
                  ? 'avatar.jpg'
                  : file.uri.pathSegments.last,
            ),
          });

          return _dio
              .post(
                endpoint,
                data: formData,
                // Keep only auth headers; Dio will attach multipart boundary.
                options: Options(headers: headers),
              )
              .timeout(
                const Duration(seconds: 25),
                onTimeout: () =>
                    throw TimeoutException('Upload avatar timed out'),
              );
        },
      );

      debugPrint(
        '[AuthService] uploadUserAvatar response ($endpoint): ${response.statusCode} → ${response.data}',
      );

      final normalized = _normalizeProfileResponseWithStatus(response);
      final success =
          normalized['success'] == true &&
          _asCleanString(normalized['errorCode']).isEmpty;
      if (success) return normalized;

      final shouldTryNext =
          i < candidateEndpoints.length - 1 && _isMissingEndpoint(normalized);
      if (!shouldTryNext) {
        return normalized;
      }

      debugPrint(
        '[AuthService] uploadUserAvatar fallback to alternate endpoint after missing route: $endpoint',
      );
    }

    return const {
      'success': false,
      'errorCode': 'HTTP404',
      'errorMsg': 'Upload avatar endpoint not found.',
      'data': <String, dynamic>{},
    };
  }

  Future<Map<String, dynamic>> getLoyaltyRewards({
    String? category,
    String? sort,
    int? page,
    int? pageSize,
  }) async {
    final query = <String, dynamic>{};
    if (_asCleanString(category).isNotEmpty) query['category'] = category;
    if (_asCleanString(sort).isNotEmpty) query['sort'] = sort;
    if (page != null && page > 0) query['page'] = page;
    if (pageSize != null && pageSize > 0) query['pageSize'] = pageSize;

    debugPrint(
      '[AuthService] getLoyaltyRewards → $_baseUrl$_loyaltyRewardsEndpoint query=$query',
    );

    var response = await _sendWithAuthRetry(
      useEnglishHeaders: true,
      send: (headers) => _dio
          .get(
            _loyaltyRewardsEndpoint,
            queryParameters: query,
            options: Options(headers: headers),
          )
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () =>
                throw TimeoutException('Get loyalty rewards timed out'),
          ),
    );

    debugPrint(
      '[AuthService] getLoyaltyRewards response: ${response.statusCode} → ${response.data}',
    );

    if (response.statusCode == 400 && _hasSerializerBodyError(response.data)) {
      debugPrint(
        '[AuthService] getLoyaltyRewards retrying with JSON body for backend compatibility',
      );
      response = await _sendWithAuthRetry(
        useEnglishHeaders: true,
        send: (headers) => _dio
            .get(
              _loyaltyRewardsEndpoint,
              data: query,
              options: Options(
                headers: {...headers, 'Content-Type': 'application/json'},
              ),
            )
            .timeout(
              const Duration(seconds: 20),
              onTimeout: () =>
                  throw TimeoutException('Get loyalty rewards timed out'),
            ),
      );

      debugPrint(
        '[AuthService] getLoyaltyRewards retry response: ${response.statusCode} → ${response.data}',
      );
    }

    return _normalizeProfileResponseWithStatus(response);
  }

  Future<Map<String, dynamic>> getLoyaltyRewardDetail({
    required String rewardId,
  }) async {
    final response = await _sendWithAuthRetry(
      useEnglishHeaders: true,
      send: (headers) => _dio
          .get(
            '$_loyaltyRewardsEndpoint/$rewardId',
            options: Options(headers: headers),
          )
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () =>
                throw TimeoutException('Get loyalty reward detail timed out'),
          ),
    );

    return _normalizeProfileResponseWithStatus(response);
  }

  Future<Map<String, dynamic>> createLoyaltyExchange({
    required Map<String, dynamic> payload,
    String? idempotencyKey,
  }) async {
    final key = _asCleanString(idempotencyKey);

    debugPrint(
      '[AuthService] createLoyaltyExchange → $_baseUrl$_loyaltyExchangesEndpoint payload=$payload',
    );

    final response = await _sendWithAuthRetry(
      useEnglishHeaders: true,
      send: (headers) {
        final effectiveHeaders = <String, dynamic>{...headers};
        if (key.isNotEmpty) {
          effectiveHeaders['Idempotency-Key'] = key;
        }
        return _dio
            .post(
              _loyaltyExchangesEndpoint,
              data: payload,
              options: Options(headers: effectiveHeaders),
            )
            .timeout(
              const Duration(seconds: 20),
              onTimeout: () =>
                  throw TimeoutException('Create loyalty exchange timed out'),
            );
      },
    );

    debugPrint(
      '[AuthService] createLoyaltyExchange response: ${response.statusCode} → ${response.data}',
    );

    return _normalizeProfileResponseWithStatus(response);
  }

  Future<Map<String, dynamic>> getLoyaltyExchanges({
    String? status,
    int? page,
    int? pageSize,
  }) async {
    final query = <String, dynamic>{};
    if (_asCleanString(status).isNotEmpty) query['status'] = status;
    if (page != null && page > 0) query['page'] = page;
    if (pageSize != null && pageSize > 0) query['pageSize'] = pageSize;

    debugPrint(
      '[AuthService] getLoyaltyExchanges → $_baseUrl$_loyaltyExchangesEndpoint query=$query',
    );

    var response = await _sendWithAuthRetry(
      useEnglishHeaders: true,
      send: (headers) => _dio
          .get(
            _loyaltyExchangesEndpoint,
            queryParameters: query,
            options: Options(headers: headers),
          )
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () =>
                throw TimeoutException('Get loyalty exchanges timed out'),
          ),
    );

    debugPrint(
      '[AuthService] getLoyaltyExchanges response: ${response.statusCode} → ${response.data}',
    );

    if (response.statusCode == 400 && _hasSerializerBodyError(response.data)) {
      debugPrint(
        '[AuthService] getLoyaltyExchanges retrying with JSON body for backend compatibility',
      );
      response = await _sendWithAuthRetry(
        useEnglishHeaders: true,
        send: (headers) => _dio
            .get(
              _loyaltyExchangesEndpoint,
              data: query,
              options: Options(
                headers: {...headers, 'Content-Type': 'application/json'},
              ),
            )
            .timeout(
              const Duration(seconds: 20),
              onTimeout: () =>
                  throw TimeoutException('Get loyalty exchanges timed out'),
            ),
      );

      debugPrint(
        '[AuthService] getLoyaltyExchanges retry response: ${response.statusCode} → ${response.data}',
      );
    }

    return _normalizeProfileResponseWithStatus(response);
  }

  Future<Map<String, dynamic>> getLoyaltyExchangeDetail({
    required String exchangeId,
  }) async {
    debugPrint(
      '[AuthService] getLoyaltyExchangeDetail → $_baseUrl$_loyaltyExchangesEndpoint/$exchangeId',
    );

    var response = await _sendWithAuthRetry(
      useEnglishHeaders: true,
      send: (headers) => _dio
          .get(
            '$_loyaltyExchangesEndpoint/$exchangeId',
            options: Options(headers: headers),
          )
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () =>
                throw TimeoutException('Get loyalty exchange detail timed out'),
          ),
    );

    debugPrint(
      '[AuthService] getLoyaltyExchangeDetail response: ${response.statusCode} → ${response.data}',
    );

    if (response.statusCode == 400 && _hasSerializerBodyError(response.data)) {
      debugPrint(
        '[AuthService] getLoyaltyExchangeDetail retrying with JSON body for backend compatibility',
      );
      response = await _sendWithAuthRetry(
        useEnglishHeaders: true,
        send: (headers) => _dio
            .get(
              '$_loyaltyExchangesEndpoint/$exchangeId',
              data: {'exchangeId': exchangeId},
              options: Options(
                headers: {...headers, 'Content-Type': 'application/json'},
              ),
            )
            .timeout(
              const Duration(seconds: 20),
              onTimeout: () => throw TimeoutException(
                'Get loyalty exchange detail timed out',
              ),
            ),
      );

      debugPrint(
        '[AuthService] getLoyaltyExchangeDetail retry response: ${response.statusCode} → ${response.data}',
      );
    }

    return _normalizeProfileResponseWithStatus(response);
  }

  Future<Map<String, dynamic>> getLoyaltyPointsHistory({
    String? category,
    int? page,
    int? pageSize,
  }) async {
    final query = <String, dynamic>{};
    if (_asCleanString(category).isNotEmpty) query['category'] = category;
    if (page != null && page > 0) query['page'] = page;
    if (pageSize != null && pageSize > 0) query['pageSize'] = pageSize;

    debugPrint(
      '[AuthService] getLoyaltyPointsHistory → $_baseUrl$_loyaltyPointsHistoryEndpoint query=$query',
    );

    var response = await _sendWithAuthRetry(
      useEnglishHeaders: true,
      send: (headers) => _dio
          .get(
            _loyaltyPointsHistoryEndpoint,
            queryParameters: query,
            options: Options(headers: headers),
          )
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () =>
                throw TimeoutException('Get loyalty points history timed out'),
          ),
    );

    debugPrint(
      '[AuthService] getLoyaltyPointsHistory response: ${response.statusCode} → ${response.data}',
    );

    if (response.statusCode == 400 && _hasSerializerBodyError(response.data)) {
      debugPrint(
        '[AuthService] getLoyaltyPointsHistory retrying with JSON body for backend compatibility',
      );
      response = await _sendWithAuthRetry(
        useEnglishHeaders: true,
        send: (headers) => _dio
            .get(
              _loyaltyPointsHistoryEndpoint,
              data: query,
              options: Options(
                headers: {...headers, 'Content-Type': 'application/json'},
              ),
            )
            .timeout(
              const Duration(seconds: 20),
              onTimeout: () => throw TimeoutException(
                'Get loyalty points history timed out',
              ),
            ),
      );

      debugPrint(
        '[AuthService] getLoyaltyPointsHistory retry response: ${response.statusCode} → ${response.data}',
      );
    }

    return _normalizeProfileResponseWithStatus(response);
  }

  Future<Map<String, dynamic>> getLoyaltyPointsExpiry({
    String? category,
  }) async {
    final query = <String, dynamic>{};
    if (_asCleanString(category).isNotEmpty) query['category'] = category;

    debugPrint(
      '[AuthService] getLoyaltyPointsExpiry → $_baseUrl$_loyaltyPointsExpiryEndpoint query=$query',
    );

    var response = await _sendWithAuthRetry(
      useEnglishHeaders: true,
      send: (headers) => _dio
          .get(
            _loyaltyPointsExpiryEndpoint,
            queryParameters: query,
            options: Options(headers: headers),
          )
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () =>
                throw TimeoutException('Get loyalty points expiry timed out'),
          ),
    );

    debugPrint(
      '[AuthService] getLoyaltyPointsExpiry response: ${response.statusCode} → ${response.data}',
    );

    if (response.statusCode == 400 && _hasSerializerBodyError(response.data)) {
      debugPrint(
        '[AuthService] getLoyaltyPointsExpiry retrying with JSON body for backend compatibility',
      );
      response = await _sendWithAuthRetry(
        useEnglishHeaders: true,
        send: (headers) => _dio
            .get(
              _loyaltyPointsExpiryEndpoint,
              data: query,
              options: Options(
                headers: {...headers, 'Content-Type': 'application/json'},
              ),
            )
            .timeout(
              const Duration(seconds: 20),
              onTimeout: () =>
                  throw TimeoutException('Get loyalty points expiry timed out'),
            ),
      );

      debugPrint(
        '[AuthService] getLoyaltyPointsExpiry retry response: ${response.statusCode} → ${response.data}',
      );
    }

    return _normalizeProfileResponseWithStatus(response);
  }
}
