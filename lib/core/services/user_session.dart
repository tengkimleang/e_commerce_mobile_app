import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { guest, authenticated }

class UserSession {
  UserSession._();

  static const String _roleKey = 'user_role';
  static const String _fullNameKey = 'user_full_name';
  static const String _phoneNumberKey = 'user_phone_number';
  static const String _tokenKey = 'token';

  static UserRole _role = UserRole.guest;
  static String _fullName = '';
  static String _phoneNumber = '';
  static String? _token;

  static UserRole get role => _role;
  static bool get isGuest => _role == UserRole.guest;
  static bool get isAuthenticated => _role == UserRole.authenticated;
  static String get fullName => _fullName;
  static String get phoneNumber => _phoneNumber;
  static String get displayName => _fullName;
  static String? get token => _token;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final roleName = prefs.getString(_roleKey);

    _role = roleName == UserRole.authenticated.name
        ? UserRole.authenticated
        : UserRole.guest;
    _fullName = prefs.getString(_fullNameKey) ?? '';
    _phoneNumber = prefs.getString(_phoneNumberKey) ?? '';
    _token = prefs.getString(_tokenKey);
  }

  static Future<void> markGuest() async {
    _role = UserRole.guest;
    _fullName = '';
    _phoneNumber = '';
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, UserRole.guest.name);
    await prefs.remove(_fullNameKey);
    await prefs.remove(_phoneNumberKey);
    await prefs.remove(_tokenKey);
  }

  static Future<void> markAuthenticated({
    String? fullName,
    String? phoneNumber,
    String? token,
  }) async {
    _role = UserRole.authenticated;

    if (fullName != null) {
      _fullName = fullName.trim();
    }
    if (phoneNumber != null) {
      _phoneNumber = phoneNumber.trim();
    }
    if (token != null) {
      final trimmedToken = token.trim();
      _token = trimmedToken.isEmpty ? null : trimmedToken;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, UserRole.authenticated.name);

    if (_fullName.isEmpty) {
      await prefs.remove(_fullNameKey);
    } else {
      await prefs.setString(_fullNameKey, _fullName);
    }

    if (_phoneNumber.isEmpty) {
      await prefs.remove(_phoneNumberKey);
    } else {
      await prefs.setString(_phoneNumberKey, _phoneNumber);
    }

    if (_token == null || _token!.isEmpty) {
      await prefs.remove(_tokenKey);
    } else {
      await prefs.setString(_tokenKey, _token!);
    }
  }
}
