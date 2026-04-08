import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_mobile_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_bloc.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_event.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_state.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  bool _orderExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
        title: const Text(
          'Your Cart',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            );
          }

          final items = state.items;
          return Column(
            children: [
              // Delivery Info row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    const Text(
                      'Delivery Info',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Select address',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 0.5),

              // Product Order header (collapsible)
              InkWell(
                onTap: () =>
                    setState(() => _orderExpanded = !_orderExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
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
                        _orderExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),

              // Product list
              if (_orderExpanded)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _CartItemRow(item: item);
                    },
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) return const SizedBox.shrink();
          return _CheckoutBar(
            itemCount: state.distinctItemCount,
            total: state.totalAmount,
          );
        },
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final CartItemViewModel item;
  const _CartItemRow({required this.item});

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<CartBloc>(),
        child: _CartItemSheet(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: item.product.imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              placeholder: (c, s) => Container(color: Colors.grey[200]),
              errorWidget: (c, s, e) =>
                  Container(color: Colors.grey[300]),
            ),
          ),
          const SizedBox(width: 12),

          // Name + qty
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
                  'x ${item.quantity}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Price
          Text(
            '\$ ${(item.product.price * item.quantity).toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    ));
  }
}

class _CartItemSheet extends StatefulWidget {
  final CartItemViewModel item;
  const _CartItemSheet({required this.item});

  @override
  State<_CartItemSheet> createState() => _CartItemSheetState();
}

class _CartItemSheetState extends State<_CartItemSheet> {
  late int _quantity;
  bool _removeIfUnavailable = true;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _quantity = widget.item.quantity;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() => _quantity++);
    context.read<CartBloc>().add(IncreaseQuantity(widget.item.product.id));
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() => _quantity--);
      context.read<CartBloc>().add(DecreaseQuantity(widget.item.product.id));
    } else {
      context.read<CartBloc>().add(RemoveFromCart(widget.item.product.id));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.primary;
    final product = widget.item.product;
    // Use the single imageUrl; could extend to a list for real multi-image
    final images = [product.imageUrl];

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),

              // Image carousel
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image with page indicator
                        Stack(
                          children: [
                            SizedBox(
                              height: 300,
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: images.length,
                                onPageChanged: (i) =>
                                    setState(() => _currentPage = i),
                                itemBuilder: (_, i) => ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: images[i],
                                    fit: BoxFit.contain,
                                    placeholder: (c, s) =>
                                        Container(color: Colors.grey[100]),
                                    errorWidget: (c, s, e) =>
                                        Container(color: Colors.grey[200]),
                                  ),
                                ),
                              ),
                            ),
                            // Page indicator
                            Positioned(
                              bottom: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_currentPage + 1}/${images.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Product name
                        Text(
                          product.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Price
                        Text(
                          '\$ ${(product.price * _quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Quantity controls
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _decrement,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Icon(Icons.remove, size: 26),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '$_quantity',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _increment,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Icon(Icons.add, size: 26),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Unavailability section
                        const Text(
                          'If this product is not available',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.07),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CheckboxListTile(
                            value: _removeIfUnavailable,
                            onChanged: (v) => setState(
                                () => _removeIfUnavailable = v ?? true),
                            title: const Text(
                              'Remove it from my order',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            activeColor: accent,
                            checkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final int itemCount;
  final double total;
  const _CheckoutBar({required this.itemCount, required this.total});

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.primary;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: const BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$itemCount Items detail',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total: \$ ${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 150,
              height: 44,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Check Out',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
