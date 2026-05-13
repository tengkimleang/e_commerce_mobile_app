import 'package:e_commerce_mobile_app/modules/checkout/models/order_summary.dart';

enum OrderStatus { requesting, ordered, canceled }

class OrderHistoryEntry {
  const OrderHistoryEntry({required this.summary, required this.status});

  final OrderSummary summary;
  final OrderStatus status;

  bool get isRequesting => status == OrderStatus.requesting;
  bool get isCanceled => status == OrderStatus.canceled;
  int get displayItemCount =>
      summary.itemCount ??
      summary.items.fold<int>(0, (sum, item) => sum + item.quantity);

  String get statusTitle {
    switch (status) {
      case OrderStatus.requesting:
        return 'Requesting';
      case OrderStatus.ordered:
        return 'Ordered';
      case OrderStatus.canceled:
        return 'Cancel';
    }
  }
}
