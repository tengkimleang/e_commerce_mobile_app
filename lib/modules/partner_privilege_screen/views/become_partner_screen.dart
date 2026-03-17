import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      create: (_) => WholesaleHistoryBloc(PrivilegePartnerRepository())
        ..add(const WholesaleHistoryFetch()),
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
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
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
      context
          .read<WholesaleHistoryBloc>()
          .add(const WholesaleHistoryLoadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wholesale Request'),
        backgroundColor: const Color(0xFFEC407A),
      ),
      body: SingleChildScrollView(
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
                    backgroundColor: const Color(0xFFEC407A),
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
                      context
                          .read<WholesaleHistoryBloc>()
                          .add(const WholesaleHistoryFetch());
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
                    icon: const Icon(Icons.refresh,
                        color: Color(0xFFEC407A), size: 22),
                    onPressed: () => context
                        .read<WholesaleHistoryBloc>()
                        .add(const WholesaleHistoryFetch()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            BlocBuilder<WholesaleHistoryBloc, WholesaleHistoryState>(
              builder: (context, state) {
                if (state.status == WholesaleHistoryStatus.loading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state.status == WholesaleHistoryStatus.failure &&
                    state.requests.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 40),
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
                          horizontal: 16, vertical: 4),
                      itemCount: state.requests.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _RequestCard(
                        request: state.requests[i],
                      ),
                    ),
                    // Bottom indicator: spinner while loading more, or
                    // "All caught up" label when every page is loaded.
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: state.isLoadingMore
                          ? const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Color(0xFFEC407A),
                                ),
                              ),
                            )
                          : !state.hasMore
                              ? Center(
                                  child: Text(
                                    'All caught up',
                                    style: TextStyle(
                                        color: Colors.grey[400], fontSize: 13),
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
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE9EE),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.receipt_long,
                color: Color(0xFFEC407A),
                size: 44,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No result found',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFEC407A),
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
    final hasImages = request.productImageUrls.isNotEmpty;
    final firstImage =
        hasImages ? request.productImageUrls.first : null;
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
                          child: const Icon(Icons.broken_image,
                              color: Colors.grey),
                        ),
                      ),
                    ),
                    if (extraCount > 0)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+$extraCount',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11),
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
                    color: const Color(0xFFFEE9EE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.inventory_2_outlined,
                      color: Color(0xFFEC407A), size: 32),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFFEC407A),
                          ),
                        ),
                        Text(
                          request.createdDate,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 14, color: Colors.grey),
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
                        const Icon(Icons.phone_outlined,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          request.phoneNumber,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey),
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
                            fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  color: Colors.grey, size: 20),
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEC407A),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE9EE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    r.createdDate,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFFEC407A)),
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
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: r.productImageUrls.length,
                      onPageChanged: (i) =>
                          setState(() => _imagePage = i),
                      itemBuilder: (_, i) => Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: r.productImageUrls[i],
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                                color: Colors.grey[200]),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image,
                                  color: Colors.grey, size: 40),
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
                              duration:
                                  const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 3),
                              width: _imagePage == i ? 10 : 6,
                              height: _imagePage == i ? 10 : 6,
                              decoration: BoxDecoration(
                                color: _imagePage == i
                                    ? const Color(0xFFEC407A)
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
                  backgroundColor: const Color(0xFFEC407A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close',
                    style: TextStyle(
                        color: Colors.white, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFFEC407A)),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 14, color: Colors.black87),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600),
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
