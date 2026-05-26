import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/core/widgets/app_skeleton.dart';

import 'package:e_commerce_mobile_app/modules/bottom_navigation/views/supermarket_bottom_navigation.dart';
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
        return Icons.receipt_long_rounded;
      case _OrderStatusFilter.active:
        return Icons.timelapse_rounded;
      case _OrderStatusFilter.requesting:
        return Icons.hourglass_top_rounded;
      case _OrderStatusFilter.picking:
        return Icons.shopping_cart_outlined;
      case _OrderStatusFilter.delivering:
        return Icons.delivery_dining_outlined;
      case _OrderStatusFilter.delivered:
        return Icons.check_circle_outline_rounded;
      case _OrderStatusFilter.canceled:
        return Icons.cancel_outlined;
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
  _OrderStatusFilter _selectedFilter = _OrderStatusFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_loadOrders(showSkeleton: true));
      _startAutoRefresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(26),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.09),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: _OrderHistoryHeader(
                selectedFilter: _selectedFilter,
                onFilterPressed: _openStatusFilter,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<OrderHistoryCubit, OrderHistoryState>(
              builder: (context, state) {
                final useFallback =
                    !UserSession.isAuthenticated && state.orders.isEmpty;
                final orders = useFallback
                    ? OrderHistoryCubit.fallbackOrders
                    : state.orders;
                if (_showOrderSkeleton || (state.isLoading && orders.isEmpty)) {
                  return const _OrderHistorySkeletonList();
                }

                if (orders.isEmpty) {
                  return const Center(child: _EmptyOrderState());
                }

                final visibleOrders = _applySelectedFilter(orders);
                if (visibleOrders.isEmpty) {
                  return const Center(child: _EmptyOrderState());
                }

                return RefreshIndicator(
                  onRefresh: () => _loadOrders(showSkeleton: true),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                    itemCount: visibleOrders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
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
      bottomNavigationBar: widget.showBottomNavigation
          ? SupermarketBottomNavigation(
              selectedIndex: 3,
              onTap: (index) => _onBottomNavTap(context, index),
            )
          : null,
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
    required this.selectedFilter,
    required this.onFilterPressed,
  });

  final _OrderStatusFilter selectedFilter;
  final VoidCallback onFilterPressed;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC407A);
    final hasActiveFilter = selectedFilter != _OrderStatusFilter.all;

    return SizedBox(
      width: double.infinity,
      height: 86,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'Ordering',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
              fontSize: 21,
            ),
          ),
          PositionedDirectional(
            end: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    key: const ValueKey('order-history-filter-button'),
                    onPressed: onFilterPressed,
                    tooltip: 'Filter orders',
                    icon: Icon(
                      Icons.filter_alt_outlined,
                      color: accent,
                      size: 26,
                    ),
                  ),
                  if (hasActiveFilter)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderStatusFilterSheet extends StatelessWidget {
  const _OrderStatusFilterSheet({required this.selectedFilter});

  final _OrderStatusFilter selectedFilter;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC407A);
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
                if (selected) Icon(Icons.check, color: accent, size: 20),
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
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => const _OrderCardSkeleton(),
      ),
    );
  }
}

class _OrderCardSkeleton extends StatelessWidget {
  const _OrderCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2F2F2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: SkeletonBox(height: 20, radius: 6)),
              SizedBox(width: 20),
              SkeletonBox(width: 72, height: 22, radius: 14),
            ],
          ),
          SizedBox(height: 12),
          SkeletonBox(width: 150, height: 16, radius: 6),
          SizedBox(height: 12),
          SkeletonBox(width: 128, height: 18, radius: 6),
          SizedBox(height: 12),
          SkeletonBox(width: 174, height: 13, radius: 6),
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
    final order = entry.summary;
    final dateText = DateFormat('d, MMM, y | h:mm a').format(order.orderDate);
    final itemCount = entry.displayItemCount;
    final itemSuffix = itemCount > 1 ? 'Items' : 'Item';

    return Material(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFF2F2F2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      order.shopName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF151515),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _OrderStatusChip(status: entry.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Order Id:#${order.orderNumber}',
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF3A3A3A),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '\$ ${order.total.toStringAsFixed(2)} ',
                      style: const TextStyle(
                        color: Color(0xFFEC407A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: '($itemCount $itemSuffix)',
                      style: const TextStyle(color: Color(0xFF6A6A6A)),
                    ),
                  ],
                ),
                style: const TextStyle(fontSize: 17, height: 1.2),
              ),
              const SizedBox(height: 8),
              Text(
                dateText,
                style: const TextStyle(fontSize: 12, color: Color(0xFF7D7D7D)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderStatusChip extends StatelessWidget {
  const _OrderStatusChip({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final IconData iconData;
    final String label;

    switch (status) {
      case OrderStatus.requesting:
        bgColor = const Color(0xFFEC407A);
        iconData = Icons.hourglass_top_rounded;
        label = 'Request';
        break;
      case OrderStatus.picking:
        bgColor = const Color(0xFFE64980);
        iconData = Icons.shopping_cart_outlined;
        label = 'Picking';
        break;
      case OrderStatus.delivering:
        bgColor = const Color(0xFF1E88E5);
        iconData = Icons.delivery_dining_outlined;
        label = 'Delivering';
        break;
      case OrderStatus.delivered:
        bgColor = const Color(0xFF2BB857);
        iconData = Icons.check;
        label = 'Delivered';
        break;
      case OrderStatus.canceled:
        bgColor = const Color(0xFFFF6200);
        iconData = Icons.close;
        label = 'Cancel';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 13,
            height: 13,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(iconData, size: 9, color: bgColor),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyOrderState extends StatelessWidget {
  const _EmptyOrderState();

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC407A);

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
                color: const Color(0xFFFAD3E3),
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
                decoration: const BoxDecoration(
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
    );
  }
}
