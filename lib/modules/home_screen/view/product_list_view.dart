import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:e_commerce_mobile_app/core/common/di.dart';
import 'package:e_commerce_mobile_app/core/data/categories_repository.dart';
import 'package:e_commerce_mobile_app/core/utils/responsive_layout.dart';
import 'package:e_commerce_mobile_app/l10n/generated/app_localizations.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/model/product_model.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/product_detail_view.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/widgets/category_image_card.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/widgets/product_card.dart';

class ProductListView extends StatefulWidget {
  final String title;
  final String categoryImageUrl;

  /// Preview products shown immediately while the full list loads.
  final List<ProductModel> products;
  final String? subtitle;
  final String? promoDateText;

  /// When provided, all products are fetched from the API on open.
  final int? categoryId;

  const ProductListView({
    super.key,
    required this.title,
    required this.categoryImageUrl,
    required this.products,
    this.subtitle,
    this.promoDateText,
    this.categoryId,
  });

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  late List<ProductModel> _products;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _products = widget.products;
    if (widget.categoryId != null) {
      _fetchAll();
    }
  }

  Future<void> _fetchAll() async {
    setState(() => _loading = true);
    try {
      // Fetch up to 200 products — adjust if categories can exceed this.
      final (items, _) = await di<CategoriesRepository>().fetchCategoryProducts(
        widget.categoryId!,
        pageSize: 200,
      );
      if (mounted) setState(() => _products = items);
    } catch (_) {
      // Keep showing preview products on failure.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final products = _products;
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final maxContentWidth = AppResponsive.maxContentWidthForWidth(width);
        final contentWidth = maxContentWidth.isFinite
            ? math.min(width, maxContentWidth)
            : width;
        final contentOffset = (width - contentWidth) / 2;

        return Scaffold(
          backgroundColor: const Color(0xFFF6F6F6),
          body: Stack(
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: contentWidth,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: AppResponsive.detailHeroHeightForWidth(
                              width,
                            ),
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CategoryImageCard(
                                  imageUrl: widget.categoryImageUrl,
                                ),
                                if (widget.promoDateText != null)
                                  Positioned(
                                    bottom: 16,
                                    left: 16,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.12,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            widget.promoDateText!,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_loading)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          )
                        else if (products.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                l10n?.noProductsFound ?? 'No products found',
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            sliver: SliverGrid(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final product = products[index];
                                return ProductCard(
                                  product: product,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailView(
                                        product: product,
                                        relatedProducts: products,
                                      ),
                                    ),
                                  ),
                                );
                              }, childCount: products.length),
                              gridDelegate:
                                  AppResponsive.productGridDelegateForWidth(
                                    contentWidth,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: topPadding + 12,
                left: contentOffset + 16,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.arrow_back_ios_new, size: 18),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
