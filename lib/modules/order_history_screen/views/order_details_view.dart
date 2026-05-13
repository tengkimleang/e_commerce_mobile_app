import 'package:e_commerce_mobile_app/modules/checkout/widgets/order_pricing_section.dart';
import 'package:e_commerce_mobile_app/modules/checkout/widgets/product_order_section.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/models/order_history_entry.dart';
import 'package:flutter/material.dart';

class OrderDetailsView extends StatelessWidget {
  const OrderDetailsView({super.key, required this.entry});

  final OrderHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final order = entry.summary;
    final isCanceled = entry.isCanceled;

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
                      entry.statusTitle,
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
