import 'package:e_commerce_mobile_app/core/localization/app_language.dart';
import 'package:e_commerce_mobile_app/modules/address/models/delivery_address.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_state.dart';

class OrderSummary {
  const OrderSummary({
    required this.orderId,
    required this.orderNumber,
    required this.orderDate,
    required this.shopName,
    this.shopNameEn = '',
    this.shopNameKm = '',
    required this.items,
    required this.deliveryAddress,
    required this.subtotal,
    required this.deliveryFee,
    required this.packageFees,
    required this.discount,
    required this.promoDiscount,
    required this.total,
    required this.paymentMethod,
    this.statusCode = '',
    this.trackStep = '',
    this.cancelReasonCode = '',
    this.cancelReasonNote = '',
    this.cancelledBy = '',
    this.cancelledAtUtc,
    this.itemCount,
    this.shopLatitude,
    this.shopLongitude,
  });

  final String orderId;
  final String orderNumber;
  final DateTime orderDate;
  final String shopName;
  final String shopNameEn;
  final String shopNameKm;
  final List<CartItemViewModel> items;
  final DeliveryAddress deliveryAddress;
  final double subtotal;
  final double deliveryFee;
  final double packageFees;
  final double discount;
  final double promoDiscount;
  final double total;
  final String paymentMethod;

  /// Backend lifecycle status (e.g. REQUESTING, PICKING, DELIVERING, DELIVERED, CANCELED).
  final String statusCode;

  /// Tracking step from backend (`track.step`). Falls back to [statusCode] when empty.
  final String trackStep;

  /// Optional cancellation metadata.
  final String cancelReasonCode;
  final String cancelReasonNote;
  final String cancelledBy;
  final DateTime? cancelledAtUtc;

  /// Optional server-provided item count from list endpoints.
  final int? itemCount;

  /// Store location — used to draw the route on the Order Track map.
  final double? shopLatitude;
  final double? shopLongitude;

  String get displayShopName =>
      displayShopNameFor(AppLanguage.currentLanguageCode);

  String displayShopNameFor(String languageCode) => AppLanguage.localizedText(
    languageCode: languageCode,
    english: shopNameEn,
    khmer: shopNameKm,
    legacy: shopName,
  );
}
