import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/constants/app_constants.dart';
import 'package:e_commerce_mobile_app/core/localization/app_language.dart';
import 'package:e_commerce_mobile_app/core/models/product_item.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/modules/address/models/delivery_address.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_state.dart';
import 'package:e_commerce_mobile_app/modules/checkout/models/order_summary.dart';
import 'package:flutter/foundation.dart';

class OrdersRepositoryException implements Exception {
  const OrdersRepositoryException({required this.code, required this.message});

  final String code;
  final String message;

  @override
  String toString() => message;
}

class PromoValidationResult {
  const PromoValidationResult({
    required this.valid,
    required this.discountAmount,
    required this.message,
  });

  final bool valid;
  final double discountAmount;
  final String message;
}

class OrdersRepository {
  const OrdersRepository(this._dio);

  final Dio _dio;

  Map<String, dynamic> get _authHeaders {
    final token = (UserSession.token ?? '').trim();
    final fallbackAuth = _asString(_dio.options.headers['Authorization']);
    return {
      'Content-Type': 'application/json',
      'Accept-Language': AppLanguage.currentLanguageCode,
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      if (token.isEmpty && fallbackAuth.isNotEmpty)
        'Authorization': fallbackAuth,
    };
  }

  Future<OrderSummary> createOrder({
    required String shopId,
    required DeliveryAddress deliveryAddress,
    required List<CartItemViewModel> items,
    required String paymentMethod,
    required String idempotencyKey,
    String promoCode = '',
  }) async {
    try {
      final response = await _dio.post(
        ApiUrl.orders,
        data: {
          'shopId': shopId,
          'deliveryAddressId': deliveryAddress.id,
          'deliveryContactName': deliveryAddress.nameAddress,
          'deliveryPhone': deliveryAddress.phoneNumber,
          'deliveryAddressText': deliveryAddress.address,
          'deliveryLatitude': deliveryAddress.latitude,
          'deliveryLongitude': deliveryAddress.longitude,
          if (promoCode.trim().isNotEmpty) 'promoCode': promoCode.trim(),
          'paymentMethod': paymentMethod,
          'items': items
              .map(
                (item) => {
                  'productId': item.product.id,
                  'quantity': item.quantity,
                },
              )
              .toList(growable: false),
        },
        options: Options(
          headers: {..._authHeaders, 'Idempotency-Key': idempotencyKey},
        ),
      );

      final body = _parseBody(response.data);
      _throwIfApiError(body);
      final data = _toMap(body['data']);
      return _parseOrderSummary(
        data,
        fallbackItems: items,
        fallbackDelivery: deliveryAddress,
        fallbackPaymentMethod: paymentMethod,
      );
    } on DioException catch (e) {
      throw _fromDioException(e);
    }
  }

  Future<PromoValidationResult> validatePromo({
    required String shopId,
    required String promoCode,
    required List<CartItemViewModel> items,
  }) async {
    try {
      final response = await _dio.post(
        ApiUrl.ordersPromoValidate,
        data: {
          'shopId': shopId,
          'promoCode': promoCode.trim(),
          'items': items
              .map(
                (item) => {
                  'productId': item.product.id,
                  'quantity': item.quantity,
                },
              )
              .toList(growable: false),
        },
        options: Options(headers: _authHeaders),
      );

      final body = _parseBody(response.data);
      _throwIfApiError(body);
      final data = _toMap(body['data']);
      final valid = _asBool(data['valid'], fallback: true);
      final discountAmount = _asDouble(data['discountAmount']);
      final message = _asString(data['message']).isEmpty
          ? 'Promo applied.'
          : _asString(data['message']);
      if (!valid) {
        throw OrdersRepositoryException(
          code: 'PROMO_INVALID',
          message: message,
        );
      }
      return PromoValidationResult(
        valid: valid,
        discountAmount: discountAmount,
        message: message,
      );
    } on DioException catch (e) {
      throw _fromDioException(e);
    }
  }

  Future<OrderSummary> fetchOrderDetail({required String orderId}) async {
    try {
      final response = await _getWithJsonBodyCompatibility(
        path: '${ApiUrl.orders}/$orderId',
      );
      final body = _parseBody(response.data);
      _throwIfApiError(body);
      final data = _toMap(body['data']);
      return _parseOrderSummary(data);
    } on DioException catch (e) {
      throw _fromDioException(e);
    }
  }

  Future<OrderSummary> approveOrder({required String orderId}) {
    return _postOrderTransition(
      path: ApiUrl.orderApprove(orderId.trim()),
      orderId: orderId,
      fallbackStatus: 'PICKING',
    );
  }

  Future<OrderSummary> cancelOrder({required String orderId}) {
    return _postOrderTransition(
      path: ApiUrl.orderCancel(orderId.trim()),
      orderId: orderId,
      fallbackStatus: 'CANCELED',
    );
  }

  Future<OrderSummary> deliverStartOrder({required String orderId}) {
    return _postOrderTransition(
      path: ApiUrl.orderDeliverStart(orderId.trim()),
      orderId: orderId,
      fallbackStatus: 'DELIVERING',
    );
  }

  Future<OrderSummary> deliverCompleteOrder({required String orderId}) {
    return _postOrderTransition(
      path: ApiUrl.orderDeliverComplete(orderId.trim()),
      orderId: orderId,
      fallbackStatus: 'DELIVERED',
    );
  }

  Future<List<OrderSummary>> fetchOrders({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _getWithJsonBodyCompatibility(
        path: ApiUrl.orders,
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      final body = _parseBody(response.data);
      _throwIfApiError(body);
      final data = _toMap(body['data']);
      final items = (data['items'] as List<dynamic>? ?? const []);
      return items
          .map((item) => _parseOrderSummary(_toMap(item)))
          .toList(growable: false);
    } on DioException catch (e) {
      throw _fromDioException(e);
    }
  }

  Future<OrderSummary> _postOrderTransition({
    required String path,
    required String orderId,
    required String fallbackStatus,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: const <String, dynamic>{},
        options: Options(headers: _authHeaders),
      );
      final body = _parseBody(response.data);
      _throwIfApiError(body);
      final data = _toMap(body['data']);
      if (data.isNotEmpty) {
        return _parseOrderSummary(data);
      }

      final latest = await fetchOrderDetail(orderId: orderId.trim());
      if (latest.statusCode.trim().isNotEmpty) return latest;

      return OrderSummary(
        orderId: latest.orderId,
        orderNumber: latest.orderNumber,
        orderDate: latest.orderDate,
        shopName: latest.shopName,
        items: latest.items,
        deliveryAddress: latest.deliveryAddress,
        subtotal: latest.subtotal,
        deliveryFee: latest.deliveryFee,
        packageFees: latest.packageFees,
        discount: latest.discount,
        promoDiscount: latest.promoDiscount,
        total: latest.total,
        paymentMethod: latest.paymentMethod,
        statusCode: fallbackStatus,
        trackStep: fallbackStatus,
        cancelReasonCode: latest.cancelReasonCode,
        cancelReasonNote: latest.cancelReasonNote,
        cancelledBy: latest.cancelledBy,
        cancelledAtUtc: latest.cancelledAtUtc,
        itemCount: latest.itemCount,
        shopLatitude: latest.shopLatitude,
        shopLongitude: latest.shopLongitude,
      );
    } on DioException catch (e) {
      throw _fromDioException(e);
    }
  }

  Future<Response<dynamic>> _getWithJsonBodyCompatibility({
    required String path,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: _authHeaders),
      );
    } on DioException catch (e) {
      if (!_shouldRetryWithJsonBody(e)) rethrow;

      final retryBody = queryParameters ?? <String, dynamic>{};
      debugPrint(
        '[OrdersRepository] retrying GET $path with JSON body for backend compatibility',
      );
      return _dio.get(
        path,
        data: retryBody,
        options: Options(
          headers: {..._authHeaders, 'Content-Type': 'application/json'},
        ),
      );
    }
  }

  bool _shouldRetryWithJsonBody(DioException e) {
    return e.response?.statusCode == 400 &&
        _hasSerializerBodyError(e.response?.data);
  }

  bool _hasSerializerBodyError(dynamic raw) {
    final payload = _parseBody(raw);
    final errors = payload['errors'];
    if (errors is! Map) return false;

    final serializerErrors =
        errors['serializerErrors'] ??
        errors['SerializerErrors'] ??
        errors['serializerError'];
    if (serializerErrors is List && serializerErrors.isNotEmpty) {
      return serializerErrors.any(
        (item) =>
            item.toString().toLowerCase().contains('json tokens') ||
            item.toString().toLowerCase().contains(
              'lineNumber: 0'.toLowerCase(),
            ),
      );
    }
    final text = serializerErrors?.toString().toLowerCase() ?? '';
    return text.contains('json tokens') || text.contains('linenumber: 0');
  }

  OrderSummary _parseOrderSummary(
    Map<String, dynamic> data, {
    List<CartItemViewModel> fallbackItems = const [],
    DeliveryAddress? fallbackDelivery,
    String fallbackPaymentMethod = 'COD',
  }) {
    final trackMap = _toMap(data['track']);
    final shopMap = _toMap(data['shop']);
    final deliveryMap = _toMap(data['delivery']);
    final pricingMap = _toMap(data['pricing']);

    final resolvedTrackStep = _firstNonEmpty([
      _asString(trackMap['step']),
      _asString(data['trackStep']),
      _asString(data['status']),
    ]);

    final resolvedStatusCode = _firstNonEmpty([
      _asString(data['status']),
      resolvedTrackStep,
    ]);

    final resolvedDelivery = DeliveryAddress(
      id: _firstNonEmpty([
        _asString(deliveryMap['addressId']),
        _asString(deliveryMap['id']),
        fallbackDelivery?.id ?? '',
      ]),
      nameAddress: _firstNonEmpty([
        _asString(deliveryMap['nameAddress']),
        _asString(deliveryMap['deliveryContactName']),
        fallbackDelivery?.nameAddress ?? '',
      ]),
      address: _firstNonEmpty([
        _asString(deliveryMap['address']),
        _asString(data['deliveryAddressText']),
        fallbackDelivery?.address ?? '',
      ]),
      phoneNumber: _firstNonEmpty([
        _asString(deliveryMap['phoneNumber']),
        _asString(deliveryMap['deliveryPhone']),
        fallbackDelivery?.phoneNumber ?? '',
      ]),
      label: fallbackDelivery?.label ?? AddressLabel.home,
      isDefault: fallbackDelivery?.isDefault ?? false,
      latitude:
          _firstNonNullDouble([
            _asNullableDouble(deliveryMap['latitude']),
            _asNullableDouble(data['deliveryLatitude']),
            fallbackDelivery?.latitude,
          ]) ??
          0,
      longitude:
          _firstNonNullDouble([
            _asNullableDouble(deliveryMap['longitude']),
            _asNullableDouble(data['deliveryLongitude']),
            fallbackDelivery?.longitude,
          ]) ??
          0,
    );

    final resolvedItems = _parseOrderItems(
      data['items'],
      fallbackItems: fallbackItems,
    );

    final itemSubtotal = _sumSubtotal(resolvedItems);
    final parsedSubtotal = _firstNonNullDouble([
      _asNullableDouble(
        _lookupValue(pricingMap, const ['subtotal', 'subTotal', 'sub_total']),
      ),
      _asNullableDouble(
        _lookupValue(data, const ['subtotal', 'subTotal', 'sub_total']),
      ),
    ]);
    final subtotal =
        parsedSubtotal == null || (parsedSubtotal == 0 && itemSubtotal > 0)
        ? itemSubtotal
        : parsedSubtotal;
    final deliveryFee =
        _firstNonNullDouble([
          _asNullableDouble(
            _lookupValue(pricingMap, const ['deliveryFee', 'delivery_fee']),
          ),
          _asNullableDouble(
            _lookupValue(data, const ['deliveryFee', 'delivery_fee']),
          ),
        ]) ??
        1.59;
    final packageFees =
        _firstNonNullDouble([
          _asNullableDouble(
            _lookupValue(pricingMap, const [
              'packageFees',
              'packageFee',
              'package_fees',
              'package_fee',
            ]),
          ),
          _asNullableDouble(
            _lookupValue(data, const [
              'packageFees',
              'packageFee',
              'package_fees',
              'package_fee',
            ]),
          ),
        ]) ??
        0.10;
    final discount =
        _firstNonNullDouble([
          _asNullableDouble(_lookupValue(pricingMap, const ['discount'])),
          _asNullableDouble(_lookupValue(data, const ['discount'])),
        ]) ??
        0.0;
    final promoDiscount =
        _firstNonNullDouble([
          _asNullableDouble(
            _lookupValue(pricingMap, const ['promoDiscount', 'promo_discount']),
          ),
          _asNullableDouble(
            _lookupValue(data, const ['promoDiscount', 'promo_discount']),
          ),
        ]) ??
        0.0;
    final total =
        _firstNonNullDouble([
          _asNullableDouble(_lookupValue(pricingMap, const ['total'])),
          _asNullableDouble(_lookupValue(data, const ['total'])),
        ]) ??
        (subtotal + deliveryFee + packageFees - discount - promoDiscount);

    return OrderSummary(
      orderId: _firstNonEmpty([
        _asString(data['orderId']),
        _asString(data['id']),
      ]),
      orderNumber: _asString(data['orderNumber']),
      orderDate: _parseDateTime(data['orderDateUtc'] ?? data['orderDate']),
      shopName: _firstNonEmpty([
        _asString(shopMap['storeName']),
        _asString(data['shopName']),
      ]),
      items: resolvedItems,
      deliveryAddress: resolvedDelivery,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      packageFees: packageFees,
      discount: discount,
      promoDiscount: promoDiscount,
      total: total,
      paymentMethod: _firstNonEmpty([
        _asString(data['paymentMethod']),
        fallbackPaymentMethod,
      ]),
      statusCode: resolvedStatusCode,
      trackStep: resolvedTrackStep,
      cancelReasonCode: _firstNonEmpty([
        _asString(data['cancelReasonCode']),
        _asString(data['cancel_reason_code']),
      ]),
      cancelReasonNote: _firstNonEmpty([
        _asString(data['cancelReasonNote']),
        _asString(data['cancel_reason_note']),
      ]),
      cancelledBy: _firstNonEmpty([
        _asString(data['cancelledBy']),
        _asString(data['canceledBy']),
        _asString(data['cancelled_by']),
      ]),
      cancelledAtUtc: _parseNullableDateTime(
        data['cancelledAtUtc'] ??
            data['canceledAtUtc'] ??
            data['cancelled_at_utc'],
      ),
      itemCount: _asNullableInt(data['itemCount']),
      shopLatitude: _firstNonNullDouble([
        _asNullableDouble(shopMap['latitude']),
        _asNullableDouble(data['shopLatitude']),
      ]),
      shopLongitude: _firstNonNullDouble([
        _asNullableDouble(shopMap['longitude']),
        _asNullableDouble(data['shopLongitude']),
      ]),
    );
  }

  List<CartItemViewModel> _parseOrderItems(
    dynamic rawItems, {
    required List<CartItemViewModel> fallbackItems,
  }) {
    final items = rawItems as List<dynamic>? ?? const [];
    if (items.isEmpty) return fallbackItems;

    final fallbackById = {
      for (final item in fallbackItems) item.product.id: item,
    };

    final parsed = <CartItemViewModel>[];
    for (final raw in items) {
      final map = _toMap(raw);
      final productId = _firstNonEmpty([
        _asString(map['productId']),
        _asString(map['id']),
      ]);
      final fallback = fallbackById[productId];
      final quantity =
          _asNullableInt(map['quantity']) ?? fallback?.quantity ?? 0;
      if (quantity <= 0) continue;

      final lineTotal = _asNullableDouble(
        _lookupValue(map, const ['lineTotal', 'line_total']),
      );
      final unitPrice =
          _firstNonNullDouble([
            _asNullableDouble(
              _lookupValue(map, const ['unitPrice', 'unit_price']),
            ),
            _asNullableDouble(map['price']),
            lineTotal != null ? lineTotal / quantity : null,
            fallback?.product.price,
          ]) ??
          0.0;

      final product = ProductModel(
        id: productId,
        name: _firstNonEmpty([
          _asString(map['name']),
          fallback?.product.name ?? '',
        ]),
        price: unitPrice,
        imageUrl: _firstNonEmpty([
          _asString(map['imageUrl']),
          fallback?.product.imageUrl ?? '',
        ]),
      );
      parsed.add(
        CartItemViewModel(
          product: product,
          quantity: quantity,
          cancelReasonCode: _firstNonEmpty([
            _asString(map['cancelReasonCode']),
            _asString(map['cancel_reason_code']),
          ]),
          cancelReasonNote: _firstNonEmpty([
            _asString(map['cancelReasonNote']),
            _asString(map['cancel_reason_note']),
          ]),
        ),
      );
    }
    return parsed.isNotEmpty ? parsed : fallbackItems;
  }

  OrdersRepositoryException _fromDioException(DioException e) {
    final body = _parseBody(e.response?.data);
    debugPrint(
      '[OrdersRepository] DioException: ${e.response?.statusCode} ${e.message} body=$body',
    );
    final code = _firstNonEmpty([
      _asString(body['errorCode']),
      'NETWORK_ERROR',
    ]);
    final message = _firstNonEmpty([
      _asString(body['errorMsg']),
      e.message ?? '',
      'Request failed. Please try again.',
    ]);
    return OrdersRepositoryException(code: code, message: message);
  }

  void _throwIfApiError(Map<String, dynamic> body) {
    final code = _asString(body['errorCode']);
    final message = _asString(body['errorMsg']);
    final hasSuccess =
        body.containsKey('success') || body.containsKey('Success');
    final success = _asBool(body['success'] ?? body['Success'], fallback: true);

    if (code.isNotEmpty || (hasSuccess && !success)) {
      throw OrdersRepositoryException(
        code: code.isEmpty ? 'BUSINESS_ERROR' : code,
        message: message.isEmpty ? 'Request failed.' : message,
      );
    }
  }

  Map<String, dynamic> _parseBody(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw.trim());
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) {
          return decoded.map((key, value) => MapEntry(key.toString(), value));
        }
      } catch (_) {}
    }
    return const {};
  }

  Map<String, dynamic> _toMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return const {};
  }

  String _asString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  bool _asBool(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return fallback;
  }

  int? _asNullableInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim()) ?? 0.0;
    return 0.0;
  }

  double? _asNullableDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  String _firstNonEmpty(List<String> values) {
    for (final value in values) {
      if (value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  double? _firstNonNullDouble(List<double?> values) {
    for (final value in values) {
      if (value != null) return value;
    }
    return null;
  }

  dynamic _lookupValue(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (map.containsKey(key)) return map[key];
    }
    final lowerKeys = keys.map((key) => key.toLowerCase()).toSet();
    for (final entry in map.entries) {
      if (lowerKeys.contains(entry.key.toLowerCase())) return entry.value;
    }
    return null;
  }

  DateTime _parseDateTime(dynamic raw) {
    final text = _asString(raw);
    final parsed = text.isEmpty ? null : DateTime.tryParse(text);
    if (parsed == null) return DateTime.now();
    return parsed.isUtc ? parsed.toLocal() : parsed;
  }

  DateTime? _parseNullableDateTime(dynamic raw) {
    final text = _asString(raw);
    if (text.isEmpty) return null;
    final parsed = DateTime.tryParse(text);
    if (parsed == null) return null;
    return parsed.isUtc ? parsed.toLocal() : parsed;
  }

  double _sumSubtotal(List<CartItemViewModel> items) {
    return items.fold<double>(
      0.0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }
}
