import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:e_commerce_mobile_app/modules/address/models/delivery_address.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_state.dart';
import 'package:e_commerce_mobile_app/modules/checkout/cubits/checkout_state.dart';
import 'package:e_commerce_mobile_app/modules/checkout/repositories/orders_repository.dart';
import 'package:e_commerce_mobile_app/modules/checkout/services/directions_service.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(this._directionsService, this._ordersRepository)
    : super(const CheckoutState());

  final DirectionsService _directionsService;
  final OrdersRepository _ordersRepository;
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
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> applyPromo({
    required String shopId,
    required List<CartItemViewModel> items,
  }) async {
    if (state.promoCode.trim().isEmpty) return;
    if (items.isEmpty) {
      _emitIfOpen(
        state.copyWith(
          status: CheckoutStatus.failure,
          errorMessage: 'Your cart is empty.',
        ),
      );
      return;
    }
    if (shopId.trim().isEmpty) {
      _emitIfOpen(
        state.copyWith(
          status: CheckoutStatus.failure,
          errorMessage: 'Please select a shop before applying promo.',
        ),
      );
      return;
    }

    try {
      final result = await _ordersRepository.validatePromo(
        shopId: shopId,
        promoCode: state.promoCode,
        items: items,
      );
      _emitIfOpen(
        state.copyWith(
          isPromoApplied: result.valid,
          promoDiscount: result.discountAmount,
          status: CheckoutStatus.idle,
          clearErrorMessage: true,
        ),
      );
    } on OrdersRepositoryException catch (e) {
      _emitIfOpen(
        state.copyWith(
          isPromoApplied: false,
          promoDiscount: 0.0,
          status: CheckoutStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      _emitIfOpen(
        state.copyWith(
          isPromoApplied: false,
          promoDiscount: 0.0,
          status: CheckoutStatus.failure,
          errorMessage: 'Failed to validate promo code. Please try again.',
        ),
      );
    }
  }

  Future<void> placeOrder({
    required List<CartItemViewModel> items,
    required DeliveryAddress deliveryAddress,
    required String shopId,
  }) async {
    if (state.status == CheckoutStatus.placingOrder) return;
    if (items.isEmpty) {
      _emitIfOpen(
        state.copyWith(
          status: CheckoutStatus.failure,
          errorMessage: 'Your cart is empty.',
        ),
      );
      return;
    }
    if (shopId.trim().isEmpty) {
      _emitIfOpen(
        state.copyWith(
          status: CheckoutStatus.failure,
          errorMessage: 'Please select a shop before placing order.',
        ),
      );
      return;
    }
    _emitIfOpen(state.copyWith(status: CheckoutStatus.placingOrder));
    try {
      final summary = await _ordersRepository.createOrder(
        shopId: shopId,
        deliveryAddress: deliveryAddress,
        items: items,
        paymentMethod: 'COD',
        idempotencyKey: const Uuid().v4(),
        promoCode: state.isPromoApplied ? state.promoCode : '',
      );

      _emitIfOpen(
        state.copyWith(
          status: CheckoutStatus.success,
          completedOrder: summary,
          clearErrorMessage: true,
        ),
      );
    } on OrdersRepositoryException catch (e) {
      _emitIfOpen(
        state.copyWith(status: CheckoutStatus.failure, errorMessage: e.message),
      );
    } catch (_) {
      _emitIfOpen(
        state.copyWith(
          status: CheckoutStatus.failure,
          errorMessage: 'Failed to place order. Please try again.',
        ),
      );
    }
  }

  void reset() {
    _emitIfOpen(const CheckoutState());
  }
}
