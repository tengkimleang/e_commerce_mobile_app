import 'package:flutter/material.dart';

import '../models/chipmong_mall_model.dart';
import '../widget/loyalty_widget/loyalty_bottom_nav_bar.dart';
import '../widget/loyalty_widget/loyalty_filter_bar.dart';
import '../widget/loyalty_widget/loyalty_models.dart';
import '../widget/loyalty_widget/loyalty_product_card.dart';
import '../widget/loyalty_widget/loyalty_tab_bar.dart';
import '../widget/loyalty_widget/tier_card.dart';
import '../widget/loyalty_widget/tier_progress_header.dart';

class LoyaltyCardDetailScreen extends StatefulWidget {
  const LoyaltyCardDetailScreen({super.key, required this.info});

  final ChipmongMallLoyaltyInfo info;

  @override
  State<LoyaltyCardDetailScreen> createState() =>
      _LoyaltyCardDetailScreenState();
}

class _LoyaltyCardDetailScreenState extends State<LoyaltyCardDetailScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final TabController _tabController;

  int _currentPage = 0;
  int _selectedFilter = 0;
  bool _sortDescending = true;

  static const _filters = [
    'ទាំងអស់',
    'ប័ណ្ណបញ្ចូល',
    'ផលិតផល',
    'ប័ណ្ណទឹកប្រាក់',
    'ហ្គេម',
    'គ្រឿងអេឡិចត្រូនិក',
    'សំបុត្រកម្មវិធី',
  ];

  static const _navItems = <LoyaltyNavItem>[
    LoyaltyNavItem(icon: Icons.home, label: 'ទំព័រដើម'),
    LoyaltyNavItem(icon: Icons.qr_code_scanner, label: 'QR កូដ'),
    LoyaltyNavItem(icon: Icons.local_offer_outlined, label: 'ប្រូម៉ូសិន'),
    LoyaltyNavItem(icon: Icons.emoji_events_outlined, label: 'គម្រូ'),
  ];

  List<LoyaltyProduct> get _sortedProducts {
    final list = [...loyaltyMockProducts];
    list.sort((a, b) => _sortDescending
        ? b.points.compareTo(a.points)
        : a.points.compareTo(b.points));
    return list;
  }

  @override
  void initState() {
    super.initState();
    final startPage = loyaltyTiers.indexWhere(
      (t) => t.name.toLowerCase() == widget.info.tier.toLowerCase(),
    );
    _currentPage = startPage < 0 ? 0 : startPage;
    _pageController = PageController(initialPage: _currentPage);
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _sortedProducts;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: TierProgressHeader(
                tiers: loyaltyTiers,
                currentPage: _currentPage,
              ),
            ),
            SliverToBoxAdapter(child: _buildCardPageView()),
            SliverToBoxAdapter(
              child: LoyaltyTabBar(controller: _tabController),
            ),
            SliverToBoxAdapter(
              child: LoyaltyFilterBar(
                filters: _filters,
                selectedIndex: _selectedFilter,
                sortDescending: _sortDescending,
                onFilterChanged: (i) => setState(() => _selectedFilter = i),
                onSortToggle: () =>
                    setState(() => _sortDescending = !_sortDescending),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => LoyaltyProductCard(product: sorted[i]),
                  childCount: sorted.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
      bottomNavigationBar: LoyaltyBottomNavBar(
        items: _navItems,
        selectedIndex: 3,
        onTap: (i) {
          if (i != 3) Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildCardPageView() {
    return SizedBox(
      height: 190,
      child: PageView.builder(
        controller: _pageController,
        itemCount: loyaltyTiers.length,
        onPageChanged: (p) => setState(() => _currentPage = p),
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: TierCard(tier: loyaltyTiers[i], info: widget.info),
        ),
      ),
    );
  }
}
