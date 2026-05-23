import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/constants/app_constants.dart';
import 'package:e_commerce_mobile_app/modules/notification_screen/models/notification_promotion_entry.dart';

abstract class NotificationPromotionsRepository {
  Future<List<NotificationPromotionEntry>> fetchPromotions({
    String shopId = '',
  });
}

class HttpNotificationPromotionsRepository
    implements NotificationPromotionsRepository {
  const HttpNotificationPromotionsRepository(this._dio);

  static const _lastDisplayOrder = 1 << 30;

  final Dio _dio;

  @override
  Future<List<NotificationPromotionEntry>> fetchPromotions({
    String shopId = '',
  }) async {
    final response = await _dio.get(
      ApiUrl.notificationPromotions,
      queryParameters: {if (shopId.trim().isNotEmpty) 'shopId': shopId.trim()},
    );
    final body = _parseBody(response.data);
    _checkApiError(body);

    final data = body['data'];
    final rawItems = data is Map<String, dynamic>
        ? data['items']
        : body['items'];
    final items = rawItems is List<dynamic> ? rawItems : const <dynamic>[];
    final result = items
        .whereType<Map<String, dynamic>>()
        .map(NotificationPromotionEntry.fromJson)
        .toList();

    result.sort(_comparePromotions);
    return result;
  }

  int _comparePromotions(
    NotificationPromotionEntry a,
    NotificationPromotionEntry b,
  ) {
    final orderCompare = (a.displayOrder ?? _lastDisplayOrder).compareTo(
      b.displayOrder ?? _lastDisplayOrder,
    );
    if (orderCompare != 0) return orderCompare;

    final aDate = a.sortDate;
    final bDate = b.sortDate;
    if (aDate == null && bDate == null) return 0;
    if (aDate == null) return 1;
    if (bDate == null) return -1;
    return bDate.compareTo(aDate);
  }

  Map<String, dynamic> _parseBody(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw.trim());
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return {};
  }

  void _checkApiError(Map<String, dynamic> body) {
    if (body['success'] == false) {
      final message =
          (body['errorMsg'] as String? ?? 'Failed to load promotions').trim();
      throw Exception(message);
    }

    final code = (body['errorCode'] as String? ?? '').trim();
    if (code.isNotEmpty) {
      final message = (body['errorMsg'] as String? ?? code).trim();
      throw Exception(message);
    }
  }
}
