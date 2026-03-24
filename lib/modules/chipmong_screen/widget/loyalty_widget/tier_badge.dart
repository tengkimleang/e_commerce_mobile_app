import 'package:flutter/material.dart';

import 'loyalty_models.dart';

class TierBadge extends StatelessWidget {
  const TierBadge({super.key, required this.tier});

  final LoyaltyTier tier;

  @override
  Widget build(BuildContext context) {
    final grad = tier.badgeGradient;
    return Container(
      
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: grad == null ? tier.badgeColor : null,
        gradient: grad != null
            ? LinearGradient(
                colors: grad,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
        boxShadow: grad != null
            ? [
                BoxShadow(
                  color: const Color(0xFFB5813C).withValues(alpha: 0.45),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.workspace_premium,
            color: Colors.white,
            size: 13,
          ),
          const SizedBox(width: 4),
          Text(
            tier.name.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
