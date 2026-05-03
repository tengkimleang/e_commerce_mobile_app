import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/constants/app_constants.dart';
import 'package:e_commerce_mobile_app/modules/shop_selector/models/shop_option.dart';

class ShopRepository {
  ShopRepository(this._dio);

  final Dio _dio;

  Future<List<ShopOption>> fetchStores() async {
    final response = await _dio.get(ApiUrl.stores);
    final body = _parseBody(response);

    final code = (body['errorCode'] as String? ?? '').trim();
    if (code.isNotEmpty) {
      final msg = (body['errorMsg'] as String? ?? code).trim();
      throw Exception(msg);
    }

    final data = body['data'] as Map<String, dynamic>? ?? {};
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => ShopOption.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> _parseBody(Response<dynamic> response) {
    final raw = response.data;
    if (raw is Map<String, dynamic>) return raw;
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw.trim());
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return {};
  }
}
