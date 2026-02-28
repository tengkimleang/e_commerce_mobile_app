import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:e_commerce_mobile_app/modules/home_screen/model/product_model.dart';
import 'become_partner_view.dart';
import 'price_checking_view.dart';
import 'widgets/product_card.dart';
import 'widgets/product_carousel_section.dart';

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
  int _selectedIndex = 0;

  final List<String> _images = [
    'https://www.chipmong.com/wp-content/uploads/2020/04/2.Chip-mong-Supermarket-.jpg',
    'https://www.apacoutlookmag.com/media/chip-mong-retail-1-1597331139.profileImage.2x-1536x884.webp',
    'https://www.chipmong.com/wp-content/uploads/portfolio/retail/598-Mall/2.jpg',
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
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            // borderRadius:BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
            color: Color(0xFFEC407A),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Profile Icon and Cart
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {},
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        'Welcome',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Stack(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.shopping_cart,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {},
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                '1',
                                style: TextStyle(
                                  color: Color(0xFFEC407A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Location Text
                Row(
                  children: [
                    // const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'CHIP MONG SUPERMARKET 271 MEGA MALL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(
                                  Icons.expand_more,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(maxWidth: 24),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              color: Color(0xFFEC407A),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products, brands and more',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFFEC407A),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 16, right: 16),
              child: SizedBox(
                height: 300,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _controller,
                      itemCount: _images.length,
                      onPageChanged: (i) => setState(() => _current = i),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(16),
                          ),
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
                              color: _current == i
                                  ? Colors.white
                                  : Colors.white54,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            ..._buildReusableProductRows(),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer Loyalty',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                      imageUrl:
                          'https://www.shutterstock.com/image-vector/cashback-reward-program-advertising-idea-600nw-2553858371.jpg',
                      onTap: () => _showPartnerQr(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOverlayCard(
                      context,
                      title: 'Price Checking',
                      imageUrl:
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTZ5i8QBjeV3H4nA5m5T3ILCaeeQYcWN0pg9Q&s',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PriceCheckingView(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Partner Privileges',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
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
                        placeholder: (c, s) =>
                            Container(color: Colors.grey[200]),
                        errorWidget: (c, s, e) =>
                            Container(color: Colors.grey[300]),
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
                      color: _partnerCurrent == i
                          ? Colors.black87
                          : Colors.black26,
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
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BecomePartnerView()),
                ),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(14),
                            ),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEC407A), Color(0xFFEA2E6D)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Wholesale Price',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'High quality products\nwith special price',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(14),
                        ),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(index: 0, icon: Icons.home, label: 'Home'),
              _buildBottomNavItem(
                index: 1,
                icon: Icons.local_offer,
                label: 'Promo',
              ),
              _buildBottomNavItem(index: 2, icon: Icons.qr_code, label: 'QR'),
              _buildBottomNavItem(
                index: 3,
                icon: Icons.list_alt,
                label: 'Orders',
              ),
              _buildBottomNavItem(
                index: 4,
                icon: Icons.person,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required IconData icon,
    String? label,
  }) {
    final selected = _selectedIndex == index;
    const accent = Color(0xFFEC407A);

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: selected
                ? const EdgeInsets.all(10)
                : const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: selected ? accent : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 22,
              color: selected ? Colors.white : accent,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildReusableProductRows() {
    final productsList = [
      _getMilkProducts(),
      _getOrangeProducts(),
      _getBakeryProducts(),
      _getSnackProducts(),
      _getSoftDrinkProducts(),
      _getNoodleProducts(),
      _getFrozenProducts(),
      _getHouseholdProducts(),
      _getPersonalCareProducts(),
      _getBabyProducts(),
    ];
    final sectionTitles = [
      'Fresh Milk',
      'Fresh Orange',
      'Bakery & Pastry',
      'Snacks & Chips',
      'Soft Drinks',
      'Instant Noodles',
      'Frozen Foods',
      'Household Essentials',
      'Personal Care',
      'Baby & Kids',
    ];
    final sectionCategoryImages = [
      'https://cdn.vectorstock.com/i/500p/66/59/cute-cartoon-cow-vector-1146659.jpg',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcThxysu6Ll2xNQDH-3bhYnyYu75uzsCzF2QWQ&s',
      'https://thumbs.dreamstime.com/b/adorable-bakery-scene-featuring-whimsical-storefront-adorned-adorable-bakery-scene-featuring-whimsical-storefront-adorned-370748772.jpg',
      'https://img.freepik.com/free-vector/hand-drawn-food-elements-collection_23-2148903178.jpg',
      'https://img.freepik.com/free-vector/kawaii-fast-food-cute-drinks-illustration_24908-60622.jpg?semt=ais_rp_progressive&w=740&q=80',
      'https://cdn.apartmenttherapy.info/image/upload/f_jpg,q_auto:eco,c_fill,g_auto,w_1500,ar_1:1/tk%2Fphoto%2F2025%2F09-2025%2F2025-09-korean-noodles%2Fkorean-noodles-020',
      'https://platform.eater.com/wp-content/uploads/sites/2/chorus/uploads/chorus_asset/file/25524135/Comparisons.png?quality=90&strip=all&crop=0,3.4613147178592,100,93.077370564282',
      'https://cdn.shopify.com/s/files/1/0064/8439/4039/files/Household-Essentials.jpg?v=1566467543',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQpPkz9FU5o9eUhqXeZuExREfblaKrs2--TGQ&s',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRsMliwTws9_e78uKQca3wnv8dZFSX4CUk5MQ&s',
    ];

    return List<Widget>.generate(10, (index) {
      return Padding(
        padding: EdgeInsets.only(bottom: index == 9 ? 0 : 20),
        child: ProductCarouselSection(
          title: sectionTitles[index],
          products: productsList[index],
          categoryImageUrl: sectionCategoryImages[index],
          height:
              index == 0 || index == 2 || index == 4 || index == 6 || index == 8
              ? 160
              : 180,
          onViewAllTap: () {},
          onCategoryTap: () {},
          onFavoriteTap: (_) {},
          productCardBuilder: (context, product) =>
              _buildCustomProductCard(product: product, rowIndex: index),
        ),
      );
    });
  }

  Widget _buildCustomProductCard({
    required ProductModel product,
    required int rowIndex,
  }) {
    switch (rowIndex) {
      case 0:
        return _getMilkProducts()
            .where((p) => p.id == product.id)
            .map((p) => ProductCard(product: p))
            .first;
      case 1:
        return _getOrangeProducts()
            .where((p) => p.id == product.id)
            .map((p) => ProductCard(product: p))
            .first;
      case 2:
        return _getBakeryProducts()
            .where((p) => p.id == product.id)
            .map((p) => ProductCard(product: p))
            .first;
      case 3:
        return _getSnackProducts()
            .where((p) => p.id == product.id)
            .map((p) => ProductCard(product: p))
            .first;
      case 4:
        return _getSoftDrinkProducts()
            .where((p) => p.id == product.id)
            .map((p) => ProductCard(product: p))
            .first;
      case 5:
        return _getNoodleProducts()
            .where((p) => p.id == product.id)
            .map((p) => ProductCard(product: p))
            .first;
      case 6:
        return _getFrozenProducts()
            .where((p) => p.id == product.id)
            .map((p) => ProductCard(product: p))
            .first;
      case 7:
        return _getHouseholdProducts()
            .where((p) => p.id == product.id)
            .map((p) => ProductCard(product: p))
            .first;
      case 8:
        return _getPersonalCareProducts()
            .where((p) => p.id == product.id)
            .map((p) => ProductCard(product: p))
            .first;
      case 9:
        return _getBabyProducts()
            .where((p) => p.id == product.id)
            .map((p) => ProductCard(product: p))
            .first;
      default:
        return ProductCard(product: product);
    }
  }

  Widget _buildOverlayCard(
    BuildContext context, {
    required String title,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
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
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
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

    final qrData = Uri.encodeComponent(
      'user:$username;phone:$phone;points:$points',
    );
    final qrUrl =
        'https://api.qrserver.com/v1/create-qr-code/?size=400x400&data=$qrData';

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Image.network(
                      qrUrl,
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
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
                              const Text(
                                'Username:',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Phone number:',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                phone,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Supermarket Point:',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                points,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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

  List<ProductModel> _getMilkProducts() {
    return [
      ProductModel(
        id: '1',
        name: 'PHKA CHHOUK STERILISE MILK',
        price: 0.60,
        imageUrl: 'https://cccbic.org/businesses-covers/541-cover.jpg',
        isFavorite: false,
      ),
      ProductModel(
        id: '2',
        name: 'Milk PHKA CHHOUK',
        price: 1.10,
        imageUrl:
            'https://media.makrocambodiaclick.com/PRODUCT_1768386378570.jpeg',
        isFavorite: false,
      ),
      ProductModel(
        id: '3',
        name: 'Condensed Milk',
        price: 0.85,
        imageUrl:
            'https://megastorecambodia.com/files/products/442_cow-head-pure-milk-1l.gif',
        isFavorite: false,
      ),
      ProductModel(
        id: '4',
        name: 'Yogurt Plain',
        price: 1.25,
        imageUrl:
            'https://foodpanda.dhmedia.io/image/darkstores/nv-global-catalog/kh/de56639d-e599-46d1-97cb-3cf102b2e7f3.jpg?height=176',
        isFavorite: false,
      ),
    ];
  }

  List<ProductModel> _getOrangeProducts() {
    return [
      ProductModel(
        id: '5',
        name: 'PAPA MANDARIN PRC 1XKG',
        price: 2.45,
        originalPrice: 4.98,
        discountPercent: 51,
        imageUrl:
            'https://cdn.britannica.com/24/174524-050-A851D3F2/Oranges.jpg',
        isFavorite: false,
      ),
      ProductModel(
        id: '6',
        name: 'FUJI APPLE PRC',
        price: 2.99,
        originalPrice: 3.99,
        discountPercent: 25,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/1/15/Red_Apple.jpg',
        isFavorite: false,
      ),
      ProductModel(
        id: '7',
        name: 'Fresh Orange',
        price: 1.99,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/c/c4/Orange-Fruit-Pieces.jpg',
        isFavorite: false,
      ),
      ProductModel(
        id: '8',
        name: 'Banana Bunch',
        price: 0.99,
        originalPrice: 1.49,
        discountPercent: 33,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/8/8a/Banana-Single.jpg',
        isFavorite: false,
      ),
    ];
  }

  List<ProductModel> _getBakeryProducts() {
    return [
      ProductModel(
        id: '9',
        name: 'Baguette Bread',
        price: 1.50,
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSaKirtgDcOcqy_UrduOm6SZ5QT3RNt9z8DNQ&s',
        isFavorite: false,
      ),
      ProductModel(
        id: '10',
        name: 'Chocolate Croissant',
        price: 2.25,
        imageUrl:
            'https://theculinarycollectiveatl.com/wp-content/uploads/2024/03/2148516578.webp',
        isFavorite: false,
      ),
      ProductModel(
        id: '11',
        name: 'Blueberry Muffin',
        price: 1.75,
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1pAgeowdlTw4VQZOR7TF9Vw9Rn1lZNiKU-Q&s',
        isFavorite: false,
      ),
      ProductModel(
        id: '12',
        name: 'Cinnamon Roll',
        price: 2.00,
        imageUrl:
            'https://dev.bakerpedia.com/wp-content/uploads/2020/06/Pastry_baking-processes-e1593464950587.jpg',
        isFavorite: false,
      ),
    ];
  }

  List<ProductModel> _getSnackProducts() {
    return [
      ProductModel(
        id: '13',
        name: 'Potato Chips',
        price: 1.99,
        imageUrl:
            'https://images-na.ssl-images-amazon.com/images/I/517Pa8vUG0L.jpg',
        isFavorite: false,
      ),
      ProductModel(
        id: '14',
        name: 'Chocolate Bar',
        price: 0.99,
        imageUrl:
            'https://frontierbiscuit.com/cdn/shop/products/Potato_chips.webp?v=1692429566',
        isFavorite: false,
      ),
      ProductModel(
        id: '15',
        name: 'Mixed Nuts',
        price: 3.50,
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSOJA-6dmtS-xNlx1kUX25V48MTz9QAc3I_qA&s',
        isFavorite: false,
      ),
      ProductModel(
        id: '16',
        name: 'Granola Bar',
        price: 1.25,
        imageUrl:
            'https://caribshopper.com/cdn/shop/products/sunshine-snacks-potato-chips-6-or-12-pack-caribshopper-940101_1080x.jpg?v=1663023573',
        isFavorite: false,
      ),
    ];
  }

  List<ProductModel> _getSoftDrinkProducts() {
    return [
      ProductModel(
        id: '17',
        name: 'Cola Soda',
        price: 1.50,
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3-gxDPR43rg5voQTtrQ5mBCOMLhWQUpHINg&s',
        isFavorite: false,
      ),
      ProductModel(
        id: '18',
        name: 'Lemon-Lime Soda',
        price: 1.25,
        imageUrl:
            'https://at.coca-colahellenic.com/en/our-24-7-portfolio/sparkling/_jcr_content/root/sectionteaser_image/container/teaser.coreimg.jpeg/1651242522120/brands.jpeg',
        isFavorite: false,
      ),
      ProductModel(
        id: '19',
        name: 'Orange Soda',
        price: 1.30,
        imageUrl:
            'https://i5.walmartimages.com/seo/Sunkist-Orange-Soda-Pop-2-L-Bottle_3002740e-3996-4c0f-84eb-eceb88ea2ead.504b27cdf06e785897b7ef739ccf9b25.jpeg',
        isFavorite: false,
      ),
      ProductModel(
        id: '20',
        name: 'Ginger Ale',
        price: 1.75,
        imageUrl:
            'https://media.makrocambodiaclick.com/PRODUCT_1630310862860.jpeg',
        isFavorite: false,
      ),
    ];
  }

  List<ProductModel> _getNoodleProducts() {
    return [
      ProductModel(
        id: '21',
        name: 'Instant Ramen',
        price: 0.75,
        imageUrl:
            'https://m.media-amazon.com/images/I/710yLnSkQgL._SL1200_.jpg',
        isFavorite: false,
      ),
      ProductModel(
        id: '22',
        name: 'Rice Noodles',
        price: 1.50,
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ742i14MS2X5sGAWjpgiDFj3GmWfPmuQ1Wbg&s',
        isFavorite: false,
      ),
      ProductModel(
        id: '23',
        name: 'Egg Noodles',
        price: 1.25,
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQb-WQMWCruEHVvvOPT-w6CIgsKkU5-k4wRKA&s',
        isFavorite: false,
      ),
      ProductModel(
        id: '24',
        name: 'Soba Noodles',
        price: 2.00,
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTa6B-JmTnu6MAnnUuh-PVdraga0Mt7zFZ9zw&s',
        isFavorite: false,
      ),
    ];
  }

  List<ProductModel> _getFrozenProducts() {
    return [
      ProductModel(
        id: '25',
        name: 'Frozen Pizza',
        price: 4.99,
        imageUrl:
            'https://grillonadime.com/wp-content/uploads/2024/06/Frozen-Pizza-on-Blackstone-low-res-13-1.jpg',
        isFavorite: false,
      ),
      ProductModel(
        id: '26',
        name: 'Ice Cream Tub',
        price: 3.50,
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQl-bR-NeaPgq1GrUR1P5IEiO3JyoUwVkao6w&s',
        isFavorite: false,
      ),
      ProductModel(
        id: '27',
        name: 'Frozen Vegetables',
        price: 2.25,
        imageUrl:
            'https://i5.walmartimages.com/seo/Great-Value-Frozen-Peas-Carrots-Gluten-Free-12-oz-Steamable-Bag_4965b44b-d7c1-4714-96aa-5bab328cf176.f446c946f8892a1799264540713146d5.jpeg',
        isFavorite: false,
      ),
      ProductModel(
        id: '28',
        name: 'Frozen Berries',
        price: 3.00,
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTU_bGfm9veREzjRbSr0A2nY8s4I4UyyKKYHA&s',
        isFavorite: false,
      ),
    ];
  }

  List<ProductModel> _getHouseholdProducts() {
    return [
      ProductModel(
        id: '29',
        name: 'Laundry Detergent',
        price: 5.99,
        imageUrl:
            'https://cdn.thewirecutter.com/wp-content/media/2025/12/BEST-LAUNDRY-DETERGENTS-2048px-0210-2x1-1.jpg?width=2048&quality=75&crop=2:1&auto=webp',
        isFavorite: false,
      ),
      ProductModel(
        id: '30',
        name: '`Dish Soap`',
        price: 2.50,
        imageUrl:
            'https://images.thdstatic.com/productImages/d9bd2952-5230-45db-81e7-8f7e99f18794/svn/dawn-dish-soap-003077209403-64_1000.jpg',
        isFavorite: false,
      ),
      ProductModel(
        id: '31',
        name: 'All-Purpose Cleaner',
        price: 3.75,
        imageUrl:
            'https://hips.hearstapps.com/hmg-prod/images/gh-062222-best-all-purpose-cleaners-1655921002.png?crop=0.6666666666666666xw:1xh;center,top&resize=1200:*',
        isFavorite: false,
      ),
      ProductModel(
        id: '32',
        name: 'Paper Towels',
        price: 4.00,
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRGbJ53pxoCBjgdiY1a_8YpG6wqi_C8eh50iw&s',
        isFavorite: false,
      ),
    ];
  }

  List<ProductModel> _getPersonalCareProducts() {
    return [
      ProductModel(
        id: '33',
        name: 'Shampoo Bottle',
        price: 6.99,
        imageUrl:
            'https://t4.ftcdn.net/jpg/00/47/30/15/360_F_47301594_mLvjoHeB4UvNvZ0zOotvrhPfqLQlIDRv.jpg',
        isFavorite: false,
      ),
      ProductModel(
        id: '34',
        name: 'Body Wash',
        price: 5.50,
        imageUrl:
            'https://acmarca.com/en/wp-content/uploads/sites/2/2025/02/areas_personal_care_higiene_bdg_internacional_03.png',
        isFavorite: false,
      ),
      ProductModel(
        id: '36',
        name: 'Toothpaste Tube',
        price: 3.25,
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSPnlafGFZRIvGcqzU4hbYNl87wM4cKpBZjxQ&s',
        isFavorite: false,
      ),
      ProductModel(
        id: '37',
        name: 'Deodorant Stick',
        price: 4.00,
        imageUrl:
            'https://i5.walmartimages.com/seo/Dove-Men-Care-Extra-Fresh-72H-Men-s-Antiperspirant-Deodorant-Stick-2-7-oz_d855a43f-f964-49f0-bff4-851f3b0ebe72.ac132ca29b5044d8184e96410526bbdd.jpeg',
        isFavorite: false,
      ),
    ];
  }

  List<ProductModel> _getBabyProducts() {
    return [
      ProductModel(
        id: '38',
        name: 'Baby Diapers',
        price: 19.99,
        imageUrl:
            'https://www.menmoms.in/cdn/shop/files/MM-3060-M-_PK-of-28_-1.jpg?v=1734341164&width=600',
        isFavorite: false,
      ),
      ProductModel(
        id: '39',
        name: 'Baby Wipes',
        price: 4.50,
        imageUrl:
            'https://i5.walmartimages.com/seo/WaterWipes-Original-99-9-Water-Based-Baby-Wipes-Unscented-9-Resealable-Packs-540-Wipes_acb2b827-b0f5-454f-988c-9be4e1fae873.4622633907b4c335e5e290f9fe1c9319.jpeg',
        isFavorite: false,
      ),
      ProductModel(
        id: '40',
        name: 'Baby Formula',
        price: 29.99,
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRlfplo8vbKxzEyGQ65R-ATUQqUnZreBVXYUw&s',
        isFavorite: false,
      ),
      ProductModel(
        id: '41',
        name: 'Baby Lotion',
        price: 6.25,
        imageUrl:
            'https://themothercare.pk/cdn/shop/files/Baby_Lotion_French_Berries_Family_300ml.jpg?v=1748253694',
        isFavorite: false,
      ),
    ];
  }
}
