import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { guest, authenticated }

class UserSession {
  UserSession._();

  static const String _roleKey = 'user_role';
  static const String _fullNameKey = 'user_full_name';
  static const String _phoneNumberKey = 'user_phone_number';
  static const String _tokenKey = 'token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _accessTokenExpiryEpochMsKey =
      'access_token_expiry_epoch_ms';
  static const String _refreshTokenExpiryEpochMsKey =
      'refresh_token_expiry_epoch_ms';
  static const String _lastKnownFullNameKey = 'last_known_full_name';
  static const String _lastKnownPhoneKey = 'last_known_phone';

  static UserRole _role = UserRole.guest;
  static String _fullName = '';
  static String _phoneNumber = '';
  static String? _token;
  static String? _refreshToken;
  static int? _accessTokenExpiryEpochMs;
  static int? _refreshTokenExpiryEpochMs;
  static String _lastKnownFullName = '';
  static String _lastKnownPhone = '';
  static String _selectedShopId = '';

  static UserRole get role => _role;
  static bool get isGuest => _role == UserRole.guest;
  static bool get isAuthenticated => _role == UserRole.authenticated;
  static String get fullName => _fullName;
  static String get phoneNumber => _phoneNumber;
  static String get displayName =>
      _fullName.isNotEmpty ? _fullName : _phoneNumber;
  static String? get token => _token;
  static String? get refreshToken => _refreshToken;
  static DateTime? get accessTokenExpiresAt =>
      _toDateTime(_accessTokenExpiryEpochMs);
  static DateTime? get refreshTokenExpiresAt =>
      _toDateTime(_refreshTokenExpiryEpochMs);
  static bool get hasRefreshToken => (_refreshToken ?? '').trim().isNotEmpty;
  static String get selectedShopId => _selectedShopId;

  static void setSelectedShop(String shopId) {
    _selectedShopId = shopId;
  }

  static DateTime? _toDateTime(int? epochMs) {
    if (epochMs == null || epochMs <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(epochMs);
  }

  static int? _toExpiryEpochMs(int expiresInSeconds) {
    if (expiresInSeconds <= 0) return null;
    final now = DateTime.now().millisecondsSinceEpoch;
    return now + (expiresInSeconds * 1000);
  }

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final roleName = prefs.getString(_roleKey);

    _role = roleName == UserRole.authenticated.name
        ? UserRole.authenticated
        : UserRole.guest;
    _fullName = prefs.getString(_fullNameKey) ?? '';
    _phoneNumber = prefs.getString(_phoneNumberKey) ?? '';
    _token = prefs.getString(_tokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
    _accessTokenExpiryEpochMs = prefs.getInt(_accessTokenExpiryEpochMsKey);
    _refreshTokenExpiryEpochMs = prefs.getInt(_refreshTokenExpiryEpochMsKey);
    _lastKnownFullName = prefs.getString(_lastKnownFullNameKey) ?? '';
    _lastKnownPhone = prefs.getString(_lastKnownPhoneKey) ?? '';
  }

  static Future<void> markGuest() async {
    _role = UserRole.guest;
    _fullName = '';
    _phoneNumber = '';
    _token = null;
    _refreshToken = null;
    _accessTokenExpiryEpochMs = null;
    _refreshTokenExpiryEpochMs = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, UserRole.guest.name);
    await prefs.remove(_fullNameKey);
    await prefs.remove(_phoneNumberKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_accessTokenExpiryEpochMsKey);
    await prefs.remove(_refreshTokenExpiryEpochMsKey);
  }

  static Future<void> markAuthenticated({
    String? fullName,
    String? phoneNumber,
    String? token,
    String? refreshToken,
    int? accessTokenExpiresInSeconds,
    int? refreshTokenExpiresInSeconds,
  }) async {
    _role = UserRole.authenticated;

    final hasPhoneUpdate = phoneNumber != null;
    final hasFullNameUpdate = fullName != null;
    final hasTokenUpdate = token != null;
    final hasRefreshTokenUpdate = refreshToken != null;

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

    if (hasTokenUpdate) {
      final trimmedToken = token.trim();
      _token = trimmedToken.isEmpty ? null : trimmedToken;
      if (_token == null) {
        _accessTokenExpiryEpochMs = null;
      }
    }

    if (hasRefreshTokenUpdate) {
      final trimmedRefreshToken = refreshToken.trim();
      _refreshToken = trimmedRefreshToken.isEmpty ? null : trimmedRefreshToken;
      if (_refreshToken == null) {
        _refreshTokenExpiryEpochMs = null;
      }
    }

    if (accessTokenExpiresInSeconds != null) {
      _accessTokenExpiryEpochMs = _toExpiryEpochMs(accessTokenExpiresInSeconds);
    }

    if (refreshTokenExpiresInSeconds != null) {
      _refreshTokenExpiryEpochMs = _toExpiryEpochMs(
        refreshTokenExpiresInSeconds,
      );
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

    if (_refreshToken == null || _refreshToken!.isEmpty) {
      await prefs.remove(_refreshTokenKey);
    } else {
      await prefs.setString(_refreshTokenKey, _refreshToken!);
    }

    if (_accessTokenExpiryEpochMs == null || _accessTokenExpiryEpochMs! <= 0) {
      await prefs.remove(_accessTokenExpiryEpochMsKey);
    } else {
      await prefs.setInt(
        _accessTokenExpiryEpochMsKey,
        _accessTokenExpiryEpochMs!,
      );
    }

    if (_refreshTokenExpiryEpochMs == null ||
        _refreshTokenExpiryEpochMs! <= 0) {
      await prefs.remove(_refreshTokenExpiryEpochMsKey);
    } else {
      await prefs.setInt(
        _refreshTokenExpiryEpochMsKey,
        _refreshTokenExpiryEpochMs!,
      );
    }
  }
}
