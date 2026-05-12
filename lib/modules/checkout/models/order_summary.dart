import 'package:e_commerce_mobile_app/modules/address/models/delivery_address.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_state.dart';

class OrderSummary {
  const OrderSummary({
    required this.orderId,
    required this.orderNumber,
    required this.orderDate,
    required this.shopName,
    required this.items,
    required this.deliveryAddress,
    required this.subtotal,
    required this.deliveryFee,
    required this.packageFees,
    required this.discount,
    required this.promoDiscount,
    required this.total,
    required this.paymentMethod,
    this.shopLatitude,
    this.shopLongitude,
  });

  final String orderId;
  final String orderNumber;
  final DateTime orderDate;
  final String shopName;
  final List<CartItemViewModel> items;
  final DeliveryAddress deliveryAddress;
  final double subtotal;
  final double deliveryFee;
  final double packageFees;
  final double discount;
  final double promoDiscount;
  final double total;
  final String paymentMethod;
  /// Store location — used to draw the route on the Order Track map.
  final double? shopLatitude;
  final double? shopLongitude;
}
