import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { guest, authenticated }

class UserSession {
  UserSession._();

  static const String _roleKey = 'user_role';
  static const String _fullNameKey = 'user_full_name';
  static const String _phoneNumberKey = 'user_phone_number';
  static const String _tokenKey = 'token';
  static const String _lastKnownFullNameKey = 'last_known_full_name';
  static const String _lastKnownPhoneKey = 'last_known_phone';

  static UserRole _role = UserRole.guest;
  static String _fullName = '';
  static String _phoneNumber = '';
  static String? _token;
  static String _lastKnownFullName = '';
  static String _lastKnownPhone = '';

  static UserRole get role => _role;
  static bool get isGuest => _role == UserRole.guest;
  static bool get isAuthenticated => _role == UserRole.authenticated;
  static String get fullName => _fullName;
  static String get phoneNumber => _phoneNumber;
  static String get displayName =>
      _fullName.isNotEmpty ? _fullName : _phoneNumber;
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
    _lastKnownFullName = prefs.getString(_lastKnownFullNameKey) ?? '';
    _lastKnownPhone = prefs.getString(_lastKnownPhoneKey) ?? '';
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

    final hasPhoneUpdate = phoneNumber != null;
    final hasFullNameUpdate = fullName != null;

    if (hasPhoneUpdate) {
      _phoneNumber = phoneNumber.trim();
    }

    if (hasFullNameUpdate) {
      _fullName = fullName.trim();
    } else if (hasPhoneUpdate) {
      // Login verify currently may return only phone. Reuse the latest
      // known full name when logging in with the same phone.
      if (_lastKnownPhone == _phoneNumber && _lastKnownFullName.isNotEmpty) {
        _fullName = _lastKnownFullName;
      } else {
        _fullName = '';
      }
    }

    if (token != null) {
      final trimmedToken = token.trim();
      _token = trimmedToken.isEmpty ? null : trimmedToken;
    }

    if (_fullName.isNotEmpty && _phoneNumber.isNotEmpty) {
      _lastKnownFullName = _fullName;
      _lastKnownPhone = _phoneNumber;
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

    if (_lastKnownFullName.isNotEmpty && _lastKnownPhone.isNotEmpty) {
      await prefs.setString(_lastKnownFullNameKey, _lastKnownFullName);
      await prefs.setString(_lastKnownPhoneKey, _lastKnownPhone);
    }

    if (_token == null || _token!.isEmpty) {
      await prefs.remove(_tokenKey);
    } else {
      await prefs.setString(_tokenKey, _token!);
    }
  }
}
