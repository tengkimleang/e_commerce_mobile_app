import 'package:flutter/material.dart';

class PriceCheckingView extends StatelessWidget {
  const PriceCheckingView({super.key});

  static const _sampleProducts = [
    {
      'title': 'NR-OSTRA FZ-BABY WHOLE OCTOPUS',
      'price': '\$ 8.50',
      'image': 'https://allansvending.com/wp-content/uploads/2024/05/coke-products.png'
    },
    {
      'title': 'NR-OSTRA FZ-SQUID FLOWER 500G',
      'price': '\$ 5.50',
      'image': 'https://media.allure.com/photos/66b399da6d09ec3641ed7e7a/16:9/w_2560%2Cc_limit/Best%2520Japanese%2520Skin%2520Care%2520082024%2520Lede.jpg'
    },
    {
      'title': 'NR-OSTRA FZ-TUNA SAKU 300-350G',
      'price': '\$ 8.00',
      'image': 'https://foodindustryexecutive.com/wp-content/uploads/2023/03/daring-new-products.png'
    },
    {
      'title': 'NR-OSTRA FZ-SALMON FIN 500G',
      'price': '\$ 3.75',
      'image': 'https://www.ift.org/-/media/food-technology/feature-images/2022/04/0422_f1_mt_top10functional/0422_mt_top10functional_2hostessboost_s.jpg?la=en&h=467&mw=1290&w=700&hash=34B16E2A5ADFEE8817345848B437FBF9'
    },
    {
      'title': 'NR-OSTRA FZ-USA SCALLOPS 500G',
      'price': '\$ 23.00',
      'image': 'https://www.flavorchem.com/wp-content/uploads/2023/01/1-immunity.jpg'
    },
    {
      'title': 'NR-OSTRA FZ-JUMBO LUMP CRAB',
      'price': '\$ 24.50',
      'image': 'https://eatanytime.in/cdn/shop/files/Artboard2_9508d23c-e023-4424-b2fe-e39176856f33.png?v=1761777624&width=533'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Checking'),
        backgroundColor: const Color(0xFFEC407A),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
        child: GridView.builder(
          itemCount: _sampleProducts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final p = _sampleProducts[index];
            return _ProductCard(title: p['title']!, price: p['price']!, imageUrl: p['image']!);
          },
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String imageUrl;

  const _ProductCard({required this.title, required this.price, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(imageUrl, height: 110, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(price, style: const TextStyle(color: Color(0xFFE91E63), fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite_border, color: Colors.pink),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

