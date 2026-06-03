import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_state.dart';
import 'package:flutter/material.dart';

/// Collapsible "Product Order" section shared between CheckoutScreen and
/// OrderTrackScreen. When [showPickedCount] is true the quantity label renders
/// as "x 0/N" (order-track style); otherwise it renders "x N" (checkout style).
class ProductOrderSection extends StatefulWidget {
  const ProductOrderSection({
    super.key,
    required this.items,
    this.showPickedCount = false,
    this.showOutOfStock = false,
    this.canceledFallbackLabel = 'Canceled',
    this.initiallyExpanded = true,
    this.showUnitPrice = false,
  });

  final List<CartItemViewModel> items;
  final bool showPickedCount;
  final bool showOutOfStock;
  final String canceledFallbackLabel;
  final bool initiallyExpanded;
  final bool showUnitPrice;

  @override
  State<ProductOrderSection> createState() => _ProductOrderSectionState();
}

class _ProductOrderSectionState extends State<ProductOrderSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text(
                  'Product Order',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.items.length,
            separatorBuilder: (_, _) => const Divider(
              height: 1,
              thickness: 0.5,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return _ProductOrderRow(
                item: item,
                showPickedCount: widget.showPickedCount,
                showOutOfStock: widget.showOutOfStock,
                canceledFallbackLabel: widget.canceledFallbackLabel,
                showUnitPrice: widget.showUnitPrice,
              );
            },
          ),
      ],
    );
  }
}

class _ProductOrderRow extends StatelessWidget {
  const _ProductOrderRow({
    required this.item,
    required this.showPickedCount,
    required this.showOutOfStock,
    required this.canceledFallbackLabel,
    required this.showUnitPrice,
  });

  final CartItemViewModel item;
  final bool showPickedCount;
  final bool showOutOfStock;
  final String canceledFallbackLabel;
  final bool showUnitPrice;

  String _resolveCanceledReasonText() {
    final code = item.cancelReasonCode.trim().toUpperCase();
    final note = item.cancelReasonNote.trim();

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
    return canceledFallbackLabel;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final qtyLabel = showPickedCount
        ? 'x 0/${item.quantity}'
        : 'x ${item.quantity}';
    final canceledReasonText = showOutOfStock
        ? _resolveCanceledReasonText()
        : '';
    final displayedPrice = showUnitPrice
        ? item.product.price
        : (item.product.price * item.quantity);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: item.product.imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: Colors.grey[200]),
              errorWidget: (_, _, _) => Container(color: Colors.grey[300]),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      qtyLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    if (showOutOfStock) ...[
                      const SizedBox(width: 10),
                      Text(
                        canceledReasonText,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFE57373),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '\$ ${displayedPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }
}
