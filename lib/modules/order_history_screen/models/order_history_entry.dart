import 'package:e_commerce_mobile_app/modules/checkout/models/order_summary.dart';

enum OrderStatus { requesting, picking, delivering, delivered, canceled }

class OrderHistoryEntry {
  const OrderHistoryEntry({required this.summary, required this.status});

  final OrderSummary summary;
  final OrderStatus status;

  bool get isRequesting =>
      status == OrderStatus.requesting ||
      status == OrderStatus.picking ||
      status == OrderStatus.delivering;
  bool get isCanceled => status == OrderStatus.canceled;
  int get displayItemCount =>
      summary.itemCount ??
      summary.items.fold<int>(0, (sum, item) => sum + item.quantity);

  String get statusTitle {
    switch (status) {
      case OrderStatus.requesting:
        return 'Request';
      case OrderStatus.picking:
        return 'Picking';
      case OrderStatus.delivering:
        return 'Delivering';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.canceled:
        return 'Cancel';
    }
  }
}
