import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class MallBannerCarousel extends StatefulWidget {
  const MallBannerCarousel({super.key, required this.images});

  final List<String> images;

  @override
  State<MallBannerCarousel> createState() => _MallBannerCarouselState();
}

class _MallBannerCarouselState extends State<MallBannerCarousel> {
  late final PageController _controller;
  late final Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _timer = Timer.periodic(const Duration(seconds: 4), _onTick);
  }

  void _onTick(Timer _) {
    if (!mounted || !_controller.hasClients || widget.images.isEmpty) return;
    final next = (_currentPage + 1) % widget.images.length;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SizedBox(
        height: 150,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Stack(
            children: [
              PageView.builder(
                controller: _controller,
                itemCount: widget.images.length,
                onPageChanged: (p) => setState(() => _currentPage = p),
                itemBuilder: (_, i) => CachedNetworkImage(
                  imageUrl: widget.images[i],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (_, _) => Container(color: Colors.grey[200]),
                  errorWidget: (_, _, _) => Container(
                    color: AppColors.primary.withAlpha(30),
                    child: const Icon(Icons.image_outlined, size: 48),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.images.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _currentPage ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _currentPage
                            ? Colors.white
                            : Colors.white70,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
