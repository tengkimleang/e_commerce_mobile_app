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
      case 'PICKING':
      case 'DELIVERING':
      case 'DELIVERED':
        return 'Ordered';
      case 'REQUESTING':
        return 'Requesting';
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
                    const SizedBox(height: 10),
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          ProductOrderSection(
                            items: order.items,
                            showPickedCount: isCanceled,
                            showOutOfStock: isCanceled,
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
