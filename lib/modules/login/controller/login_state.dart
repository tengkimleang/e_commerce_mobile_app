// States represent different screens the user sees
// Example: Loading spinner, Success message, Error message, etc.
import 'package:e_commerce_mobile_app/modules/login/model/login_model.dart';

abstract class LoginState {
  const LoginState();
}

// Initial state - when user first opens login screen
class LoginInitial extends LoginState {
  const LoginInitial();
}

// While data is being validated or sent to server
class LoginLoading extends LoginState {
  const LoginLoading();
}

// When login is successful
class LoginSuccess extends LoginState {
  final String message;
  const LoginSuccess(this.message);
}

// When login fails with error
class LoginError extends LoginState {
  final String message;
  const LoginError(this.message);
}

// Updated state when user types in form fields
class LoginUpdated extends LoginState {
  final LoginModel loginModel;
  final bool isPasswordVisible;
  final bool isPhoneValid;
  final bool isPasswordValid;

  const LoginUpdated({
    required this.loginModel,
    this.isPasswordVisible = false,
    this.isPhoneValid = false,
    this.isPasswordValid = false,
  });

  LoginUpdated copyWith({
    LoginModel? loginModel,
    bool? isPasswordVisible,
    bool? isPhoneValid,
    bool? isPasswordValid,
  }) {
    return LoginUpdated(
      loginModel: loginModel ?? this.loginModel,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isPhoneValid: isPhoneValid ?? this.isPhoneValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
    );
  }
}