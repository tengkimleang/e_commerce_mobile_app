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

  /// Idempotently adds a single product favorite on the server.
  Future<void> addFavorite(String productId);

  /// Idempotently removes a single product favorite on the server.
  Future<void> removeFavorite(String productId);

  /// Legacy toggle endpoint kept only for backward compatibility.
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

  static Future<bool>? _refreshInFlight;

  final Dio _dio;

  Options _authOptions({bool Function(int?)? validateStatus}) => Options(
    headers: {
      'Content-Type': 'application/json',
      if ((UserSession.token ?? '').trim().isNotEmpty)
        'Authorization': 'Bearer ${UserSession.token}',
    },
    validateStatus: validateStatus,
  );

  /// The catalog schema uses INT PKs for products.
  /// We store them as String internally, but send them as int to match the DB.
  /// Falls back to the raw string if parsing fails (future-proofing).
  dynamic _toProductIdJson(String productId) =>
      int.tryParse(productId) ?? productId;

  @override
  Future<List<String>?> loadFavoriteIds() async {
    try {
      final response = await _sendWithAuthRetry(
        () => _dio.get(
          ApiUrl.favorites,
          options: _authOptions(validateStatus: _acceptAnyStatus),
        ),
      );

      if (!_isSuccessfulResponse(response)) return null;

      final decoded = _decodeResponseBody(response.data);

      // Response shape: { "success": true, "data": { "items": [{ "productId": int }] } }
      // Return null on unexpected format so callers don't accidentally wipe local state.
      if (decoded is! Map) return null;
      if (_hasExplicitFailure(decoded)) return null;
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
  Future<void> addFavorite(String productId) async {
    final response = await _sendWithAuthRetry(
      () => _dio.put(
        ApiUrl.favoriteByProductId(productId),
        options: _authOptions(validateStatus: _acceptAnyStatus),
      ),
    );
    if (!_isSuccessfulResponse(response)) {
      throw StateError('Favorite add failed with HTTP ${response.statusCode}');
    }
  }

  @override
  Future<void> removeFavorite(String productId) async {
    final response = await _sendWithAuthRetry(
      () => _dio.delete(
        ApiUrl.favoriteByProductId(productId),
        options: _authOptions(validateStatus: _acceptAnyStatus),
      ),
    );
    if (!_isSuccessfulResponse(response)) {
      throw StateError(
        'Favorite remove failed with HTTP ${response.statusCode}',
      );
    }
  }

  @override
  Future<void> toggleFavorite(String productId) async {
    final response = await _sendWithAuthRetry(
      () => _dio.post(
        ApiUrl.favorites,
        data: jsonEncode({'productId': _toProductIdJson(productId)}),
        options: _authOptions(validateStatus: _acceptAnyStatus),
      ),
    );
    if (!_isSuccessfulResponse(response)) {
      throw StateError(
        'Favorite toggle failed with HTTP ${response.statusCode}',
      );
    }
  }

  @override
  Future<void> syncFavorites(List<String> productIds) async {
    if (productIds.isEmpty) return;
    final response = await _sendWithAuthRetry(
      () => _dio.post(
        ApiUrl.favoritesSync,
        data: jsonEncode({
          'productIds': productIds.map(_toProductIdJson).toList(),
        }),
        options: _authOptions(validateStatus: _acceptAnyStatus),
      ),
    );
    if (!_isSuccessfulResponse(response)) {
      throw StateError(
        'Favorites sync failed with HTTP ${response.statusCode}',
      );
    }
  }

  bool _acceptAnyStatus(int? status) => status != null;

  Future<Response<T>> _sendWithAuthRetry<T>(
    Future<Response<T>> Function() send,
  ) async {
    var response = await send();
    if (!_isUnauthorizedResponse(response)) return response;

    final refreshed = await _refreshAccessTokenWithLock();
    if (!refreshed) return response;

    response = await send();
    return response;
  }

  bool _isSuccessfulResponse(Response<dynamic> response) {
    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) return false;

    final decoded = _decodeResponseBody(response.data);
    if (decoded is Map && _hasExplicitFailure(decoded)) return false;
    return true;
  }

  bool _isUnauthorizedResponse(Response<dynamic> response) {
    if (response.statusCode == 401) return true;
    final decoded = _decodeResponseBody(response.data);
    if (decoded is! Map) return false;
    final code = _readStringFromPayloadAndData(decoded, [
      'errorCode',
      'ErrorCode',
    ]).toUpperCase();
    return code == 'AUTH401' || code == 'UNAUTHORIZED';
  }

  bool _hasExplicitFailure(Map<dynamic, dynamic> payload) {
    final rawSuccess = payload['success'] ?? payload['Success'];
    if (rawSuccess == null) return false;
    if (rawSuccess is bool) return !rawSuccess;
    if (rawSuccess is num) return rawSuccess == 0;
    if (rawSuccess is String) {
      final value = rawSuccess.trim().toLowerCase();
      return value == 'false' || value == '0';
    }
    return false;
  }

  Future<bool> _refreshAccessTokenWithLock() async {
    final inFlight = _refreshInFlight;
    if (inFlight != null) return inFlight;

    final future = _refreshAccessToken();
    _refreshInFlight = future;
    try {
      return await future;
    } finally {
      if (identical(_refreshInFlight, future)) {
        _refreshInFlight = null;
      }
    }
  }

  Future<bool> _refreshAccessToken() async {
    final refreshToken = (UserSession.refreshToken ?? '').trim();
    if (refreshToken.isEmpty) return false;

    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: jsonEncode({'refreshToken': refreshToken}),
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: _acceptAnyStatus,
        ),
      );

      if (!_isSuccessfulResponse(response)) return false;

      final decoded = _decodeResponseBody(response.data);
      if (decoded is! Map) return false;

      final accessToken = _readStringFromPayloadAndData(decoded, [
        'accessToken',
        'AccessToken',
        'token',
        'Token',
        'jwt',
        'Jwt',
        'jwtToken',
        'JwtToken',
      ]);
      if (accessToken.isEmpty) return false;

      final newRefreshToken = _readStringFromPayloadAndData(decoded, [
        'refreshToken',
        'RefreshToken',
      ]);
      final accessTokenExpiresInSeconds = _readIntFromPayloadAndData(decoded, [
        'accessTokenExpiresInSeconds',
        'AccessTokenExpiresInSeconds',
        'accessTokenExpiresInSecond',
        'AccessTokenExpiresInSecond',
        'expiresInSeconds',
        'ExpiresInSeconds',
      ]);
      final refreshTokenExpiresInSeconds = _readIntFromPayloadAndData(decoded, [
        'refreshTokenExpiresInSeconds',
        'RefreshTokenExpiresInSeconds',
        'refreshExpiresInSeconds',
        'RefreshExpiresInSeconds',
      ]);

      await UserSession.markAuthenticated(
        token: accessToken,
        refreshToken: newRefreshToken.isEmpty ? null : newRefreshToken,
        accessTokenExpiresInSeconds: accessTokenExpiresInSeconds > 0
            ? accessTokenExpiresInSeconds
            : null,
        refreshTokenExpiresInSeconds: refreshTokenExpiresInSeconds > 0
            ? refreshTokenExpiresInSeconds
            : null,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  dynamic _decodeResponseBody(dynamic body) {
    if (body is String) {
      try {
        return jsonDecode(body);
      } catch (_) {
        return body;
      }
    }
    return body;
  }

  Map<dynamic, dynamic> _extractDataMap(Map<dynamic, dynamic> payload) {
    final data = payload['data'] ?? payload['Data'];
    if (data is Map) return data;
    return payload;
  }

  String _readStringField(Map<dynamic, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  String _readStringFromPayloadAndData(
    Map<dynamic, dynamic> payload,
    List<String> keys,
  ) {
    final direct = _readStringField(payload, keys);
    if (direct.isNotEmpty) return direct;
    return _readStringField(_extractDataMap(payload), keys);
  }

  int _readIntFromPayloadAndData(
    Map<dynamic, dynamic> payload,
    List<String> keys,
  ) {
    for (final source in [payload, _extractDataMap(payload)]) {
      for (final key in keys) {
        final raw = source[key];
        if (raw is int) return raw;
        if (raw is num) return raw.toInt();
        if (raw is String) {
          final value = int.tryParse(raw.trim());
          if (value != null) return value;
        }
      }
    }
    return 0;
  }
}
