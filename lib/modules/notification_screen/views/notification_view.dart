import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/common/di.dart';
import 'package:e_commerce_mobile_app/core/data/categories_repository.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/core/widgets/app_skeleton.dart';
import 'package:e_commerce_mobile_app/modules/notification_screen/cubits/notification_promotions_cubit.dart';
import 'package:e_commerce_mobile_app/modules/notification_screen/cubits/notification_promotions_state.dart';
import 'package:e_commerce_mobile_app/modules/notification_screen/models/notification_promotion_entry.dart';
import 'package:e_commerce_mobile_app/modules/notification_screen/repositories/notification_promotions_repository.dart';
import 'package:e_commerce_mobile_app/modules/notification_screen/views/notification_promotion_content_detail_view.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/cubits/order_history_cubit.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/cubits/order_history_state.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/models/order_history_entry.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/views/order_details_view.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/product_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key, this.promotionsRepository});

  final NotificationPromotionsRepository? promotionsRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationPromotionsCubit>(
      create: (_) => NotificationPromotionsCubit(
        repository: promotionsRepository ?? _resolvePromotionsRepository(),
      ),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: const Color(0xFF1D1B24),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new, size: 22),
            ),
            title: const Text(
              'Notification',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D1B24),
              ),
            ),
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(44),
              child: _NotificationTabs(),
            ),
          ),
          body: const TabBarView(
            children: [
              _NotificationOrderTab(),
              _NotificationPromotionTab(),
              _NotificationEmptyState(),
            ],
          ),
        ),
      ),
    );
  }

  NotificationPromotionsRepository _resolvePromotionsRepository() {
    if (di.isRegistered<NotificationPromotionsRepository>()) {
      return di<NotificationPromotionsRepository>();
    }
    return HttpNotificationPromotionsRepository(di<Dio>());
  }
}

class _NotificationOrderTab extends StatefulWidget {
  const _NotificationOrderTab();

  @override
  State<_NotificationOrderTab> createState() => _NotificationOrderTabState();
}

class _NotificationOrderTabState extends State<_NotificationOrderTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !UserSession.isAuthenticated) return;
      unawaited(context.read<OrderHistoryCubit>().loadOrders());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderHistoryCubit, OrderHistoryState>(
      builder: (context, state) {
        final useFallback =
            !UserSession.isAuthenticated && state.orders.isEmpty;
        final orders = useFallback
            ? OrderHistoryCubit.fallbackOrders
            : state.orders;

        if (state.isLoading && orders.isEmpty) {
          return const _NotificationOrderSkeletonList();
        }

        if (orders.isEmpty) {
          return const _NotificationEmptyState();
        }

        return Container(
          color: Colors.white,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(38, 34, 16, 24),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const Divider(
              height: 28,
              thickness: 0.7,
              color: Color(0xFFE7E2E5),
            ),
            itemBuilder: (context, index) {
              final entry = orders[index];
              return _NotificationOrderRow(
                entry: entry,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => OrderDetailsView(
                        entry: entry,
                        showCancelAction: false,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _NotificationOrderRow extends StatelessWidget {
  const _NotificationOrderRow({required this.entry, required this.onTap});

  final OrderHistoryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final order = entry.summary;
    final dateText = DateFormat('d MMM').format(order.orderDate);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Your order '),
                      TextSpan(
                        text: '#${order.orderNumber}',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(text: ' has submitted.'),
                    ],
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.35,
                    color: Color(0xFF28232B),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  dateText,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB8B3BC),
                    fontWeight: FontWeight.w400,
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

class _NotificationOrderSkeletonList extends StatelessWidget {
  const _NotificationOrderSkeletonList();

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(38, 42, 16, 24),
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(height: 24),
        itemBuilder: (_, _) => const Row(
          children: [
            Expanded(child: SkeletonBox(height: 20, radius: 6)),
            SizedBox(width: 36),
            SkeletonBox(width: 48, height: 16, radius: 6),
          ],
        ),
      ),
    );
  }
}

class _NotificationPromotionTab extends StatefulWidget {
  const _NotificationPromotionTab();

  @override
  State<_NotificationPromotionTab> createState() =>
      _NotificationPromotionTabState();
}

class _NotificationPromotionTabState extends State<_NotificationPromotionTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        context.read<NotificationPromotionsCubit>().loadPromotions(
          shopId: UserSession.selectedShopId,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      NotificationPromotionsCubit,
      NotificationPromotionsState
    >(
      builder: (context, state) {
        if (state.status == NotificationPromotionsStatus.initial ||
            state.isLoading) {
          return const _NotificationPromotionSkeletonList();
        }

        if (state.isFailure) {
          return _NotificationPromotionErrorState(
            onRetry: () => context
                .read<NotificationPromotionsCubit>()
                .loadPromotions(shopId: UserSession.selectedShopId),
          );
        }

        if (state.items.isEmpty) {
          return const _NotificationEmptyState();
        }

        return Container(
          color: Colors.white,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
            itemCount: state.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final entry = state.items[index];
              return _NotificationPromotionCard(
                entry: entry,
                onTap: () {
                  unawaited(_openPromotion(context, entry));
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openPromotion(
    BuildContext context,
    NotificationPromotionEntry entry,
  ) async {
    if (entry.isCategory && entry.categoryId != null) {
      final categoryTitle = await _resolveCategoryTitle(entry.categoryId!);
      if (!context.mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ProductListView(
            title: categoryTitle ?? entry.title,
            categoryImageUrl: entry.imageUrl,
            products: const [],
            categoryId: entry.categoryId,
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotificationPromotionContentDetailView(entry: entry),
      ),
    );
  }

  Future<String?> _resolveCategoryTitle(int categoryId) async {
    if (!di.isRegistered<CategoriesRepository>()) return null;

    try {
      final categories = await di<CategoriesRepository>().fetchCategories();
      for (final category in categories) {
        if (category.id != categoryId) continue;

        final title = category.displayTitle.trim();
        return title.isEmpty ? null : title;
      }
    } catch (_) {
      return null;
    }

    return null;
  }
}

class _NotificationPromotionCard extends StatelessWidget {
  const _NotificationPromotionCard({required this.entry, required this.onTap});

  final NotificationPromotionEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: entry.imageUrl,
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey.shade200),
                  errorWidget: (context, url, error) => Container(
                    width: 96,
                    height: 96,
                    color: primary.withValues(alpha: 0.20),
                    child: Icon(Icons.image_outlined, color: primary),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1D1B24),
                        fontSize: 18,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      entry.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF5C565F),
                        fontSize: 14,
                        height: 1.45,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationPromotionSkeletonList extends StatelessWidget {
  const _NotificationPromotionSkeletonList();

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: ListView.separated(
        key: const ValueKey('notification-promotion-skeleton'),
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
        itemCount: 5,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (_, _) => Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              SkeletonBox(width: 96, height: 96, radius: 10),
              SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(height: 20, radius: 6),
                    SizedBox(height: 12),
                    SkeletonBox(height: 14, radius: 6),
                    SizedBox(height: 8),
                    SkeletonBox(width: 140, height: 14, radius: 6),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationPromotionErrorState extends StatelessWidget {
  const _NotificationPromotionErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey.shade500),
          const SizedBox(height: 12),
          const Text(
            'Failed to load promotions',
            style: TextStyle(color: Color(0xFF6A6A6A), fontSize: 15),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: TextStyle(color: accent, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTabs extends StatelessWidget {
  const _NotificationTabs();

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return ColoredBox(
      color: Colors.white,
      child: SizedBox(
        height: 44,
        child: TabBar(
          indicatorColor: accent,
          indicatorWeight: 2,
          indicatorSize: TabBarIndicatorSize.tab,
          labelPadding: EdgeInsets.zero,
          dividerColor: const Color(0xFFE9E6EB),
          labelColor: accent,
          unselectedLabelColor: const Color(0xFFC2BDC6),
          labelStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1.1,
            letterSpacing: 0,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            height: 1.1,
            letterSpacing: 0,
          ),
          tabs: const [
            Tab(child: _NotificationTabLabel('Order')),
            Tab(child: _NotificationTabLabel('Promotion')),
            Tab(child: _NotificationTabLabel('Promote Code')),
          ],
        ),
      ),
    );
  }
}

class _NotificationTabLabel extends StatelessWidget {
  const _NotificationTabLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(text, maxLines: 1, softWrap: false),
      ),
    );
  }
}

class _NotificationEmptyState extends StatelessWidget {
  const _NotificationEmptyState();

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 46,
                  color: accent.withValues(alpha: 0.95),
                ),
              ),
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.check, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'No result found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: accent.withValues(alpha: 0.65),
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
