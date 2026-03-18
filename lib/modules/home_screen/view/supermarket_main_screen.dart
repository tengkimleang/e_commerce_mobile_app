import 'dart:async';
import 'dart:math';
import 'package:e_commerce_mobile_app/core/data/product_data.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/views/customer_loyalty_screen.dart';
import 'package:e_commerce_mobile_app/modules/partner_privilege_screen/views/become_partner_screen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_mobile_app/modules/bottom_navigation/views/supermarket_bottom_navigation.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_bloc.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_mobile_app/modules/cart/views/cart_view.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/views/order_history_view.dart';
import 'package:e_commerce_mobile_app/modules/promotion_screen/views/promotion_view.dart';
import 'package:e_commerce_mobile_app/modules/qr_code_screen/views/qr_code_view.dart';
import 'package:e_commerce_mobile_app/modules/shop_selector/models/shop_option.dart';
import 'package:e_commerce_mobile_app/modules/shop_selector/views/shop_selector_bottom_sheet.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/model/product_model.dart';
import 'product_detail_view.dart';
import 'product_list_view.dart';
import 'widgets/product_card.dart';
import 'widgets/product_carousel_section.dart';
import 'search_products.dart';
import '../../user_info_screen/views/user_info_view.dart';

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
  late ShopOption _selectedShop;
  int _partnerCurrent = 0;
  int _selectedIndex = 0;
  bool _showLaunchPopup = false;
  late String _launchImage;
  Timer? _launchTimer;
  // popup sizing (customize these values)
  final double _popupMaxWidth = 320; // max popup width in px
  final double _popupAspectRatio = 16 / 16; // width / height

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
  final List<ShopOption> _shops = const [
    ShopOption(
      storeName: 'CHIP MONG SUPERMARKET SORLA',
      branchLabel: 'EDEN GARDEN',
      imageUrl:
          'https://www.chipmong.com/wp-content/uploads/2020/12/DSC_7842-1-585x391.jpg',
    ),
    ShopOption(
      storeName: 'CHIP MONG SUPERMARKET NORO',
      branchLabel: 'NORO SUPERMARKET',
      imageUrl:
          'https://www.chipmong.com/wp-content/uploads/2022/02/1-585x391.jpg',
    ),
    ShopOption(
      storeName: 'CHIP MONG EXPRESS BAK TOUK',
      branchLabel: 'EXPRESS BAK TOUK',
      imageUrl:
          'https://www.chipmong.com/wp-content/uploads/portfolio/retail/598-Mall/2.jpg',
    ),
    ShopOption(
      storeName: 'CHIP MONG SEN SOK SUPERMARKET',
      branchLabel: 'SEN SOK SUPERMARKET',
      imageUrl:
          'https://www.chipmong.com/wp-content/uploads/2020/04/2.Chip-mong-Supermarket-.jpg',
    ),
    ShopOption(
      storeName: 'CHIP MONG 271 MEGA MALL',
      branchLabel: '271 MEGA MALL',
      imageUrl:
          'https://www.apacoutlookmag.com/media/chip-mong-retail-1-1597331139.profileImage.2x-1536x884.webp',
    ),
    ShopOption(
      storeName: 'CHIP MONG RETAIL OUTLET',
      branchLabel: 'RETAIL OUTLET',
      imageUrl:
          'https://cdn.kiripost.com/static/images/_WC19073.2e16d0ba.fill-960x540.jpg',
    ),
  ];

  @override
  void initState() {
    _partnerController = PageController(viewportFraction: 0.95);
    _selectedShop = _shops.first;
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _selectedIndex != 0 || !_controller.hasClients) return;
      final next = (_current + 1) % _images.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });

    // Show launch popup once when the main view first appears — preload image first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ProductData.sectionImages.isNotEmpty) {
        final rnd = Random();
        final selected = ProductData
            .sectionImages[rnd.nextInt(ProductData.sectionImages.length)];
        final image = NetworkImage(selected);
        precacheImage(image, context)
            .then((_) {
              if (!mounted) return;
              setState(() {
                _launchImage = selected;
                _showLaunchPopup = true;
              });
              _launchTimer = Timer(const Duration(seconds: 10), () {
                if (mounted) setState(() => _showLaunchPopup = false);
              });
            })
            .catchError((_) {
              // If precache fails, still show the popup to avoid blocking UX
              if (!mounted) return;
              setState(() {
                _launchImage = selected;
                _showLaunchPopup = true;
              });
              _launchTimer = Timer(const Duration(seconds: 10), () {
                if (mounted) setState(() => _showLaunchPopup = false);
              });
            });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _launchTimer?.cancel();
    _controller.dispose();
    _partnerController.dispose();
    super.dispose();
  }

  void _showBannerImagePopup(BuildContext context, int initialIndex) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) {
        final pageCtrl = PageController(initialPage: initialIndex);
        int currentPage = initialIndex;
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: StatefulBuilder(
            builder: (ctx2, setPopupState) => Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(ctx2).size.height * 0.60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Stack(
                  children: [
                    // Title top-left
                    Positioned(
                      top: 16,
                      left: 16,
                      child: const Text(
                        'រូបភាព',
                        style: TextStyle(
                          color: Color(0xFFEC407A),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    // X close button top-right
                    Positioned(
                      top: 12,
                      right: 16,
                      child: GestureDetector(
                        onTap: () {
                          pageCtrl.dispose();
                          Navigator.of(ctx2).pop();
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: Color(0xFFEC407A),
                          ),
                        ),
                      ),
                    ),
                    // Slidable images
                    Positioned.fill(
                      top: 56,
                      bottom: 32,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          // borderRadius: BorderRadius.circular(16),
                          child: PageView.builder(
                            controller: pageCtrl,
                            itemCount: _images.length,
                            onPageChanged: (i) =>
                                setPopupState(() => currentPage = i),
                            itemBuilder: (_, i) => CachedNetworkImage(
                              imageUrl: _images[i],
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Dot indicators at the bottom
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_images.length, (i) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin:
                                const EdgeInsets.symmetric(horizontal: 4),
                            width: currentPage == i ? 12 : 8,
                            height: currentPage == i ? 12 : 8,
                            decoration: BoxDecoration(
                              color: currentPage == i
                                  ? const Color(0xFFEC407A)
                                  : Colors.grey[400],
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
          ),
        );
      },
    );
  }

  void _showPartnerPopup(BuildContext context, String imageUrl) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            // ~60 % of screen height, always covers bottom
            height: MediaQuery.of(ctx).size.height * 0.60,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Stack(
              children: [
                // X close button — top right of the white card
                Positioned(
                  top: 12,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Color(0xFFEC407A),
                      ),
                    ),
                  ),
                ),
                // Image — centred inside the white card
                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (_, __) => Container(
                          height: 220,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          height: 220,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedIndex != 0) {
      return Scaffold(
        body: _buildSecondaryTabBody(),
        bottomNavigationBar: SupermarketBottomNavigation(
          selectedIndex: _selectedIndex,
          onTap: _onBottomNavTap,
        ),
      );
    }

    final scaffold = Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
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
                      onPressed: () {
                        setState(() => _selectedIndex = 4);
                      },
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
                    BlocBuilder<CartBloc, CartState>(
                      builder: (context, cartState) {
                        final itemTypes = cartState.distinctItemCount;
                        return Stack(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.shopping_cart,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CartView(),
                                  ),
                                );
                              },
                            ),
                            if (itemTypes > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$itemTypes',
                                    style: const TextStyle(
                                      color: Color(0xFFEC407A),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                // Location Text
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    GestureDetector(
                      onTap: _showShopSelectorBottomSheet,
                      child: Text(
                        _selectedShop.storeName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _showShopSelectorBottomSheet,
                      child: const Icon(
                        Icons.expand_more,
                        color: Colors.white,
                        size: 20,
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
            // Search Bar (opens dedicated search view) - slightly shorter
            Container(
              color: const Color(0xFFEC407A),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GestureDetector(
                onTap: () {
                  final all = _getAllProducts();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SearchProducts(products: all),
                    ),
                  );
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: const [
                        Icon(Icons.search, color: Color(0xFFEC407A)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Search products, brands and more',
                            style: TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
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
                        return GestureDetector(
                          onTap: () =>
                              _showBannerImagePopup(context, index),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(16),
                            ),
                            child: Image.network(
                              _images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
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

            //Customer Loyalty Section
            SizedBox(height: 20),
            CustomerLoyaltySection(products: _getAllProducts()),

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
                    child: GestureDetector(
                      onTap: () => _showPartnerPopup(context, _partnerImages[index]),
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
      bottomNavigationBar: SupermarketBottomNavigation(
        selectedIndex: _selectedIndex,
        onTap: _onBottomNavTap,
      ),
    );

    // Overlay launch popup if active
    if (!_showLaunchPopup) return scaffold;

    return Stack(
      children: [
        scaffold,
        Positioned.fill(
          child: Container(
            color: Colors.black45,
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Stack(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: LayoutBuilder(
                        builder: (c, constraints) {
                          final screenW = MediaQuery.of(context).size.width;
                          final w = screenW - 40 > _popupMaxWidth
                              ? _popupMaxWidth
                              : screenW - 40;
                          final h = w / _popupAspectRatio;
                          return Image.network(
                            _launchImage,
                            width: w,
                            height: h,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          247,
                          136,
                          175,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        _launchTimer?.cancel();
                        setState(() => _showLaunchPopup = false);
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          'Skip',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onBottomNavTap(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  Widget _buildSecondaryTabBody() {
    switch (_selectedIndex) {
      case 1:
        return PromotionView(
          products: _getAllProducts(),
          showBottomNavigation: false,
        );
      case 2:
        return const QrCodeView(showBottomNavigation: false);
      case 3:
        return const OrderHistoryView(showBottomNavigation: false);
      case 4:
        return const UserInfoView(showBottomNavigation: false);
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _showShopSelectorBottomSheet() async {
    final selected = await showShopSelectorBottomSheet(
      context,
      shops: _shops,
      selectedShop: _selectedShop,
    );

    if (!mounted || selected == null) return;
    setState(() => _selectedShop = selected);
  }

  List<Widget> _buildReusableProductRows() {
    return List<Widget>.generate(ProductData.sectionTitles.length, (index) {
      final sectionTitle = ProductData.sectionTitles[index];
      final sectionProducts = ProductData.sectionAt(index);
      final sectionImage = ProductData.sectionImages[index];

      return Padding(
        padding: EdgeInsets.only(
          bottom: index == ProductData.sectionTitles.length - 1 ? 0 : 20,
        ),
        child: ProductCarouselSection(
          title: sectionTitle,
          products: sectionProducts,
          categoryImageUrl: sectionImage,
          height: index.isEven ? 160 : 180,
          onViewAllTap: () => _openCategoryProducts(
            title: sectionTitle,
            categoryImageUrl: sectionImage,
            products: sectionProducts,
          ),
          onCategoryTap: () => _openCategoryProducts(
            title: sectionTitle,
            categoryImageUrl: sectionImage,
            products: sectionProducts,
          ),
          onFavoriteTap: (_) {},
          productCardBuilder: (context, product) =>
              _buildCustomProductCard(product: product, rowIndex: index),
        ),
      );
    });
  }

  List<ProductModel> _getAllProducts() => ProductData.allProducts;

  Widget _buildCustomProductCard({
    required ProductModel product,
    required int rowIndex,
  }) {
    return ProductCard(
      product: product,
      onTap: () => _openProductDetails(
        product: product,
        relatedProducts: ProductData.sectionAt(rowIndex),
      ),
    );
  }

  void _openCategoryProducts({
    required String title,
    required String categoryImageUrl,
    required List<ProductModel> products,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductListView(
          title: title,
          categoryImageUrl: categoryImageUrl,
          products: products,
        ),
      ),
    );
  }

  void _openProductDetails({
    required ProductModel product,
    required List<ProductModel> relatedProducts,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailView(
          product: product,
          relatedProducts: relatedProducts,
        ),
      ),
    );
  }
}
