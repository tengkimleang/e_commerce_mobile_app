// States represent different screens the user sees
// Example: Loading spinner, Success message, Error message, etc.
import 'package:e_commerce_mobile_app/modules/login_screen/models/login_model.dart';

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

// When phone was accepted and user should enter PIN.
class LoginPinRequired extends LoginState {
  final String phoneNumber;
  const LoginPinRequired(this.phoneNumber);
}

class LoginPhoneNotRegistered extends LoginState {
  final String phoneNumber;
  final String message;
  const LoginPhoneNotRegistered({
    required this.phoneNumber,
    required this.message,
  });
}

enum LoginErrorType { network, server, validation, unknown }

// When login fails with error
class LoginError extends LoginState {
  final String message;
  final LoginErrorType errorType;
  const LoginError(this.message, {this.errorType = LoginErrorType.unknown});
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
