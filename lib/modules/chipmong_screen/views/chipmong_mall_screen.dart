import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../bloc/chipmong_mall_bloc.dart';
import '../bloc/chipmong_mall_event.dart';
import '../bloc/chipmong_mall_state.dart';
import '../models/chipmong_mall_model.dart';

// ---------------------------------------------------------------------------
// Entry-point widget — provides the BLoC to the subtree
// ---------------------------------------------------------------------------
class ChipmongMallScreen extends StatelessWidget {
  const ChipmongMallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChipmongMallBloc()..add(const ChipmongMallStarted()),
      child: const _ChipmongMallView(),
    );
  }
}

// ---------------------------------------------------------------------------
// Stateful inner view — owns TabController, PageController and banner timer
// ---------------------------------------------------------------------------
class _ChipmongMallView extends StatefulWidget {
  const _ChipmongMallView();

  @override
  State<_ChipmongMallView> createState() => _ChipmongMallViewState();
}

class _ChipmongMallViewState extends State<_ChipmongMallView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final PageController _bannerController;
  late final Timer _bannerTimer;

  int _bannerPage = 0;

  /// Kept in sync with bloc state via BlocConsumer listener so the timer
  /// never needs to call context.read inside its callback.
  List<String> _bannerImages = [];

  static const _navItems = <_NavItem>[
    _NavItem(icon: Icons.home, label: 'ទំព័រដើម'),
    _NavItem(icon: Icons.qr_code_scanner, label: 'QR កូដ'),
    _NavItem(icon: Icons.local_offer_outlined, label: 'ប្រូម៉ូសិន'),
    _NavItem(icon: Icons.emoji_events_outlined, label: 'កម្មវិធីសមាជិក'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _bannerController = PageController();
    _tabController.addListener(_onTabChanged);
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), _onBannerTick);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    context
        .read<ChipmongMallBloc>()
        .add(ChipmongMallTabChanged(_tabController.index));
  }

  void _onBannerTick(Timer _) {
    if (!mounted || !_bannerController.hasClients || _bannerImages.isEmpty) {
      return;
    }
    final next = (_bannerPage + 1) % _bannerImages.length;
    _bannerController.animateToPage(
      next,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _bannerController.dispose();
    _bannerTimer.cancel();
    super.dispose();
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChipmongMallBloc, ChipmongMallState>(
      listener: (_, state) {
        if (state.bannerImages.isNotEmpty) {
          _bannerImages = state.bannerImages;
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: SafeArea(
            bottom: false,
            child: NestedScrollView(
              headerSliverBuilder: (_, __) => [
                SliverToBoxAdapter(child: _TopBar(state: state)),
                SliverToBoxAdapter(child: _buildBannerCarousel()),
                SliverToBoxAdapter(child: _buildCategoryRow()),
                SliverToBoxAdapter(
                  child: _LoyaltyCard(info: state.loyaltyInfo),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(_tabController),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _PromotionGrid(
                    key: const PageStorageKey('tab0'),
                    items: state.promotions,
                  ),
                  _PromotionGrid(
                    key: const PageStorageKey('tab1'),
                    items: state.programs,
                  ),
                  _PromotionGrid(
                    key: const PageStorageKey('tab2'),
                    items: state.news,
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Material(
              color: Colors.white,
              elevation: 10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildBottomCTA(context),
                  _buildBottomNav(context, state.bottomNavIndex),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Banner carousel ───────────────────────────────────────────────────────

  Widget _buildBannerCarousel() {
    if (_bannerImages.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          PageView.builder(
            controller: _bannerController,
            itemCount: _bannerImages.length,
            onPageChanged: (p) => setState(() => _bannerPage = p),
            itemBuilder: (_, i) => CachedNetworkImage(
              imageUrl: _bannerImages[i],
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (_, __) =>
                  Container(color: Colors.grey[200]),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.primary.withAlpha(30),
                child: const Icon(Icons.image_outlined, size: 48),
              ),
            ),
          ),
          // Dot indicators
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _bannerImages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _bannerPage ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color:
                        i == _bannerPage ? Colors.white : Colors.white54,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Category icons row ────────────────────────────────────────────────────

  Widget _buildCategoryRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: chipmongMallCategories
            .map(
              (cat) => Expanded(
                child: _CategoryItem(category: cat),
              ),
            )
            .toList(),
      ),
    );
  }

  // ── Bottom CTA button ─────────────────────────────────────────────────────

  Widget _buildBottomCTA(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: ElevatedButton.icon(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        icon: const Icon(Icons.edit_outlined, size: 18),
        label: const Text(
          'ចូលរួមបំណងប្រាថ្នាបន្ត',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Battambang',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ── Bottom navigation bar ─────────────────────────────────────────────────

  Widget _buildBottomNav(BuildContext context, int selectedIndex) {
    return Row(
      children: List.generate(
        _navItems.length,
        (i) => Expanded(
          child: _BottomNavItem(
            item: _navItems[i],
            isSelected: i == selectedIndex,
            onTap: () => context
                .read<ChipmongMallBloc>()
                .add(ChipmongMallBottomNavChanged(i)),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top bar widget
// ---------------------------------------------------------------------------
class _TopBar extends StatelessWidget {
  const _TopBar({required this.state});

  final ChipmongMallState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'សាខា',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontFamily: 'Battambang',
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          state.selectedBranch,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Battambang',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Profile avatar
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loyalty card
// ---------------------------------------------------------------------------
class _LoyaltyCard extends StatelessWidget {
  const _LoyaltyCard({required this.info});

  final ChipmongMallLoyaltyInfo info;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Pink gradient background behind the white card
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF48FB1), Color(0xFFEC407A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Container(
        // White card
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name + tier badge row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.username,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Battambang',
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${info.memberId}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Tier badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: Colors.amber,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        info.tier,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Points section
            Text(
              'ចំនួនពិន្ទុ',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontFamily: 'Battambang',
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${info.points}',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.stars_rounded, color: AppColors.primary, size: 26),
              ],
            ),
            const SizedBox(height: 12),
            // Expiry date
            GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'អស់កំណត់ : ${info.expiryDate}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Battambang',
                      color: Colors.black54,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Colors.black45,
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

// ---------------------------------------------------------------------------
// Category icon item
// ---------------------------------------------------------------------------
class _CategoryItem extends StatelessWidget {
  const _CategoryItem({required this.category});

  final ChipmongMallCategory category;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: category.hasBadge
                      ? AppColors.primary.withAlpha(25)
                      : const Color(0xFFF0F0F0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  size: 26,
                  color: category.hasBadge
                      ? AppColors.primary
                      : Colors.grey[700],
                ),
              ),
              if (category.hasBadge && category.badgeLabel != null)
                Positioned(
                  top: -4,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category.badgeLabel!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              category.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontFamily: 'Battambang',
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Promotion grid — used inside each TabBarView tab
// ---------------------------------------------------------------------------
class _PromotionGrid extends StatelessWidget {
  const _PromotionGrid({super.key, required this.items});

  final List<ChipmongMallPromotion> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'មិនមានទិន្នន័យ',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Battambang',
            color: Colors.grey,
          ),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _PromotionCard(promo: items[i]),
    );
  }
}

// ---------------------------------------------------------------------------
// Single promotion card
// ---------------------------------------------------------------------------
class _PromotionCard extends StatelessWidget {
  const _PromotionCard({required this.promo});

  final ChipmongMallPromotion promo;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with badge overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: promo.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 120,
                      color: Colors.grey[200],
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 120,
                      color: AppColors.primary.withAlpha(20),
                      child: Icon(
                        Icons.image_outlined,
                        size: 36,
                        color: AppColors.primary.withAlpha(100),
                      ),
                    ),
                  ),
                ),
                if (promo.isActive)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'កំពុងចែកជូន',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontFamily: 'Battambang',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Text info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promo.brandName,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontFamily: 'Battambang',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    promo.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Battambang',
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    promo.date,
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
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

// ---------------------------------------------------------------------------
// Tab bar sticky header delegate
// ---------------------------------------------------------------------------
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate(this.controller);

  final TabController controller;

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Colors.white,
      child: TabBar(
        controller: controller,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontFamily: 'Battambang',
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Battambang',
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'ប្រូម៉ូសិន'),
          Tab(text: 'កម្មវិធី'),
          Tab(text: 'ព័ត៌មាន'),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => old.controller != controller;
}

// ---------------------------------------------------------------------------
// Bottom nav item data holder
// ---------------------------------------------------------------------------
class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}

// ---------------------------------------------------------------------------
// Bottom nav item widget
// ---------------------------------------------------------------------------
class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : Colors.grey;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 24, color: color),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontFamily: 'Battambang',
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
