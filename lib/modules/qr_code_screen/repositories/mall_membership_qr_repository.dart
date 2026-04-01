import 'package:e_commerce_mobile_app/core/services/auth_service.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';

import '../models/mall_membership_qr_model.dart';

class MallMembershipQrRepository {
  MallMembershipQrRepository({AuthService? authService})
    : _authService = authService ?? AuthService();

  final AuthService _authService;

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
    );
  }

  Future<MallMembershipQrModel> loadMembershipQr() async {
    final fallback = buildLocalFallback();

    try {
      final response = await _authService.getMallMembershipQrProfile();
      final errorCode = _asCleanString(response['errorCode']);
      final success = response['success'] == true;
      if (errorCode.isNotEmpty || !success) {
        return fallback;
      }

      final data = _extractDataMap(response);

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

      final membershipType = _firstNonEmpty([
        data['membershipType'],
        data['type'],
        data['memberType'],
        '$tierLevel Member',
      ]);

      final points = _readInt(
        values: [data['points'], data['balancePoints'], data['loyaltyPoints']],
        fallback: fallback.points,
      );

      final qrPayload = _buildQrPayload(
        data: data,
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
      );
    } catch (_) {
      return fallback;
    }
  }

  String _buildQrPayload({
    required Map<String, dynamic> data,
    required String fallbackMembershipId,
    required String fallbackPayload,
  }) {
    final directPayload = _firstNonEmpty([
      data['qrPayload'],
      data['payload'],
      data['qrData'],
      data['qrContent'],
    ]);
    if (directPayload.isNotEmpty) return directPayload;

    final token = _firstNonEmpty([
      data['qrToken'],
      data['token'],
      data['scanToken'],
      data['referenceToken'],
    ]);
    if (token.isNotEmpty) {
      return 'cmr://chipmong-mall/member?token=$token';
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
}
