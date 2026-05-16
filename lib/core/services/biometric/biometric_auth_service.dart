import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

enum BiometricPromptFailure {
  canceled,
  noHardware,
  notEnrolled,
  temporaryLockout,
  permanentLockout,
  passcodeNotSet,
  unavailable,
  unknown,
}

class DeviceBiometricStatus {
  const DeviceBiometricStatus({
    required this.isSupported,
    required this.hasEnrolledBiometrics,
    required this.isFaceIdAvailable,
    required this.isFingerprintAvailable,
  });

  final bool isSupported;
  final bool hasEnrolledBiometrics;
  final bool isFaceIdAvailable;
  final bool isFingerprintAvailable;

  String get settingsLabel => isFaceIdAvailable && Platform.isIOS
      ? 'Login with Face ID:'
      : 'Login with Biometric:';

  String get actionLabel =>
      isFaceIdAvailable && Platform.isIOS ? 'Use Face ID' : 'Use Biometric';

  String get promptReason => isFaceIdAvailable && Platform.isIOS
      ? 'Scan your Face ID to continue'
      : 'Authenticate with your biometrics to continue';

  String get backendBiometricType {
    if (isFaceIdAvailable) return 'face';
    if (isFingerprintAvailable) return 'fingerprint';
    return 'biometric';
  }
}

class BiometricPromptResult {
  const BiometricPromptResult._({
    required this.didAuthenticate,
    this.failure,
    this.message = '',
  });

  final bool didAuthenticate;
  final BiometricPromptFailure? failure;
  final String message;

  bool get wasCanceled => failure == BiometricPromptFailure.canceled;

  factory BiometricPromptResult.success() {
    return const BiometricPromptResult._(didAuthenticate: true);
  }

  factory BiometricPromptResult.failure(
    BiometricPromptFailure failure, {
    required String message,
  }) {
    return BiometricPromptResult._(
      didAuthenticate: false,
      failure: failure,
      message: message,
    );
  }
}

class BiometricAuthService {
  BiometricAuthService({LocalAuthentication? localAuthentication})
    : _localAuthentication = localAuthentication ?? LocalAuthentication();

  static final BiometricAuthService instance = BiometricAuthService();

  final LocalAuthentication _localAuthentication;

  Future<DeviceBiometricStatus> getDeviceStatus() async {
    final canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
    List<BiometricType> availableBiometrics = const <BiometricType>[];

    if (canCheckBiometrics) {
      try {
        availableBiometrics = await _localAuthentication
            .getAvailableBiometrics();
      } catch (_) {
        availableBiometrics = const <BiometricType>[];
      }
    }

    if (kDebugMode) {
      debugPrint(
        '[BiometricAuthService] canCheckBiometrics=$canCheckBiometrics, '
        'availableBiometrics=$availableBiometrics',
      );
    }

    return DeviceBiometricStatus(
      isSupported: canCheckBiometrics,
      hasEnrolledBiometrics: availableBiometrics.isNotEmpty,
      isFaceIdAvailable: availableBiometrics.contains(BiometricType.face),
      isFingerprintAvailable: availableBiometrics.contains(
        BiometricType.fingerprint,
      ),
    );
  }

  Future<BiometricPromptResult> authenticate({
    required String localizedReason,
  }) async {
    try {
      final didAuthenticate = await _localAuthentication.authenticate(
        localizedReason: localizedReason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Biometric Login',
            cancelButton: 'Cancel',
          ),
          IOSAuthMessages(cancelButton: 'Cancel'),
        ],
      );

      if (didAuthenticate) {
        return BiometricPromptResult.success();
      }

      return BiometricPromptResult.failure(
        BiometricPromptFailure.canceled,
        message: 'Biometric authentication was canceled.',
      );
    } on LocalAuthException catch (error) {
      return _mapLocalAuthException(error);
    } catch (_) {
      return BiometricPromptResult.failure(
        BiometricPromptFailure.unknown,
        message:
            'Biometric authentication could not be completed right now. Please try again.',
      );
    }
  }

  BiometricPromptResult _mapLocalAuthException(LocalAuthException error) {
    switch (error.code.name) {
      case 'noBiometricHardware':
        return BiometricPromptResult.failure(
          BiometricPromptFailure.noHardware,
          message: 'This device does not support biometric login.',
        );
      case 'noBiometricsEnrolled':
        return BiometricPromptResult.failure(
          BiometricPromptFailure.notEnrolled,
          message:
              'No Face ID or fingerprint is enrolled on this device yet. Please enable it in device settings, then try again.',
        );
      case 'temporaryLockout':
        return BiometricPromptResult.failure(
          BiometricPromptFailure.temporaryLockout,
          message:
              'Biometric authentication is temporarily locked. Please unlock your device and try again.',
        );
      case 'biometricLockout':
        return BiometricPromptResult.failure(
          BiometricPromptFailure.permanentLockout,
          message:
              'Biometric authentication is locked. Please unlock it from your device settings before trying again.',
        );
      case 'passcodeNotSet':
        return BiometricPromptResult.failure(
          BiometricPromptFailure.passcodeNotSet,
          message:
              'Your device security is not set up yet. Please enable a device passcode and biometrics first.',
        );
      case 'notAvailable':
      case 'otherOperatingSystem':
      case 'unsupported':
        return BiometricPromptResult.failure(
          BiometricPromptFailure.unavailable,
          message: 'Biometric login is not available on this device.',
        );
      case 'userCanceled':
      case 'systemCanceled':
        return BiometricPromptResult.failure(
          BiometricPromptFailure.canceled,
          message: 'Biometric authentication was canceled.',
        );
      default:
        return BiometricPromptResult.failure(
          BiometricPromptFailure.unknown,
          message:
              'Biometric authentication could not be completed right now. Please try again.',
        );
    }
  }
}
