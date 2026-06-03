import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:e_commerce_mobile_app/core/common/di.dart';
import 'package:e_commerce_mobile_app/core/data/categories_repository.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/core/utils/responsive_layout.dart';
import 'package:e_commerce_mobile_app/core/widgets/app_skeleton.dart';
import 'package:e_commerce_mobile_app/l10n/generated/app_localizations.dart';
import 'package:e_commerce_mobile_app/modules/bottom_navigation/views/supermarket_bottom_navigation.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/blocs/favorite_bloc.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/blocs/favorite_event.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/blocs/favorite_state.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/model/product_model.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/product_detail_view.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/product_list_view.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/views/order_history_view.dart';
import 'package:e_commerce_mobile_app/modules/promotion_screen/blocs/promotion_bloc.dart';
import 'package:e_commerce_mobile_app/modules/promotion_screen/blocs/promotion_event.dart';
import 'package:e_commerce_mobile_app/modules/promotion_screen/blocs/promotion_state.dart';
import 'package:e_commerce_mobile_app/modules/qr_code_screen/views/qr_code_view.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/views/user_info_view.dart';

class PromotionView extends StatelessWidget {
  final bool showBottomNavigation;

  const PromotionView({super.key, this.showBottomNavigation = true});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PromotionBloc>(
      create: (_) =>
          PromotionBloc(di<CategoriesRepository>())
            ..add(LoadPromotionSections(UserSession.selectedShopId)),
      child: _PromotionScaffold(showBottomNavigation: showBottomNavigation),
    );
  }
}

class _PromotionScaffold extends StatefulWidget {
  final bool showBottomNavigation;

  const _PromotionScaffold({required this.showBottomNavigation});

  @override
  State<_PromotionScaffold> createState() => _PromotionScaffoldState();
}

class _PromotionScaffoldState extends State<_PromotionScaffold> {
  static const _promotionSkeletonMinDuration = Duration(milliseconds: 650);

  int _promotionSkeletonSerial = 0;
  DateTime? _promotionSkeletonStartedAt;
  bool _showPromotionSkeleton = true;

  @override
  void initState() {
    super.initState();
    _startPromotionSkeleton();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);

    return SupermarketAdaptiveScaffold(
      selectedIndex: 1,
      onTap: (index) => _onBottomNavTap(context, index),
      showNavigation: widget.showBottomNavigation,
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
                    l10n?.promotion ?? 'Promotion',
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
            child: BlocConsumer<PromotionBloc, PromotionState>(
              listener: (context, state) {
                if (state is PromotionLoading || state is PromotionInitial) {
                  _startPromotionSkeleton();
                  return;
                }

                if (state is PromotionLoaded || state is PromotionError) {
                  unawaited(_hidePromotionSkeletonAfterMinimum());
                }
              },
              builder: (context, state) {
                if (_showPromotionSkeleton ||
                    state is PromotionLoading ||
                    state is PromotionInitial) {
                  return const _PromotionLoadingSkeleton();
                }
                if (state is PromotionError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n?.failedToLoadPromotions ??
                              'Failed to load promotions',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            _startPromotionSkeleton();
                            context.read<PromotionBloc>().add(
                              LoadPromotionSections(UserSession.selectedShopId),
                            );
                          },
                          child: Text(
                            l10n?.retry ?? 'Retry',
                            style: TextStyle(color: accent),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (state is PromotionLoaded) {
                  final sections = state.sections;
                  if (sections.isEmpty) {
                    return Center(
                      child: Text(
                        l10n?.noPromotionsAvailable ??
                            'No promotions available',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 20),
                    itemBuilder: (context, index) {
                      final category = sections[index];
                      return _PromotionSection(
                        title: category.displayTitle,
                        bannerImageUrl: category.bannerImageUrl,
                        products: category.previewProducts,
                        onViewAllTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductListView(
                              title: category.displayTitle,
                              categoryImageUrl: category.bannerImageUrl,
                              products: category.previewProducts,
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 24),
                    itemCount: sections.length,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _startPromotionSkeleton() {
    _promotionSkeletonSerial++;
    _promotionSkeletonStartedAt = DateTime.now();
    if (!_showPromotionSkeleton && mounted) {
      setState(() => _showPromotionSkeleton = true);
    }
  }

  Future<void> _hidePromotionSkeletonAfterMinimum() async {
    final serial = _promotionSkeletonSerial;
    final startedAt = _promotionSkeletonStartedAt;

    if (!_showPromotionSkeleton || startedAt == null) return;

    final elapsed = DateTime.now().difference(startedAt);
    final remaining = _promotionSkeletonMinDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }

    if (!mounted || serial != _promotionSkeletonSerial) return;
    setState(() => _showPromotionSkeleton = false);
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
}

class _PromotionLoadingSkeleton extends StatelessWidget {
  const _PromotionLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: ListView.separated(
        key: const ValueKey('promotion-list-skeleton'),
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 20),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(height: 24),
        itemBuilder: (_, sectionIndex) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  SkeletonBox(width: 180, height: 18, radius: 8),
                  Spacer(),
                  SkeletonBox(width: 62, height: 14, radius: 6),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 290,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, index) => SizedBox(
                  width: index == 0 ? 164 : 168,
                  child: index == 0
                      ? const SkeletonBox(height: double.infinity, radius: 14)
                      : const SkeletonProductCard(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    final primary = Theme.of(context).colorScheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final itemWidth = AppResponsive.carouselItemWidthForWidth(width);
        final sectionHeight = AppResponsive.carouselHeightForWidth(width, 290);

        return ResponsiveCenter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                          color: primary,
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
                height: sectionHeight,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _PromotionBannerCard(
                        imageUrl: bannerImageUrl,
                        width: itemWidth,
                      );
                    }

                    final product = products[index - 1];
                    return _PromotionProductCard(
                      product: product,
                      relatedProducts: products,
                      width: itemWidth,
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemCount: products.length + 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PromotionBannerCard extends StatelessWidget {
  final String imageUrl;
  final double width;

  const _PromotionBannerCard({required this.imageUrl, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
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
  final double width;

  const _PromotionProductCard({
    required this.product,
    required this.relatedProducts,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

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
        width: width,
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
                      decoration: BoxDecoration(
                        color: primary,
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
                              color: isFavorite ? primary : Colors.grey[600],
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
                product.displayName.toUpperCase(),
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primary,
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
                  Icon(Icons.add_shopping_cart, size: 24, color: primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
