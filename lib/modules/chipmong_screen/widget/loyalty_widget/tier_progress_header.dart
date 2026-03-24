import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'loyalty_models.dart';

class TierProgressHeader extends StatelessWidget {
  const TierProgressHeader({
    super.key,
    required this.tiers,
    required this.currentPage,
  });

  final List<LoyaltyTier> tiers;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    final prev = currentPage > 0 ? tiers[currentPage - 1] : null;
    final curr = tiers[currentPage];
    final next = currentPage < tiers.length - 1 ? tiers[currentPage + 1] : null;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left node
          SizedBox(
            width: 72,
            child: prev == null
                ? const SizedBox()
                : Column(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prev.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'Battambang',
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
          ),
          // Left line
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                height: 2,
                color: prev != null ? AppColors.primary : Colors.transparent,
              ),
            ),
          ),
          // Current tier
          Column(
            children: [
              Icon(Icons.workspace_premium, color: curr.badgeColor, size: 32),
              const SizedBox(height: 2),
              Text(
                curr.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: curr.badgeColor,
                  fontFamily: 'Battambang',
                  decoration: TextDecoration.underline,
                  decorationColor: curr.badgeColor,
                ),
              ),
            ],
          ),
          // Right line
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                height: 2,
                color: next != null ? Colors.grey[300] : Colors.transparent,
              ),
            ),
          ),
          // Right node
          SizedBox(
            width: 72,
            child: next == null
                ? const SizedBox()
                : Column(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withAlpha(200),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        next.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'Battambang',
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
