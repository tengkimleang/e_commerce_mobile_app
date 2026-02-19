// BLoC = Business Logic Component
// This is where all the logic happens:
// - Validates phone number/password
// - Handles login request
// - Emits different states based on results

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_mobile_app/modules/login/controller/login_event.dart';
import 'package:e_commerce_mobile_app/modules/login/controller/login_state.dart';
import 'package:e_commerce_mobile_app/modules/login/model/login_model.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginInitial()) {
    // Register event handlers
    on<PhoneChanged>(_onPhoneChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<LoginPressed>(_onLoginPressed);
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);
  }

  // Variables to store current form data
  String _currentPhoneNumber = '';
  String _currentPassword = '';
  bool _isPasswordVisible = false;

  // Validation method for phone number
  bool _isValidPhone(String phoneNumber) {
    // Phone number should be at least 10 digits (including country code)
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegex.hasMatch(phoneNumber);
  }

  // Validation method for password
  bool _isValidPassword(String password) {
    // Password should be at least 6 characters
    return password.length >= 6;
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
        loginModel: LoginModel(
          phoneNumber: _currentPhoneNumber,
          password: _currentPassword,
        ),
        isPasswordVisible: _isPasswordVisible,
        isPhoneValid: isPhoneValid,
        isPasswordValid: _isValidPassword(_currentPassword),
      ),
    );
  }

  // Handle password input change
  Future<void> _onPasswordChanged(
    PasswordChanged event,
    Emitter<LoginState> emit,
  ) async {
    _currentPassword = event.password;

    // Validate and emit updated state
    final isPasswordValid = _isValidPassword(_currentPassword);
    emit(
      LoginUpdated(
        loginModel: LoginModel(
          phoneNumber: _currentPhoneNumber,
          password: _currentPassword,
        ),
        isPasswordVisible: _isPasswordVisible,
        isPhoneValid: _isValidPhone(_currentPhoneNumber),
        isPasswordValid: isPasswordValid,
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

    if (!_isValidPassword(_currentPassword)) {
      emit(const LoginError('Password must be at least 6 characters'));
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

      // For now, simulate success
      emit(const LoginSuccess('Login successful! Redirecting...'));
    } catch (e) {
      emit(LoginError('Login failed: ${e.toString()}'));
    }
  }

  // Handle password visibility toggle
  Future<void> _onTogglePasswordVisibility(
    TogglePasswordVisibility event,
    Emitter<LoginState> emit,
  ) async {
    _isPasswordVisible = !_isPasswordVisible;

    // Emit updated state
    if (state is LoginUpdated) {
      final currentState = state as LoginUpdated;
      emit(
        currentState.copyWith(
          isPasswordVisible: _isPasswordVisible,
        ),
      );
    } else {
      emit(
        LoginUpdated(
          loginModel: LoginModel(
            phoneNumber: _currentPhoneNumber,
            password: _currentPassword,
          ),
          isPasswordVisible: _isPasswordVisible,
          isPhoneValid: _isValidPhone(_currentPhoneNumber),
          isPasswordValid: _isValidPassword(_currentPassword),
        ),
      );
    }
  }
}