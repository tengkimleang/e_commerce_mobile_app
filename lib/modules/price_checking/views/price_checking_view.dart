import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/views/product_detail_view.dart';
import 'package:flutter/material.dart';

import 'package:e_commerce_mobile_app/core/models/product_item.dart';

import '../../customer_loyalty_screen/models/customer_loyalty_data.dart';


class PriceCheckingView extends StatelessWidget {
  final bool selectionMode;

  const PriceCheckingView({super.key, this.selectionMode = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Checking',style: TextStyle(color:Colors.white),),
        backgroundColor: const Color(0xFFEC407A),
        elevation: 0,
        
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
        child: GridView.builder(
          itemCount: PriceCheckingProducts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final product = PriceCheckingProducts[index];
            return _ProductCard(
              product: product,
              onTap: () {
                if (selectionMode) {
                  Navigator.of(context).pop({
                    'id': product.id,
                    'title': product.name,
                    'price': '\$ ${product.price.toStringAsFixed(2)}',
                    'image': product.imageUrl,
                  });
                  return;
                }

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductDetailView(product: product),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductItem product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                product.imageUrl,
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$ ${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFFE91E63),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        Icons.favorite_border,
                        color: Colors.pink,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
