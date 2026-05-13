import 'package:e_commerce_mobile_app/core/models/product_item.dart';
import 'package:e_commerce_mobile_app/modules/address/models/delivery_address.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_state.dart';
import 'package:e_commerce_mobile_app/modules/checkout/models/order_summary.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/cubits/order_history_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderHistoryCubit', () {
    test('uses fallback orders when no real orders exist', () {
      final cubit = OrderHistoryCubit();

      expect(cubit.state.orders, isEmpty);
      expect(cubit.displayOrders, isNotEmpty);
    });

    test('addPlacedOrder prepends newest orders', () {
      final cubit = OrderHistoryCubit();
      final firstOrder = _buildOrder('a', '00010', 3.20);
      final secondOrder = _buildOrder('b', '00011', 5.80);

      cubit.addPlacedOrder(firstOrder);
      cubit.addPlacedOrder(secondOrder);

      expect(cubit.state.orders.length, 2);
      expect(cubit.state.orders.first.summary.orderId, 'b');
      expect(cubit.state.orders.last.summary.orderId, 'a');
      expect(cubit.displayOrders.length, 2);
    });
  });
}

OrderSummary _buildOrder(String id, String orderNumber, double total) {
  return OrderSummary(
    orderId: id,
    orderNumber: orderNumber,
    orderDate: DateTime(2026, 5, 13, 10, 0),
    shopName: 'Supermarket 271 Mega Mall',
    items: const [
      CartItemViewModel(
        product: ProductModel(
          id: 'p1',
          name: 'Test Product',
          price: 1.0,
          imageUrl: '',
        ),
        quantity: 1,
      ),
    ],
    deliveryAddress: const DeliveryAddress(
      id: 'addr-1',
      nameAddress: 'Home',
      address: 'Street 271',
      phoneNumber: '012345678',
      label: AddressLabel.home,
      isDefault: true,
      latitude: 11.5,
      longitude: 104.9,
    ),
    subtotal: total - 1.69,
    deliveryFee: 1.59,
    packageFees: 0.10,
    discount: 0.0,
    promoDiscount: 0.0,
    total: total,
    paymentMethod: 'Cash on Delivery',
  );
}
