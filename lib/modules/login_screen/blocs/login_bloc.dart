import 'package:e_commerce_mobile_app/core/services/auth_service.dart';
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
    if (!_isValidPhone(_currentPhoneNumber)) {
      emit(
        LoginUpdated(
          loginModel: LoginModel(phoneNumber: _currentPhoneNumber),
          isPhoneValid: false,
        ),
      );
      emit(const LoginError('Phone number must start with 0 and be valid'));
      return;
    }

    emit(const LoginLoading());

    try {
      final response = await _authService.requestOtp(_currentPhoneNumber);

// Debug OTP
      print("OTP response: $response");

emit(LoginOtpSent(_currentPhoneNumber));
    } catch (e) {
      emit(LoginError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}