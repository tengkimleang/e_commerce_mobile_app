import 'package:flutter/material.dart';

class ProductDetailView extends StatelessWidget {
  final String id;
  final String title;
  final String price;
  final String imageUrl;

  const ProductDetailView({
    super.key,
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
  });

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
              imageUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: const TextStyle(fontSize: 16, color: Color(0xFFE91E63)),
            ),
            const SizedBox(height: 8),
            Text('ID: $id'),
          ],
        ),
      ),
    );
  }
}
