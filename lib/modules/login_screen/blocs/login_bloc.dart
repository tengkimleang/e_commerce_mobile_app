import 'dart:async' show TimeoutException;
import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_mobile_app/modules/login_screen/blocs/login_event.dart';
import 'package:e_commerce_mobile_app/modules/login_screen/blocs/login_state.dart';
import 'package:e_commerce_mobile_app/modules/login_screen/models/login_model.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginInitial()) {
    on<PhoneChanged>(_onPhoneChanged);
    on<LoginPressed>(_onLoginPressed);
  }

  final AuthService _authService = AuthService();
  String _currentPhoneNumber = '';

  bool _isValidPhone(String phone) {
    final regex = RegExp(r'^0\d{8,9}$');
    return regex.hasMatch(phone);
  }

  Future<void> _onPhoneChanged(
    PhoneChanged event,
    Emitter<LoginState> emit,
  ) async {
    _currentPhoneNumber = event.phoneNumber;

    emit(
      LoginUpdated(
        loginModel: LoginModel(phoneNumber: _currentPhoneNumber),
        isPhoneValid: _isValidPhone(_currentPhoneNumber),
      ),
    );
  }

  Future<void> _onLoginPressed(
    LoginPressed event,
    Emitter<LoginState> emit,
  ) async {
    final phoneToSubmit = _currentPhoneNumber;

    if (!_isValidPhone(phoneToSubmit)) {
      emit(
        LoginUpdated(
          loginModel: LoginModel(phoneNumber: phoneToSubmit),
          isPhoneValid: false,
        ),
      );
      emit(const LoginError('Phone number must start with 0 and be valid'));
      return;
    }

    emit(const LoginLoading());
    debugPrint('[LoginBloc] checking phone registration for $phoneToSubmit');

    try {
      final isRegistered = await _authService.checkLoginPhoneRegistered(
        phoneNumber: phoneToSubmit,
      );
      if (isRegistered == false) {
        emit(
          LoginPhoneNotRegistered(
            phoneNumber: phoneToSubmit,
            message: 'This phone number is not registered yet.',
          ),
        );
        return;
      }

      // If endpoint is unavailable/unknown (null), continue with PIN flow.
      emit(LoginPinRequired(phoneToSubmit));
    } on DioException catch (e) {
      debugPrint('[LoginBloc] DioException: ${e.type} → ${e.message}');
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        emit(
          const LoginError(
            'No internet connection. Please check your network and try again.',
            errorType: LoginErrorType.network,
          ),
        );
        return;
      }
      emit(
        const LoginError(
          'Unable to check account right now. Please try again.',
          errorType: LoginErrorType.server,
        ),
      );
    } on TimeoutException {
      emit(
        const LoginError(
          'Request timed out. Please check your connection and try again.',
          errorType: LoginErrorType.network,
        ),
      );
    } catch (e) {
      debugPrint('[LoginBloc] Unexpected error: $e');
      emit(
        const LoginError(
          'Unable to continue login right now. Please try again.',
          errorType: LoginErrorType.unknown,
        ),
      );
    }
  }
}
