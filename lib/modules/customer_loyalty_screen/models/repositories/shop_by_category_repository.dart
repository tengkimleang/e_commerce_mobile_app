import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/constants/app_constants.dart';
import 'package:e_commerce_mobile_app/core/models/product_item.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/models/shop_by_category_model.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/model/sub_category_model.dart';

abstract class ShopByCategoryRepository {
  Future<List<ShopByCategoryModel>> fetchCategories();

  Future<List<SubCategoryModel>> fetchSubCategories(int shopByCategoryId);

  Future<(List<ProductModel>, int)> fetchProducts(
    int shopByCategoryId, {
    int? subCategoryId,
    int page = 1,
    int pageSize = 20,
    String keyword = '',
  });
}

class HttpShopByCategoryRepository implements ShopByCategoryRepository {
  HttpShopByCategoryRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<ShopByCategoryModel>> fetchCategories() async {
    final shopId = UserSession.selectedShopId;
    final response = await _dio.get(
      ApiUrl.shopByCategories,
      queryParameters: {if (shopId.isNotEmpty) 'shopId': shopId},
    );
    final body = _parseBody(response);
    _checkApiError(body);
    final data = body['data'] as Map<String, dynamic>? ?? {};
    final items = data['items'] as List<dynamic>? ?? [];
    final categories = items
        .map((e) => ShopByCategoryModel.fromJson(e as Map<String, dynamic>))
        .where((category) => category.isActive)
        .toList();
    categories.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return categories;
  }

  @override
  Future<List<SubCategoryModel>> fetchSubCategories(
    int shopByCategoryId,
  ) async {
    final shopId = UserSession.selectedShopId;
    final response = await _dio.get(
      ApiUrl.shopByCategorySubCategories(shopByCategoryId),
      queryParameters: {if (shopId.isNotEmpty) 'shopId': shopId},
    );
    final body = _parseBody(response);
    _checkApiError(body);
    final data = body['data'] as Map<String, dynamic>? ?? {};
    final items = data['items'] as List<dynamic>? ?? [];
    final subCategories = items
        .map((e) => SubCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
    subCategories.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return subCategories;
  }

  @override
  Future<(List<ProductModel>, int)> fetchProducts(
    int shopByCategoryId, {
    int? subCategoryId,
    int page = 1,
    int pageSize = 20,
    String keyword = '',
  }) async {
    final shopId = UserSession.selectedShopId;
    final trimmedKeyword = keyword.trim();
    final queryParameters = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (shopId.isNotEmpty) 'shopId': shopId,
      if (trimmedKeyword.isNotEmpty) 'keyword': trimmedKeyword,
    };
    if (subCategoryId != null) {
      queryParameters['subCategoryId'] = subCategoryId;
    }
    final response = await _dio.get(
      ApiUrl.shopByCategoryProducts(shopByCategoryId),
      queryParameters: queryParameters,
    );
    final body = _parseBody(response);
    _checkApiError(body);
    final data = body['data'] as Map<String, dynamic>? ?? {};
    final items = (data['items'] as List<dynamic>? ?? [])
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final total = data['total'] as int? ?? 0;
    return (items, total);
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

  void _checkApiError(Map<String, dynamic> body) {
    final code = (body['errorCode'] as String? ?? '').trim();
    if (code.isNotEmpty) {
      final msg = (body['errorMsg'] as String? ?? code).trim();
      throw Exception(msg);
    }
  }
}
