import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_mobile_app/core/common/auth_required_dialog.dart';
import 'package:e_commerce_mobile_app/core/common/di.dart';
import 'package:e_commerce_mobile_app/core/data/categories_repository.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/core/utils/responsive_layout.dart';
import 'package:e_commerce_mobile_app/core/utils/country_flag_utils.dart';
import 'package:e_commerce_mobile_app/l10n/generated/app_localizations.dart';

import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_bloc.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_event.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_state.dart';
import 'package:e_commerce_mobile_app/modules/cart/views/cart_view.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/model/product_model.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/widgets/product_card.dart';

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
  late final PageController _imagePageController;
  List<ProductModel> _suggestions = [];
  int _activeImageIndex = 0;
  double _scrollOffset = 0;

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

  void _updateScrollOffset(double offset) {
    final nextOffset = offset < 0 ? 0.0 : offset;
    if ((nextOffset - _scrollOffset).abs() < 0.5) return;

    setState(() => _scrollOffset = nextOffset);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    final accent = Theme.of(context).colorScheme.primary;
    final product = widget.product;
    final images = _productImages;
    final description = product.displayDescription.trim();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final imageHeight = AppResponsive.detailHeroHeightForWidth(width) * 0.7;
        final imageOpacity = (1 - (_scrollOffset / (imageHeight * 0.78))).clamp(
          0.0,
          1.0,
        );

        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F2),
          body: Stack(
            children: [
              SafeArea(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.axis == Axis.vertical) {
                      _updateScrollOffset(notification.metrics.pixels);
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
                              color: Colors.white.withValues(
                                alpha: imageOpacity,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: 0.08 * imageOpacity,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: _openImageSlider,
                                  child: SizedBox(
                                    height: imageHeight,
                                    width: double.infinity,
                                    child: Opacity(
                                      opacity: imageOpacity,
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
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    top: 4,
                                  ),
                                  child: Opacity(
                                    opacity: imageOpacity,
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
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    22,
                                    16,
                                    20,
                                  ),
                                  child: Visibility(
                                    visible: false,
                                    maintainAnimation: true,
                                    maintainSize: true,
                                    maintainState: true,
                                    child: Text(
                                      product.displayName.toUpperCase(),
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
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: accent,
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
                                  style: TextStyle(
                                    color: accent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (description.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                              child: Text(
                                l10n?.productDescription ?? 'Description',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1D1B24),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              child: Text(
                                description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.45,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
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
                                return ProductCard(
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
                child: _ProductCollapsingHeaderOverlay(
                  title: product.displayName,
                  imageHeight: imageHeight,
                  scrollOffset: _scrollOffset,
                  onBack: () => Navigator.of(context).pop(),
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
                  decoration: BoxDecoration(
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
                              '${l10n?.total ?? 'Total'}: \$ ${cartState.totalAmount.toStringAsFixed(2)}',
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
                          child: Text(
                            l10n?.checkOut ?? 'Check Out',
                            style: const TextStyle(
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

class _ProductCollapsingHeaderOverlay extends StatelessWidget {
  final String title;
  final double imageHeight;
  final double scrollOffset;
  final VoidCallback onBack;

  const _ProductCollapsingHeaderOverlay({
    required this.title,
    required this.imageHeight,
    required this.scrollOffset,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    const cardTop = 8.0;
    const pageIndicatorSpace = 26.0;
    const titleTopSpacing = 22.0;
    const expandedLeft = 26.0;
    const expandedRight = 26.0;
    const collapsedLeft = 100.0;
    const collapsedRight = 18.0;
    const collapsedTop = 28.0;
    const lockRange = 136.0;

    final expandedTop =
        cardTop + imageHeight + pageIndicatorSpace + titleTopSpacing;
    final lockOffset = expandedTop - collapsedTop;
    final collapseProgress =
        ((scrollOffset - (lockOffset - lockRange)) / lockRange).clamp(0.0, 1.0);
    final easedProgress = Curves.easeOutCubic.transform(collapseProgress);
    final naturalTitleTop = expandedTop - scrollOffset;
    final titleTop = _lerpDouble(naturalTitleTop, collapsedTop, easedProgress);
    final titleLeft = _lerpDouble(expandedLeft, collapsedLeft, easedProgress);
    final titleRight = _lerpDouble(
      expandedRight,
      collapsedRight,
      easedProgress,
    );
    final titleSize = _lerpDouble(16, 18, easedProgress);
    final headerOpacity = Curves.easeOut.transform(collapseProgress);

    return SafeArea(
      bottom: false,
      child: ResponsiveCenter(
        child: SizedBox(
          height: 116,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IgnorePointer(
                ignoring: headerOpacity == 0,
                child: Opacity(
                  opacity: headerOpacity,
                  child: Container(
                    height: 82,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.16 * headerOpacity,
                          ),
                          blurRadius: 14,
                          spreadRadius: -2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 36,
                child: SizedBox(
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
              ),
              Positioned(
                top: titleTop,
                left: titleLeft,
                right: titleRight,
                child: Text(
                  title.toUpperCase(),
                  maxLines: collapseProgress < 0.35 ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF17151D),
                    fontSize: titleSize,
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
    );
  }
}

double _lerpDouble(double begin, double end, double t) {
  return begin + (end - begin) * t;
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
    final primary = Theme.of(context).colorScheme.primary;

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
                  Expanded(
                    child: Text(
                      'Image',
                      style: TextStyle(
                        color: primary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: primary, size: 32),
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
    final primary = Theme.of(context).colorScheme.primary;

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
            color: isActive ? primary : const Color(0xFFBDBDBD),
          ),
        );
      }),
    );
  }
}
