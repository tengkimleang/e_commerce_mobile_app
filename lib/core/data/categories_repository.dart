import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:e_commerce_mobile_app/core/constants/app_constants.dart';
import 'package:e_commerce_mobile_app/core/models/product_item.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/model/category_model.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/model/sub_category_model.dart';

// ─────────────────────────────────────────────────────────────
// Abstract interface
// ─────────────────────────────────────────────────────────────

abstract class CategoriesRepository {
  /// Returns all active categories ordered by displayOrder,
  /// each with a [previewProducts] list embedded for home-screen carousels.
  Future<List<CategoryModel>> fetchCategories();

  /// Returns paginated products belonging to [categoryId].
  /// Result is a record of (products, totalCount).
  Future<(List<ProductModel>, int)> fetchCategoryProducts(
    int categoryId, {
    int page = 1,
    int pageSize = 20,
  });

  /// Returns sub-categories under [categoryId].
  Future<List<SubCategoryModel>> fetchSubCategories(int categoryId);

  /// Returns paginated products belonging to [subCategoryId].
  /// Result is a record of (products, totalCount).
  Future<(List<ProductModel>, int)> fetchSubCategoryProducts(
    int subCategoryId, {
    int page = 1,
    int pageSize = 20,
  });

  /// Searches products across all categories by [keyword].
  /// Empty [keyword] returns all active products.
  /// Result is a record of (products, totalCount).
  Future<(List<ProductModel>, int)> searchProducts(
    String keyword, {
    int page = 1,
    int pageSize = 20,
  });

  /// Returns paginated products whose countryOfOrigin matches [country].
  /// Result is a record of (products, totalCount).
  Future<(List<ProductModel>, int)> fetchProductsByCountry(
    String country, {
    int page = 1,
    int pageSize = 20,
  });

  /// Returns categories marked showInPromotion=true for the given [shopId],
  /// sorted by promotionDisplayOrder ?? displayOrder (ascending).
  /// Each category will have [previewProducts] populated.
  Future<List<CategoryModel>> fetchPromotionCategories(String shopId);

  /// Fetches a single product whose barcode matches [code].
  /// Returns null when no product is found (HTTP 404 / empty result).
  Future<ProductModel?> fetchProductByBarcode(String code);
}

// ─────────────────────────────────────────────────────────────
// HTTP — calls the real ASP.NET Core API.
// ─────────────────────────────────────────────────────────────

class HttpCategoriesRepository implements CategoriesRepository {
  final Dio _dio;

  HttpCategoriesRepository(this._dio);

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    final shopId = UserSession.selectedShopId;
    final response = await _dio.get(
      ApiUrl.categories,
      queryParameters: {if (shopId.isNotEmpty) 'shopId': shopId},
    );
    final body = _parseBody(response);
    _checkApiError(body);
    final data = body['data'] as Map<String, dynamic>? ?? {};
    final items = data['items'] as List<dynamic>? ?? [];
    final categories = items
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // BE does not embed previewProducts in the category list response.
    // Fetch the first page of products for each category in parallel so
    // the home-screen carousels have data without sequential N+1 delays.
    final previews = await Future.wait(
      categories.map((c) => fetchCategoryProducts(c.id, pageSize: 10)),
    );

    return List.generate(categories.length, (i) {
      final (products, _) = previews[i];
      return CategoryModel(
        id: categories[i].id,
        nameEn: categories[i].nameEn,
        nameKm: categories[i].nameKm,
        bannerImageUrl: categories[i].bannerImageUrl,
        displayOrder: categories[i].displayOrder,
        isActive: categories[i].isActive,
        promoStartAt: categories[i].promoStartAt,
        promoEndAt: categories[i].promoEndAt,
        previewProducts: products,
        showInPromotion: categories[i].showInPromotion,
        promotionDisplayOrder: categories[i].promotionDisplayOrder,
      );
    });
  }

  @override
  Future<List<CategoryModel>> fetchPromotionCategories(String shopId) async {
    final response = await _dio.get(
      ApiUrl.categories,
      queryParameters: {
        if (shopId.isNotEmpty) 'shopId': shopId,
        'showInPromotion': true,
      },
    );
    final body = _parseBody(response);
    _checkApiError(body);
    final data = body['data'] as Map<String, dynamic>? ?? {};
    final items = data['items'] as List<dynamic>? ?? [];
    final categories = items
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // previewProducts are not embedded — parallel-fetch per category.
    final previews = await Future.wait(
      categories.map((c) => fetchCategoryProducts(c.id, pageSize: 10)),
    );

    final result = List.generate(categories.length, (i) {
      final (products, _) = previews[i];
      return CategoryModel(
        id: categories[i].id,
        nameEn: categories[i].nameEn,
        nameKm: categories[i].nameKm,
        bannerImageUrl: categories[i].bannerImageUrl,
        displayOrder: categories[i].displayOrder,
        isActive: categories[i].isActive,
        promoStartAt: categories[i].promoStartAt,
        promoEndAt: categories[i].promoEndAt,
        previewProducts: products,
        showInPromotion: categories[i].showInPromotion,
        promotionDisplayOrder: categories[i].promotionDisplayOrder,
      );
    });

    // Defensive client-side sort: BE sorts, but guard against inconsistency.
    result.sort(
      (a, b) => (a.promotionDisplayOrder ?? a.displayOrder).compareTo(
        b.promotionDisplayOrder ?? b.displayOrder,
      ),
    );
    return result;
  }

  @override
  Future<(List<ProductModel>, int)> fetchCategoryProducts(
    int categoryId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final shopId = UserSession.selectedShopId;
    final response = await _dio.get(
      ApiUrl.categoryProducts(categoryId),
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (shopId.isNotEmpty) 'shopId': shopId,
      },
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

  @override
  Future<List<SubCategoryModel>> fetchSubCategories(int categoryId) async {
    final response = await _dio.get(ApiUrl.categorySubCategories(categoryId));
    final body = _parseBody(response);
    _checkApiError(body);
    final data = body['data'] as Map<String, dynamic>? ?? {};
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => SubCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<(List<ProductModel>, int)> fetchSubCategoryProducts(
    int subCategoryId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final shopId = UserSession.selectedShopId;
    final response = await _dio.get(
      ApiUrl.subCategoryProducts(subCategoryId),
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (shopId.isNotEmpty) 'shopId': shopId,
      },
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

  @override
  Future<(List<ProductModel>, int)> searchProducts(
    String keyword, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final shopId = UserSession.selectedShopId;
    final response = await _dio.get(
      ApiUrl.products,
      queryParameters: {
        'keyword': keyword,
        'page': page,
        'pageSize': pageSize,
        if (shopId.isNotEmpty) 'shopId': shopId,
      },
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

  @override
  Future<(List<ProductModel>, int)> fetchProductsByCountry(
    String country, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final shopId = UserSession.selectedShopId;
    final response = await _dio.get(
      ApiUrl.products,
      queryParameters: {
        'countryOfOrigin': country,
        'page': page,
        'pageSize': pageSize,
        if (shopId.isNotEmpty) 'shopId': shopId,
      },
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

  /// BE convention: business errors come back as HTTP 200 with a
  /// non-empty errorCode. Always check this field, not just HTTP status.
  void _checkApiError(Map<String, dynamic> body) {
    final code = (body['errorCode'] as String? ?? '').trim();
    if (code.isNotEmpty) {
      final msg = (body['errorMsg'] as String? ?? code).trim();
      throw Exception(msg);
    }
  }

  @override
  Future<ProductModel?> fetchProductByBarcode(String code) async {
    try {
      final shopId = UserSession.selectedShopId;
      final trimmed = code.trim();
      final url = ApiUrl.productByBarcode(trimmed);
      debugPrint(
        '[REPO] fetchProductByBarcode → code: "$trimmed" | shopId: "$shopId" | url: $url',
      );
      final response = await _dio.get(
        url,
        queryParameters: {if (shopId.isNotEmpty) 'shopId': shopId},
      );
      debugPrint('[REPO] Response status: ${response.statusCode}');
      debugPrint('[REPO] Response body: ${response.data}');
      final body = _parseBody(response);
      _checkApiError(body);
      final data = body['data'] as Map<String, dynamic>?;
      if (data == null) return null;
      return ProductModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint(
        '[REPO] DioException: ${e.response?.statusCode} | ${e.response?.data}',
      );
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}
