import 'package:e_commerce_mobile_app/core/services/auth_service.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:dio/dio.dart';

import '../models/mall_membership_qr_model.dart';

class MallMembershipQrRepository {
  MallMembershipQrRepository({AuthService? authService})
    : _authService = authService ?? AuthService();

  final AuthService _authService;

  static const _syncErrorMessage =
      'Unable to sync latest QR data right now. Showing current member information.';
  static const _sessionExpiredMessage =
      'Your session has expired. Please login again to refresh your QR code.';
  static const _memberMissingMessage =
      'Member profile was not found. Please contact support.';
  static const _permissionDeniedMessage =
      'You do not have permission to generate this QR code.';

  MallMembershipQrModel buildLocalFallback() {
    final sessionName = UserSession.displayName.trim();
    final sessionPhone = UserSession.phoneNumber.trim();
    final fallbackId = sessionPhone.isNotEmpty
        ? sessionPhone
        : MallMembershipQrModel.fallback.membershipId;

    return MallMembershipQrModel.fallback.copyWith(
      username: sessionName.isNotEmpty
          ? sessionName
          : MallMembershipQrModel.fallback.username,
      membershipId: fallbackId,
      qrPayload: 'cmr://chipmong-mall/member?id=$fallbackId',
      isFallback: true,
      clearStatusMessage: true,
    );
  }

  Future<MallMembershipQrModel> loadMembershipQr() async {
    final fallback = buildLocalFallback();

    try {
      final response = await _authService.getMallMembershipQrProfile();
      final errorCode = _asCleanString(response['errorCode']);
      final success = response['success'] == true;
      if (errorCode.isNotEmpty || !success) {
        return _fallbackForBusinessError(base: fallback, errorCode: errorCode);
      }

      final data = _extractDataMap(response);
      final directPayload = _firstNonEmpty([
        data['qrPayload'],
        data['payload'],
        data['qrData'],
        data['qrContent'],
      ]);
      final token = _firstNonEmpty([
        data['qrToken'],
        data['token'],
        data['scanToken'],
        data['referenceToken'],
      ]);
      final hasQrPayloadOrToken = directPayload.isNotEmpty || token.isNotEmpty;

      final username = _firstNonEmpty([
        data['username'],
        data['fullName'],
        data['name'],
        fallback.username,
      ]);

      final tierLevel = _firstNonEmpty([
        data['tierLevel'],
        data['tier'],
        data['membershipTier'],
        data['memberTier'],
        fallback.tierLevel,
      ]);

      final membershipId = _firstNonEmpty([
        data['membershipId'],
        data['memberId'],
        data['loyaltyId'],
        data['customerId'],
        fallback.membershipId,
      ]);

      final points = _readInt(
        values: [data['points'], data['balancePoints'], data['loyaltyPoints']],
        fallback: fallback.points,
      );

      if (!hasQrPayloadOrToken) {
        return _asQrUnavailableFallback(
          base: fallback,
          username: username,
          points: points,
        );
      }

      final membershipType = _firstNonEmpty([
        data['membershipType'],
        data['type'],
        data['memberType'],
        '$tierLevel Member',
      ]);

      final qrPayload = _buildQrPayload(
        directPayload: directPayload,
        token: token,
        fallbackMembershipId: membershipId,
        fallbackPayload: fallback.qrPayload,
      );

      final expiresAt = _readDateTime([
        data['expiresAt'],
        data['expiryAt'],
        data['qrExpiresAt'],
      ]);

      return fallback.copyWith(
        username: username,
        tierLevel: tierLevel,
        membershipId: membershipId,
        membershipType: membershipType,
        points: points,
        qrPayload: qrPayload,
        expiresAt: expiresAt,
        clearExpiresAt: expiresAt == null,
        isFallback: false,
        clearStatusMessage: true,
      );
    } on DioException catch (e) {
      final errorCode = _dioErrorCode(e);
      if (errorCode.isNotEmpty) {
        return _fallbackForBusinessError(base: fallback, errorCode: errorCode);
      }
      return fallback.copyWith(
        statusMessage: _syncErrorMessage,
        isFallback: true,
      );
    } catch (_) {
      return fallback.copyWith(
        statusMessage: _syncErrorMessage,
        isFallback: true,
      );
    }
  }

  String _buildQrPayload({
    required String directPayload,
    required String token,
    required String fallbackMembershipId,
    required String fallbackPayload,
  }) {
    if (directPayload.isNotEmpty) return directPayload;

    if (token.isNotEmpty) {
      return token;
    }

    if (fallbackMembershipId.isNotEmpty) {
      return 'cmr://chipmong-mall/member?id=$fallbackMembershipId';
    }

    return fallbackPayload;
  }

  Map<String, dynamic> _extractDataMap(Map<String, dynamic> payload) {
    final nested = payload['data'];
    if (nested is Map<String, dynamic>) return nested;
    if (nested is Map) {
      return nested.map((key, value) => MapEntry(key.toString(), value));
    }
    return payload;
  }

  String _firstNonEmpty(Iterable<dynamic> values) {
    for (final value in values) {
      final text = _asCleanString(value);
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  String _asCleanString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  int _readInt({required Iterable<dynamic> values, required int fallback}) {
    for (final value in values) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null) return parsed;
      }
    }
    return fallback;
  }

  DateTime? _readDateTime(Iterable<dynamic> values) {
    for (final value in values) {
      final text = _asCleanString(value);
      if (text.isEmpty) continue;
      final parsed = DateTime.tryParse(text);
      if (parsed != null) return parsed;
    }
    return null;
  }

  MallMembershipQrModel _asQrUnavailableFallback({
    required MallMembershipQrModel base,
    String? username,
    int? points,
  }) {
    return base.copyWith(
      username: username,
      points: points,
      isFallback: true,
      statusMessage: _syncErrorMessage,
    );
  }

  MallMembershipQrModel _fallbackForBusinessError({
    required MallMembershipQrModel base,
    required String errorCode,
  }) {
    final normalized = errorCode.trim().toUpperCase();
    final message = switch (normalized) {
      'AUTH401' => _sessionExpiredMessage,
      'AUTH403' => _permissionDeniedMessage,
      'USR404' => _memberMissingMessage,
      _ => _syncErrorMessage,
    };

    return base.copyWith(isFallback: true, statusMessage: message);
  }

  String _dioErrorCode(DioException error) {
    final payload = error.response?.data;
    if (payload is Map<String, dynamic>) {
      return _asCleanString(payload['errorCode'] ?? payload['ErrorCode']);
    }
    if (payload is Map) {
      return _asCleanString(payload['errorCode'] ?? payload['ErrorCode']);
    }
    return '';
  }
}
