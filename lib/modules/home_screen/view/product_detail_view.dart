import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top image area
            SizedBox(
              height: 320,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (c, u) => Container(color: Colors.grey[200]),
                        errorWidget: (c, u, e) => Container(color: Colors.grey[300]),
                      ),
                    ),
                  ),
                  // back button
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black87),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  // image counter / indicator
                  Positioned(
                    left: 16,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(20)),
                      child: const Text('1/3', style: TextStyle(color: Colors.black87)),
                    ),
                  ),
                ],
              ),
            ),

            // Details card
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        price,
                        style: const TextStyle(color: Color(0xFFEC407A), fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      const Text('ប្រភពបង្ហាញពិនិត្យតម្លៃ', style: TextStyle(fontSize: 14, color: Colors.black87)),
                      const SizedBox(height: 12),
                      // disabled search-like field placeholder
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: const Text('ដាក់លេខផ្ទេរឬបញ្ចូលអត្ថបទ', style: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(height: 40),

                      // Center empty state icon + label (matches screenshot)
                      Column(
                        children: [
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBF1),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Center(
                              child: Icon(Icons.receipt_long, color: Color(0xFFEC407A), size: 44),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'រកមិនឃើញលទ្ធផល',
                            style: TextStyle(color: Color(0xFFEC407A), fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
