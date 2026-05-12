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

  Future<void> loadDirections(LatLng storeLocation, LatLng deliveryLocation) async {
    emit(state.copyWith(status: CheckoutStatus.loadingDirections));
    final points =
        await _directionsService.getRoutePoints(storeLocation, deliveryLocation);
    // Fall back to a straight line so the map always shows a route
    final finalPoints = points.isNotEmpty
        ? points
        : [storeLocation, deliveryLocation];
    emit(state.copyWith(
      status: CheckoutStatus.idle,
      polylinePoints: finalPoints,
    ));
  }

  void updatePromoCode(String code) {
    emit(state.copyWith(promoCode: code, isPromoApplied: false, promoDiscount: 0.0));
  }

  void applyPromo() {
    // Phase 1: mock — no real validation yet
    if (state.promoCode.trim().isEmpty) return;
    emit(state.copyWith(isPromoApplied: true, promoDiscount: 0.0));
  }

  Future<void> placeOrder({
    required List<CartItemViewModel> items,
    required DeliveryAddress deliveryAddress,
    required String shopName,
    double? storeLatitude,
    double? storeLongitude,
  }) async {
    if (state.status == CheckoutStatus.placingOrder) return;
    emit(state.copyWith(status: CheckoutStatus.placingOrder));

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

    emit(state.copyWith(
      status: CheckoutStatus.success,
      completedOrder: summary,
    ));
  }

  void reset() {
    emit(const CheckoutState());
  }
}
