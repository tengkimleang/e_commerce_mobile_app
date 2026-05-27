import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_mobile_app/core/common/auth_required_dialog.dart';
import 'package:e_commerce_mobile_app/core/common/di.dart';
import 'package:e_commerce_mobile_app/core/data/categories_repository.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/core/utils/responsive_layout.dart';
import 'package:e_commerce_mobile_app/core/utils/country_flag_utils.dart';

import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_bloc.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_event.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_state.dart';
import 'package:e_commerce_mobile_app/modules/cart/views/cart_view.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/blocs/favorite_bloc.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/blocs/favorite_event.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/blocs/favorite_state.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/model/product_model.dart';

class ProductDetailView extends StatefulWidget {
  final ProductModel product;
  final List<ProductModel> relatedProducts;
  final bool loadSubCategorySuggestions;

  const ProductDetailView({
    super.key,
    required this.product,
    this.relatedProducts = const [],
    this.loadSubCategorySuggestions = true,
  });

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  static const _accent = Color(0xFFEC407A);
  static const _stickyHeaderRevealOffset = 16.0;

  late final PageController _imagePageController;
  List<ProductModel> _suggestions = [];
  int _activeImageIndex = 0;
  bool _showStickyHeader = false;

  List<String> get _productImages {
    final images = widget.product.galleryImages;
    return images.isEmpty ? [''] : images;
  }

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController(
      initialPage: _initialInfiniteImagePage(0, _productImages.length),
    );
    _loadSuggestions();
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  Future<void> _loadSuggestions() async {
    final subCategoryId = widget.product.subCategoryId;
    if (widget.loadSubCategorySuggestions && subCategoryId != null) {
      try {
        final (items, _) = await di<CategoriesRepository>()
            .fetchSubCategoryProducts(subCategoryId, pageSize: 20);
        if (!mounted) return;
        setState(() {
          _suggestions = items
              .where((p) => p.id != widget.product.id)
              .take(6)
              .toList();
        });
        return;
      } catch (_) {
        // fall through to relatedProducts fallback
      }
    }
    if (mounted) {
      setState(() {
        _suggestions = widget.relatedProducts
            .where((p) => p.id != widget.product.id)
            .take(6)
            .toList();
      });
    }
  }

  void _openImageSlider() {
    final images = _productImages;
    final initialIndex = _activeImageIndex < images.length
        ? _activeImageIndex
        : 0;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          _ProductImageSliderSheet(images: images, initialIndex: initialIndex),
    );
  }

  void _updateStickyHeaderVisibility(double offset, double triggerOffset) {
    final shouldShow = offset >= triggerOffset;
    if (shouldShow == _showStickyHeader) return;

    setState(() => _showStickyHeader = shouldShow);
  }

  @override
  Widget build(BuildContext context) {
    const accent = _accent;
    final product = widget.product;
    final images = _productImages;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final imageHeight = AppResponsive.detailHeroHeightForWidth(width) * 0.7;

        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F2),
          body: Stack(
            children: [
              SafeArea(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.axis == Axis.vertical) {
                      _updateStickyHeaderVisibility(
                        notification.metrics.pixels,
                        _stickyHeaderRevealOffset,
                      );
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    child: ResponsiveCenter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new,
                                    size: 20,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _openImageSlider,
                                  child: SizedBox(
                                    height: imageHeight,
                                    width: double.infinity,
                                    child: PageView.builder(
                                      controller: _imagePageController,
                                      itemCount: images.length > 1
                                          ? null
                                          : images.length,
                                      onPageChanged: (index) => setState(
                                        () => _activeImageIndex =
                                            index % images.length,
                                      ),
                                      itemBuilder: (context, index) {
                                        final imageIndex =
                                            index % images.length;
                                        return _ProductImageFrame(
                                          imageUrl: images[imageIndex],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    top: 4,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${_activeImageIndex + 1}/${images.length}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    22,
                                    16,
                                    20,
                                  ),
                                  child: Text(
                                    product.name.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      height: 1.05,
                                      color: Color(0xFF1D1B24),
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '\$ ${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFEC407A),
                                  ),
                                ),
                                if (product.originalPrice != null) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '\$ ${product.originalPrice!.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey[500],
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${product.discountPercent}% OFF',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1D1B24),
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                if (product.countryOfOrigin != null)
                                  CountryFlagBadge(
                                    countryOfOrigin: product.countryOfOrigin!,
                                    size: 32,
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: BlocBuilder<CartBloc, CartState>(
                              builder: (context, cartState) {
                                final quantity = cartState.quantityFor(
                                  product.id,
                                );

                                if (quantity == 0) {
                                  return SizedBox(
                                    width: double.infinity,
                                    height: 44,
                                    child: ElevatedButton(
                                      onPressed: product.isOutOfStock
                                          ? null
                                          : () async {
                                              if (UserSession.isGuest) {
                                                await showAuthRequiredDialog(
                                                  context,
                                                );
                                                return;
                                              }
                                              if (!context.mounted) return;
                                              context.read<CartBloc>().add(
                                                AddToCart(product),
                                              );
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: product.isOutOfStock
                                            ? Colors.grey[400]
                                            : accent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            32,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        product.isOutOfStock
                                            ? 'Out of Stock'
                                            : 'Add to cart',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F7F7),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: const Color(0xFFE8E8E8),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          if (quantity > 1) {
                                            context.read<CartBloc>().add(
                                              DecreaseQuantity(product.id),
                                            );
                                          } else {
                                            context.read<CartBloc>().add(
                                              RemoveFromCart(product.id),
                                            );
                                          }
                                        },
                                        icon: Icon(
                                          quantity > 1
                                              ? Icons.remove
                                              : Icons.delete_outline,
                                        ),
                                        color: Colors.grey[500],
                                      ),
                                      const Spacer(),
                                      Text(
                                        '$quantity',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF1D1B24),
                                        ),
                                      ),
                                      const Spacer(),
                                      if (product.stockQty == null ||
                                          quantity < product.stockQty!)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: 10,
                                          ),
                                          child: GestureDetector(
                                            onTap: () =>
                                                context.read<CartBloc>().add(
                                                  IncreaseQuantity(product.id),
                                                ),
                                            child: Container(
                                              width: 36,
                                              height: 36,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.add,
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        )
                                      else
                                        const SizedBox(width: 46),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          BlocBuilder<CartBloc, CartState>(
                            builder: (context, cartState) {
                              final quantity = cartState.quantityFor(
                                product.id,
                              );
                              if (quantity == 0) return const SizedBox.shrink();

                              return Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  0,
                                ),
                                child: Text(
                                  '$quantity in cart',
                                  style: const TextStyle(
                                    color: accent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 18, 16, 8),
                            child: Text(
                              'If this product is not available',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1D1B24),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                            child: SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.grey[500],
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Remove it from my order',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 10, 16, 12),
                            child: Text(
                              'You may also like',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1D1B24),
                              ),
                            ),
                          ),
                          if (_suggestions.isEmpty)
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
                              child: Text(
                                'No related products',
                                style: TextStyle(color: Colors.black54),
                              ),
                            )
                          else
                            GridView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  AppResponsive.productGridDelegateForWidth(
                                    width,
                                    childAspectRatio: 0.72,
                                  ),
                              itemBuilder: (context, index) {
                                final item = _suggestions[index];
                                return _RelatedProductCard(
                                  product: item,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailView(
                                        product: item,
                                        relatedProducts: _suggestions,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              itemCount: _suggestions.length,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  ignoring: !_showStickyHeader,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    offset: _showStickyHeader
                        ? Offset.zero
                        : const Offset(0, -0.16),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOut,
                      opacity: _showStickyHeader ? 1 : 0,
                      child: _ProductStickyHeader(
                        title: product.name,
                        onBack: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              if (cartState.distinctItemCount == 0) {
                return const SizedBox.shrink();
              }

              return SafeArea(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: const BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${cartState.distinctItemCount} Items detail',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Total: \$ ${cartState.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CartView(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Check Out',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ProductStickyHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _ProductStickyHeader({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 14,
            spreadRadius: -2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: ResponsiveCenter(
          child: SizedBox(
            height: 104,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(36, 16, 18, 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 42,
                    height: 48,
                    child: IconButton(
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).backButtonTooltip,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onBack,
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF5F6068),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 22),
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF17151D),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductImageSliderSheet extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _ProductImageSliderSheet({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_ProductImageSliderSheet> createState() =>
      _ProductImageSliderSheetState();
}

class _ProductImageSliderSheetState extends State<_ProductImageSliderSheet> {
  static const _accent = Color(0xFFEC407A);

  late final PageController _pageController;
  late int _activeIndex;

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.initialIndex;
    _pageController = PageController(
      initialPage: _initialInfiniteImagePage(
        widget.initialIndex,
        widget.images.length,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return SafeArea(
      top: false,
      child: Container(
        height: screenHeight * 0.76,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 28, 20, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Image',
                      style: TextStyle(
                        color: _accent,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: _accent, size: 32),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length > 1
                    ? null
                    : widget.images.length,
                onPageChanged: (index) =>
                    setState(() => _activeIndex = index % widget.images.length),
                itemBuilder: (context, index) {
                  final imageIndex = index % widget.images.length;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _ProductImageFrame(
                      imageUrl: widget.images[imageIndex],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 30),
              child: _ImageDotsIndicator(
                totalDots: widget.images.length,
                activeDotIndex: _activeIndex,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

int _initialInfiniteImagePage(int initialIndex, int imageCount) {
  if (imageCount <= 1) return initialIndex;
  const basePage = 10000;
  return basePage - (basePage % imageCount) + initialIndex;
}

class _ProductImageFrame extends StatelessWidget {
  final String imageUrl;

  const _ProductImageFrame({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = imageUrl.trim();

    if (trimmedUrl.isEmpty) {
      return const _ProductImagePlaceholder();
    }

    return CachedNetworkImage(
      imageUrl: trimmedUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.contain,
      placeholder: (context, url) => const _ProductImagePlaceholder(),
      errorWidget: (context, url, error) => const _ProductImagePlaceholder(),
    );
  }
}

class _ProductImagePlaceholder extends StatelessWidget {
  const _ProductImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F4F4),
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 42),
    );
  }
}

class _ImageDotsIndicator extends StatelessWidget {
  final int totalDots;
  final int activeDotIndex;

  const _ImageDotsIndicator({
    required this.totalDots,
    required this.activeDotIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalDots, (index) {
        final isActive = index == activeDotIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: isActive ? 10 : 8,
          height: isActive ? 10 : 8,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFFEC407A) : const Color(0xFFBDBDBD),
          ),
        );
      }),
    );
  }
}

class _RelatedProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const _RelatedProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                      fit: BoxFit.contain,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[100]),
                      errorWidget: (context, url, error) =>
                          Container(color: Colors.grey[200]),
                    ),
                  ),
                  if (product.discountPercent != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEC407A),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${product.discountPercent}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (product.countryOfOrigin != null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: CountryFlagBadge(
                        countryOfOrigin: product.countryOfOrigin!,
                        size: 24,
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
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
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: Text(
                product.name,
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
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
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
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                  ),
                  BlocBuilder<CartBloc, CartState>(
                    builder: (context, cartState) {
                      final quantity = cartState.quantityFor(product.id);
                      return Row(
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minHeight: 24,
                              minWidth: 24,
                            ),
                            onPressed: product.isOutOfStock
                                ? null
                                : () async {
                                    if (UserSession.isGuest) {
                                      await showAuthRequiredDialog(context);
                                      return;
                                    }
                                    if (!context.mounted) return;
                                    context.read<CartBloc>().add(
                                      AddToCart(product),
                                    );
                                  },
                            icon: Icon(
                              quantity > 0
                                  ? Icons.shopping_cart
                                  : Icons.add_shopping_cart,
                              color: product.isOutOfStock
                                  ? Colors.grey[400]
                                  : const Color(0xFFEC407A),
                              size: 24,
                            ),
                          ),
                          if (quantity > 0)
                            Text(
                              '$quantity',
                              style: const TextStyle(
                                color: Color(0xFFEC407A),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      );
                    },
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
