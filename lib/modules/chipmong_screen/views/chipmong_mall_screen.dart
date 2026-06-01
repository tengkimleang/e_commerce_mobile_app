import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../bloc/chipmong_mall_bloc.dart';
import '../bloc/chipmong_mall_event.dart';
import '../bloc/chipmong_mall_state.dart';
import '../widget/chipmong_widget/mall_banner_carousel.dart';
import '../widget/chipmong_widget/mall_bottom_cta.dart';
import '../widget/chipmong_widget/mall_bottom_nav.dart';
import '../widget/chipmong_widget/mall_category_row.dart';
import '../widget/chipmong_widget/mall_loyalty_card.dart';
import '../widget/chipmong_widget/mall_promotion_section.dart';
import '../widget/chipmong_widget/mall_promotion_tab_content.dart';
import '../widget/chipmong_widget/mall_tab_bar_header.dart';
import '../widget/chipmong_widget/mall_top_bar.dart';
import '../models/chipmong_mall_model.dart';
import 'chipmong_mall_promotion_detail_screen.dart';
import 'loyalty_card_detail_screen.dart';
import '../../qr_code_screen/views/qr_code_view.dart';

// ---------------------------------------------------------------------------
// Entry-point widget — provides the BLoC to the subtree
// ---------------------------------------------------------------------------
class ChipmongMallScreen extends StatelessWidget {
  const ChipmongMallScreen({super.key, this.openLoyaltyOnStart = false});

  final bool openLoyaltyOnStart;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChipmongMallBloc()..add(const ChipmongMallStarted()),
      child: _ChipmongMallView(openLoyaltyOnStart: openLoyaltyOnStart),
    );
  }
}

// ---------------------------------------------------------------------------
// Stateful inner view — owns TabController, PageController and banner timer
// ---------------------------------------------------------------------------
class _ChipmongMallView extends StatefulWidget {
  const _ChipmongMallView({required this.openLoyaltyOnStart});

  final bool openLoyaltyOnStart;

  @override
  State<_ChipmongMallView> createState() => _ChipmongMallViewState();
}

class _ChipmongMallViewState extends State<_ChipmongMallView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _didOpenInitialLoyalty = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    context.read<ChipmongMallBloc>().add(
      ChipmongMallTabChanged(_tabController.index),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _openInitialLoyaltyIfNeeded(ChipmongMallState state) {
    if (!widget.openLoyaltyOnStart ||
        _didOpenInitialLoyalty ||
        state.isLoading) {
      return;
    }

    _didOpenInitialLoyalty = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _openLoyaltyDetail(state.loyaltyInfo);
    });
  }

  Future<void> _openLoyaltyDetail(ChipmongMallLoyaltyInfo loyaltyInfo) async {
    try {
      final result = await Navigator.of(context).push<LoyaltyCardDetailResult>(
        PageRouteBuilder<LoyaltyCardDetailResult>(
          // Zero duration = instant switch, identical to the other tabs.
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (_, _, _) => LoyaltyCardDetailScreen(
            info: loyaltyInfo,
            onBottomNavTap: (i) {
              if (!mounted) return;
              context.read<ChipmongMallBloc>().add(
                ChipmongMallBottomNavChanged(i),
              );
            },
          ),
        ),
      );
      if (!mounted || result == null) return;
      // Tab switch was already handled by onBottomNavTap; only sync loyalty info.
      context.read<ChipmongMallBloc>().add(
        ChipmongMallLoyaltyInfoUpdated(result.loyaltyInfo),
      );
    } catch (e) {
      debugPrint('[ChipmongMallScreen] failed to open loyalty detail: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open loyalty card detail right now.'),
        ),
      );
    }
  }

  Future<void> _openMallSearch(ChipmongMallState state) async {
    final items = <ChipmongMallPromotion>[];
    final seen = <String>{};
    for (final item in [
      ...state.promotions,
      ...state.programs,
      ...state.news,
    ]) {
      final key = '${item.brandName}|${item.title}|${item.date}';
      if (seen.add(key)) items.add(item);
    }

    final result = await showSearch<ChipmongMallPromotion?>(
      context: context,
      delegate: _MallSearchDelegate(items),
    );
    if (!mounted || result == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChipmongMallPromotionDetailScreen(promo: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChipmongMallBloc, ChipmongMallState>(
      builder: (context, state) {
        _openInitialLoyaltyIfNeeded(state);

        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isQrTab = state.bottomNavIndex == 1;
        final isPromotionTab = state.bottomNavIndex == 2;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: isQrTab
              ? AppBar(
                  title: const Text(
                    'My QR',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                )
              : null,
          body: isQrTab
              ? const QrCodeBody()
              : isPromotionTab
              ? MallPromotionTabContent(
                  controller: _tabController,
                  promotions: state.promotions,
                  events: state.programs,
                  news: state.news,
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      MallTopBar(
                        state: state,
                        onSearchTap: () => _openMallSearch(state),
                      ),
                      MallBannerCarousel(images: state.bannerImages),
                      MallCategoryRow(categories: chipmongMallCategories),
                      GestureDetector(
                        onTap: () => _openLoyaltyDetail(state.loyaltyInfo),
                        child: MallLoyaltyCard(info: state.loyaltyInfo),
                      ),
                      MallTabBarHeader(controller: _tabController),
                      SizedBox(
                        height: 220,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            MallPromotionGrid(
                              key: const PageStorageKey('tab0'),
                              items: state.promotions,
                            ),
                            MallPromotionGrid(
                              key: const PageStorageKey('tab1'),
                              items: state.programs,
                            ),
                            MallPromotionGrid(
                              key: const PageStorageKey('tab2'),
                              items: state.news,
                            ),
                          ],
                        ),
                      ),
                      const MallBottomCta(),
                    ],
                  ),
                ),
          bottomNavigationBar: MallBottomNav(
            items: chipmongMallNavItems,
            selectedIndex: state.bottomNavIndex,
            onTap: (i) {
              if (i == 3) {
                _openLoyaltyDetail(state.loyaltyInfo);
                return;
              }
              context.read<ChipmongMallBloc>().add(
                ChipmongMallBottomNavChanged(i),
              );
            },
          ),
        );
      },
    );
  }
}

class _MallSearchDelegate extends SearchDelegate<ChipmongMallPromotion?> {
  _MallSearchDelegate(this.items)
    : super(
        searchFieldLabel: 'Search shops, offers and events',
        searchFieldStyle: AppTypography.input,
      );

  final List<ChipmongMallPromotion> items;

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.white70,
          fontSize: 14,
        ),
        border: InputBorder.none,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: theme.textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () => query = '',
          icon: const Icon(Icons.close),
          tooltip: 'Clear',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
      tooltip: 'Back',
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildMatches(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildMatches(context);

  Widget _buildMatches(BuildContext context) {
    final matches = _matches;
    if (matches.isEmpty) {
      return Center(
        child: Text(
          query.trim().isEmpty
              ? 'No mall offers available'
              : 'No results found',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: matches.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = matches[index];
        return ListTile(
          onTap: () => close(context, item),
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withAlpha(20),
            child: const Icon(
              Icons.local_offer_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          title: Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            '${item.brandName} - ${item.date}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  List<ChipmongMallPromotion> get _matches {
    final keyword = query.trim().toLowerCase();
    if (keyword.isEmpty) return items;
    return items.where((item) {
      final source = '${item.brandName} ${item.title} ${item.date}'
          .toLowerCase();
      return source.contains(keyword);
    }).toList();
  }
}
