import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/constants/app_constants.dart';
import 'package:e_commerce_mobile_app/core/data/product_data.dart';
import 'package:e_commerce_mobile_app/core/models/product_item.dart';
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
}

// ─────────────────────────────────────────────────────────────
// Mock — backed by local ProductData.
// Use this while the backend is being built.
// To switch to the real API, change the DI registration in di.dart.
// ─────────────────────────────────────────────────────────────

class MockCategoriesRepository implements CategoriesRepository {
  @override
  Future<List<CategoryModel>> fetchCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.generate(ProductData.sectionTitles.length, (index) {
      return CategoryModel(
        id: index + 1,
        nameEn: ProductData.sectionTitles[index],
        nameKm: index == 0 ? 'ដឹកជញ្ជូនឥតគិតថ្លៃ' : '',
        bannerImageUrl: ProductData.sectionImages[index],
        displayOrder: index,
        isActive: true,
        promoStartAt: index == 0 ? DateTime(2026, 4, 1) : null,
        promoEndAt: index == 0 ? DateTime(2026, 4, 30) : null,
        previewProducts: ProductData.sectionAt(index),
      );
    });
  }

  @override
  Future<(List<ProductModel>, int)> fetchCategoryProducts(
    int categoryId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final products = ProductData.sectionAt(categoryId - 1);
    return (products, products.length);
  }

  @override
  Future<List<SubCategoryModel>> fetchSubCategories(int categoryId) async =>
      const [];

  @override
  Future<(List<ProductModel>, int)> fetchSubCategoryProducts(
    int subCategoryId, {
    int page = 1,
    int pageSize = 20,
  }) async => (const <ProductModel>[], 0);

  @override
  Future<(List<ProductModel>, int)> searchProducts(
    String keyword, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final q = keyword.trim().toLowerCase();
    final all = ProductData.allProducts;
    final filtered = q.isEmpty
        ? all
        : all.where((p) => p.name.toLowerCase().contains(q)).toList();
    final start = ((page - 1) * pageSize).clamp(0, filtered.length);
    final end = (start + pageSize).clamp(0, filtered.length);
    return (filtered.sublist(start, end), filtered.length);
  }

  @override
  Future<(List<ProductModel>, int)> fetchProductsByCountry(
    String country, {
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final filtered = ProductData.allProducts
        .where((p) =>
            p.countryOfOrigin?.toLowerCase() == country.toLowerCase())
        .toList();
    final start = ((page - 1) * pageSize).clamp(0, filtered.length);
    final end = (start + pageSize).clamp(0, filtered.length);
    return (filtered.sublist(start, end), filtered.length);
  }
}

// ─────────────────────────────────────────────────────────────
// HTTP — calls the real ASP.NET Core API.
// Switch DI registration from MockCategoriesRepository to this
// once BE endpoints are live in Swagger.
// ─────────────────────────────────────────────────────────────

class HttpCategoriesRepository implements CategoriesRepository {
  final Dio _dio;

  HttpCategoriesRepository(this._dio);

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    final response = await _dio.get(ApiUrl.categories);
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
      );
    });
  }

  @override
  Future<(List<ProductModel>, int)> fetchCategoryProducts(
    int categoryId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiUrl.categoryProducts(categoryId),
      queryParameters: {'page': page, 'pageSize': pageSize},
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
    final response = await _dio.get(
      ApiUrl.subCategoryProducts(subCategoryId),
      queryParameters: {'page': page, 'pageSize': pageSize},
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
    final response = await _dio.get(
      ApiUrl.products,
      queryParameters: {'keyword': keyword, 'page': page, 'pageSize': pageSize},
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
    final response = await _dio.get(
      ApiUrl.products,
      queryParameters: {
        'countryOfOrigin': country,
        'page': page,
        'pageSize': pageSize,
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
}
