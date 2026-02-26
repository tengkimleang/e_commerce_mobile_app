import 'package:flutter/material.dart';
import 'wholesale_form_view.dart';

class BecomePartnerView extends StatelessWidget {
  const BecomePartnerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wholesale Request'), backgroundColor: const Color(0xFFEC407A)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large top banner image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
              child: Image.network(
                'https://images.unsplash.com/photo-1441986300352-c8b586dc6ccf?w=600&h=400&fit=crop',
                width: double.infinity,
                height: 280,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: double.infinity,
                  height: 280,
                  color: Colors.grey[300],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Drop your Inquiry button (centered in middle section)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEC407A),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WholesaleFormView()));
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Drop your Inquiry', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ),

            const SizedBox(height: 80),

            // Order History section at bottom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order History', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 60),

                  // No results placeholder
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(color: const Color(0xFFFEE9EE), borderRadius: BorderRadius.circular(18)),
                          child: const Icon(Icons.receipt_long, color: Color(0xFFEC407A), size: 44),
                        ),
                        const SizedBox(height: 12),
                        Text('No result found', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFFEC407A), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
