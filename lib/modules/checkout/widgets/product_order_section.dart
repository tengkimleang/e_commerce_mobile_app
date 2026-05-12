import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_mobile_app/core/theme/app_theme.dart';
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
    this.initiallyExpanded = true,
  });

  final List<CartItemViewModel> items;
  final bool showPickedCount;
  final bool initiallyExpanded;

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
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            separatorBuilder: (_, __) =>
                const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return _ProductOrderRow(
                item: item,
                showPickedCount: widget.showPickedCount,
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
  });

  final CartItemViewModel item;
  final bool showPickedCount;

  @override
  Widget build(BuildContext context) {
    final qtyLabel = showPickedCount
        ? 'x 0/${item.quantity}'
        : 'x ${item.quantity}';

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
              placeholder: (_, __) => Container(color: Colors.grey[200]),
              errorWidget: (_, __, ___) => Container(color: Colors.grey[300]),
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
                Text(
                  qtyLabel,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '\$ ${(item.product.price * item.quantity).toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
