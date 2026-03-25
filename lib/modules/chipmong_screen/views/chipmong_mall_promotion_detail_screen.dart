import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/chipmong_mall_model.dart';

class ChipmongMallPromotionDetailScreen extends StatelessWidget {
  const ChipmongMallPromotionDetailScreen({super.key, required this.promo});

  final ChipmongMallPromotion promo;

  @override
  Widget build(BuildContext context) {
    final description = promo.description.trim().isEmpty
        ? _fallbackDescription
        : promo.description.trim();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        title: const Text(
          'ព័ត៌មានលម្អិតប្រូម៉ូសិន',
          style: TextStyle(
            fontFamily: 'Battambang',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share action is coming soon')),
              );
            },
            icon: const Icon(Icons.ios_share_outlined),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AspectRatio(
                  aspectRatio: 0.9,
                  child: CachedNetworkImage(
                    imageUrl: promo.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey.shade200),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.primary.withAlpha(15),
                      child: Icon(
                        Icons.image_outlined,
                        size: 44,
                        color: AppColors.primary.withAlpha(80),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                promo.date,
                style: TextStyle(
                  fontFamily: 'Battambang',
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${promo.brandName} | ${promo.title}',
                style: const TextStyle(
                  fontFamily: 'Battambang',
                  fontSize: 38,
                  height: 1.12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                description,
                style: TextStyle(
                  fontFamily: 'Battambang',
                  fontSize: 16,
                  height: 1.65,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _fallbackDescription {
    return '${promo.brandName}\n\n${promo.title}\n\n'
        'Please check with the official store for complete terms and updates.';
  }
}
