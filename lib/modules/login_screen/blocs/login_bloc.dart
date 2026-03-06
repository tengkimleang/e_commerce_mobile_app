// BLoC = Business Logic Component
// This is where all the logic happens:
// - Validates phone number/password
// - Handles login request
// - Emits different states based on results

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_mobile_app/modules/login_screen/blocs/login_event.dart';
import 'package:e_commerce_mobile_app/modules/login_screen/blocs/login_state.dart';
import 'package:e_commerce_mobile_app/modules/login_screen/models/login_model.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginInitial()) {
    // Register event handlers
    on<PhoneChanged>(_onPhoneChanged);
    on<LoginPressed>(_onLoginPressed);
  }

  // Variables to store current form data
  String _currentPhoneNumber = '';

  // Validation method for phone number
  bool _isValidPhone(String phoneNumber) {
    // Phone number should be at least 10 digits (including country code)
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegex.hasMatch(phoneNumber);
  }

  // Handle phone number input change
  Future<void> _onPhoneChanged(
    PhoneChanged event,
    Emitter<LoginState> emit,
  ) async {
    _currentPhoneNumber = event.phoneNumber;

    // Validate and emit updated state
    final isPhoneValid = _isValidPhone(_currentPhoneNumber);
    emit(
      LoginUpdated(
        loginModel: LoginModel(phoneNumber: _currentPhoneNumber),

        isPhoneValid: isPhoneValid,
      ),
    );
  }

  // Handle password input change
  Future<void> _onPasswordChanged(Emitter<LoginState> emit) async {
    // Validate and emit updated state
    emit(
      LoginUpdated(
        loginModel: LoginModel(phoneNumber: _currentPhoneNumber),

        isPhoneValid: _isValidPhone(_currentPhoneNumber),
      ),
    );
  }

  // Handle login button press
  Future<void> _onLoginPressed(
    LoginPressed event,
    Emitter<LoginState> emit,
  ) async {
    // Check if phone number and password are valid
    if (!_isValidPhone(_currentPhoneNumber)) {
      emit(const LoginError('Please enter a valid phone number'));
      return;
    }

    // Show loading state
    emit(const LoginLoading());

    try {
      // Simulate API call delay (in real app, you'd call actual API here)
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Replace with actual API call
      // In real application, you would:
      // final response = await loginService.login(
      //   phoneNumber: _currentPhoneNumber,
      //   password: _currentPassword,
      // );

      // For now, simulate OTP send instead of direct success
      // Emit an OTP sent state so UI can navigate to OTP input
      emit(LoginOtpSent(_currentPhoneNumber));
    } catch (e) {
      emit(LoginError('Login failed: ${e.toString()}'));
    }
  }

  // Handle password visibility toggle
  Future<void> _onTogglePasswordVisibility(Emitter<LoginState> emit) async {
    // Emit updated state
    if (state is LoginUpdated) {
      final currentState = state as LoginUpdated;
      emit(currentState.copyWith());
    } else {
      emit(
        LoginUpdated(
          loginModel: LoginModel(phoneNumber: _currentPhoneNumber),

          isPhoneValid: _isValidPhone(_currentPhoneNumber),
        ),
      );
    }
  }
}
