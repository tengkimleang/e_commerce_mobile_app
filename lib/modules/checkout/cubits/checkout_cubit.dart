import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:e_commerce_mobile_app/modules/address/models/delivery_address.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_state.dart';
import 'package:e_commerce_mobile_app/modules/checkout/cubits/checkout_state.dart';
import 'package:e_commerce_mobile_app/modules/checkout/models/order_summary.dart';
import 'package:e_commerce_mobile_app/modules/checkout/services/directions_service.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(this._directionsService) : super(const CheckoutState());

  final DirectionsService _directionsService;

  static const double _deliveryFee = 1.59;
  static const double _packageFees = 0.10;
  static const String _paymentMethod = 'Cash on Delivery';

  int _orderCounter = 1;
  int _directionsRequestId = 0;

  void _emitIfOpen(CheckoutState nextState) {
    if (!isClosed) emit(nextState);
  }

  Future<void> loadDirections(
    LatLng storeLocation,
    LatLng deliveryLocation,
  ) async {
    if (isClosed) return;
    final requestId = ++_directionsRequestId;
    _emitIfOpen(state.copyWith(status: CheckoutStatus.loadingDirections));

    try {
      final points = await _directionsService.getRoutePoints(
        storeLocation,
        deliveryLocation,
      );
      if (isClosed || requestId != _directionsRequestId) return;

      // Fall back to a straight line so the map always shows a route
      final finalPoints = points.isNotEmpty
          ? points
          : [storeLocation, deliveryLocation];
      _emitIfOpen(
        state.copyWith(
          status: CheckoutStatus.idle,
          polylinePoints: finalPoints,
        ),
      );
    } catch (_) {
      if (isClosed || requestId != _directionsRequestId) return;
      // Keep UI stable even when directions API fails.
      _emitIfOpen(
        state.copyWith(
          status: CheckoutStatus.idle,
          polylinePoints: [storeLocation, deliveryLocation],
        ),
      );
    }
  }

  void updatePromoCode(String code) {
    _emitIfOpen(
      state.copyWith(
        promoCode: code,
        isPromoApplied: false,
        promoDiscount: 0.0,
      ),
    );
  }

  void applyPromo() {
    // Phase 1: mock — no real validation yet
    if (state.promoCode.trim().isEmpty) return;
    _emitIfOpen(state.copyWith(isPromoApplied: true, promoDiscount: 0.0));
  }

  Future<void> placeOrder({
    required List<CartItemViewModel> items,
    required DeliveryAddress deliveryAddress,
    required String shopName,
    double? storeLatitude,
    double? storeLongitude,
  }) async {
    if (state.status == CheckoutStatus.placingOrder) return;
    _emitIfOpen(state.copyWith(status: CheckoutStatus.placingOrder));

    final subtotal = items.fold<double>(
      0.0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
    final total = subtotal + _deliveryFee + _packageFees - state.promoDiscount;
    final orderNumber = _orderCounter.toString().padLeft(5, '0');
    _orderCounter++;

    final summary = OrderSummary(
      orderId: const Uuid().v4(),
      orderNumber: orderNumber,
      orderDate: DateTime.now(),
      shopName: shopName,
      items: items,
      deliveryAddress: deliveryAddress,
      subtotal: subtotal,
      deliveryFee: _deliveryFee,
      packageFees: _packageFees,
      discount: 0.0,
      promoDiscount: state.promoDiscount,
      total: total,
      paymentMethod: _paymentMethod,
      shopLatitude: storeLatitude,
      shopLongitude: storeLongitude,
    );

    _emitIfOpen(
      state.copyWith(status: CheckoutStatus.success, completedOrder: summary),
    );
  }

  void reset() {
    _emitIfOpen(const CheckoutState());
  }
}
