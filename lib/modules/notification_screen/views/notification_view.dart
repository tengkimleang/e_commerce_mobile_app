import 'package:flutter/material.dart';

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
            _NotificationEmptyState(),
            _NotificationEmptyState(),
            _NotificationEmptyState(),
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
      labelStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
      unselectedLabelStyle: const TextStyle(
        fontSize: 24,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 58,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7BDD5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: accent,
                  size: 36,
                ),
              ),
              Positioned(
                right: -10,
                top: -2,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.circle, color: accent, size: 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'No result found',
            style: TextStyle(
              color: Color(0xFFF08AB8),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
