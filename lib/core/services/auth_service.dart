import 'dart:async' show TimeoutException;
import 'dart:convert' show jsonDecode;
import 'dart:io' show File, Platform;
import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static const _mallMembershipQrEndpoint = '/user/me/mall-qr';

  static String get _baseUrl {
    // Android emulator uses 10.0.2.2 to reach host; iOS uses localhost
    return Platform.isAndroid
        ? 'http://192.168.100.39:5058'
        : 'http://localhost:5058';
  }

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      headers: {'Content-Type': 'application/json'},
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
    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) {
        throw Exception('Unexpected empty response from server.');
      }
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    }
    throw Exception('Unexpected response format from server.');
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

  Map<String, dynamic> _authHeaders({String? accessToken}) {
    final token = (accessToken ?? UserSession.token ?? '').trim();
    if (token.isEmpty) return const {};
    return {'Authorization': 'Bearer $token'};
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

    final response = await _dio
        .get(
          '/user/me',
          options: Options(headers: _authHeaders(accessToken: accessToken)),
        )
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw TimeoutException('Get profile timed out'),
        );

    debugPrint(
      '[AuthService] getUserProfile response: ${response.statusCode} → ${response.data}',
    );

    return _normalizeProfileResponse(response.data);
  }

  Future<Map<String, dynamic>> getMallMembershipQrProfile() async {
    debugPrint(
      '[AuthService] getMallMembershipQrProfile → $_baseUrl$_mallMembershipQrEndpoint',
    );

    final response = await _dio
        .get(
          _mallMembershipQrEndpoint,
          options: Options(headers: _authHeaders()),
        )
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw TimeoutException('Get mall QR data timed out'),
        );

    debugPrint(
      '[AuthService] getMallMembershipQrProfile response: ${response.statusCode} → ${response.data}',
    );

    return _normalizeProfileResponse(response.data);
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

    final response = await _dio
        .put(
          '/user/me',
          data: payload,
          options: Options(headers: _authHeaders()),
        )
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw TimeoutException('Update profile timed out'),
        );

    debugPrint(
      '[AuthService] updateUserProfile response: ${response.statusCode} → ${response.data}',
    );

    return _normalizeProfileResponse(response.data);
  }

  Future<Map<String, dynamic>> uploadUserAvatar({
    required String filePath,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Selected profile image was not found.');
    }

    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        file.path,
        filename: file.uri.pathSegments.isEmpty
            ? 'avatar.jpg'
            : file.uri.pathSegments.last,
      ),
    });

    final response = await _dio
        .post(
          '/user/me/avatar',
          data: formData,
          options: Options(
            headers: {..._authHeaders(), 'Content-Type': 'multipart/form-data'},
          ),
        )
        .timeout(
          const Duration(seconds: 25),
          onTimeout: () => throw TimeoutException('Upload avatar timed out'),
        );

    debugPrint(
      '[AuthService] uploadUserAvatar response: ${response.statusCode} → ${response.data}',
    );

    return _normalizeProfileResponse(response.data);
  }
}
