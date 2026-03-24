import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/chipmong_mall_model.dart';

class MallPromotionGrid extends StatelessWidget {
  const MallPromotionGrid({super.key, required this.items});

  final List<ChipmongMallPromotion> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'មិនមានទិន្នន័យ',
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
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (_, i) => SizedBox(
        width: 185,
        child: MallPromotionCard(promo: items[i]),
      ),
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
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with active badge overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: promo.imageUrl,
                    height: 105,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(height: 95, color: Colors.grey[200]),
                    errorWidget: (_, __, ___) => Container(
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
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'កំពុងចែកជូន',
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
