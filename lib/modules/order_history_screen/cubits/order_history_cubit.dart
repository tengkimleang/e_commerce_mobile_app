import 'package:e_commerce_mobile_app/core/models/product_item.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/modules/address/models/delivery_address.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_state.dart';
import 'package:e_commerce_mobile_app/modules/checkout/models/order_summary.dart';
import 'package:e_commerce_mobile_app/modules/checkout/repositories/orders_repository.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/cubits/order_history_state.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/models/order_history_entry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  OrderHistoryCubit({OrdersRepository? ordersRepository})
    : _ordersRepository = ordersRepository,
      super(const OrderHistoryState());

  final OrdersRepository? _ordersRepository;

  static final List<OrderHistoryEntry> fallbackOrders = _buildFallbackOrders();

  List<OrderHistoryEntry> get displayOrders {
    return state.orders.isNotEmpty ? state.orders : fallbackOrders;
  }

  void addPlacedOrder(OrderSummary summary) {
    final next = OrderHistoryEntry(
      summary: summary,
      status: _statusFromCode(summary.statusCode),
    );
    emit(OrderHistoryState(orders: [next, ...state.orders]));
  }

  Future<void> loadOrders({int page = 1, int pageSize = 20}) async {
    final repository = _ordersRepository;
    if (repository == null || !UserSession.isAuthenticated) return;
    try {
      final summaries = await repository.fetchOrders(
        page: page,
        pageSize: pageSize,
      );
      final entries = summaries
          .map(
            (summary) => OrderHistoryEntry(
              summary: summary,
              status: _statusFromCode(summary.statusCode),
            ),
          )
          .toList(growable: false);
      emit(state.copyWith(orders: entries));
    } catch (_) {
      // Keep current/fallback UI when backend history fetch fails.
      debugPrint('[OrderHistoryCubit] loadOrders failed.');
    }
  }

  static OrderStatus _statusFromCode(String code) {
    final normalized = code.trim().toUpperCase();
    switch (normalized) {
      case 'CANCELED':
        return OrderStatus.canceled;
      case 'REQUESTING':
        return OrderStatus.requesting;
      case 'PICKING':
      case 'DELIVERING':
      case 'DELIVERED':
        return OrderStatus.ordered;
      default:
        return OrderStatus.requesting;
    }
  }

  static List<OrderHistoryEntry> _buildFallbackOrders() {
    final address = DeliveryAddress(
      id: 'fallback-address-1',
      nameAddress: 'Home',
      address: 'Street 271, Phnom Penh',
      phoneNumber: '012 345 678',
      label: AddressLabel.home,
      isDefault: true,
      latitude: 11.5564,
      longitude: 104.9282,
    );

    final canceledItems = [
      const CartItemViewModel(
        product: ProductModel(
          id: 'fallback-product-1',
          name: 'CAMBODIA PREMIUM BEER 4.4 VOL NCP 330ML',
          price: 0.0,
          imageUrl:
              'https://images.unsplash.com/photo-1571767454101-f3b5d6b8ec8f?auto=format&fit=crop&w=200&q=80',
        ),
        quantity: 1,
      ),
      const CartItemViewModel(
        product: ProductModel(
          id: 'fallback-product-2',
          name: 'JIA DUO BAO HERBAL TEA 310ML',
          price: 0.0,
          imageUrl:
              'https://images.unsplash.com/photo-1622483767028-c2c6c26a622d?auto=format&fit=crop&w=200&q=80',
        ),
        quantity: 1,
      ),
    ];

    final orderedItems = [
      const CartItemViewModel(
        product: ProductModel(
          id: 'fallback-product-3',
          name: 'WONDA COFFEE LATTE 240ML',
          price: 1.25,
          imageUrl:
              'https://images.unsplash.com/photo-1517701550927-30cf4ba1f3d1?auto=format&fit=crop&w=200&q=80',
        ),
        quantity: 1,
      ),
      const CartItemViewModel(
        product: ProductModel(
          id: 'fallback-product-4',
          name: 'KIRI APPLE JUICE 1L',
          price: 1.99,
          imageUrl:
              'https://images.unsplash.com/photo-1600271886742-f049cd5bba5b?auto=format&fit=crop&w=200&q=80',
        ),
        quantity: 1,
      ),
    ];

    return [
      OrderHistoryEntry(
        summary: OrderSummary(
          orderId: 'fallback-order-1',
          orderNumber: '00001',
          orderDate: DateTime(2026, 5, 12, 9, 34),
          shopName: 'Supermarket 271 Mega Mall',
          items: canceledItems,
          deliveryAddress: address,
          subtotal: 0.0,
          deliveryFee: 1.59,
          packageFees: 0.10,
          discount: 0.0,
          promoDiscount: 0.0,
          total: 1.69,
          paymentMethod: 'Cash on Delivery',
          statusCode: 'CANCELED',
        ),
        status: OrderStatus.canceled,
      ),
      OrderHistoryEntry(
        summary: OrderSummary(
          orderId: 'fallback-order-2',
          orderNumber: '00002',
          orderDate: DateTime(2026, 5, 11, 17, 22),
          shopName: 'Supermarket 271 Mega Mall',
          items: orderedItems,
          deliveryAddress: address,
          subtotal: 3.24,
          deliveryFee: 1.59,
          packageFees: 0.10,
          discount: 0.0,
          promoDiscount: 0.0,
          total: 4.93,
          paymentMethod: 'Cash on Delivery',
          statusCode: 'REQUESTING',
        ),
        status: OrderStatus.requesting,
      ),
    ];
  }
}
