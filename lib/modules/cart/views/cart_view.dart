import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:e_commerce_mobile_app/modules/cart/controller/cart_controller.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC407A);
    final cart = CartController.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.4,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'My Cart',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
      ),
      body: AnimatedBuilder(
        animation: cart,
        builder: (context, _) {
          if (cart.items.isEmpty) {
            return const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            );
          }

          final items = cart.items;
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: item.product.imageUrl,
                          width: 78,
                          height: 78,
                          fit: BoxFit.cover,
                          placeholder: (c, s) =>
                              Container(color: Colors.grey[200]),
                          errorWidget: (c, s, e) =>
                              Container(color: Colors.grey[300]),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1D1B24),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$ ${item.product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: accent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F7F7),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      if (item.quantity > 1) {
                                        cart.decrease(item.product.id);
                                      } else {
                                        cart.remove(item.product.id);
                                      }
                                    },
                                    icon: Icon(
                                      item.quantity > 1
                                          ? Icons.remove
                                          : Icons.delete_outline,
                                    ),
                                    color: Colors.grey[500],
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: GestureDetector(
                                      onTap: () =>
                                          cart.increase(item.product.id),
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.add, size: 22),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, separatorIndex) => const SizedBox(height: 12),
            itemCount: items.length,
          );
        },
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: cart,
        builder: (context, _) {
          if (cart.items.isEmpty) return const SizedBox.shrink();

          return SafeArea(
            minimum: const EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                          '${cart.distinctItemCount} Items detail',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total: \$ ${cart.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 170,
                    height: 64,
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
                          fontSize: 18,
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
        },
      ),
    );
  }
}
