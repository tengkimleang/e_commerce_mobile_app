import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/chipmong_mall_model.dart';
import '../loyalty_widget/loyalty_models.dart';
import 'package:e_commerce_mobile_app/l10n/generated/app_localizations.dart';

class MallLoyaltyCard extends StatelessWidget {
  const MallLoyaltyCard({super.key, required this.info});

  final ChipmongMallLoyaltyInfo info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final matchedTier = loyaltyTiers
        .where((t) => t.name.toLowerCase() == info.tier.toLowerCase())
        .firstOrNull;
    final outerGradient =
        matchedTier?.gradient ??
        [const Color(0xFFF48FB1), const Color.fromARGB(255, 178, 147, 157)];
    final badgeGrad = matchedTier?.badgeGradient;
    final badgeColor = matchedTier?.badgeColor ?? AppColors.primary;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: outerGradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.titleSmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'ID: ${info.memberId}',
                            style: theme.bodySmall?.copyWith(
                              color: const Color(0xFF6F6A73),
                              fontSize: 12,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
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
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: badgeGrad != null
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFFB5813C,
                                  ).withValues(alpha: 0.35),
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
                            Icons.workspace_premium_rounded,
                            color: badgeGrad != null
                                ? const Color(0xFF5C3A00)
                                : Colors.white,
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
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Text(
                  AppLocalizations.of(context)!.availablePoints,
                  style: theme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${info.points}',
                      style: theme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.stars_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Expire : ${info.expiryDate}',
                      style: theme.bodySmall?.copyWith(
                        color: const Color(0xFF6F6A73),
                        fontSize: 12,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 17,
                      color: Color(0xFF6F6A73),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
