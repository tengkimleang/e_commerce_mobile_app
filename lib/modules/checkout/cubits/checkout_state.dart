import 'package:e_commerce_mobile_app/modules/checkout/models/order_summary.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum CheckoutStatus { idle, loadingDirections, placingOrder, success }

class CheckoutState {
  const CheckoutState({
    this.status = CheckoutStatus.idle,
    this.promoCode = '',
    this.isPromoApplied = false,
    this.promoDiscount = 0.0,
    this.polylinePoints = const [],
    this.completedOrder,
  });

  final CheckoutStatus status;
  final String promoCode;
  final bool isPromoApplied;
  final double promoDiscount;
  final List<LatLng> polylinePoints;
  final OrderSummary? completedOrder;

  CheckoutState copyWith({
    CheckoutStatus? status,
    String? promoCode,
    bool? isPromoApplied,
    double? promoDiscount,
    List<LatLng>? polylinePoints,
    OrderSummary? completedOrder,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      promoCode: promoCode ?? this.promoCode,
      isPromoApplied: isPromoApplied ?? this.isPromoApplied,
      promoDiscount: promoDiscount ?? this.promoDiscount,
      polylinePoints: polylinePoints ?? this.polylinePoints,
      completedOrder: completedOrder ?? this.completedOrder,
    );
  }
}
