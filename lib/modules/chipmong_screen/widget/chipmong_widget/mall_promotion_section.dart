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
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Battambang',
            color: Colors.grey,
          ),
        ),
      );
    }
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(width: 10),
      itemBuilder: (context, i) =>
          SizedBox(width: 185, child: MallPromotionCard(promo: items[i])),
    );
  }
}

class MallPromotionCard extends StatelessWidget {
  const MallPromotionCard({super.key, required this.promo});

  final ChipmongMallPromotion promo;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChipmongMallPromotionDetailScreen(promo: promo),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with active badge overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: promo.imageUrl,
                    height: 105,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(height: 95, color: Colors.grey[200]),
                    errorWidget: (context, url, error) => Container(
                      height: 105,
                      color: AppColors.primary.withAlpha(20),
                      child: Icon(
                        Icons.image_outlined,
                        size: 36,
                        color: AppColors.primary.withAlpha(100),
                      ),
                    ),
                  ),
                ),
                if (promo.isActive)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Happening',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontFamily: 'Battambang',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Text info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promo.brandName,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontFamily: 'Battambang',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    promo.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Battambang',
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    promo.date,
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
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
