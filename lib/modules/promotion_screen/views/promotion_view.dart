import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:e_commerce_mobile_app/modules/bottom_navigation/views/supermarket_bottom_navigation.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/blocs/favorite_bloc.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/blocs/favorite_event.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/blocs/favorite_state.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/model/product_model.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/product_detail_view.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/product_list_view.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/views/order_history_view.dart';
import 'package:e_commerce_mobile_app/modules/qr_code_screen/views/qr_code_view.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/views/user_info_view.dart';

class PromotionView extends StatelessWidget {
  final List<ProductModel> products;
  final bool showBottomNavigation;

  const PromotionView({
    super.key,
    this.products = const [],
    this.showBottomNavigation = true,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC407A);
    final baseProducts = products.isEmpty ? _fallbackProducts() : products;
    final promoProducts = _mapToPromotionProducts(baseProducts);
    final sections = _buildSections(promoProducts);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(26),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.09),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 86,
                child: Center(
                  child: Text(
                    'Promotion',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 21,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 20),
              itemBuilder: (context, index) {
                final section = sections[index];
                return _PromotionSection(
                  title: section.title,
                  bannerImageUrl: section.bannerImageUrl,
                  products: section.products,
                  onViewAllTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductListView(
                        title: section.title,
                        categoryImageUrl: section.bannerImageUrl,
                        products: section.products,
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 24),
              itemCount: sections.length,
            ),
          ),
        ],
      ),
      bottomNavigationBar: showBottomNavigation
          ? SupermarketBottomNavigation(
              selectedIndex: 1,
              onTap: (index) => _onBottomNavTap(context, index),
            )
          : null,
    );
  }

  void _onBottomNavTap(BuildContext context, int index) {
    if (index == 1) return;

    if (index == 0) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      return;
    }

    if (index == 2) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const QrCodeView()));
      return;
    }

    if (index == 3) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OrderHistoryView()),
      );
      return;
    }

    if (index == 4) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const UserInfoView()),
      );
    }
  }

  List<_PromotionSectionData> _buildSections(List<ProductModel> allProducts) {
    return [
      _PromotionSectionData(
        title: 'Happy Khmer New Year 🌸',
        bannerImageUrl:
            'https://files.intocambodia.org/wp-content/uploads/2024/08/03152726/Khmer-New-Year-%C2%A9-Angkor-Sangranta-Team-960x640.jpg',
        products: _takeProducts(allProducts, start: 0, count: 4),
      ),
      _PromotionSectionData(
        title: 'Discount Up To 33% 🔥',
        bannerImageUrl:
            'https://previews.123rf.com/images/roxanabalint/roxanabalint1410/roxanabalint141000185/32487885-special-discount-red-leather-label-or-price-tag-on-white-background-vector-illustration.jpg',
        products: _takeProducts(allProducts, start: 4, count: 4),
      ),
      _PromotionSectionData(
        title: 'Special Weekly Promotion 🇰🇭',
        bannerImageUrl:
            'https://media.istockphoto.com/id/1010805154/vector/weekly-offers-concept.jpg?s=612x612&w=0&k=20&c=cYM75U52EdVkje7PC7_yYoIVD_f_vixGsyKzDKCBSS0=',
        products: _takeProducts(allProducts, start: 8, count: 4),
      ),
    ];
  }

  List<ProductModel> _takeProducts(
    List<ProductModel> products, {
    required int start,
    required int count,
  }) {
    if (products.isEmpty) return const [];

    return List<ProductModel>.generate(count, (index) {
      final itemIndex = (start + index) % products.length;
      return products[itemIndex];
    });
  }

  List<ProductModel> _mapToPromotionProducts(List<ProductModel> source) {
    const syntheticDiscounts = [10, 15, 22, 23, 33];
    var fallbackIndex = 0;

    return source.take(20).map((product) {
      final discount =
          product.discountPercent ??
          syntheticDiscounts[fallbackIndex++ % syntheticDiscounts.length];
      final originalPrice =
          product.originalPrice ??
          _computeOriginalPrice(product.price, discount);

      return ProductModel(
        id: product.id,
        name: product.name,
        price: product.price,
        originalPrice: originalPrice,
        imageUrl: product.imageUrl,
        discountPercent: discount,
        isFavorite: product.isFavorite,
      );
    }).toList();
  }

  double _computeOriginalPrice(double price, int discountPercent) {
    final ratio = 1 - (discountPercent / 100);
    if (ratio <= 0) return price;
    return double.parse((price / ratio).toStringAsFixed(2));
  }

  List<ProductModel> _fallbackProducts() {
    return const [
      ProductModel(
        id: '5',
        name: 'PAPA MANDARIN PRC 1XKG',
        price: 2.45,
        originalPrice: 4.98,
        discountPercent: 51,
        imageUrl:
            'https://cdn.britannica.com/24/174524-050-A851D3F2/Oranges.jpg',
      ),
      ProductModel(
        id: '6',
        name: 'FUJI APPLE PRC',
        price: 2.99,
        originalPrice: 3.99,
        discountPercent: 25,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/1/15/Red_Apple.jpg',
      ),
      ProductModel(
        id: '8',
        name: 'Banana Bunch',
        price: 0.99,
        originalPrice: 1.49,
        discountPercent: 33,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/8/8a/Banana-Single.jpg',
      ),
      ProductModel(
        id: '9',
        name: 'Baguette Bread',
        price: 1.50,
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSaKirtgDcOcqy_UrduOm6SZ5QT3RNt9z8DNQ&s',
      ),
      ProductModel(
        id: '10',
        name: 'Chocolate Croissant',
        price: 2.25,
        imageUrl:
            'https://theculinarycollectiveatl.com/wp-content/uploads/2024/03/2148516578.webp',
      ),
      ProductModel(
        id: '13',
        name: 'Potato Chips',
        price: 1.99,
        imageUrl:
            'https://images-na.ssl-images-amazon.com/images/I/517Pa8vUG0L.jpg',
      ),
      ProductModel(
        id: '17',
        name: 'Cola Soda',
        price: 1.50,
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3-gxDPR43rg5voQTtrQ5mBCOMLhWQUpHINg&s',
      ),
      ProductModel(
        id: '21',
        name: 'Instant Ramen',
        price: 0.75,
        imageUrl:
            'https://m.media-amazon.com/images/I/710yLnSkQgL._SL1200_.jpg',
      ),
      ProductModel(
        id: '26',
        name: 'Ice Cream Tub',
        price: 3.50,
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQl-bR-NeaPgq1GrUR1P5IEiO3JyoUwVkao6w&s',
      ),
      ProductModel(
        id: '29',
        name: 'Laundry Detergent',
        price: 5.99,
        imageUrl:
            'https://cdn.thewirecutter.com/wp-content/media/2025/12/BEST-LAUNDRY-DETERGENTS-2048px-0210-2x1-1.jpg?width=2048&quality=75&crop=2:1&auto=webp',
      ),
    ];
  }
}

class _PromotionSection extends StatelessWidget {
  final String title;
  final String bannerImageUrl;
  final List<ProductModel> products;
  final VoidCallback onViewAllTap;

  const _PromotionSection({
    required this.title,
    required this.bannerImageUrl,
    required this.products,
    required this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF262626),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onViewAllTap,
                child: Text(
                  'View all  ›',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFEC407A),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 290,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _PromotionBannerCard(imageUrl: bannerImageUrl);
              }

              final product = products[index - 1];
              return _PromotionProductCard(
                product: product,
                relatedProducts: products,
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemCount: products.length + 1,
          ),
        ),
      ],
    );
  }
}

class _PromotionBannerCard extends StatelessWidget {
  final String imageUrl;

  const _PromotionBannerCard({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 164,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.grey[300]),
          errorWidget: (context, url, error) =>
              Container(color: Colors.grey[400]),
        ),
      ),
    );
  }
}

class _PromotionProductCard extends StatelessWidget {
  final ProductModel product;
  final List<ProductModel> relatedProducts;

  const _PromotionProductCard({
    required this.product,
    required this.relatedProducts,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductDetailView(
            product: product,
            relatedProducts: relatedProducts,
          ),
        ),
      ),
      child: Container(
        width: 168,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[100]),
                      errorWidget: (context, url, error) =>
                          Container(color: Colors.grey[200]),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEC407A),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        ),
                      ),
                      child: Text(
                        '${product.discountPercent ?? 10}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: BlocBuilder<FavoriteBloc, FavoriteState>(
                      builder: (context, favoriteState) {
                        final isFavorite = favoriteState.contains(product.id);
                        return GestureDetector(
                          onTap: () {
                            context.read<FavoriteBloc>().add(
                              FavoriteToggled(product),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 18,
                              color: isFavorite
                                  ? const Color(0xFFEC407A)
                                  : Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: Text(
                product.name.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1D1B24),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        Text(
                          '\$ ${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEC407A),
                          ),
                        ),
                        if (product.originalPrice != null)
                          Text(
                            '\$ ${product.originalPrice!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black45,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.add_shopping_cart,
                    size: 24,
                    color: Color(0xFFEC407A),
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

class _PromotionSectionData {
  final String title;
  final String bannerImageUrl;
  final List<ProductModel> products;

  const _PromotionSectionData({
    required this.title,
    required this.bannerImageUrl,
    required this.products,
  });
}
