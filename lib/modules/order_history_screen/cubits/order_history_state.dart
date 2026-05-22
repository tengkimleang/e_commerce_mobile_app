import 'package:e_commerce_mobile_app/modules/order_history_screen/models/order_history_entry.dart';

class OrderHistoryState {
  const OrderHistoryState({this.orders = const [], this.isLoading = false});

  final List<OrderHistoryEntry> orders;
  final bool isLoading;

  OrderHistoryState copyWith({
    List<OrderHistoryEntry>? orders,
    bool? isLoading,
  }) {
    return OrderHistoryState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
