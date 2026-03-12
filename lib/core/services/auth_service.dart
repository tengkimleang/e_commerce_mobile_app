import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:5058',
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

Future<Map<String, dynamic>> requestOtp(String phoneNumber) async {
  final response = await _dio.post(
    '/auth/request-otp',
    data: {
      'phoneNumber': phoneNumber,
    },
  );

  return response.data;
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