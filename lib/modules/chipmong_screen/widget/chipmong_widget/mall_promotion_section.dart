import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/chipmong_mall_model.dart';
import '../../views/chipmong_mall_promotion_detail_screen.dart';

class MallPromotionGrid extends StatelessWidget {
  const MallPromotionGrid({super.key, required this.items});

  final List<ChipmongMallPromotion> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemBuilder: (context, i) =>
          SizedBox(width: 156, child: MallPromotionCard(promo: items[i])),
    );
  }
}

class MallPromotionCard extends StatelessWidget {
  const MallPromotionCard({super.key, required this.promo});

  final ChipmongMallPromotion promo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChipmongMallPromotionDetailScreen(promo: promo),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: promo.imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(height: 100, color: Colors.grey[200]),
                    errorWidget: (context, url, error) => Container(
                      height: 100,
                      color: AppColors.primary.withAlpha(20),
                      child: Icon(
                        Icons.image_outlined,
                        size: 36,
                        color: AppColors.primary.withAlpha(100),
                      ),
                    ),
                  ),
                  if (promo.isActive)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          'Happening',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promo.brandName,
                      style: theme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: const Color(0xFF6F6A73),
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      promo.title,
                      style: theme.titleSmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      promo.date,
                      style: theme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
