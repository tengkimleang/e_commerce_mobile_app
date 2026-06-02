import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_mobile_app/modules/notification_screen/models/notification_promotion_entry.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationPromotionContentDetailView extends StatelessWidget {
  const NotificationPromotionContentDetailView({
    super.key,
    required this.entry,
  });

  final NotificationPromotionEntry entry;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.12,
                    child: CachedNetworkImage(
                      imageUrl: entry.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey.shade200),
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFFFAD3E3),
                        child: Icon(
                          Icons.image_outlined,
                          color: primary,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: topPadding + 12,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.86),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: const TextStyle(
                      color: Color(0xFF1D1B24),
                      fontSize: 25,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (entry.startsAt != null || entry.endsAt != null) ...[
                    const SizedBox(height: 16),
                    _PromotionDateRow(
                      startsAt: entry.startsAt,
                      endsAt: entry.endsAt,
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    entry.description,
                    style: const TextStyle(
                      color: Color(0xFF5C565F),
                      fontSize: 18,
                      height: 1.55,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromotionDateRow extends StatelessWidget {
  const _PromotionDateRow({required this.startsAt, required this.endsAt});

  final DateTime? startsAt;
  final DateTime? endsAt;

  @override
  Widget build(BuildContext context) {
    final startText = _formatDate(startsAt);
    final endText = _formatDate(endsAt);

    return Row(
      children: [
        if (startText.isNotEmpty)
          Expanded(
            child: Text(
              startText,
              style: const TextStyle(fontSize: 14, color: Color(0xFF5C565F)),
            ),
          ),
        if (endText.isNotEmpty)
          Expanded(
            child: Text(
              endText,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, color: Color(0xFF5C565F)),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('d, MMM, y | h:mm a').format(date);
  }
}
