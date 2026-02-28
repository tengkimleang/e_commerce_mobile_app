import 'package:flutter/material.dart';

import 'package:e_commerce_mobile_app/core/models/product_item.dart';

class ProductDetailView extends StatelessWidget {
  final ProductItem product;

  const ProductDetailView({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              product.imageUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 12),
            Text(
              product.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '\$ ${product.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, color: Color(0xFFE91E63)),
            ),
            const SizedBox(height: 8),
            Text('ID: ${product.id}'),
          ],
        ),
      ),
    );
  }
}
