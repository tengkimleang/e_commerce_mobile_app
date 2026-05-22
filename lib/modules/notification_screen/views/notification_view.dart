import 'dart:async';

import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/core/widgets/app_skeleton.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/cubits/order_history_cubit.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/cubits/order_history_state.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/models/order_history_entry.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/views/order_details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F3F3),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
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
            preferredSize: Size.fromHeight(48),
            child: _NotificationTabs(),
          ),
        ),
        body: const TabBarView(
          children: [
            _NotificationOrderTab(),
            _NotificationEmptyState(),
            _NotificationEmptyState(),
          ],
        ),
      ),
    );
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
                        style: const TextStyle(
                          color: Color(0xFFD81B60),
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

class _NotificationTabs extends StatelessWidget {
  const _NotificationTabs();

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC407A);

    return TabBar(
      indicatorColor: accent,
      indicatorWeight: 3,
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: accent,
      unselectedLabelColor: Color(0xFFB8B3BC),
      labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      unselectedLabelStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
      ),
      tabs: const [
        Tab(text: 'Order'),
        Tab(text: 'Promotion'),
        Tab(text: 'Promote Code'),
      ],
    );
  }
}

class _NotificationEmptyState extends StatelessWidget {
  const _NotificationEmptyState();

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC407A);

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
      ),
    );
  }
}
