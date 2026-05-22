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

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC407A);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
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
              child: SizedBox(
                height: 86,
                child: Center(
                  child: Text(
                    'Ordering',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 21,
                    ),
                  ),
                ),
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

                return RefreshIndicator(
                  onRefresh: () => _loadOrders(showSkeleton: true),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                    itemCount: orders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final entry = orders[index];
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
              SkeletonBox(width: 86, height: 30, radius: 18),
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
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
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
                'Order: # ${order.orderNumber}',
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 15,
            height: 15,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(iconData, size: 11, color: bgColor),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
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
