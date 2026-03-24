import 'dart:async' show TimeoutException;
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
      headers: {
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
    ),
  );

  Future<Map<String, dynamic>> requestOtp(String phoneNumber) async {
    debugPrint('[AuthService] requestOtp → $phoneNumber to $_baseUrl/auth/login/request-otp');

    final response = await _dio.post(
      '/auth/login/request-otp',
      data: {
        'phoneNumber': phoneNumber,
      },
    ).timeout(
      const Duration(seconds: 20),
      onTimeout: () => throw TimeoutException('OTP request timed out'),
    );

    debugPrint('[AuthService] requestOtp response: ${response.statusCode} → ${response.data}');

    final data = response.data;

    // Handle non-Map responses (plain text, boolean, etc.)
    if (data is! Map<String, dynamic>) {
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'sent': true, 'raw': data};
      }
      throw Exception('Unexpected response format from server.');
    }

    // Check 'sent' field (requestOtp response) or 'success' as fallback
    final sent = data['sent'] ?? data['success'];
    if (sent != true) {
      throw Exception(
        data['errorMsg'] ?? data['message'] ?? 'Failed to send OTP. Please try again.',
      );
    }
    return data;
  }

  Future<void> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    debugPrint('[AuthService] verifyOtp → $phoneNumber');

    final response = await _dio.post(
      '/auth/login/verify-otp',
      data: {
        'phoneNumber': phoneNumber,
        'otpCode': otpCode,
      },
    ).timeout(
      const Duration(seconds: 20),
      onTimeout: () => throw TimeoutException('OTP verification timed out'),
    );

    debugPrint('[AuthService] verifyOtp response: ${response.statusCode} → ${response.data}');

    final data = response.data;

    if (data is! Map<String, dynamic>) {
      if (response.statusCode == 200 || response.statusCode == 201) return;
      throw Exception('Unexpected response format from server.');
    }

    final success = data['success'] ?? data['Success'];
    if (success != true && success != 'true' && success != 1) {
      throw Exception(data['errorMsg'] ?? data['message'] ?? 'OTP verification failed');
    }
  }
}