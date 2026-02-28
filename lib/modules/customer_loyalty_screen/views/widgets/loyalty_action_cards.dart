import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class LoyaltyActionCards extends StatelessWidget {
  final String exchangePointsImageUrl;
  final String priceCheckingImageUrl;
  final VoidCallback onExchangePointsTap;
  final VoidCallback onPriceCheckingTap;

  const LoyaltyActionCards({
    super.key,
    required this.exchangePointsImageUrl,
    required this.priceCheckingImageUrl,
    required this.onExchangePointsTap,
    required this.onPriceCheckingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: _OverlayCard(
              title: 'Exchange Points',
              imageUrl: exchangePointsImageUrl,
              onTap: onExchangePointsTap,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _OverlayCard(
              title: 'Price Checking',
              imageUrl: priceCheckingImageUrl,
              onTap: onPriceCheckingTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const _OverlayCard({
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (c, s) => Container(color: Colors.grey[200]),
                errorWidget: (c, s, e) => Container(color: Colors.grey[300]),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
