import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class BiometricCredential {
  const BiometricCredential({
    required this.deviceId,
    required this.phoneNumber,
    required this.biometricToken,
    required this.biometricType,
    this.expiresAt,
  });

  final String deviceId;
  final String phoneNumber;
  final String biometricToken;
  final String biometricType;
  final DateTime? expiresAt;

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now().toUtc());
}

class BiometricCredentialStore {
  BiometricCredentialStore({FlutterSecureStorage? secureStorage, Uuid? uuid})
    : _secureStorage =
          secureStorage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(),
            iOptions: IOSOptions(accessibility: KeychainAccessibility.unlocked),
          ),
      _uuid = uuid ?? const Uuid();

  static final BiometricCredentialStore instance = BiometricCredentialStore();

  static const _enabledKey = 'biometric_login_enabled';
  static const _deviceIdKey = 'biometric_device_id';
  static const _phoneNumberKey = 'biometric_phone_number';
  static const _tokenKey = 'biometric_token';
  static const _expiresAtKey = 'biometric_expires_at_utc';
  static const _biometricTypeKey = 'biometric_type';

  final FlutterSecureStorage _secureStorage;
  final Uuid _uuid;

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<String> getOrCreateDeviceId() async {
    final existing = (await _secureStorage.read(key: _deviceIdKey) ?? '')
        .trim();
    if (existing.isNotEmpty) return existing;

    final created = _uuid.v4();
    await _secureStorage.write(key: _deviceIdKey, value: created);
    return created;
  }

  Future<bool> isEnabledForPhone(String phoneNumber) async {
    final credential = await readCredential();
    if (credential == null) return false;
    if (credential.isExpired) {
      await clearEnrollment();
      return false;
    }

    final prefs = await _prefs;
    final enabled = prefs.getBool(_enabledKey) ?? false;
    return enabled &&
        credential.phoneNumber.trim() == phoneNumber.trim() &&
        credential.biometricToken.trim().isNotEmpty;
  }

  Future<bool> isEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_enabledKey) ?? false;
  }

  Future<BiometricCredential?> readCredential() async {
    final deviceId = (await _secureStorage.read(key: _deviceIdKey) ?? '')
        .trim();
    final phoneNumber = (await _secureStorage.read(key: _phoneNumberKey) ?? '')
        .trim();
    final token = (await _secureStorage.read(key: _tokenKey) ?? '').trim();
    final expiresAtRaw = (await _secureStorage.read(key: _expiresAtKey) ?? '')
        .trim();
    final biometricType =
        (await _secureStorage.read(key: _biometricTypeKey) ?? '').trim();

    if (deviceId.isEmpty || phoneNumber.isEmpty || token.isEmpty) {
      return null;
    }

    return BiometricCredential(
      deviceId: deviceId,
      phoneNumber: phoneNumber,
      biometricToken: token,
      biometricType: biometricType.isEmpty ? 'biometric' : biometricType,
      expiresAt: expiresAtRaw.isEmpty
          ? null
          : DateTime.tryParse(expiresAtRaw)?.toUtc(),
    );
  }

  Future<void> saveCredential(BiometricCredential credential) async {
    final prefs = await _prefs;
    await prefs.setBool(_enabledKey, true);
    await _secureStorage.write(key: _deviceIdKey, value: credential.deviceId);
    await _secureStorage.write(
      key: _phoneNumberKey,
      value: credential.phoneNumber,
    );
    await _secureStorage.write(
      key: _tokenKey,
      value: credential.biometricToken,
    );
    await _secureStorage.write(
      key: _biometricTypeKey,
      value: credential.biometricType,
    );

    if (credential.expiresAt != null) {
      await _secureStorage.write(
        key: _expiresAtKey,
        value: credential.expiresAt!.toUtc().toIso8601String(),
      );
    } else {
      await _secureStorage.delete(key: _expiresAtKey);
    }
  }

  Future<void> clearEnrollment() async {
    final prefs = await _prefs;
    await prefs.setBool(_enabledKey, false);
    await _secureStorage.delete(key: _phoneNumberKey);
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _expiresAtKey);
    await _secureStorage.delete(key: _biometricTypeKey);
  }
}
