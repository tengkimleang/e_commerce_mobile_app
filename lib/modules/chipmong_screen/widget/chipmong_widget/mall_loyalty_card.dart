import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/chipmong_mall_model.dart';
import '../loyalty_widget/loyalty_models.dart';

class MallLoyaltyCard extends StatelessWidget {
  const MallLoyaltyCard({super.key, required this.info});

  final ChipmongMallLoyaltyInfo info;

  @override
  Widget build(BuildContext context) {
    final matchedTier = loyaltyTiers
        .where((t) => t.name.toLowerCase() == info.tier.toLowerCase())
        .firstOrNull;
    final outerGradient =
        matchedTier?.gradient ??
        [const Color(0xFFF48FB1), const Color.fromARGB(255, 178, 147, 157)];
    final badgeGrad = matchedTier?.badgeGradient;
    final badgeColor = matchedTier?.badgeColor ?? AppColors.primary;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        // borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: outerGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name + tier badge row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.username,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Battambang',
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'ID: ${info.memberId}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Tier badge
                Container(
                  // margin: const EdgeInsets.only(top: 20),
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: badgeGrad == null ? badgeColor : null,
                    gradient: badgeGrad != null
                        ? LinearGradient(
                            colors: badgeGrad,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : null,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    boxShadow: badgeGrad != null
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFFB5813C,
                              ).withValues(alpha: 0.45),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: badgeGrad != null
                            ? const Color(0xFF5C3A00)
                            : Colors.amber,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        info.tier,
                        style: TextStyle(
                          color: badgeGrad != null
                              ? const Color(0xFF4A2800)
                              : Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Points section
            Text(
              'Available points',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontFamily: 'Battambang',
              ),
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${info.points}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.stars_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Expiry date
            GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Expire : ${info.expiryDate}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Battambang',
                      color: Colors.black54,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Colors.black45,
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
