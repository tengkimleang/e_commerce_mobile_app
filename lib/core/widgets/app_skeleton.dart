import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:e_commerce_mobile_app/core/utils/responsive_layout.dart';

class AppSkeleton extends StatelessWidget {
  const AppSkeleton({super.key, required this.child, this.enabled = true});

  static const baseColor = Color(0xFFE4E4E4);
  static const highlightColor = Color(0xFFF7F7F7);

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: enabled,
      effect: const ShimmerEffect(
        baseColor: baseColor,
        highlightColor: highlightColor,
        duration: Duration(milliseconds: 1100),
      ),
      child: child,
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
    this.margin = EdgeInsets.zero,
  });

  final double? width;
  final double height;
  final double radius;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Skeleton.leaf(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppSkeleton.baseColor,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({
    super.key,
    required this.size,
    this.margin = EdgeInsets.zero,
  });

  final double size;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Skeleton.leaf(
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppSkeleton.baseColor,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class SkeletonProductCard extends StatelessWidget {
  const SkeletonProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SkeletonBox(height: double.infinity, radius: 12),
                  ),
                  Positioned(top: 8, right: 8, child: SkeletonCircle(size: 30)),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 96, height: 14, radius: 5),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: SkeletonBox(height: 16, radius: 5)),
                      SizedBox(width: 14),
                      SkeletonCircle(size: 24),
                    ],
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

class SkeletonCategoryCard extends StatelessWidget {
  const SkeletonCategoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSkeleton(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: SkeletonBox(height: double.infinity, radius: 12)),
          SizedBox(height: 8),
          SkeletonBox(width: 92, height: 13, radius: 5),
          SizedBox(height: 5),
          SkeletonBox(width: 70, height: 11, radius: 5),
        ],
      ),
    );
  }
}

class SkeletonProductGrid extends StatelessWidget {
  const SkeletonProductGrid({
    super.key,
    this.controller,
    this.itemCount = 6,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 24),
  });

  final ScrollController? controller;
  final int itemCount;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        return GridView.builder(
          key: const ValueKey('shop-product-grid-skeleton'),
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: padding,
          itemCount: itemCount,
          gridDelegate: AppResponsive.productGridDelegateForWidth(width),
          itemBuilder: (context, index) => const SkeletonProductCard(),
        );
      },
    );
  }
}

class SkeletonCarouselSection extends StatelessWidget {
  const SkeletonCarouselSection({
    super.key,
    this.height = 180,
    this.itemCount = 4,
  });

  final double height;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final itemWidth = AppResponsive.carouselItemWidthForWidth(width);
        final sectionHeight = AppResponsive.carouselHeightForWidth(
          width,
          height,
        );

        return AppSkeleton(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    SkeletonBox(width: 150, height: 18, radius: 6),
                    Spacer(),
                    SkeletonBox(width: 54, height: 14, radius: 6),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: sectionHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: itemCount,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) => SizedBox(
                    width: itemWidth,
                    child: const SkeletonProductCard(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SkeletonShopHomeContent extends StatelessWidget {
  const SkeletonShopHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        return AppSkeleton(
          child: ResponsiveCenter(
            child: ListView(
              key: const ValueKey('shop-home-content-skeleton'),
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SkeletonBox(
                    height: AppResponsive.homeHeroHeightForWidth(width),
                    radius: 14,
                  ),
                ),
                const SizedBox(height: 26),
                const SkeletonCarouselSection(height: 170),
                const SizedBox(height: 24),
                const SkeletonCarouselSection(height: 190),
                const SizedBox(height: 24),
                const SkeletonCarouselSection(height: 150, itemCount: 3),
              ],
            ),
          ),
        );
      },
    );
  }
}
