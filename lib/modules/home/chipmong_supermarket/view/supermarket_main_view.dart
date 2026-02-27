
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_mobile_app/modules/home/chipmong_supermarket/controller/supermarket_category_bloc.dart';
import 'package:e_commerce_mobile_app/modules/home/chipmong_supermarket/controller/supermarket_category_event.dart';
import 'package:e_commerce_mobile_app/modules/home/chipmong_supermarket/model/category_model.dart';
import 'package:e_commerce_mobile_app/modules/home/chipmong_supermarket/model/product_model.dart';
import 'loyalty_view.dart';
import 'become_partner_view.dart';
import 'price_checking_view.dart';
import 'widgets/product_card.dart';

class SupermarketMainView extends StatefulWidget {
  const SupermarketMainView({super.key});

  @override
  State<SupermarketMainView> createState() => _SupermarketMainViewState();
}

class _SupermarketMainViewState extends State<SupermarketMainView> {
  final PageController _controller = PageController();
  int _current = 0;
  late final Timer _timer;
  late final PageController _partnerController;
  int _partnerCurrent = 0;

  final List<String> _images = [
    'https://www.chipmong.com/wp-content/uploads/2020/04/2.Chip-mong-Supermarket-.jpg',
    'https://www.apacoutlookmag.com/media/chip-mong-retail-1-1597331139.profileImage.2x-1536x884.webp',
    'https://www.chipmong.com/wp-content/uploads/portfolio/retail/598-Mall/2.jpg'
  ];

  final List<String> _partnerImages = [
    'https://cdn.kiripost.com/static/images/_WC19073.2e16d0ba.fill-960x540.jpg',
    'https://www.chipmong.com/wp-content/uploads/2020/12/DSC_7842-1-585x391.jpg',
    'https://www.chipmong.com/wp-content/uploads/2022/02/1-585x391.jpg',
  ];

  @override
  void initState() {
    _partnerController = PageController(viewportFraction: 0.95);
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      final next = (_current + 1) % _images.length;
      _controller.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    _partnerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SupermarketCategoryBloc()..add(LoadCategories()),
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Chip Mong Supermarket'),
        backgroundColor: const Color(0xFFEC407A),
      ),
      body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 300,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _controller,
                      itemCount: _images.length,
                      onPageChanged: (i) => setState(() => _current = i),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                          child: Image.network(
                            _images[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        );
                      },
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_images.length, (i) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _current == i ? 12 : 8,
                            height: _current == i ? 12 : 8,
                            decoration: BoxDecoration(
                              color: _current == i ? Colors.white : Colors.white54,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Products Categories Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Top Deals', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () {},
                      child: const Text('View all', style: TextStyle(color: Color(0xFFEC407A), fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _getDairyProducts().length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: SizedBox(
                        width: 160,
                        child: ProductCard(
                          product: _getDairyProducts()[index],
                          onFavoriteTap: () {},
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Fresh Products Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fresh Fruits', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () {},
                      child: const Text('View all', style: TextStyle(color: Color(0xFFEC407A), fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _getFreshProducts().length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: SizedBox(
                        width: 160,
                        child: ProductCard(
                          product: _getFreshProducts()[index],
                          onFavoriteTap: () {},
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer Loyalty', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('01-28 Feb 2026 — Special promotions and bundles.'),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildOverlayCard(
                        context,
                        title: 'Exchange Points',
                        imageUrl: 'https://www.shutterstock.com/image-vector/cashback-reward-program-advertising-idea-600nw-2553858371.jpg',
                          onTap: () => _showPartnerQr(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildOverlayCard(
                        context,
                        title: 'Price Checking',
                        imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTZ5i8QBjeV3H4nA5m5T3ILCaeeQYcWN0pg9Q&s',
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PriceCheckingView())),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Partner Privileges', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: PageView.builder(
                  controller: _partnerController,
                  itemCount: _partnerImages.length,
                  onPageChanged: (i) => setState(() => _partnerCurrent = i),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: CachedNetworkImage(
                          imageUrl: _partnerImages[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (c, s) => Container(color: Colors.grey[200]),
                          errorWidget: (c, s, e) => Container(color: Colors.grey[300]),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_partnerImages.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _partnerCurrent == i ? 12 : 8,
                      height: _partnerCurrent == i ? 12 : 8,
                      decoration: BoxDecoration(
                        color: _partnerCurrent == i ? Colors.black87 : Colors.black26,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BecomePartnerView())),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0,4))],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                              gradient: const LinearGradient(colors: [Color(0xFFEC407A), Color(0xFFEA2E6D)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            ),
                            child: Column(
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Wholesale Price', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                const SizedBox(height: 6),
                                Text('High quality products\nwith special price', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
                              ],
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
                          child: Image.asset(
                            'assets/images/woman.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            // errorBuilder: (c, e, s) => Container(color: Colors.grey[200], width: 120, height: 120),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, CategoryModel c) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: InkWell(
          onTap: () {
            if (c.id == 'loyalty') {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoyaltyView()));
            } else if (c.id == 'partner') {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BecomePartnerView()));
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,2))],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: c.imageUrl,
                    width: 140,
                    height: 120,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayCard(BuildContext context, {required String title, required String imageUrl, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0,2))],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (c, s) => Container(color: Colors.grey[200]),
                errorWidget: (c, s, e) => Container(color: Colors.grey[300]),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showPartnerQr(BuildContext context) {
    // Placeholder user data — replace with real user data from your auth/profile service
    const username = 'Jame Taki';
    const phone = '099 123 4567';
    const points = '0';

    final qrData = Uri.encodeComponent('user:$username;phone:$phone;points:$points');
    final qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=400x400&data=$qrData';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: SingleChildScrollView(
              controller: controller,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(height: 18),
                    Image.network(qrUrl, width: 200, height: 200, fit: BoxFit.contain),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Username:', style: TextStyle(color: Colors.grey)),
                              Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Phone number:', style: TextStyle(color: Colors.grey)),
                              Text(phone, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Supermarket Point:', style: TextStyle(color: Colors.grey)),
                              Text(points, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<ProductModel> _getDairyProducts() {
    return [
      ProductModel(
        id: '1',
        name: 'PHKA CHHOUK STERILISE MILK',
        price: 0.60,
        imageUrl: 'https://images.unsplash.com/photo-1587351021759-0ac274a73f0f?w=500&h=500&fit=crop',
        isFavorite: false,
      ),
      ProductModel(
        id: '2',
        name: 'ទឹកដោះគោ PHKA CHHOUK',
        price: 1.10,
        imageUrl: 'https://images.unsplash.com/photo-1576568787621-au006d085368?w=500&h=500&fit=crop',
        isFavorite: false,
      ),
      ProductModel(
        id: '3',
        name: 'Condensed Milk',
        price: 0.85,
        imageUrl: 'https://images.unsplash.com/photo-1550584521-daf3d40ea2ad?w=500&h=500&fit=crop',
        isFavorite: false,
      ),
      ProductModel(
        id: '4',
        name: 'Yogurt Plain',
        price: 1.25,
        imageUrl: 'https://images.unsplash.com/photo-1488477181946-6ca0a360b517?w=500&h=500&fit=crop',
        isFavorite: false,
      ),
    ];
  }

  List<ProductModel> _getFreshProducts() {
    return [
      ProductModel(
        id: '5',
        name: 'PAPA MANDARIN PRC 1XKG',
        price: 2.45,
        originalPrice: 4.98,
        discountPercent: 51,
        imageUrl: 'https://images.unsplash.com/photo-1587735512104-58d8b9a0e001?w=500&h=500&fit=crop',
        isFavorite: false,
      ),
      ProductModel(
        id: '6',
        name: 'FUJI APPLE PRC',
        price: 2.99,
        originalPrice: 3.99,
        discountPercent: 25,
        imageUrl: 'https://images.unsplash.com/photo-1560806674-104da1e4f07a?w=500&h=500&fit=crop',
        isFavorite: false,
      ),
      ProductModel(
        id: '7',
        name: 'Fresh Orange',
        price: 1.99,
        imageUrl: 'https://images.unsplash.com/photo-1557872200-817461347587?w=500&h=500&fit=crop',
        isFavorite: false,
      ),
      ProductModel(
        id: '8',
        name: 'Banana Bunch',
        price: 0.99,
        originalPrice: 1.49,
        discountPercent: 33,
        imageUrl: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=500&h=500&fit=crop',
        isFavorite: false,
      ),
    ];
  }
}
