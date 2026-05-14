import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/common/di.dart';
import 'package:e_commerce_mobile_app/modules/checkout/models/order_summary.dart';
import 'package:e_commerce_mobile_app/modules/checkout/widgets/order_pricing_section.dart';
import 'package:e_commerce_mobile_app/modules/checkout/widgets/product_order_section.dart';
import 'package:e_commerce_mobile_app/modules/checkout/repositories/orders_repository.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/models/order_history_entry.dart';
import 'package:flutter/material.dart';

class OrderDetailsView extends StatefulWidget {
  const OrderDetailsView({
    super.key,
    required this.entry,
    this.ordersRepository,
  });

  final OrderHistoryEntry entry;
  final OrdersRepository? ordersRepository;

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  late OrderSummary _order;
  late final OrdersRepository? _ordersRepository;
  bool _isSubmittingCancel = false;

  @override
  void initState() {
    super.initState();
    _order = widget.entry.summary;
    _ordersRepository = widget.ordersRepository ?? _resolveOrdersRepository();
    _refreshOrderDetail();
  }

  OrdersRepository? _resolveOrdersRepository() {
    try {
      return OrdersRepository(di<Dio>());
    } catch (_) {
      return null;
    }
  }

  Future<void> _refreshOrderDetail() async {
    final repository = _ordersRepository;
    final orderId = _order.orderId.trim();
    if (repository == null || orderId.isEmpty) return;

    try {
      final latest = await repository.fetchOrderDetail(orderId: orderId);
      if (!mounted) return;
      setState(() => _order = latest);
    } catch (_) {
      // Keep the list summary visible if the detail endpoint is unavailable.
    }
  }

  String get _statusTitle {
    final code = _resolvedStatusCode;
    switch (code) {
      case 'CANCELED':
      case 'CANCELLED':
        return 'Cancel';
      case 'DELIVERED':
        return 'Delivered';
      case 'DELIVERING':
        return 'Delivering';
      case 'PICKING':
        return 'Picking';
      case 'REQUESTING':
        return 'Request';
      default:
        return widget.entry.statusTitle;
    }
  }

  String get _resolvedStatusCode {
    return (_order.trackStep.trim().isNotEmpty
            ? _order.trackStep
            : _order.statusCode)
        .trim()
        .toUpperCase();
  }

  bool get _isCanceled {
    final code = _resolvedStatusCode;
    return code == 'CANCELED' ||
        code == 'CANCELLED' ||
        (code.isEmpty && widget.entry.isCanceled);
  }

  bool get _canCancelByCustomer {
    final code = _resolvedStatusCode;
    return code == 'REQUESTING';
  }

  String get _orderCancelReasonText {
    final code = _order.cancelReasonCode.trim().toUpperCase();
    final note = _order.cancelReasonNote.trim();

    final label = switch (code) {
      'OUT_OF_STOCK' => 'Out of stock',
      'CUSTOMER_REQUEST' => 'Customer canceled',
      'PAYMENT_ISSUE' => 'Payment issue',
      'DELIVERY_UNAVAILABLE' => 'Delivery unavailable',
      'STORE_CLOSED' => 'Store closed',
      'OTHER' => 'Other',
      _ => '',
    };

    if (note.isNotEmpty && label.isNotEmpty) return '$label: $note';
    if (note.isNotEmpty) return note;
    if (label.isNotEmpty) return label;
    return 'Canceled';
  }

  Future<void> _cancelOrderByCustomer() async {
    final repository = _ordersRepository;
    final orderId = _order.orderId.trim();
    if (repository == null || orderId.isEmpty || _isSubmittingCancel) return;

    setState(() => _isSubmittingCancel = true);
    try {
      final updated = await repository.cancelOrder(orderId: orderId);
      if (!mounted) return;
      setState(() => _order = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order canceled successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmittingCancel = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    final isCanceled = _isCanceled;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      _statusTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (isCanceled)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _orderCancelReasonText,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFE57373),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          if (_canCancelByCustomer)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isSubmittingCancel
                                      ? null
                                      : _cancelOrderByCustomer,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF6200),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: _isSubmittingCancel
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Cancel Order'),
                                ),
                              ),
                            ),
                          ProductOrderSection(
                            items: order.items,
                            showPickedCount: false,
                            showOutOfStock: isCanceled,
                            canceledFallbackLabel: 'Canceled',
                            showUnitPrice: true,
                          ),
                          const Divider(height: 1, thickness: 0.7),
                          OrderPricingSection(
                            paymentMethod: order.paymentMethod,
                            deliveryFee: order.deliveryFee,
                            subtotal: order.subtotal,
                            packageFees: order.packageFees,
                            discount: order.discount,
                            promoDiscount: order.promoDiscount,
                            total: order.total,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
