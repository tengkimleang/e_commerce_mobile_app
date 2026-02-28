import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PartnerCarousel extends StatefulWidget {
  final List<String> images;
  final ValueChanged<int> onPageChanged;

  const PartnerCarousel({
    super.key,
    required this.images,
    required this.onPageChanged,
  });

  @override
  State<PartnerCarousel> createState() => _PartnerCarouselState();
}

class _PartnerCarouselState extends State<PartnerCarousel> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.95);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        onPageChanged: widget.onPageChanged,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: widget.images[index],
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (c, s) => Container(color: Colors.grey[200]),
                errorWidget: (c, s, e) => Container(color: Colors.grey[300]),
              ),
            ),
          );
        },
      ),
    );
  }
}
