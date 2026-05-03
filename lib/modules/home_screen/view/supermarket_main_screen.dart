import 'dart:async';
import 'dart:math';
import 'package:e_commerce_mobile_app/core/common/auth_required_dialog.dart';
import 'package:e_commerce_mobile_app/core/data/product_data.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/views/customer_loyalty_screen.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/blocs/supermarket_category_bloc.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/blocs/supermarket_category_event.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/blocs/supermarket_category_state.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/model/category_model.dart';
import 'package:e_commerce_mobile_app/modules/partner_privilege_screen/views/become_partner_screen.dart';
import 'package:e_commerce_mobile_app/modules/shop_selector/blocs/shop_bloc.dart';
import 'package:e_commerce_mobile_app/modules/shop_selector/blocs/shop_state.dart';
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
  ShopOption? _selectedShop;
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
    'https://www.chipmong.com/wp-content/uploads/portfolio/retail/598-Mall/2.jpg',
    'https://www.chipmong.com/wp-content/uploads/portfolio/retail/598-Mall/2.jpg',
  ];

  final List<String> _partnerImages = [
    'https://cdn.kiripost.com/static/images/_WC19073.2e16d0ba.fill-960x540.jpg',
    'https://www.chipmong.com/wp-content/uploads/2020/12/DSC_7842-1-585x391.jpg',
    'https://www.chipmong.com/wp-content/uploads/2022/02/1-585x391.jpg',
  ];

  bool get _isGuest => UserSession.isGuest;

  @override
  void initState() {
    _partnerController = PageController(viewportFraction: 0.95);
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
                                color: Colors.black.withValues(alpha: 0.12),
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
                        child: PageView.builder(
                          controller: pageCtrl,
                          itemCount: _images.length,
                          onPageChanged: (i) =>
                              setPopupState(() => currentPage = i),
                          itemBuilder: (_, i) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: CachedNetworkImage(
                                imageUrl: _images[i],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
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
                            margin: const EdgeInsets.symmetric(horizontal: 4),
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
                            color: Colors.black.withValues(alpha: 0.12),
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
                        placeholder: (context, url) => Container(
                          height: 220,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
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
    return BlocListener<ShopBloc, ShopState>(
      listener: (context, state) {
        if (state is ShopsLoaded && state.shops.isNotEmpty && _selectedShop == null) {
          final first = state.shops.first;
          UserSession.setSelectedShop(first.shopId);
          setState(() => _selectedShop = first);
          context.read<SupermarketCategoryBloc>().add(LoadCategories());
        }
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
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
        preferredSize: const Size.fromHeight(64),
        child: Container(
          color: const Color(0xFFEC407A),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Walking person icon
                  GestureDetector(
                    onTap: _showShopSelectorBottomSheet,
                    child: const Icon(
                      Icons.directions_walk,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // "Shop at" label + store name + chevron
                  Expanded(
                    child: GestureDetector(
                      onTap: _showShopSelectorBottomSheet,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Shop at',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _selectedShop?.storeName ?? 'Select Shop',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Cart icon with badge
                  BlocBuilder<CartBloc, CartState>(
                    builder: (context, cartState) {
                      final itemTypes = cartState.distinctItemCount;
                      return Stack(
                        clipBehavior: Clip.none,
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
                              right: 6,
                              top: 6,
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
                                    fontSize: 11,
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
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar (opens dedicated search view)
            Container(
              color: const Color(0xFFEC407A),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Tappable search pill
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SearchProducts(),
                          ),
                        );
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
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
                  const SizedBox(width: 8),
                ],
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
                          onTap: () => _showBannerImagePopup(context, index),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5),
                              ),
                              child: Image.network(
                                _images[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
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
            BlocBuilder<SupermarketCategoryBloc, SupermarketCategoryState>(
              builder: (context, state) {
                if (state is CategoriesLoaded) {
                  return Column(
                    children: _buildCategoryRows(state.categories),
                  );
                }
                if (state is CategoriesError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            //Customer Loyalty Section
            SizedBox(height: 20),
            CustomerLoyaltySection(
              products: _getAllProducts(),
              isGuest: _isGuest,
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
                    child: GestureDetector(
                      onTap: () =>
                          _showPartnerPopup(context, _partnerImages[index]),
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
                onTap: () async {
                  if (_isGuest) {
                    await showAuthRequiredDialog(context);
                    return;
                  }
                  if (!context.mounted) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const BecomePartnerView(),
                    ),
                  );
                },
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
        return QrCodeView(showBottomNavigation: false, isGuest: _isGuest);
      case 3:
        if (_isGuest) {
          return const _GuestLoginRequiredTab();
        }
        return const OrderHistoryView(showBottomNavigation: false);
      case 4:
        if (_isGuest) {
          return const _GuestLoginRequiredTab();
        }
        return const UserInfoView(showBottomNavigation: false);
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _showShopSelectorBottomSheet() async {
    final shopState = context.read<ShopBloc>().state;
    if (shopState is! ShopsLoaded || shopState.shops.isEmpty) return;

    final selected = await showShopSelectorBottomSheet(
      context,
      shops: shopState.shops,
      selectedShop: _selectedShop ?? shopState.shops.first,
      isGuest: _isGuest,
    );

    if (!mounted || selected == null) return;
    if (_isGuest && !selected.guestAllowed) {
      await showAuthRequiredDialog(
        context,
        title: 'Branch unavailable',
        message: 'This branch requires Login or Signup',
      );
      return;
    }
    UserSession.setSelectedShop(selected.shopId);
    setState(() => _selectedShop = selected);
    context.read<SupermarketCategoryBloc>().add(LoadCategories());
  }

  List<Widget> _buildCategoryRows(List<CategoryModel> categories) {
    return List<Widget>.generate(categories.length, (index) {
      final category = categories[index];
      return Padding(
        padding: EdgeInsets.only(
          bottom: index == categories.length - 1 ? 0 : 20,
        ),
        child: ProductCarouselSection(
          title: category.displayTitle,
          products: category.previewProducts,
          categoryImageUrl: category.bannerImageUrl,
          height: index.isEven ? 160 : 180,
          onViewAllTap: () => _openCategoryProducts(
            title: category.displayTitle,
            categoryImageUrl: category.bannerImageUrl,
            products: category.previewProducts,
            promoDateText: category.promoLabel,
            categoryId: category.id,
          ),
          onCategoryTap: () => _openCategoryProducts(
            title: category.displayTitle,
            categoryImageUrl: category.bannerImageUrl,
            products: category.previewProducts,
            promoDateText: category.promoLabel,
            categoryId: category.id,
          ),
          onFavoriteTap: (_) {},
          productCardBuilder: (context, product) => ProductCard(
            product: product,
            onTap: () => _openProductDetails(
              product: product,
              relatedProducts: category.previewProducts,
            ),
          ),
        ),
      );
    });
  }

  List<ProductModel> _getAllProducts() => ProductData.allProducts;

  void _openCategoryProducts({
    required String title,
    required String categoryImageUrl,
    required List<ProductModel> products,
    String? promoDateText,
    int? categoryId,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductListView(
          title: title,
          categoryImageUrl: categoryImageUrl,
          products: products,
          promoDateText: promoDateText,
          categoryId: categoryId,
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

class _GuestLoginRequiredTab extends StatelessWidget {
  const _GuestLoginRequiredTab();

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC407A);
    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        color: const Color(0xFFF3F3F3),
        child: Column(
          children: [
            const Spacer(flex: 4),
            Image.asset(
              'assets/images/Chipmong_Logo.png',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
            const Spacer(flex: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    showAuthRequiredDialog(context);
                  },
                  child: const Text('Login', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
