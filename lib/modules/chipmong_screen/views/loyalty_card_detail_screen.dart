import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/services/user_session.dart';
import '../../../core/theme/app_theme.dart';
import '../models/chipmong_mall_model.dart';
import '../repositories/loyalty_repository.dart';
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
  late final LoyaltyRepository _loyaltyRepository;
  late int _availablePoints;
  late List<LoyaltyProduct> _rewards;
  late List<_PointHistoryItem> _historyItems;
  late List<_ExpiryItem> _expiryItems;

  int _currentPage = 0;
  int _selectedRewardFilter = 0;
  int _selectedHistoryCategory = 0;
  int _selectedExpiryCategory = 0;
  bool _sortDescending = true;
  bool _isSyncingData = false;
  String? _rewardsLoadMessage;

  static const _rewardFilters = [
    'All',
    'Voucher',
    'Merch',
    'Mall Cash Voucher',
    'Game',
    'Electronics',
    'Event Ticket',
  ];

  static const _historyCategories = ['All', 'Earned', 'Redeemed', 'Bonus'];

  static const _expiryCategories = [
    'All',
    'Not Expired',
    'Near Expiry',
    'Expired',
  ];

  static const _navItems = <LoyaltyNavItem>[
    LoyaltyNavItem(icon: Icons.home, label: 'Home'),
    LoyaltyNavItem(icon: Icons.qr_code_scanner, label: 'My QR'),
    LoyaltyNavItem(icon: Icons.local_offer_outlined, label: 'Promotions'),
    LoyaltyNavItem(icon: Icons.emoji_events_outlined, label: 'Loyalty'),
  ];

  List<LoyaltyProduct> get _sortedProducts {
    final safeFilterIndex =
        (_selectedRewardFilter >= 0 &&
            _selectedRewardFilter < _rewardFilters.length)
        ? _selectedRewardFilter
        : 0;
    final selectedFilter = _rewardFilters[safeFilterIndex];
    final list = _rewards.where((reward) {
      if (safeFilterIndex == 0) return true;
      final category = reward.category.trim();
      return category == selectedFilter || category.contains(selectedFilter);
    }).toList();
    list.sort(
      (a, b) => _sortDescending
          ? b.points.compareTo(a.points)
          : a.points.compareTo(b.points),
    );
    return list;
  }

  List<_PointHistoryItem> get _filteredHistoryItems {
    final safeItems = _sanitizedHistoryItems(_historyItems);
    if (_selectedHistoryCategory < 0 ||
        _selectedHistoryCategory >= _historyCategories.length) {
      return safeItems;
    }
    if (_selectedHistoryCategory == 0) return safeItems;
    final category = _historyCategories[_selectedHistoryCategory];
    return safeItems
        .where((item) => _safeHistoryCategory(item) == category)
        .toList();
  }

  List<_ExpiryItem> get _filteredExpiryItems {
    if (_selectedExpiryCategory < 0 ||
        _selectedExpiryCategory >= _expiryCategories.length) {
      return _expiryItems;
    }
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
    _loyaltyRepository = LoyaltyRepository();
    _availablePoints = widget.info.points;
    // Start empty so users never interact with mock rewards that have no
    // backend rewardId.
    _rewards = const [];
    _historyItems = const [];
    _expiryItems = const [];
    final startPage = loyaltyTiers.indexWhere(
      (t) => t.name.toLowerCase() == widget.info.tier.toLowerCase(),
    );
    _currentPage = startPage < 0 ? 0 : startPage;
    _pageController = PageController(initialPage: _currentPage);
    _tabController = TabController(length: 3, vsync: this);
    _loadLoyaltyData();
    _syncLatestPointsFromBackend();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.of(context).pop(_currentInfo);
      },
      child: Scaffold(
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
            if (i != 3) Navigator.of(context).pop(_currentInfo);
          },
        ),
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
        if (_isSyncingData)
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 6, 12, 4),
            child: LinearProgressIndicator(minHeight: 2),
          ),
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
          child: sorted.isEmpty
              ? _RewardsEmptyState(message: _rewardsLoadMessage)
              : GridView.builder(
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
    try {
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
                  'No history data',
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
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  try {
                    final item = items[i];
                    return _HistoryItemCard(
                      item: item,
                      onTap: _hasHistoryExchangeId(item)
                          ? () {
                              _openHistoryDetail(item);
                            }
                          : null,
                    );
                  } catch (e) {
                    debugPrint(
                      '[LoyaltyCardDetailScreen] failed to build history row #$i: $e',
                    );
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          const SizedBox(height: 16),
        ],
      );
    } catch (e) {
      debugPrint('[LoyaltyCardDetailScreen] failed to build history tab: $e');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubCategoryRow(
            categories: _historyCategories,
            selectedIndex: _selectedHistoryCategory,
            onChanged: (index) =>
                setState(() => _selectedHistoryCategory = index),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            color: const Color(0xFFF5F5F5),
            child: const Center(
              child: Text(
                'Unable to load history right now.',
                style: TextStyle(
                  fontFamily: 'Battambang',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }
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
                'No expiry data',
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
    final safeSelectedIndex =
        (selectedIndex >= 0 && selectedIndex < categories.length)
        ? selectedIndex
        : 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(categories.length, (index) {
            final isSelected = safeSelectedIndex == index;
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
    if (loyaltyTiers.isEmpty) {
      return const SizedBox(height: 0);
    }

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
    try {
      final exchange = await Navigator.of(context).push<LoyaltyItemExchange>(
        MaterialPageRoute(
          builder: (_) => LoyaltyRewardDetailScreen(
            product: product,
            availablePoints: _availablePoints,
            repository: _loyaltyRepository,
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

      await _refreshHistoryAndExpiry();
    } catch (e) {
      debugPrint('[LoyaltyCardDetailScreen] reward card tap failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open reward detail right now.'),
        ),
      );
    }
  }

  void _applyExchange(LoyaltyItemExchange exchange) {
    final serverRemaining = exchange.remainingPoints < 0
        ? 0
        : exchange.remainingPoints;
    final optimisticRemaining = (_availablePoints - exchange.exchangedPoints)
        .clamp(0, 1 << 31)
        .toInt();
    final resolvedRemaining =
        (exchange.exchangedPoints > 0 && serverRemaining >= _availablePoints)
        ? optimisticRemaining
        : serverRemaining;

    setState(() {
      _availablePoints = resolvedRemaining;
    });

    _syncLatestPointsFromBackend();
  }

  Future<void> _loadLoyaltyData() async {
    setState(() {
      _isSyncingData = true;
      _rewardsLoadMessage = null;
    });

    final token = (UserSession.token ?? '').trim();
    if (token.isEmpty) {
      if (!mounted) return;
      setState(() {
        _rewards = const [];
        _rewardsLoadMessage =
            'Session expired. Please login again to load rewards.';
        _isSyncingData = false;
      });
      _historyItems = const [];
      _expiryItems = const [];
      return;
    }

    List<LoyaltyProduct> rewards = const [];
    String? rewardsLoadMessage;

    try {
      rewards = await _loyaltyRepository.fetchRewards(
        category: 'ALL',
        sort: 'latest',
        page: 1,
        pageSize: 100,
      );
      if (rewards.isEmpty) {
        // Compatibility fallback if backend ignores/doesn't support filters.
        rewards = await _loyaltyRepository.fetchRewards(page: 1, pageSize: 100);
      }
      if (rewards.isEmpty) {
        final isMockSession =
            (UserSession.token ?? '').trim() == 'dev-mock-token';
        rewardsLoadMessage = isMockSession
            ? 'You are using DEV mock login. Please login with OTP account to load real rewards.'
            : 'No rewards available from backend for this account yet.';
      }
    } catch (e) {
      rewards = const [];
      rewardsLoadMessage = e is LoyaltyRepositoryException
          ? e.message
          : 'Unable to load rewards right now.';
    }

    if (!mounted) return;

    setState(() {
      _rewards = rewards;
      _rewardsLoadMessage = rewardsLoadMessage;
      _isSyncingData = false;
    });

    _refreshHistoryAndExpiry();
  }

  Future<void> _refreshHistoryAndExpiry() async {
    List<_PointHistoryItem> updatedHistoryItems = const [];
    List<_ExpiryItem>? updatedExpiryItems;

    try {
      final history = await _loyaltyRepository.fetchPointsHistory(
        status: 'PENDING_REVIEW',
        page: 1,
        pageSize: 10,
      );
      final parsedHistoryItems = history
          .map(
            (entry) => _PointHistoryItem(
              title: entry.title,
              date: _formatDate(entry.occurredAt),
              status: entry.statusLabel,
              statusCode: entry.statusCode,
              pointsDelta: entry.pointsDelta,
              category: entry.categoryLabel,
              exchangeId: entry.exchangeId,
              imageUrl: _resolveHistoryImageUrl(entry),
            ),
          )
          .toList();
      updatedHistoryItems = _dedupeHistoryItems(parsedHistoryItems);
    } catch (e) {
      debugPrint('[LoyaltyCardDetailScreen] history refresh failed: $e');
      // Avoid keeping stale/corrupted rows when refresh fails.
      updatedHistoryItems = const [];
    }

    try {
      final expiry = await _loyaltyRepository.fetchPointsExpiry(
        category: 'ALL',
      );
      updatedExpiryItems = expiry
          .map(
            (entry) => _ExpiryItem(
              title: entry.title,
              status: entry.statusLabel,
              pointsDelta: entry.pointsDelta,
              expiryDate: entry.expiryDate == null
                  ? '--'
                  : _formatDate(entry.expiryDate!),
              category: entry.categoryLabel,
            ),
          )
          .toList();
    } catch (_) {
      // Keep previous expiry on error.
    }

    if (!mounted) return;

    setState(() {
      _historyItems = updatedHistoryItems;
      if (updatedExpiryItems != null) {
        _expiryItems = updatedExpiryItems;
      }
    });
  }

  Future<void> _syncLatestPointsFromBackend() async {
    final token = (UserSession.token ?? '').trim();
    if (token.isEmpty) return;

    try {
      final latestPoints = await _loyaltyRepository.fetchCurrentPoints();
      if (!mounted || latestPoints == _availablePoints) return;
      setState(() => _availablePoints = latestPoints);
    } catch (_) {
      // Keep current point balance on sync failures.
    }
  }

  Future<void> _openHistoryDetail(_PointHistoryItem item) async {
    final exchangeId = _historyExchangeId(item);
    if (exchangeId.isEmpty) return;

    try {
      final exchange = await _loyaltyRepository.fetchExchangeDetail(
        exchangeId: exchangeId,
        fallbackRemainingPoints: _availablePoints,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LoyaltyItemExchangedDetailScreen(exchange: exchange),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e is LoyaltyRepositoryException
          ? e.message
          : 'Unable to load exchange detail right now.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  String _formatDate(DateTime date) {
    final month = _months[date.month - 1];
    final day = date.day.toString().padLeft(2, '0');
    return '$month $day, ${date.year}';
  }

  List<_PointHistoryItem> _dedupeHistoryItems(List<_PointHistoryItem> items) {
    final seen = <String>{};
    final deduped = <_PointHistoryItem>[];
    for (final item in items) {
      final exchangeId = _historyExchangeId(item);
      final title = _historyTitle(item);
      final date = _historyDate(item);
      final status = _historyStatus(item);
      final pointsDelta = _historyPointsDelta(item);
      final key = exchangeId.isNotEmpty
          ? 'id:$exchangeId'
          : 'fallback:$title|$date|$pointsDelta|$status';
      if (seen.add(key)) {
        deduped.add(item);
      }
    }
    return deduped;
  }

  List<_PointHistoryItem> _sanitizedHistoryItems(
    List<_PointHistoryItem> items,
  ) {
    final safe = <_PointHistoryItem>[];
    for (final item in items) {
      try {
        // Touch all fields that can crash from stale hot-reload objects.
        final validationKey =
            '${item.title}|${item.date}|${item.status}|${item.pointsDelta}|${item.category}';
        if (validationKey.isEmpty) {
          continue;
        }
        safe.add(item);
      } catch (e) {
        debugPrint(
          '[LoyaltyCardDetailScreen] Dropped corrupted history row: $e',
        );
      }
    }
    return safe;
  }

  String _safeHistoryCategory(_PointHistoryItem item) {
    try {
      final value = item.category;
      return value.trim().isEmpty ? 'Redeemed' : value;
    } catch (_) {
      return 'Redeemed';
    }
  }

  bool _hasHistoryExchangeId(_PointHistoryItem item) {
    return _historyExchangeId(item).isNotEmpty;
  }

  String _historyExchangeId(_PointHistoryItem item) {
    try {
      return (item.exchangeId ?? '').trim();
    } catch (_) {
      return '';
    }
  }

  String _historyTitle(_PointHistoryItem item) {
    try {
      final value = item.title;
      return value.trim().isEmpty ? 'Redeemed' : value;
    } catch (_) {
      return 'Redeemed';
    }
  }

  String _historyDate(_PointHistoryItem item) {
    try {
      final value = item.date;
      return value.trim().isEmpty ? '--' : value;
    } catch (_) {
      return '--';
    }
  }

  String _historyStatus(_PointHistoryItem item) {
    try {
      final value = item.status;
      return value.trim().isEmpty ? 'Pending review' : value;
    } catch (_) {
      return 'Pending review';
    }
  }

  int _historyPointsDelta(_PointHistoryItem item) {
    try {
      return item.pointsDelta;
    } catch (_) {
      return 0;
    }
  }

  String? _resolveHistoryImageUrl(LoyaltyHistoryEntry entry) {
    final directUrl = entry.imageUrl?.trim() ?? '';
    if (directUrl.isNotEmpty) return directUrl;

    final normalizedTitle = _normalizeHistoryTitleForMatch(entry.title);
    if (normalizedTitle.isEmpty) return null;

    for (final reward in _rewards) {
      final rewardTitle = reward.title.trim().toLowerCase();
      if (rewardTitle.isEmpty) continue;
      if (normalizedTitle == rewardTitle ||
          normalizedTitle.contains(rewardTitle) ||
          rewardTitle.contains(normalizedTitle)) {
        final imageUrl = reward.imageUrl.trim();
        if (imageUrl.isNotEmpty) return imageUrl;
      }
    }
    return null;
  }

  String _normalizeHistoryTitleForMatch(String title) {
    final normalized = title.trim().toLowerCase();
    if (normalized.isEmpty) return '';
    if (normalized.startsWith('redeemed')) {
      return normalized.replaceFirst('redeemed', '').trim();
    }
    if (normalized.startsWith('ប្តូររង្វាន់')) {
      return normalized.replaceFirst('ប្តូររង្វាន់', '').trim();
    }
    return normalized;
  }
}

class _HistoryItemCard extends StatelessWidget {
  const _HistoryItemCard({required this.item, this.onTap});

  final _PointHistoryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    try {
      final pointsDelta = _safePointsDelta();
      final title = _safeTitle();
      final date = _safeDate();
      final status = _safeStatus();
      final statusCode = _safeStatusCode();
      final statusMeta = _resolveStatusMeta(status: status, statusCode: statusCode);
      final isPositive = pointsDelta >= 0;
      final pointsColor = isPositive
          ? const Color(0xFF2E7D32)
          : const Color(0xFFD32F2F);
      final statusColor = statusMeta.textColor;
      final pointsText = isPositive
          ? '+$pointsDelta Points'
          : '$pointsDelta Points';

      return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLeading(statusMeta),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
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
                            date,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              status,
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
          ),
        ),
      );
    } catch (e) {
      debugPrint('[HistoryItemCard] build failed: $e');
      return const SizedBox.shrink();
    }
  }

  int _safePointsDelta() {
    try {
      return item.pointsDelta;
    } catch (_) {
      return 0;
    }
  }

  String _safeTitle() {
    try {
      final value = item.title;
      return value.trim().isEmpty ? 'Redeemed' : value;
    } catch (_) {
      return 'Redeemed';
    }
  }

  String _safeDate() {
    try {
      final value = item.date;
      return value.trim().isEmpty ? '--' : value;
    } catch (_) {
      return '--';
    }
  }

  String _safeStatus() {
    try {
      final value = item.status;
      return value.trim().isEmpty ? 'Pending review' : value;
    } catch (_) {
      return 'Pending review';
    }
  }

  String _safeStatusCode() {
    try {
      final value = item.statusCode ?? '';
      return value.trim();
    } catch (_) {
      return '';
    }
  }

  String _safeImageUrl() {
    try {
      return (item.imageUrl ?? '').trim();
    } catch (_) {
      return '';
    }
  }

  Widget _buildLeading(_HistoryStatusMeta statusMeta) {
    final imageUrl = _safeImageUrl();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageUrl.isEmpty
              ? Container(
                  width: 50,
                  height: 50,
                  color: AppColors.primary.withAlpha(24),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.wallet_giftcard_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                )
              : CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    width: 50,
                    height: 50,
                    color: AppColors.primary.withAlpha(24),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.wallet_giftcard_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                ),
        ),
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: statusMeta.badgeColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(statusMeta.badgeIcon, color: Colors.white, size: 9),
          ),
        ),
      ],
    );
  }

  _HistoryStatusMeta _resolveStatusMeta({
    required String status,
    required String statusCode,
  }) {
    final normalizedCode = statusCode.trim().toUpperCase();
    final normalizedStatus = status.trim().toLowerCase();

    final isPending =
        normalizedCode == 'PENDING_REVIEW' ||
        normalizedStatus.contains('pending') ||
        normalizedStatus.contains('review') ||
        normalizedStatus.contains('កំពុងពិនិត្យ');
    if (isPending) {
      return const _HistoryStatusMeta(
        textColor: Color(0xFFF57C00),
        badgeColor: Color(0xFFF57C00),
        badgeIcon: Icons.hourglass_top_rounded,
      );
    }

    final isRejected =
        normalizedCode == 'REJECTED' ||
        normalizedStatus.contains('reject') ||
        normalizedStatus.contains('បដិសេធ');
    if (isRejected) {
      return const _HistoryStatusMeta(
        textColor: Color(0xFFD32F2F),
        badgeColor: Color(0xFFD32F2F),
        badgeIcon: Icons.close_rounded,
      );
    }

    final isCancelled =
        normalizedCode == 'CANCELLED' ||
        normalizedStatus.contains('cancel') ||
        normalizedStatus.contains('បោះបង់');
    if (isCancelled) {
      return const _HistoryStatusMeta(
        textColor: Color(0xFF757575),
        badgeColor: Color(0xFF757575),
        badgeIcon: Icons.remove_rounded,
      );
    }

    return const _HistoryStatusMeta(
      textColor: Color(0xFF2E7D32),
      badgeColor: Color(0xFF22B24C),
      badgeIcon: Icons.check,
    );
  }
}

class _HistoryStatusMeta {
  final Color textColor;
  final Color badgeColor;
  final IconData badgeIcon;

  const _HistoryStatusMeta({
    required this.textColor,
    required this.badgeColor,
    required this.badgeIcon,
  });
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
    final statusColor = item.status == 'Expired'
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
                          'Status:',
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
                'Expiry Date:',
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
  final String? statusCode;
  final int pointsDelta;
  final String category;
  final String? exchangeId;
  final String? imageUrl;

  const _PointHistoryItem({
    required this.title,
    required this.date,
    required this.status,
    this.statusCode,
    required this.pointsDelta,
    required this.category,
    this.exchangeId,
    this.imageUrl,
  });
}

class _RewardsEmptyState extends StatelessWidget {
  const _RewardsEmptyState({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final resolvedMessage = message?.trim() ?? '';
    final resolved = resolvedMessage.isEmpty
        ? 'No rewards to display.'
        : resolvedMessage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        resolved,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Battambang',
          fontSize: 14,
          color: Color(0xFF6E6E6E),
        ),
      ),
    );
  }
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
