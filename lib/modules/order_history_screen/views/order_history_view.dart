import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/core/theme/app_theme.dart';
import 'package:e_commerce_mobile_app/core/widgets/app_skeleton.dart';
import 'package:e_commerce_mobile_app/l10n/generated/app_localizations.dart';

import 'package:e_commerce_mobile_app/modules/bottom_navigation/views/supermarket_bottom_navigation.dart';
import 'package:e_commerce_mobile_app/modules/notification_screen/views/notification_view.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/cubits/order_history_cubit.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/cubits/order_history_state.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/models/order_history_entry.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/views/order_details_view.dart';
import 'package:e_commerce_mobile_app/modules/order_track/views/order_track_screen.dart';
import 'package:e_commerce_mobile_app/modules/promotion_screen/views/promotion_view.dart';
import 'package:e_commerce_mobile_app/modules/qr_code_screen/views/qr_code_view.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/views/user_info_view.dart';

enum _OrderStatusFilter {
  all,
  active,
  requesting,
  picking,
  delivering,
  delivered,
  canceled,
}

extension _OrderStatusFilterX on _OrderStatusFilter {
  String get label {
    switch (this) {
      case _OrderStatusFilter.all:
        return 'All';
      case _OrderStatusFilter.active:
        return 'Active';
      case _OrderStatusFilter.requesting:
        return 'Request';
      case _OrderStatusFilter.picking:
        return 'Picking';
      case _OrderStatusFilter.delivering:
        return 'Delivering';
      case _OrderStatusFilter.delivered:
        return 'Delivered';
      case _OrderStatusFilter.canceled:
        return 'Cancel';
    }
  }

  IconData get icon {
    switch (this) {
      case _OrderStatusFilter.all:
        return CupertinoIcons.doc_text;
      case _OrderStatusFilter.active:
        return CupertinoIcons.clock;
      case _OrderStatusFilter.requesting:
        return CupertinoIcons.clock;
      case _OrderStatusFilter.picking:
        return CupertinoIcons.cart;
      case _OrderStatusFilter.delivering:
        return CupertinoIcons.cube_box;
      case _OrderStatusFilter.delivered:
        return CupertinoIcons.checkmark_circle;
      case _OrderStatusFilter.canceled:
        return CupertinoIcons.xmark_circle;
    }
  }

  bool matches(OrderHistoryEntry entry) {
    switch (this) {
      case _OrderStatusFilter.all:
        return true;
      case _OrderStatusFilter.active:
        return entry.status == OrderStatus.requesting ||
            entry.status == OrderStatus.picking ||
            entry.status == OrderStatus.delivering;
      case _OrderStatusFilter.requesting:
        return entry.status == OrderStatus.requesting;
      case _OrderStatusFilter.picking:
        return entry.status == OrderStatus.picking;
      case _OrderStatusFilter.delivering:
        return entry.status == OrderStatus.delivering;
      case _OrderStatusFilter.delivered:
        return entry.status == OrderStatus.delivered;
      case _OrderStatusFilter.canceled:
        return entry.status == OrderStatus.canceled;
    }
  }
}

class OrderHistoryView extends StatefulWidget {
  final bool showBottomNavigation;

  const OrderHistoryView({super.key, this.showBottomNavigation = true});

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  static const _orderSkeletonMinDuration = Duration(milliseconds: 650);

  Timer? _refreshTimer;
  int _orderSkeletonSerial = 0;
  DateTime? _orderSkeletonStartedAt;
  bool _showOrderSkeleton = false;
  late final TextEditingController _searchController;
  _OrderStatusFilter _selectedFilter = _OrderStatusFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_loadOrders(showSkeleton: true));
      _startAutoRefresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders({bool showSkeleton = true}) async {
    if (!mounted || !UserSession.isAuthenticated) return;

    final serial = ++_orderSkeletonSerial;
    if (showSkeleton) {
      setState(() {
        _showOrderSkeleton = true;
        _orderSkeletonStartedAt = DateTime.now();
      });
    }

    await context.read<OrderHistoryCubit>().loadOrders();
    if (!mounted || serial != _orderSkeletonSerial || !showSkeleton) return;

    final startedAt = _orderSkeletonStartedAt;
    if (startedAt != null) {
      final elapsed = DateTime.now().difference(startedAt);
      final remaining = _orderSkeletonMinDuration - elapsed;
      if (remaining > Duration.zero) {
        await Future<void>.delayed(remaining);
      }
    }

    if (!mounted || serial != _orderSkeletonSerial) return;
    setState(() => _showOrderSkeleton = false);
  }

  void _startAutoRefresh() {
    if (!UserSession.isAuthenticated) return;
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      unawaited(_loadOrders(showSkeleton: false));
    });
  }

  Future<void> _openStatusFilter() async {
    final selected = await showModalBottomSheet<_OrderStatusFilter>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _OrderStatusFilterSheet(selectedFilter: _selectedFilter),
    );

    if (!mounted || selected == null || selected == _selectedFilter) return;
    setState(() => _selectedFilter = selected);
  }

  List<OrderHistoryEntry> _applySelectedFilter(List<OrderHistoryEntry> orders) {
    if (_selectedFilter == _OrderStatusFilter.all) return orders;
    return orders.where(_selectedFilter.matches).toList(growable: false);
  }

  List<OrderHistoryEntry> _applyVisibleFilters(List<OrderHistoryEntry> orders) {
    final statusFiltered = _applySelectedFilter(orders);
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return statusFiltered;

    return statusFiltered
        .where((entry) => _entryMatchesSearch(entry, query))
        .toList(growable: false);
  }

  bool _entryMatchesSearch(OrderHistoryEntry entry, String query) {
    final order = entry.summary;
    final amountText = order.total.toStringAsFixed(2);
    final dateText = DateFormat('d MMM yyyy').format(order.orderDate);
    final timeText = DateFormat('h:mm a').format(order.orderDate);
    final searchable = [
      order.shopName,
      order.orderNumber,
      'order ${order.orderNumber}',
      entry.statusTitle,
      _statusDisplayLabel(entry.status),
      dateText,
      timeText,
      amountText,
      '\$$amountText',
      '${entry.displayItemCount}',
    ].join(' ').toLowerCase();

    return searchable.contains(query);
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  void _openNotifications() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NotificationView()));
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SupermarketAdaptiveScaffold(
      selectedIndex: 3,
      onTap: (index) => _onBottomNavTap(context, index),
      showNavigation: widget.showBottomNavigation,
      backgroundColor: const Color(0xFFFCF8FA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _OrderHistoryHeader(
              searchController: _searchController,
              selectedFilter: _selectedFilter,
              onSearchChanged: _onSearchChanged,
              onFilterPressed: _openStatusFilter,
              onNotificationPressed: _openNotifications,
            ),
            Expanded(
              child: BlocBuilder<OrderHistoryCubit, OrderHistoryState>(
                builder: (context, state) {
                  final useFallback =
                      !UserSession.isAuthenticated && state.orders.isEmpty;
                  final orders = useFallback
                      ? OrderHistoryCubit.fallbackOrders
                      : state.orders;
                  if (_showOrderSkeleton ||
                      (state.isLoading && orders.isEmpty)) {
                    return const _OrderHistorySkeletonList();
                  }

                  if (orders.isEmpty) {
                    return const Center(child: _EmptyOrderState());
                  }

                  final visibleOrders = _applyVisibleFilters(orders);
                  if (visibleOrders.isEmpty) {
                    return const Center(child: _EmptyOrderState());
                  }

                  return RefreshIndicator(
                    color: primary,
                    onRefresh: () => _loadOrders(showSkeleton: true),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
                      itemCount: visibleOrders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (_, index) {
                        final entry = visibleOrders[index];
                        return _OrderCard(
                          entry: entry,
                          onTap: () {
                            Navigator.of(
                              context,
                            ).push(_buildOrderTapRoute(entry));
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onBottomNavTap(BuildContext context, int index) {
    if (index == 3) return;

    if (index == 0) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      return;
    }

    if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PromotionView()),
      );
      return;
    }

    if (index == 2) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const QrCodeView()));
      return;
    }

    if (index == 4) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const UserInfoView()),
      );
    }
  }

  Route<void> _buildOrderTapRoute(OrderHistoryEntry entry) {
    if (_isActiveTrackStatus(entry)) {
      return MaterialPageRoute<void>(
        builder: (_) => OrderTrackScreen(order: entry.summary),
      );
    }
    return MaterialPageRoute<void>(
      builder: (_) => OrderDetailsView(entry: entry),
    );
  }

  bool _isActiveTrackStatus(OrderHistoryEntry entry) {
    final summary = entry.summary;
    final normalized =
        (summary.trackStep.trim().isNotEmpty
                ? summary.trackStep
                : summary.statusCode)
            .trim()
            .toUpperCase();

    if (normalized.isEmpty) {
      return entry.isRequesting;
    }
    return normalized == 'REQUESTING' ||
        normalized == 'PICKING' ||
        normalized == 'DELIVERING';
  }
}

class _OrderHistoryHeader extends StatelessWidget {
  const _OrderHistoryHeader({
    required this.searchController,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onFilterPressed,
    required this.onNotificationPressed,
  });

  final TextEditingController searchController;
  final _OrderStatusFilter selectedFilter;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterPressed;
  final VoidCallback onNotificationPressed;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final hasActiveFilter = selectedFilter != _OrderStatusFilter.all;

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Orders',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: const Color(0xFF15131A),
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your recent purchase history',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF7A7780),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _NotificationButton(onPressed: onNotificationPressed),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: CupertinoSearchTextField(
                      key: const ValueKey('order-history-search-field'),
                      controller: searchController,
                      onChanged: onSearchChanged,
                      placeholder: 'Search orders...',
                      cursorColor: accent,
                      itemColor: accent,
                      itemSize: 23,
                      prefixInsets: const EdgeInsetsDirectional.fromSTEB(
                        16,
                        13,
                        8,
                        13,
                      ),
                      suffixInsets: const EdgeInsetsDirectional.fromSTEB(
                        0,
                        13,
                        14,
                        13,
                      ),
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        4,
                        14,
                        12,
                        12,
                      ),
                      style: AppTypography.input.copyWith(
                        color: Color(0xFF24212A),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      placeholderStyle: const TextStyle(
                        color: Color(0xFF8B8790),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.07),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                _FilterButton(
                  hasActiveFilter: hasActiveFilter,
                  onPressed: onFilterPressed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: 58,
      height: 58,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 5,
        shadowColor: Colors.black26,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                CupertinoIcons.bell,
                color: Color(0xFF56515A),
                size: 27,
              ),
              Positioned(
                right: 16,
                top: 14,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
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

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.hasActiveFilter, required this.onPressed});

  final bool hasActiveFilter;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: 52,
      height: 52,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        elevation: 5,
        shadowColor: Colors.black.withValues(alpha: 0.13),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: const ValueKey('order-history-filter-button'),
          onTap: onPressed,
          borderRadius: BorderRadius.circular(17),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(CupertinoIcons.slider_horizontal_3, color: accent, size: 22),
              if (hasActiveFilter)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
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

class _OrderStatusFilterSheet extends StatelessWidget {
  const _OrderStatusFilterSheet({required this.selectedFilter});

  final _OrderStatusFilter selectedFilter;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.86;

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Filter by status',
                  style: TextStyle(
                    color: Color(0xFF1D1B24),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ..._OrderStatusFilter.values.map((filter) {
                  final selected = filter == selectedFilter;
                  return _OrderStatusFilterTile(
                    key: ValueKey('order-history-filter-${filter.name}'),
                    filter: filter,
                    selected: selected,
                    accent: accent,
                    onTap: () => Navigator.of(context).pop(filter),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderStatusFilterTile extends StatelessWidget {
  const _OrderStatusFilterTile({
    super.key,
    required this.filter,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final _OrderStatusFilter filter;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selectedBg = accent.withValues(alpha: 0.10);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: selected ? selectedBg : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  filter.icon,
                  color: selected ? accent : const Color(0xFF6A6A6A),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    filter.label,
                    style: TextStyle(
                      color: selected ? accent : const Color(0xFF1D1B24),
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (selected)
                  Icon(CupertinoIcons.checkmark, color: accent, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderHistorySkeletonList extends StatelessWidget {
  const _OrderHistorySkeletonList();

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: ListView.separated(
        key: const ValueKey('order-history-list-skeleton'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
        itemCount: 5,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (_, _) => const _OrderCardSkeleton(),
      ),
    );
  }
}

class _OrderCardSkeleton extends StatelessWidget {
  const _OrderCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF4EEF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 62, height: 62, radius: 16),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: SkeletonBox(height: 18, radius: 6)),
                    SizedBox(width: 18),
                    SkeletonBox(width: 82, height: 26, radius: 14),
                  ],
                ),
                SizedBox(height: 10),
                SkeletonBox(width: 116, height: 13, radius: 6),
                SizedBox(height: 12),
                SkeletonBox(width: 128, height: 17, radius: 6),
                SizedBox(height: 14),
                SkeletonBox(width: 172, height: 13, radius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.entry, required this.onTap});

  final OrderHistoryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final order = entry.summary;
    final dateText = DateFormat('d MMM yyyy').format(order.orderDate);
    final timeText = DateFormat('h:mm a').format(order.orderDate);
    final itemCount = entry.displayItemCount;
    final itemSuffix = itemCount > 1 ? 'items' : 'item';

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFF4EEF2)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OrderIconTile(icon: _orderIconFor(order.shopName)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              order.shopName.toUpperCase(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                height: 1.22,
                                color: Color(0xFF17141D),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _OrderStatusChip(status: entry.status),
                        ],
                      ),
                      const SizedBox(height: 7),
                      _OrderMetaRow(
                        icon: CupertinoIcons.doc_text,
                        text: 'Order #${order.orderNumber}',
                      ),
                      const SizedBox(height: 11),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '\$${order.total.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(
                              text: '  •  $itemCount $itemSuffix',
                              style: const TextStyle(
                                color: Color(0xFF6F6A73),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 17, height: 1.2),
                      ),
                      const SizedBox(height: 13),
                      _OrderDateTimeRow(dateText: dateText, timeText: timeText),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _orderIconFor(String shopName) {
    final normalized = shopName.toLowerCase();
    if (normalized.contains('supermarket')) {
      return CupertinoIcons.cart;
    }
    return CupertinoIcons.bag;
  }
}

class _OrderIconTile extends StatelessWidget {
  const _OrderIconTile({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: accent, size: 24),
    );
  }
}

class _OrderMetaRow extends StatelessWidget {
  const _OrderMetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF8A858E), size: 14),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF79747E),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderDateTimeRow extends StatelessWidget {
  const _OrderDateTimeRow({required this.dateText, required this.timeText});

  final String dateText;
  final String timeText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(CupertinoIcons.calendar, color: Color(0xFF8A858E), size: 14),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            dateText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF706B75),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(width: 1, height: 14, color: const Color(0xFFD8D4DA)),
        const SizedBox(width: 10),
        const Icon(CupertinoIcons.clock, color: Color(0xFF8A858E), size: 14),
        const SizedBox(width: 7),
        Text(
          timeText,
          style: const TextStyle(
            color: Color(0xFF706B75),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

String _statusDisplayLabel(OrderStatus status) {
  switch (status) {
    case OrderStatus.delivered:
      return 'Delivered';
    case OrderStatus.canceled:
      return 'Canceled';
    case OrderStatus.requesting:
    case OrderStatus.picking:
    case OrderStatus.delivering:
      return 'Processing';
  }
}

class _OrderStatusChip extends StatelessWidget {
  const _OrderStatusChip({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color fgColor;
    final Widget indicator;
    final label = _statusDisplayLabel(status);

    switch (status) {
      case OrderStatus.delivered:
        bgColor = const Color(0xFFEAF9F0);
        fgColor = const Color(0xFF20A95D);
        indicator = Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF20A95D),
            shape: BoxShape.circle,
          ),
        );
        break;
      case OrderStatus.canceled:
        bgColor = const Color(0xFFFFEEE8);
        fgColor = const Color(0xFFFF6200);
        indicator = const Icon(CupertinoIcons.xmark_circle_fill, size: 12);
        break;
      case OrderStatus.requesting:
      case OrderStatus.picking:
      case OrderStatus.delivering:
        bgColor = const Color(0xFFFFF7E7);
        fgColor = const Color(0xFFD99A24);
        indicator = const Icon(CupertinoIcons.clock, size: 12);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconTheme(
        data: IconThemeData(color: fgColor),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            indicator,
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: fgColor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyOrderState extends StatelessWidget {
  const _EmptyOrderState();

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);

    return Column(
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
                CupertinoIcons.doc_text,
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
                child: const Icon(
                  CupertinoIcons.checkmark,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          l10n?.noResultFound ?? 'No result found',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: accent.withValues(alpha: 0.65),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
