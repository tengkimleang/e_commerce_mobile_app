import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/chipmong_mall_model.dart';
import '../widget/loyalty_widget/loyalty_bottom_nav_bar.dart';
import '../widget/loyalty_widget/loyalty_filter_bar.dart';
import '../widget/loyalty_widget/loyalty_models.dart';
import '../widget/loyalty_widget/loyalty_product_card.dart';
import '../widget/loyalty_widget/loyalty_tab_bar.dart';
import '../widget/loyalty_widget/tier_card.dart';
import '../widget/loyalty_widget/tier_progress_header.dart';
import 'loyalty_item_exchanged_detail_screen.dart';
import 'loyalty_reward_detail_screen.dart';

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
  late int _availablePoints;
  late List<_PointHistoryItem> _historyItems;

  int _currentPage = 0;
  int _selectedRewardFilter = 0;
  int _selectedHistoryCategory = 0;
  int _selectedExpiryCategory = 0;
  bool _sortDescending = true;

  static const _rewardFilters = [
    'ទាំងអស់',
    'ប័ណ្ណបញ្ចូល',
    'ផលិតផល',
    'ប័ណ្ណទឹកប្រាក់',
    'ហ្គេម',
    'គ្រឿងអេឡិចត្រូនិក',
    'សំបុត្រកម្មវិធី',
  ];

  static const _historyCategories = [
    'ទាំងអស់',
    'ទទួលបាន',
    'ប្តូររង្វាន់',
    'ប្រាក់រង្វាន់',
  ];

  static const _expiryCategories = [
    'ទាំងអស់',
    'មិនផុតកំណត់',
    'ជិតផុតកំណត់',
    'ផុតកំណត់',
  ];

  static const _navItems = <LoyaltyNavItem>[
    LoyaltyNavItem(icon: Icons.home, label: 'ទំព័រដើម'),
    LoyaltyNavItem(icon: Icons.qr_code_scanner, label: 'QR កូដ'),
    LoyaltyNavItem(icon: Icons.local_offer_outlined, label: 'ប្រូម៉ូសិន'),
    LoyaltyNavItem(icon: Icons.emoji_events_outlined, label: 'គម្រូ'),
  ];

  static const _initialHistoryItems = <_PointHistoryItem>[
    _PointHistoryItem(
      title: 'ចុះបញ្ជីថ្មីជោគជ័យ',
      date: 'Feb 25, 2026',
      status: 'សម្រេចជោគជ័យ',
      pointsDelta: 30,
      category: 'ទទួលបាន',
    ),
    _PointHistoryItem(
      title: 'ប្តូររង្វាន់ Samsung Galaxy Z Fold7',
      date: 'Feb 24, 2026',
      status: 'សម្រេចជោគជ័យ',
      pointsDelta: -81999,
      category: 'ប្តូររង្វាន់',
    ),
    _PointHistoryItem(
      title: 'ប្រើប័ណ្ណបញ្ចុះតម្លៃក្នុងហាង',
      date: 'Feb 20, 2026',
      status: 'សម្រេចជោគជ័យ',
      pointsDelta: -1200,
      category: 'ប្រើរង្វាន់',
    ),
  ];

  static const _expiryItems = <_ExpiryItem>[
    _ExpiryItem(
      title: 'ចុះបញ្ជីថ្មីជោគជ័យ',
      status: 'មិនផុតកំណត់',
      pointsDelta: 30,
      expiryDate: '25/02/2027',
      category: 'មិនផុតកំណត់',
    ),
    _ExpiryItem(
      title: 'ប័ណ្ណបញ្ចុះតម្លៃពិសេស 10%',
      status: 'ជិតផុតកំណត់',
      pointsDelta: 20,
      expiryDate: '12/04/2026',
      category: 'ជិតផុតកំណត់',
    ),
    _ExpiryItem(
      title: 'ប័ណ្ណបញ្ចុះតម្លៃចាស់',
      status: 'ផុតកំណត់',
      pointsDelta: 15,
      expiryDate: '15/02/2026',
      category: 'ផុតកំណត់',
    ),
  ];

  List<LoyaltyProduct> get _sortedProducts {
    final list = [...loyaltyMockProducts];
    list.sort(
      (a, b) => _sortDescending
          ? b.points.compareTo(a.points)
          : a.points.compareTo(b.points),
    );
    return list;
  }

  List<_PointHistoryItem> get _filteredHistoryItems {
    if (_selectedHistoryCategory == 0) return _historyItems;
    final category = _historyCategories[_selectedHistoryCategory];
    return _historyItems.where((item) => item.category == category).toList();
  }

  List<_ExpiryItem> get _filteredExpiryItems {
    if (_selectedExpiryCategory == 0) return _expiryItems;
    final category = _expiryCategories[_selectedExpiryCategory];
    return _expiryItems.where((item) => item.category == category).toList();
  }

  ChipmongMallLoyaltyInfo get _currentInfo => ChipmongMallLoyaltyInfo(
    username: widget.info.username,
    memberId: widget.info.memberId,
    tier: widget.info.tier,
    points: _availablePoints,
    expiryDate: widget.info.expiryDate,
  );

  @override
  void initState() {
    super.initState();
    _availablePoints = widget.info.points;
    _historyItems = [..._initialHistoryItems];
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
            SliverToBoxAdapter(child: _buildDynamicContent()),
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

  Widget _buildDynamicContent() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        if (_tabController.index == 1) {
          return _buildHistoryContent();
        }
        if (_tabController.index == 2) {
          return _buildExpiryContent();
        }
        return _buildRewardsContent();
      },
    );
  }

  Widget _buildRewardsContent() {
    final sorted = _sortedProducts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LoyaltyFilterBar(
          filters: _rewardFilters,
          selectedIndex: _selectedRewardFilter,
          sortDescending: _sortDescending,
          onFilterChanged: (i) => setState(() => _selectedRewardFilter = i),
          onSortToggle: () =>
              setState(() => _sortDescending = !_sortDescending),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sorted.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (_, i) => LoyaltyProductCard(
              product: sorted[i],
              onTap: _onRewardProductTap,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHistoryContent() {
    final items = _filteredHistoryItems;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubCategoryRow(
          categories: _historyCategories,
          selectedIndex: _selectedHistoryCategory,
          onChanged: (index) =>
              setState(() => _selectedHistoryCategory = index),
        ),
        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            color: const Color(0xFFF5F5F5),
            child: const Center(
              child: Text(
                'មិនមានទិន្នន័យប្រវត្តិ',
                style: TextStyle(
                  fontFamily: 'Battambang',
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _HistoryItemCard(item: items[i]),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildExpiryContent() {
    final items = _filteredExpiryItems;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubCategoryRow(
          categories: _expiryCategories,
          selectedIndex: _selectedExpiryCategory,
          onChanged: (index) => setState(() => _selectedExpiryCategory = index),
        ),
        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            color: const Color(0xFFF5F5F5),
            child: const Center(
              child: Text(
                'មិនមានទិន្នន័យការផុតកំណត់',
                style: TextStyle(
                  fontFamily: 'Battambang',
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _ExpiryItemCard(item: items[i]),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSubCategoryRow({
    required List<String> categories,
    required int selectedIndex,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(categories.length, (index) {
            final isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFFCCCCCC),
                  ),
                ),
                child: Text(
                  categories[index],
                  style: TextStyle(
                    fontFamily: 'Battambang',
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            );
          }),
        ),
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
          child: TierCard(tier: loyaltyTiers[i], info: _currentInfo),
        ),
      ),
    );
  }

  Future<void> _onRewardProductTap(LoyaltyProduct product) async {
    final exchange = await Navigator.of(context).push<LoyaltyItemExchange>(
      MaterialPageRoute(
        builder: (_) => LoyaltyRewardDetailScreen(
          product: product,
          availablePoints: _availablePoints,
        ),
      ),
    );

    if (!mounted || exchange == null) return;

    _applyExchange(exchange);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoyaltyItemExchangedDetailScreen(exchange: exchange),
      ),
    );
  }

  void _applyExchange(LoyaltyItemExchange exchange) {
    setState(() {
      _availablePoints = exchange.remainingPoints;
      _historyItems = [
        _PointHistoryItem(
          title: 'ប្តូររង្វាន់ ${exchange.product.title}',
          date: _formatDate(exchange.exchangedAt),
          status: exchange.status,
          pointsDelta: -exchange.exchangedPoints,
          category: 'ប្តូររង្វាន់',
        ),
        ..._historyItems,
      ];
    });
  }

  String _formatDate(DateTime date) {
    final month = _months[date.month - 1];
    final day = date.day.toString().padLeft(2, '0');
    return '$month $day, ${date.year}';
  }
}

class _HistoryItemCard extends StatelessWidget {
  const _HistoryItemCard({required this.item});

  final _PointHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final isPositive = item.pointsDelta >= 0;
    final pointsColor = isPositive
        ? const Color(0xFF2E7D32)
        : const Color(0xFFD32F2F);
    final pointsText = isPositive
        ? '+${item.pointsDelta} Points'
        : '${item.pointsDelta} Points';

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wallet_giftcard_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),
              Positioned(
                right: -1,
                bottom: -1,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22B24C),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 9),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontFamily: 'Battambang',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      item.date,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.status,
                        style: const TextStyle(
                          fontFamily: 'Battambang',
                          fontSize: 12,
                          color: Color(0xFF2E7D32),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 92,
            child: Text(
              pointsText,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                color: pointsColor,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpiryItemCard extends StatelessWidget {
  const _ExpiryItemCard({required this.item});

  final _ExpiryItem item;

  @override
  Widget build(BuildContext context) {
    final pointsText = item.pointsDelta >= 0
        ? '+${item.pointsDelta} Points'
        : '${item.pointsDelta} Points';
    final pointsColor = item.pointsDelta >= 0
        ? const Color(0xFF2E7D32)
        : const Color(0xFFD32F2F);
    final statusColor = item.status == 'ផុតកំណត់'
        ? const Color(0xFFD32F2F)
        : const Color(0xFF2E7D32);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.wallet_giftcard_rounded,
                      color: Colors.white,
                      size: 27,
                    ),
                  ),
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22B24C),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 9,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontFamily: 'Battambang',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'ស្ថានភាព៖',
                          style: TextStyle(
                            fontFamily: 'Battambang',
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.status,
                            style: TextStyle(
                              fontFamily: 'Battambang',
                              fontSize: 12,
                              color: statusColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 92,
                child: Text(
                  pointsText,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    color: pointsColor,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: Colors.grey[300]),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'ថ្ងៃផុតកំណត់ៈ',
                style: TextStyle(
                  fontFamily: 'Battambang',
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              Text(
                item.expiryDate,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PointHistoryItem {
  final String title;
  final String date;
  final String status;
  final int pointsDelta;
  final String category;

  const _PointHistoryItem({
    required this.title,
    required this.date,
    required this.status,
    required this.pointsDelta,
    required this.category,
  });
}

class _ExpiryItem {
  final String title;
  final String status;
  final int pointsDelta;
  final String expiryDate;
  final String category;

  const _ExpiryItem({
    required this.title,
    required this.status,
    required this.pointsDelta,
    required this.expiryDate,
    required this.category,
  });
}

const _months = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
