// Events represent user actions on the login screen
// When user enters phone number, clicks button, etc., these events are triggered


abstract class LoginEvent {
  const LoginEvent();
}

// Event when user types phone number
class PhoneChanged extends LoginEvent {
  final String phoneNumber;
  const PhoneChanged(this.phoneNumber);
}

// Event when user types password
class PasswordChanged extends LoginEvent {
  final String password;
  const PasswordChanged(this.password);
}

// Event when user clicks login button
class LoginPressed extends LoginEvent {
  const LoginPressed();
}

// Event to toggle password visibility
class TogglePasswordVisibility extends LoginEvent {
  const TogglePasswordVisibility();
}