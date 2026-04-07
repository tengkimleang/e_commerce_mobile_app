import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
import 'loyalty_card_detail_screen.dart';
import '../../qr_code_screen/views/qr_code_view.dart';

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

  static const _navItems = <MallNavItem>[
    MallNavItem(icon: Icons.home, label: 'Home'),
    MallNavItem(icon: Icons.qr_code_scanner, label: 'My QR'),
    MallNavItem(icon: Icons.local_offer_outlined, label: 'Promotions'),
    MallNavItem(icon: Icons.emoji_events_outlined, label: 'Loyalty'),
  ];

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

  Future<void> _openLoyaltyDetail(ChipmongMallLoyaltyInfo loyaltyInfo) async {
    try {
      final result = await Navigator.of(context).push<LoyaltyCardDetailResult>(
        PageRouteBuilder<LoyaltyCardDetailResult>(
          // Zero duration = instant switch, identical to the other tabs.
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (_, __, ___) => LoyaltyCardDetailScreen(
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChipmongMallBloc, ChipmongMallState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isQrTab = state.bottomNavIndex == 1;
        final isPromotionTab = state.bottomNavIndex == 2;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: isQrTab
              ? AppBar(
                  title: const Text(
                    'My QR',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: Colors.white,
                  elevation: 0.5,
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
              : SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        MallTopBar(state: state),
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
                ),
          bottomNavigationBar: SafeArea(
            child: Material(
              color: Colors.white,
              elevation: 10,
              child: MallBottomNav(
                items: _navItems,
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
            ),
          ),
        );
      },
    );
  }
}
