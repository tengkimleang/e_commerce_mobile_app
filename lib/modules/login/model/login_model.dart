// This file defines the data structure for login information
class LoginModel {
  final String phoneNumber;
  final String password;

  LoginModel({
    required this.phoneNumber,
    required this.password,
  });

  // Copy with method allows creating a modified copy of the object
  LoginModel copyWith({
    String? phoneNumber,
    String? password,
  }) {
    return LoginModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
    );
  }
}