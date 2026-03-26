enum UserRole { guest, authenticated }

class UserSession {
  UserSession._();

  static UserRole _role = UserRole.guest;

  static UserRole get role => _role;
  static bool get isGuest => _role == UserRole.guest;
  static bool get isAuthenticated => _role == UserRole.authenticated;

  static void markGuest() {
    _role = UserRole.guest;
  }

  static void markAuthenticated() {
    _role = UserRole.authenticated;
  }
}
