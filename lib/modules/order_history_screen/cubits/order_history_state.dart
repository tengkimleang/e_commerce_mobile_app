import 'package:e_commerce_mobile_app/modules/order_history_screen/models/order_history_entry.dart';

class OrderHistoryState {
  const OrderHistoryState({this.orders = const []});

  final List<OrderHistoryEntry> orders;

  OrderHistoryState copyWith({List<OrderHistoryEntry>? orders}) {
    return OrderHistoryState(orders: orders ?? this.orders);
  }
}
