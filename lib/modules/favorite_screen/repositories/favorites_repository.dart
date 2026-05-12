import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/constants/app_constants.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';

// ─────────────────────────────────────────────────────────────
// Abstract interface
// ─────────────────────────────────────────────────────────────

abstract class FavoritesRepository {
  /// Returns the list of product IDs the current user has favorited globally.
  /// Returns **null** when the request itself failed (network error, auth error,
  /// unexpected response format, etc.) so callers can distinguish a genuine
  /// "user has no favorites" (empty list) from a failed call.
  Future<List<String>?> loadFavoriteIds();

  /// Toggles a single product favorite on the server.
  /// Backend adds the record if absent, removes it if present.
  Future<void> toggleFavorite(String productId);

  /// Bulk-syncs a set of product IDs to the server.
  /// Called once after login to migrate local guest favorites.
  Future<void> syncFavorites(List<String> productIds);
}

// ─────────────────────────────────────────────────────────────
// HTTP implementation
// ─────────────────────────────────────────────────────────────

class HttpFavoritesRepository implements FavoritesRepository {
  const HttpFavoritesRepository(this._dio);

  final Dio _dio;

  Options get _authOptions => Options(
        headers: {
          'Content-Type': 'application/json',
          if ((UserSession.token ?? '').trim().isNotEmpty)
            'Authorization': 'Bearer ${UserSession.token}',
        },
      );

  /// The catalog schema uses INT PKs for products.
  /// We store them as String internally, but send them as int to match the DB.
  /// Falls back to the raw string if parsing fails (future-proofing).
  dynamic _toProductIdJson(String productId) =>
      int.tryParse(productId) ?? productId;

  @override
  Future<List<String>?> loadFavoriteIds() async {
    try {
      final response = await _dio.get(
        ApiUrl.favorites,
        options: _authOptions,
      );

      final body = response.data;
      final decoded = body is String ? jsonDecode(body) : body;

      // Response shape: { "success": true, "data": { "items": [{ "productId": int }] } }
      // Return null on unexpected format so callers don't accidentally wipe local state.
      if (decoded is! Map) return null;
      final data = decoded['data'];
      if (data is! Map) return null;
      final items = data['items'];
      if (items is! List) return null;

      // productId may arrive as int (123) or string ("123") — normalize to String.
      return items
          .whereType<Map>()
          .map((e) => e['productId']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
    } catch (_) {
      // Network error, auth error, etc. — return null so the caller knows
      // the request failed and should not overwrite local state.
      return null;
    }
  }

  @override
  Future<void> toggleFavorite(String productId) async {
    await _dio.post(
      ApiUrl.favorites,
      data: jsonEncode({
        'productId': _toProductIdJson(productId),
      }),
      options: _authOptions,
    );
  }

  @override
  Future<void> syncFavorites(List<String> productIds) async {
    if (productIds.isEmpty) return;
    await _dio.post(
      ApiUrl.favoritesSync,
      data: jsonEncode({
        'productIds': productIds.map(_toProductIdJson).toList(),
      }),
      options: _authOptions,
    );
  }
}
