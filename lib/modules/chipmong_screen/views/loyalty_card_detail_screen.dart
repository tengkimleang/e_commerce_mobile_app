import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/chipmong_mall_model.dart';

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------
class LoyaltyCardDetailScreen extends StatefulWidget {
  const LoyaltyCardDetailScreen({super.key, required this.info});

  final ChipmongMallLoyaltyInfo info;

  @override
  State<LoyaltyCardDetailScreen> createState() =>
      _LoyaltyCardDetailScreenState();
}

// ---------------------------------------------------------------------------
// Tier metadata
// ---------------------------------------------------------------------------
class _Tier {
  final String name;
  final List<Color> gradient;
  final Color badgeColor;
  final bool locked;

  const _Tier({
    required this.name,
    required this.gradient,
    required this.badgeColor,
    required this.locked,
  });
}

const _tiers = <_Tier>[
  _Tier(
    name: 'Lifestyle',
    gradient: [Color(0xFFF48FB1), Color(0xFFEC407A)],
    badgeColor: AppColors.primary,
    locked: false,
  ),
  _Tier(
    name: 'Prestige',
    gradient: [Color(0xFFEC407A), Color(0xFFAD1457)],
    badgeColor: AppColors.primaryDark,
    locked: true,
  ),
  _Tier(
    name: 'Elite',
    gradient: [Color(0xFFFFB74D), Color(0xFFE65100)],
    badgeColor: Color(0xFFE65100),
    locked: true,
  ),
];

// ---------------------------------------------------------------------------
// Mock loyalty products
// ---------------------------------------------------------------------------
class _LoyaltyProduct {
  final String imageUrl;
  final String brandName;
  final String title;
  final String store;
  final int points;

  const _LoyaltyProduct({
    required this.imageUrl,
    required this.brandName,
    required this.title,
    required this.store,
    required this.points,
  });
}

const _mockProducts = <_LoyaltyProduct>[
  _LoyaltyProduct(
    imageUrl:
        r'https://images.samsung.com/is/image/samsung/p6pim/levant/2501/gallery/levant-galaxy-z-fold7-sm-f966blbaxfe-544298439?$650_519_PNG$',
    brandName: 'SAMSUNG',
    title: 'Samsung Galaxy Z Fold7 12+256GB',
    store: 'Chip Mong 271 Mega Mall',
    points: 81999,
  ),
  _LoyaltyProduct(
    imageUrl:
        'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-17-pro-max-finish-select-202409-6-9inch-desertitanium?wid=5120&hei=2880&fmt=p-jpg&qlt=80&.v=1725384541000',
    brandName: 'Apple',
    title: 'iPhone 17 Pro Max 512G (Refurbished)',
    store: 'Chip Mong 271 Mega Mall',
    points: 72399,
  ),
  _LoyaltyProduct(
    imageUrl:
        r'https://images.samsung.com/is/image/samsung/p6pim/global/2501/gallery/global-galaxy-s25-ultra-sm-s938bzkgxfe-544325422?$650_519_PNG$',
    brandName: 'SAMSUNG',
    title: 'Samsung Galaxy S25 Ultra 512GB',
    store: 'Chip Mong 271 Mega Mall',
    points: 69899,
  ),
  _LoyaltyProduct(
    imageUrl:
        'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/ipad-pro-13-select-wifi-spacegray-202405?wid=5120&hei=2880&fmt=p-jpg&qlt=80&.v=1713920820762',
    brandName: 'Apple',
    title: 'iPad Pro M4 13-inch 256GB',
    store: 'Chip Mong 271 Mega Mall',
    points: 55000,
  ),
  _LoyaltyProduct(
    imageUrl:
        r'https://images.samsung.com/is/image/samsung/p6pim/global/2501/gallery/global-galaxy-tab-s10-plus-sm-x826bzaaxfe-544234093?$650_519_PNG$',
    brandName: 'SAMSUNG',
    title: 'Samsung Galaxy Tab S10+ 12GB/256GB',
    store: 'Chip Mong 271 Mega Mall',
    points: 42500,
  ),
  _LoyaltyProduct(
    imageUrl:
        'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/macbook-air-m3-13-midnight-select-20240308?wid=5120&hei=2880&fmt=p-jpg&qlt=80&.v=1708367688034',
    brandName: 'Apple',
    title: 'MacBook Air M3 13" 8GB/256GB',
    store: 'Chip Mong 271 Mega Mall',
    points: 95000,
  ),
];

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------
class _LoyaltyCardDetailScreenState extends State<LoyaltyCardDetailScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final TabController _tabController;

  int _currentPage = 0;
  int _selectedFilter = 0;
  bool _sortDescending = true;

  List<_LoyaltyProduct> get _sortedProducts {
    final list = [..._mockProducts];
    list.sort((a, b) =>
        _sortDescending ? b.points.compareTo(a.points) : a.points.compareTo(b.points));
    return list;
  }

  static const _tabData = [
    (icon: Icons.card_giftcard_outlined, label: 'ម្ចាស់'),
    (icon: Icons.history_outlined, label: 'ប្រត្តចំណូល'),
    (icon: Icons.schedule_outlined, label: 'ការអស់កំណត់'),
  ];

  static const _filters = [
    'ទាំងអស់',
    'ប័ណ្ណបញ្ចូល',
    'ផលិតផល',
    'ប័ណ្ណទឹកប្រាក់',
    'ហ្គេម',
    'គ្រឿងអេឡិចត្រូនិក',
    'សំបុត្រកម្មវិធី',
  ];

  static const _navItems = <_NavItem>[
    _NavItem(icon: Icons.home, label: 'ទំព័រដើម'),
    _NavItem(icon: Icons.qr_code_scanner, label: 'QR កូដ'),
    _NavItem(icon: Icons.local_offer_outlined, label: 'ប្រូម៉ូសិន'),
    _NavItem(icon: Icons.emoji_events_outlined, label: 'គម្រូ'),
  ];

  @override
  void initState() {
    super.initState();
    // Start on the page that matches the user's current tier
    final startPage = _tiers.indexWhere(
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

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildTierProgressHeader()),
            SliverToBoxAdapter(child: _buildCardPageView()),
            SliverToBoxAdapter(child: _buildTabBar()),
            SliverToBoxAdapter(child: _buildFilterChips()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _LoyaltyProductCard(product: _sortedProducts[i]),
                  childCount: _sortedProducts.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Material(
          color: Colors.white,
          elevation: 10,
          child: Row(
            children: List.generate(
              _navItems.length,
              (i) => Expanded(
                child: _BottomNavItem(
                  item: _navItems[i],
                  isSelected: i == 3,
                  onTap: () {
                    if (i != 3) Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Tier progress header ──────────────────────────────────────────────────

  Widget _buildTierProgressHeader() {
    final prev = _currentPage > 0 ? _tiers[_currentPage - 1] : null;
    final curr = _tiers[_currentPage];
    final next =
        _currentPage < _tiers.length - 1 ? _tiers[_currentPage + 1] : null;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left node ──────────────────────────────────────────────
          SizedBox(
            width: 72,
            child: prev == null
                ? const SizedBox()
                : Column(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prev.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'Battambang',
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
          ),

          // ── Left line ─────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                height: 2,
                color: prev != null ? AppColors.primary : Colors.transparent,
              ),
            ),
          ),

          // ── Current tier (crown) ───────────────────────────────────
          Column(
            children: [
              Icon(Icons.workspace_premium, color: curr.badgeColor, size: 32),
              const SizedBox(height: 2),
              Text(
                curr.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: curr.badgeColor,
                  fontFamily: 'Battambang',
                  decoration: TextDecoration.underline,
                  decorationColor: curr.badgeColor,
                ),
              ),
            ],
          ),

          // ── Right line ────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                height: 2,
                color: next != null ? Colors.grey[300] : Colors.transparent,
              ),
            ),
          ),

          // ── Right node ────────────────────────────────────────────
          SizedBox(
            width: 72,
            child: next == null
                ? const SizedBox()
                : Column(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withAlpha(200),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        next.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'Battambang',
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ── Card PageView ─────────────────────────────────────────────────────────

  Widget _buildCardPageView() {
    return SizedBox(
      height: 190,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _tiers.length,
        onPageChanged: (p) => setState(() => _currentPage = p),
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: _buildTierCard(_tiers[i]),
        ),
      ),
    );
  }

  Widget _buildTierCard(_Tier tier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: tier.locked
            ? _buildLockedCardContent(tier)
            : _buildActiveCardContent(tier),
      ),
    );
  }

  Widget _buildActiveCardContent(_Tier tier) {
    final info = widget.info;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Battambang',
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'ID: ${info.memberId}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            _TierBadge(tier: tier),
          ],
        ),
        const Spacer(),
        Text(
          'ចំនួនពិន្ទុធនាគារ',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
            fontFamily: 'Battambang',
          ),
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${info.points}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 5),
            Icon(Icons.stars_rounded, color: AppColors.primary, size: 20),
          ],
        ),
        const SizedBox(height: 6),
        Row(
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
            const Icon(Icons.chevron_right, size: 16, color: Colors.black45),
          ],
        ),
      ],
    );
  }

  Widget _buildLockedCardContent(_Tier tier) {
    final info = widget.info;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Battambang',
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.lock_outline,
                          size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        'ចាក់សោ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontFamily: 'Battambang',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _TierBadge(tier: tier),
          ],
        ),
        const Spacer(),
        Text(
          'រឹបបណ្ណគ្មានទំនិញ?',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            fontFamily: 'Battambang',
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'ទទួលបានពិន្ទុច្រើនទៀតដើម្បីឈានដល់កម្រិតនេះ',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontFamily: 'Battambang',
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ── Tab bar ───────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: AnimatedBuilder(
        animation: _tabController,
        builder: (_, __) {
          final selected = _tabController.index;
          return Row(
            children: List.generate(_tabData.length, (i) {
              final isSelected = i == selected;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tabController.animateTo(i)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _tabData[i].icon,
                          size: 15,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _tabData[i].label,
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'Battambang',
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  // ── Filter chips ──────────────────────────────────────────────────────────

  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_filters.length, (i) {
                  final isSelected = i == _selectedFilter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 170),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey[350]!,
                        ),
                      ),
                      child: Text(
                        _filters[i],
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Battambang',
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _sortDescending = !_sortDescending),
            child: SizedBox(
              width: 28,
              height: 28,
              child: CustomPaint(
                painter: _SortIconPainter(
                  descending: _sortDescending,
                  color: Colors.grey[700]!,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tier badge pill
// ---------------------------------------------------------------------------
class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.tier});

  final _Tier tier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: tier.badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium, color: Colors.amber, size: 13),
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

// ---------------------------------------------------------------------------
// Loyalty product card
// ---------------------------------------------------------------------------
class _LoyaltyProductCard extends StatelessWidget {
  const _LoyaltyProductCard({required this.product});

  final _LoyaltyProduct product;

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
            // Product image
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(height: 130, color: Colors.grey[200]),
                    errorWidget: (_, __, ___) => Container(
                      height: 130,
                      color: AppColors.primary.withAlpha(15),
                      child: Icon(Icons.image_outlined,
                          size: 40,
                          color: AppColors.primary.withAlpha(80)),
                    ),
                  ),
                ),
                // Brand badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(220),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.brandName,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Product info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ប័ណ្ណចំណូល',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                        fontFamily: 'Battambang',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Battambang',
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product.store,
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Dashed separator
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: CustomPaint(
                        size: const Size(double.infinity, 1),
                        painter: _DashedLinePainter(),
                      ),
                    ),
                    // Points row
                    Row(
                      children: [
                        Text(
                          'ចំណុចទំ:',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontFamily: 'Battambang',
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${product.points}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Text(
                          ' ពិន្ទុ',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontFamily: 'Battambang',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sort icon painter — 4-line hamburger with fixed down-arrow
// descending=true  → lines longest→shortest (big to small)
// descending=false → lines shortest→longest (small to big)
// ---------------------------------------------------------------------------
class _SortIconPainter extends CustomPainter {
  final bool descending;
  final Color color;

  const _SortIconPainter({required this.descending, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final arrowColor = color;
    final arrowPaint = Paint()
      ..color = arrowColor
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    // ── Arrow (always pointing down) on the left ──────────────────────────
    final arrowX = w * 0.18;
    final arrowTop = h * 0.08;
    final arrowBottom = h * 0.88;
    final arrowMid = h * 0.62;

    // Vertical shaft
    canvas.drawLine(
      Offset(arrowX, arrowTop),
      Offset(arrowX, arrowBottom),
      arrowPaint,
    );
    // Left chevron
    canvas.drawLine(
      Offset(arrowX - w * 0.12, arrowMid),
      Offset(arrowX, arrowBottom),
      arrowPaint,
    );
    // Right chevron
    canvas.drawLine(
      Offset(arrowX + w * 0.12, arrowMid),
      Offset(arrowX, arrowBottom),
      arrowPaint,
    );

    // ── 4 horizontal lines ────────────────────────────────────────────────
    // Line lengths as fractions of remaining width (right of arrow)
    const lineLengths = [1.0, 0.78, 0.56, 0.34]; // longest→shortest
    final lineStart = w * 0.36;
    final maxLineWidth = w - lineStart - w * 0.04;
    final rowH = h / 4.5;

    for (int i = 0; i < 4; i++) {
      // Descending: row 0 = longest; ascending: row 0 = shortest
      final lengthFraction =
          descending ? lineLengths[i] : lineLengths[3 - i];
      final lineWidth = maxLineWidth * lengthFraction;
      final y = h * 0.14 + i * rowH;
      canvas.drawLine(
        Offset(lineStart, y),
        Offset(lineStart + lineWidth, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SortIconPainter old) => old.descending != descending;
}

// ---------------------------------------------------------------------------
// Dashed line painter
// ---------------------------------------------------------------------------
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ---------------------------------------------------------------------------
// Bottom nav helpers (mirrors ChipmongMallScreen items)
// ---------------------------------------------------------------------------
class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}

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
