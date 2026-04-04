import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/chipmong_mall_model.dart';
import '../../views/chipmong_mall_promotion_detail_screen.dart';
import 'mall_tab_bar_header.dart';

class MallPromotionTabContent extends StatefulWidget {
  const MallPromotionTabContent({
    super.key,
    required this.controller,
    required this.promotions,
    required this.events,
    required this.news,
  });

  final TabController controller;
  final List<ChipmongMallPromotion> promotions;
  final List<ChipmongMallPromotion> events;
  final List<ChipmongMallPromotion> news;

  @override
  State<MallPromotionTabContent> createState() =>
      _MallPromotionTabContentState();
}

class _MallPromotionTabContentState extends State<MallPromotionTabContent> {
  static const _categories = <String>[
    'All',
    'Fashion',
    'Restaurants',
    'Entertainment',
    'Goods',
  ];

  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTabChanged);
  }

  @override
  void didUpdateWidget(covariant MallPromotionTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_onTabChanged);
    widget.controller.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (widget.controller.indexIsChanging) return;
    if (!mounted) return;
    setState(() => _selectedCategoryIndex = 0);
  }

  List<ChipmongMallPromotion> get _activeTabItems {
    switch (widget.controller.index) {
      case 0:
        return widget.promotions;
      case 1:
        return widget.events;
      case 2:
        return widget.news;
      default:
        return widget.promotions;
    }
  }

  List<ChipmongMallPromotion> get _filteredItems {
    if (_selectedCategoryIndex <= 0) return _activeTabItems;
    final selectedCategory = _categories[_selectedCategoryIndex];
    return _activeTabItems
        .where((item) => _resolveCategory(item) == selectedCategory)
        .toList();
  }

  String _resolveCategory(ChipmongMallPromotion promo) {
    final source = '${promo.brandName} ${promo.title}'.toLowerCase();

    const fashionKeywords = <String>[
      'fashion',
      'collection',
      'sale',
      'zara',
      'levi',
      'fila',
      'apparel',
      'style',
    ];
    const restaurantKeywords = <String>[
      'pizza',
      'restaurant',
      'food',
      'drink',
      'cafe',
      'dining',
      'meal',
      'bite',
    ];
    const entertainmentKeywords = <String>[
      'event',
      'ticket',
      'live',
      'bts',
      'tour',
      'mario',
      'game',
      'kart',
      'show',
    ];

    if (fashionKeywords.any(source.contains)) return 'Fashion';
    if (restaurantKeywords.any(source.contains)) return 'Restaurants';
    if (entertainmentKeywords.any(source.contains)) return 'Entertainment';
    return 'Goods';
  }

  bool _isExpired(ChipmongMallPromotion promo) {
    final parsedDate = _tryParseDate(promo.date);
    if (parsedDate == null) return !promo.isActive;
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return parsedDate.isBefore(startOfToday);
  }

  DateTime? _tryParseDate(String dateText) {
    final clean = dateText.trim().replaceAll(',', '');
    if (clean.isEmpty) return null;
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length < 3) return null;

    const monthMap = <String, int>{
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };

    final month = monthMap[parts[0].toLowerCase()];
    final day = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (month == null || day == null || year == null) return null;
    return DateTime(year, month, day);
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;

    return Column(
      children: [
        Container(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Promotion',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                MallTabBarHeader(controller: widget.controller),
                _PromotionCategoryChips(
                  categories: _categories,
                  selectedIndex: _selectedCategoryIndex,
                  onTap: (index) =>
                      setState(() => _selectedCategoryIndex = index),
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(
                  child: Text(
                    'No promotions available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontFamily: 'Battambang',
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final promo = items[index];
                    return _PromotionFeedCard(
                      promo: promo,
                      expired: _isExpired(promo),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _PromotionCategoryChips extends StatelessWidget {
  const _PromotionCategoryChips({
    required this.categories,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(categories.length, (index) {
            final selected = index == selectedIndex;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 170),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : const Color(0xFFCCCCCC),
                    ),
                  ),
                  child: Text(
                    categories[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Battambang',
                      color: selected ? Colors.white : Colors.grey[700],
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _PromotionFeedCard extends StatelessWidget {
  const _PromotionFeedCard({required this.promo, required this.expired});

  final ChipmongMallPromotion promo;
  final bool expired;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChipmongMallPromotionDetailScreen(promo: promo),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: promo.imageUrl,
                    width: double.infinity,
                    height: 260,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: double.infinity,
                      height: 260,
                      color: Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: double.infinity,
                      height: 260,
                      color: AppColors.primary.withAlpha(18),
                      child: Icon(
                        Icons.image_outlined,
                        size: 50,
                        color: AppColors.primary.withAlpha(100),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      expired ? 'Expired' : 'Happening',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Battambang',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promo.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      fontFamily: 'Battambang',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    promo.date,
                    style: TextStyle(fontSize: 12.5, color: Colors.grey[600]),
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
