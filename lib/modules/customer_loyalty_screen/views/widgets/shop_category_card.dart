import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/models/shop_by_category_model.dart';
import 'package:flutter/material.dart';

class ShopCategoryCard extends StatelessWidget {
  const ShopCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  final ShopByCategoryModel category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 150;
        final horizontalPadding = compact ? 8.0 : 10.0;
        final topPadding = compact ? 8.0 : 10.0;
        final bottomPadding = compact ? 8.0 : 10.0;
        final labelHeight = compact ? 32.0 : 38.0;
        final imageInset = compact ? 2.0 : 4.0;

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                topPadding,
                horizontalPadding,
                bottomPadding,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Padding(
                          padding: EdgeInsets.all(imageInset),
                          child: _CategoryImage(imageUrl: category.imageUrl),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: labelHeight,
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: (constraints.maxWidth - (horizontalPadding * 2))
                            .clamp(40.0, 220.0)
                            .toDouble(),
                        child: Text(
                          category.displayTitle,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF1D1B24),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            height: 1.18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CategoryImage extends StatelessWidget {
  const _CategoryImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = imageUrl.trim();
    if (trimmedUrl.isEmpty) {
      return const _ImageFallback();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: trimmedUrl,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        placeholder: (context, url) => Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        errorWidget: (context, url, error) => const _ImageFallback(),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.category_outlined,
        color: Color(0xFFEC407A),
        size: 34,
      ),
    );
  }
}
