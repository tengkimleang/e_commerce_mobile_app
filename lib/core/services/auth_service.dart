import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:5058',
      headers: {
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
    ),
  );

  Future<Map<String, dynamic>> requestOtp(String phoneNumber) async {
    final response = await _dio.post(
      '/auth/request-otp',
      data: {
        'phoneNumber': phoneNumber,
      },
    );

    final data = response.data;
    if (data == null || data['success'] != true) {
      throw Exception(data?['errorMsg'] ?? 'Failed to send OTP. Please try again.');
    }
    return data;
  }

  Future<void> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    final response = await _dio.post(
      '/auth/verify-otp',
      data: {
        'phoneNumber': phoneNumber,
        'otpCode': otpCode,
      },
    );

    final data = response.data;
    if (data == null || data['success'] != true) {
      throw Exception(data?['errorMsg'] ?? 'OTP verification failed');
    }
  }
}