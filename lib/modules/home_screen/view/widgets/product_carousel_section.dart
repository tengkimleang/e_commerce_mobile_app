import 'package:flutter/material.dart';
import 'package:e_commerce_mobile_app/core/utils/responsive_layout.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/model/product_model.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/widgets/category_image_card.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/widgets/product_card.dart';

class ProductCarouselSection extends StatelessWidget {
  final String title;
  final List<ProductModel> products;
  final String categoryImageUrl;
  final double height;
  final VoidCallback? onViewAllTap;
  final VoidCallback? onCategoryTap;
  final ValueChanged<ProductModel>? onFavoriteTap;
  final Widget Function(BuildContext context)? categoryCardBuilder;
  final Widget Function(BuildContext context, ProductModel product)?
  productCardBuilder;

  const ProductCarouselSection({
    super.key,
    required this.title,
    required this.products,
    required this.categoryImageUrl,
    this.height = 180,
    this.onViewAllTap,
    this.onCategoryTap,
    this.onFavoriteTap,
    this.categoryCardBuilder,
    this.productCardBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final itemWidth = AppResponsive.carouselItemWidthForWidth(width);
        final sectionHeight = AppResponsive.carouselHeightForWidth(
          width,
          height,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onViewAllTap,
                    child: Text(
                      'View all',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: sectionHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: products.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: SizedBox(
                        width: itemWidth,
                        child:
                            categoryCardBuilder?.call(context) ??
                            CategoryImageCard(
                              imageUrl: categoryImageUrl,
                              onTap: onCategoryTap ?? () {},
                            ),
                      ),
                    );
                  }

                  final product = products[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: SizedBox(
                      width: itemWidth,
                      child:
                          productCardBuilder?.call(context, product) ??
                          ProductCard(
                            product: product,
                            onFavoriteTap: () => onFavoriteTap?.call(product),
                          ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
