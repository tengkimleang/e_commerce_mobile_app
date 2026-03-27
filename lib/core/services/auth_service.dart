import 'dart:async' show TimeoutException;
import 'dart:convert' show jsonDecode;
import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AuthService {
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
}
