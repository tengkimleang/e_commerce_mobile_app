import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:e_commerce_mobile_app/core/widgets/app_skeleton.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/wholesale_form_view.dart';
import 'package:e_commerce_mobile_app/modules/partner_privilege_screen/blocs/wholesale_history_bloc.dart';
import 'package:e_commerce_mobile_app/modules/partner_privilege_screen/blocs/wholesale_history_event.dart';
import 'package:e_commerce_mobile_app/modules/partner_privilege_screen/blocs/wholesale_history_state.dart';
import 'package:e_commerce_mobile_app/modules/partner_privilege_screen/models/wholesale_request.dart';
import 'package:e_commerce_mobile_app/modules/partner_privilege_screen/repositories/privilege_partner.dart';

class BecomePartnerView extends StatelessWidget {
  const BecomePartnerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WholesaleHistoryBloc(PrivilegePartnerRepository()),
      child: const _BecomePartnerBody(),
    );
  }
}

class _BecomePartnerBody extends StatefulWidget {
  const _BecomePartnerBody();

  @override
  State<_BecomePartnerBody> createState() => _BecomePartnerBodyState();
}

class _BecomePartnerBodyState extends State<_BecomePartnerBody> {
  static const _historySkeletonMinDuration = Duration(milliseconds: 650);

  final ScrollController _scrollCtrl = ScrollController();
  int _historySkeletonSerial = 0;
  DateTime? _historySkeletonStartedAt;
  bool _showHistorySkeleton = true;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHistory();
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Trigger load-more when within 200 px of the bottom.
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<WholesaleHistoryBloc>().add(
        const WholesaleHistoryLoadMore(),
      );
    }
  }

  void _fetchHistory({bool showSkeleton = true}) {
    if (!mounted) return;

    if (showSkeleton) {
      _startHistorySkeleton();
    }

    context.read<WholesaleHistoryBloc>().add(const WholesaleHistoryFetch());
  }

  void _startHistorySkeleton() {
    _historySkeletonSerial++;
    _historySkeletonStartedAt = DateTime.now();
    if (!_showHistorySkeleton) {
      setState(() => _showHistorySkeleton = true);
    }
  }

  Future<void> _hideHistorySkeletonAfterMinimum() async {
    final serial = _historySkeletonSerial;
    final startedAt = _historySkeletonStartedAt;

    if (!_showHistorySkeleton || startedAt == null) return;

    final elapsed = DateTime.now().difference(startedAt);
    final remaining = _historySkeletonMinDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }

    if (!mounted || serial != _historySkeletonSerial) return;
    setState(() => _showHistorySkeleton = false);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wholesale Request'),
        backgroundColor: primary,
      ),
      body: BlocListener<WholesaleHistoryBloc, WholesaleHistoryState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status != WholesaleHistoryStatus.loading,
        listener: (context, state) {
          _hideHistorySkeletonAfterMinimum();
        },
        child: SingleChildScrollView(
          controller: _scrollCtrl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(14),
                ),
                child: Image.network(
                  'https://techpacker.com/blog/content/images/2020/08/Wholesale-Vs-Retail.jpg',
                  width: double.infinity,
                  height: 280,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return const AppSkeleton(
                      child: SkeletonBox(
                        width: double.infinity,
                        height: 280,
                        radius: 0,
                      ),
                    );
                  },
                  errorBuilder: (c, e, s) => Container(
                    width: double.infinity,
                    height: 280,
                    color: Colors.grey[300],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const WholesaleFormView(),
                        ),
                      );
                      // Refresh history after returning from the form
                      if (context.mounted) {
                        _fetchHistory();
                      }
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Drop your Inquiry',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Request History',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Refresh button — resets to page 1
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.refresh, color: primary, size: 22),
                      onPressed: _fetchHistory,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              BlocBuilder<WholesaleHistoryBloc, WholesaleHistoryState>(
                builder: (context, state) {
                  if (_showHistorySkeleton ||
                      state.status == WholesaleHistoryStatus.loading) {
                    return const _WholesaleHistorySkeletonList();
                  }

                  if (state.status == WholesaleHistoryStatus.failure &&
                      state.requests.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 40,
                      ),
                      child: Center(
                        child: Text(
                          state.errorMessage ?? 'Failed to load history',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  if (state.requests.isEmpty) {
                    return _EmptyHistory();
                  }

                  return Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        itemCount: state.requests.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) =>
                            _RequestCard(request: state.requests[i]),
                      ),
                      // Bottom indicator: spinner while loading more, or
                      // "All caught up" label when every page is loaded.
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: state.isLoadingMore
                            ? const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: AppSkeleton(
                                  child: _RequestCardSkeleton(),
                                ),
                              )
                            : !state.hasMore
                            ? Center(
                                child: Text(
                                  'All caught up',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 13,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Loading state ────────────────────────────────────────────────────────────

class _WholesaleHistorySkeletonList extends StatelessWidget {
  const _WholesaleHistorySkeletonList();

  @override
  Widget build(BuildContext context) {
    return const AppSkeleton(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 4, 16, 24),
        child: Column(
          children: [
            _RequestCardSkeleton(),
            SizedBox(height: 12),
            _RequestCardSkeleton(),
            SizedBox(height: 12),
            _RequestCardSkeleton(),
            SizedBox(height: 12),
            _RequestCardSkeleton(),
            SizedBox(height: 12),
            _RequestCardSkeleton(),
          ],
        ),
      ),
    );
  }
}

class _RequestCardSkeleton extends StatelessWidget {
  const _RequestCardSkeleton();

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

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(Icons.receipt_long, color: primary, size: 44),
            ),
            const SizedBox(height: 12),
            Text(
              'No result found',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── History card ─────────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final WholesaleRequest request;
  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final hasImages = request.productImageUrls.isNotEmpty;
    final firstImage = hasImages ? request.productImageUrls.first : null;
    final extraCount = request.productImageUrls.length - 1;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product thumbnail
              if (firstImage != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: firstImage,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 72,
                          height: 72,
                          color: Colors.grey[200],
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 72,
                          height: 72,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    if (extraCount > 0)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+$extraCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              else
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: primary,
                    size: 32,
                  ),
                ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Request #${request.id}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: primary,
                          ),
                        ),
                        Text(
                          request.createdDate,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          request.customerName,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          request.phoneNumber,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    if (request.remark.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        request.remark,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RequestDetailSheet(request: request),
    );
  }
}

// ── Detail bottom sheet ───────────────────────────────────────────────────────

class _RequestDetailSheet extends StatefulWidget {
  final WholesaleRequest request;
  const _RequestDetailSheet({required this.request});

  @override
  State<_RequestDetailSheet> createState() => _RequestDetailSheetState();
}

class _RequestDetailSheetState extends State<_RequestDetailSheet> {
  int _imagePage = 0;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final r = widget.request;
    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Request #${r.id}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    r.createdDate,
                    style: TextStyle(fontSize: 12, color: primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Info rows
            _infoRow(Icons.person_outline, 'Customer', r.customerName),
            const SizedBox(height: 10),
            _infoRow(Icons.phone_outlined, 'Phone', r.phoneNumber),
            if (r.remark.isNotEmpty) ...[
              const SizedBox(height: 10),
              _infoRow(Icons.notes, 'Remark', r.remark),
            ],
            // Product images
            if (r.productImageUrls.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Product Images',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: r.productImageUrls.length,
                      onPageChanged: (i) => setState(() => _imagePage = i),
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: r.productImageUrls[i],
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: Colors.grey[200]),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // dots
                    if (r.productImageUrls.length > 1)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            r.productImageUrls.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: _imagePage == i ? 10 : 6,
                              height: _imagePage == i ? 10 : 6,
                              decoration: BoxDecoration(
                                color: _imagePage == i
                                    ? primary
                                    : Colors.white70,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    final primary = Theme.of(context).colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: primary),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
