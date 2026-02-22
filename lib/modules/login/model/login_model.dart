// This file defines the data structure for login information
class LoginModel {
  final String phoneNumber;

  LoginModel({
    required this.phoneNumber,
  });

  // Copy with method allows creating a modified copy of the object
  LoginModel copyWith({
    String? phoneNumber,
  }) {
    return LoginModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}