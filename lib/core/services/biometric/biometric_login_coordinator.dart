import 'dart:io';

import 'package:e_commerce_mobile_app/core/services/auth_service.dart';
import 'package:e_commerce_mobile_app/core/services/biometric/biometric_auth_service.dart';
import 'package:e_commerce_mobile_app/core/services/biometric/biometric_credential_store.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';

enum BiometricFlowStatus {
  success,
  canceled,
  unavailable,
  fallbackToPin,
  backendUnavailable,
  error,
}

class AuthSessionData {
  const AuthSessionData({
    required this.fullName,
    required this.phoneNumber,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresInSeconds,
    required this.refreshTokenExpiresInSeconds,
  });

  final String fullName;
  final String phoneNumber;
  final String accessToken;
  final String refreshToken;
  final int? accessTokenExpiresInSeconds;
  final int? refreshTokenExpiresInSeconds;
}

class BiometricFlowResult {
  const BiometricFlowResult({
    required this.status,
    this.message = '',
    this.sessionData,
  });

  final BiometricFlowStatus status;
  final String message;
  final AuthSessionData? sessionData;

  bool get isSuccess => status == BiometricFlowStatus.success;
}

class BiometricLoginCoordinator {
  BiometricLoginCoordinator({
    BiometricAuthService? biometricAuthService,
    BiometricCredentialStore? credentialStore,
    AuthService? authService,
  }) : _biometricAuthService =
           biometricAuthService ?? BiometricAuthService.instance,
       _credentialStore = credentialStore ?? BiometricCredentialStore.instance,
       _authService = authService ?? AuthService();

  static final BiometricLoginCoordinator instance = BiometricLoginCoordinator();

  static const _staleCredentialCodes = <String>{
    'BIO_NOT_ENABLED',
    'BIO_DEVICE_MISMATCH',
    'BIO_REVOKED',
    'BIO_EXPIRED',
  };

  final BiometricAuthService _biometricAuthService;
  final BiometricCredentialStore _credentialStore;
  final AuthService _authService;

  Future<DeviceBiometricStatus> getDeviceStatus() {
    return _biometricAuthService.getDeviceStatus();
  }

  Future<bool> isEnabledForPhone(String phoneNumber) {
    return _credentialStore.isEnabledForPhone(phoneNumber);
  }

  Future<BiometricFlowResult> enableBiometricLogin({
    required String phoneNumber,
  }) async {
    final normalizedPhone = phoneNumber.trim();
    if (normalizedPhone.isEmpty || !UserSession.isAuthenticated) {
      return const BiometricFlowResult(
        status: BiometricFlowStatus.error,
        message: 'Please sign in normally before enabling biometric login.',
      );
    }

    final status = await _biometricAuthService.getDeviceStatus();
    if (!status.isSupported) {
      return const BiometricFlowResult(
        status: BiometricFlowStatus.unavailable,
        message: 'This device does not support biometric login.',
      );
    }
    if (!status.hasEnrolledBiometrics) {
      return const BiometricFlowResult(
        status: BiometricFlowStatus.unavailable,
        message:
            'No Face ID or fingerprint is enrolled on this device yet. Please enable it in device settings, then try again.',
      );
    }

    final prompt = await _biometricAuthService.authenticate(
      localizedReason: status.promptReason,
    );
    if (!prompt.didAuthenticate) {
      return BiometricFlowResult(
        status: prompt.wasCanceled
            ? BiometricFlowStatus.canceled
            : BiometricFlowStatus.unavailable,
        message: prompt.message,
      );
    }

    final deviceId = await _credentialStore.getOrCreateDeviceId();
    final response = await _authService.registerBiometric(
      deviceId: deviceId,
      platform: Platform.isIOS ? 'ios' : 'android',
      deviceName: Platform.isIOS ? 'iOS Device' : 'Android Device',
      biometricType: status.backendBiometricType,
    );

    final errorCode = _clean(response['errorCode']).toUpperCase();
    final errorMessage = _clean(response['errorMsg']);
    final success = response['success'] == true && errorCode.isEmpty;

    if (_isMissingEndpointResponse(
      errorCode: errorCode,
      errorMessage: errorMessage,
    )) {
      return const BiometricFlowResult(
        status: BiometricFlowStatus.backendUnavailable,
        message: 'Biometric login is not available on the backend yet.',
      );
    }

    if (!success) {
      return BiometricFlowResult(
        status: BiometricFlowStatus.error,
        message: errorMessage.isEmpty
            ? 'Unable to enable biometric login right now.'
            : errorMessage,
      );
    }

    final biometricToken = _extractBiometricToken(response);
    if (biometricToken.isEmpty) {
      return const BiometricFlowResult(
        status: BiometricFlowStatus.error,
        message: 'The server did not return a biometric login credential.',
      );
    }

    await _credentialStore.saveCredential(
      BiometricCredential(
        deviceId: deviceId,
        phoneNumber: normalizedPhone,
        biometricToken: biometricToken,
        biometricType: status.backendBiometricType,
        expiresAt: _extractBiometricExpiry(response),
      ),
    );

    return BiometricFlowResult(
      status: BiometricFlowStatus.success,
      message: status.isFaceIdAvailable && Platform.isIOS
          ? 'Face ID login is now enabled.'
          : 'Biometric login is now enabled.',
    );
  }

  Future<BiometricFlowResult> loginWithBiometrics({
    required String phoneNumber,
  }) async {
    final normalizedPhone = phoneNumber.trim();
    final credential = await _credentialStore.readCredential();
    if (credential == null ||
        credential.phoneNumber.trim() != normalizedPhone ||
        credential.biometricToken.trim().isEmpty) {
      return const BiometricFlowResult(
        status: BiometricFlowStatus.fallbackToPin,
      );
    }

    if (credential.isExpired) {
      await _credentialStore.clearEnrollment();
      return const BiometricFlowResult(
        status: BiometricFlowStatus.fallbackToPin,
        message:
            'Biometric login expired. Please sign in with PIN and enable it again.',
      );
    }

    final status = await _biometricAuthService.getDeviceStatus();
    if (!status.isSupported || !status.hasEnrolledBiometrics) {
      return const BiometricFlowResult(
        status: BiometricFlowStatus.unavailable,
        message:
            'Biometric login is not available on this device right now. Please use your PIN instead.',
      );
    }

    final prompt = await _biometricAuthService.authenticate(
      localizedReason: status.promptReason,
    );
    if (!prompt.didAuthenticate) {
      return BiometricFlowResult(
        status: prompt.wasCanceled
            ? BiometricFlowStatus.canceled
            : BiometricFlowStatus.fallbackToPin,
        message: prompt.message,
      );
    }

    final response = await _authService.loginWithBiometric(
      phoneNumber: normalizedPhone,
      deviceId: credential.deviceId,
      biometricToken: credential.biometricToken,
    );

    final errorCode = _clean(response['errorCode']).toUpperCase();
    final errorMessage = _clean(response['errorMsg']);
    final success = response['success'] == true && errorCode.isEmpty;

    if (_isMissingEndpointResponse(
      errorCode: errorCode,
      errorMessage: errorMessage,
    )) {
      return const BiometricFlowResult(
        status: BiometricFlowStatus.backendUnavailable,
        message: 'Biometric login is not available on the backend yet.',
      );
    }

    if (!success) {
      if (_staleCredentialCodes.contains(errorCode)) {
        await _credentialStore.clearEnrollment();
        return BiometricFlowResult(
          status: BiometricFlowStatus.fallbackToPin,
          message: errorMessage.isEmpty
              ? 'Biometric login is no longer available for this account. Please sign in with PIN and enable it again.'
              : errorMessage,
        );
      }

      return BiometricFlowResult(
        status: BiometricFlowStatus.fallbackToPin,
        message: errorMessage.isEmpty
            ? 'Biometric login failed. Please use your PIN instead.'
            : errorMessage,
      );
    }

    final rotatedBiometricToken = _extractBiometricToken(response);
    await _credentialStore.saveCredential(
      BiometricCredential(
        deviceId: credential.deviceId,
        phoneNumber: normalizedPhone,
        biometricToken: rotatedBiometricToken.isEmpty
            ? credential.biometricToken
            : rotatedBiometricToken,
        biometricType: credential.biometricType,
        expiresAt: _extractBiometricExpiry(response) ?? credential.expiresAt,
      ),
    );

    return BiometricFlowResult(
      status: BiometricFlowStatus.success,
      sessionData: _extractSessionData(
        response,
        fallbackPhoneNumber: normalizedPhone,
      ),
    );
  }

  Future<void> disableBiometricLogin({bool revokeServer = true}) async {
    final credential = await _credentialStore.readCredential();

    if (revokeServer && credential != null) {
      try {
        await _authService.revokeBiometric(deviceId: credential.deviceId);
      } catch (_) {
        // Local cleanup must still happen even if revoke fails.
      }
    }

    await _credentialStore.clearEnrollment();
  }

  Future<void> clearEnrollmentForSecurityChange() async {
    await _credentialStore.clearEnrollment();
  }

  String _clean(dynamic value) => value?.toString().trim() ?? '';

  bool _isMissingEndpointResponse({
    required String errorCode,
    required String errorMessage,
  }) {
    if (errorCode == 'HTTP404' || errorCode == 'HTTP405') {
      return true;
    }
    final normalizedMessage = errorMessage.toLowerCase();
    return normalizedMessage.contains('not found') ||
        normalizedMessage.contains('no endpoint');
  }

  Map<String, dynamic>? _toMap(dynamic source) {
    if (source is Map<String, dynamic>) return source;
    if (source is Map) {
      return source.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  Map<String, dynamic> _extractDataMap(Map<String, dynamic> payload) {
    final nested = _toMap(payload['data']);
    return nested ?? payload;
  }

  String _pickFirstNonEmpty(Iterable<dynamic> values) {
    for (final value in values) {
      final text = _clean(value);
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  int? _pickFirstPositiveInt(Iterable<dynamic> values) {
    for (final value in values) {
      if (value is int && value > 0) return value;
      if (value is num && value > 0) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null && parsed > 0) return parsed;
      }
    }
    return null;
  }

  String _extractBiometricToken(Map<String, dynamic> payload) {
    final data = _extractDataMap(payload);
    return _pickFirstNonEmpty([
      payload['biometricToken'],
      payload['token'],
      data['biometricToken'],
      data['token'],
    ]);
  }

  DateTime? _extractBiometricExpiry(Map<String, dynamic> payload) {
    final data = _extractDataMap(payload);
    final raw = _pickFirstNonEmpty([
      payload['expiresAt'],
      payload['biometricExpiresAt'],
      data['expiresAt'],
      data['biometricExpiresAt'],
    ]);
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toUtc();
  }

  AuthSessionData _extractSessionData(
    Map<String, dynamic> payload, {
    String fallbackPhoneNumber = '',
  }) {
    final data = _extractDataMap(payload);
    return AuthSessionData(
      fullName: _pickFirstNonEmpty([
        data['fullName'],
        data['name'],
        data['username'],
      ]),
      phoneNumber: _pickFirstNonEmpty([
        data['phoneNumber'],
        data['phone'],
        fallbackPhoneNumber,
      ]),
      accessToken: _pickFirstNonEmpty([
        payload['accessToken'],
        payload['token'],
        payload['jwt'],
        payload['jwtToken'],
        data['accessToken'],
        data['token'],
        data['jwt'],
        data['jwtToken'],
      ]),
      refreshToken: _pickFirstNonEmpty([
        payload['refreshToken'],
        data['refreshToken'],
      ]),
      accessTokenExpiresInSeconds: _pickFirstPositiveInt([
        payload['accessTokenExpiresInSeconds'],
        payload['accessTokenExpiresInSecond'],
        payload['expiresInSeconds'],
        data['accessTokenExpiresInSeconds'],
        data['accessTokenExpiresInSecond'],
        data['expiresInSeconds'],
      ]),
      refreshTokenExpiresInSeconds: _pickFirstPositiveInt([
        payload['refreshTokenExpiresInSeconds'],
        payload['refreshExpiresInSeconds'],
        data['refreshTokenExpiresInSeconds'],
        data['refreshExpiresInSeconds'],
      ]),
    );
  }
}
