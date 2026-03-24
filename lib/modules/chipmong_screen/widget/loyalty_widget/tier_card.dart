import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/chipmong_mall_model.dart';
import 'loyalty_models.dart';
import 'tier_badge.dart';

class TierCard extends StatelessWidget {
  const TierCard({super.key, required this.tier, required this.info});

  final LoyaltyTier tier;
  final ChipmongMallLoyaltyInfo info;

  @override
  Widget build(BuildContext context) {
    final outerGradient = tier.gradient;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
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
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: tier.locked ? _LockedContent(tier: tier, info: info) : _ActiveContent(tier: tier, info: info),
        ),
      ),
    );
  }
}

class _ActiveContent extends StatelessWidget {
  const _ActiveContent({required this.tier, required this.info});

  final LoyaltyTier tier;
  final ChipmongMallLoyaltyInfo info;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            TierBadge(tier: tier),
          ],
        ),
        const Spacer(),
        Text(
          'ចំនួនពិន្ទុធនាគារ',
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
            const Icon(Icons.stars_rounded, color: AppColors.primary, size: 20),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'អស់កំណត់ : ${info.expiryDate}',
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Battambang',
                color: Colors.black54,
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: Colors.black45),
          ],
        ),
      ],
    );
  }
}

class _LockedContent extends StatelessWidget {
  const _LockedContent({required this.tier, required this.info});

  final LoyaltyTier tier;
  final ChipmongMallLoyaltyInfo info;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.lock_outline,
                          size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        'ចាក់សោ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontFamily: 'Battambang',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            TierBadge(tier: tier),
          ],
        ),
        const Spacer(),
        const Text(
          'រឹបបណ្ណគ្មានទំនិញ?',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            fontFamily: 'Battambang',
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'ទទួលបានពិន្ទុច្រើនទៀតដើម្បីឈានដល់កម្រិតនេះ',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontFamily: 'Battambang',
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
