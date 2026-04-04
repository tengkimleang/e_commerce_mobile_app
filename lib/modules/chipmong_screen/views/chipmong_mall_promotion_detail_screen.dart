import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/chipmong_mall_model.dart';

class ChipmongMallPromotionDetailScreen extends StatefulWidget {
  const ChipmongMallPromotionDetailScreen({super.key, required this.promo});

  final ChipmongMallPromotion promo;

  @override
  State<ChipmongMallPromotionDetailScreen> createState() =>
      _ChipmongMallPromotionDetailScreenState();
}

class _ChipmongMallPromotionDetailScreenState
    extends State<ChipmongMallPromotionDetailScreen> {
  static const _autoSlideDuration = Duration(seconds: 3);
  static const _autoSlideAnimationDuration = Duration(milliseconds: 320);

  late final PageController _imagePageController;
  late final int _initialCarouselPage;
  Timer? _autoSlideTimer;
  int _activeImageIndex = 0;

  List<String> get _images => widget.promo.galleryImages;

  @override
  void initState() {
    super.initState();
    _initialCarouselPage = _images.length * 1000;
    _imagePageController = PageController(initialPage: _initialCarouselPage);
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final promo = widget.promo;
    final description = promo.description.trim().isEmpty
        ? _fallbackDescription(promo)
        : promo.description.trim();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        title: const Text(
          'Promotion Details',
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
              _buildImageCarousel(),
              const SizedBox(height: 8),
              Center(
                child: _ImageDotsIndicator(
                  totalDots: _images.length,
                  activeDotIndex: _activeImageIndex,
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

  Widget _buildImageCarousel() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: AspectRatio(
        aspectRatio: 0.9,
        child: PageView.builder(
          controller: _imagePageController,
          onPageChanged: (index) =>
              setState(() => _activeImageIndex = index % _images.length),
          itemBuilder: (context, index) {
            final imageIndex = index % _images.length;
            return CachedNetworkImage(
              imageUrl: _images[imageIndex],
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
            );
          },
        ),
      ),
    );
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(_autoSlideDuration, (timer) {
      if (!mounted || !_imagePageController.hasClients) return;

      final currentPage =
          _imagePageController.page?.round() ?? _initialCarouselPage;
      _imagePageController.animateToPage(
        currentPage + 1,
        duration: _autoSlideAnimationDuration,
        curve: Curves.easeInOut,
      );
    });
  }

  String _fallbackDescription(ChipmongMallPromotion promo) {
    return '${promo.brandName}\n\n${promo.title}\n\n'
        'Please check with the official store for complete terms and updates.';
  }
}

class _ImageDotsIndicator extends StatelessWidget {
  const _ImageDotsIndicator({
    required this.totalDots,
    required this.activeDotIndex,
  });

  final int totalDots;
  final int activeDotIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalDots, (index) {
        final isActive = index == activeDotIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: isActive ? 8 : 7,
          height: isActive ? 8 : 7,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primary : Colors.grey.shade300,
          ),
        );
      }),
    );
  }
}
