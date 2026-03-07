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
