import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../widget/loyalty_widget/loyalty_models.dart';

class LoyaltyItemExchangedDetailScreen extends StatelessWidget {
  const LoyaltyItemExchangedDetailScreen({super.key, required this.exchange});

  final LoyaltyItemExchange exchange;

  @override
  Widget build(BuildContext context) {
    final product = exchange.product;
    final isUnderReview = exchange.status == 'កំពុងពិនិត្យ';
    final statusColor = isUnderReview
        ? const Color(0xFFF57C00)
        : const Color(0xFF2E7D32);
    final headerText = isUnderReview
        ? 'សំណើប្តូររង្វាន់កំពុងពិនិត្យ'
        : 'ការប្តូររង្វាន់បានជោគជ័យ';
    final headerIcon = isUnderReview
        ? Icons.hourglass_top_rounded
        : Icons.check_circle_rounded;
    final detailRows = <_DetailRowEntry>[
      _DetailRowEntry(label: 'លេខប្រតិបត្តិការ', value: exchange.referenceNo),
      _DetailRowEntry(
        label: 'កាលបរិច្ឆេទប្តូរ',
        value: _formatDateTime(exchange.exchangedAt),
      ),
      _DetailRowEntry(
        label: 'ស្ថានភាព',
        value: exchange.status,
        valueColor: statusColor,
      ),
      _DetailRowEntry(
        label: 'របៀបទទួលរង្វាន់',
        value:
            '${exchange.fulfillmentMethod.label} (${exchange.fulfillmentMethod.khmerLabel})',
      ),
      _DetailRowEntry(label: 'ឈ្មោះអ្នកទទួល', value: exchange.receiverName),
      _DetailRowEntry(label: 'ទូរស័ព្ទអ្នកទទួល', value: exchange.receiverPhone),
      _DetailRowEntry(
        label: 'ពិន្ទុប្រើប្រាស់',
        value: '-${exchange.exchangedPoints} Points',
        valueColor: const Color(0xFFD32F2F),
      ),
      _DetailRowEntry(
        label: 'ពិន្ទុនៅសល់',
        value: '${exchange.remainingPoints} Points',
        valueColor: AppColors.primary,
      ),
      _DetailRowEntry(
        label: 'ប្តូរមុនថ្ងៃ',
        value: _formatDate(exchange.collectBeforeDate),
      ),
    ];

    if (exchange.fulfillmentMethod == LoyaltyFulfillmentMethod.pickup) {
      if (exchange.pickupUserType != null) {
        detailRows.add(
          _DetailRowEntry(
            label: 'ប្រភេទអ្នកទទួល',
            value:
                '${exchange.pickupUserType!.label} (${exchange.pickupUserType!.khmerLabel})',
          ),
        );
      }
      detailRows.add(
        _DetailRowEntry(
          label: 'ទីតាំងទទួលរង្វាន់',
          value: exchange.pickupLocation,
        ),
      );
    } else {
      detailRows.add(
        _DetailRowEntry(
          label: 'អាសយដ្ឋានដឹកជញ្ជូន',
          value: exchange.deliveryAddress ?? '-',
        ),
      );
    }

    if (exchange.representativeName != null &&
        exchange.representativeName!.isNotEmpty) {
      detailRows.add(
        _DetailRowEntry(
          label: 'ឈ្មោះអ្នកតំណាង',
          value: exchange.representativeName!,
        ),
      );
    }

    if (exchange.representativePhone != null &&
        exchange.representativePhone!.isNotEmpty) {
      detailRows.add(
        _DetailRowEntry(
          label: 'ទូរស័ព្ទអ្នកតំណាង',
          value: exchange.representativePhone!,
        ),
      );
    }

    if (exchange.exchangeNote != null && exchange.exchangeNote!.isNotEmpty) {
      detailRows.add(
        _DetailRowEntry(label: 'ចំណាំ', value: exchange.exchangeNote!),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.4,
        title: const Text(
          'Form Detail Item Exchanged',
          style: TextStyle(
            fontFamily: 'Battambang',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(24),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(headerIcon, color: statusColor, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        headerText,
                        style: const TextStyle(
                          fontFamily: 'Battambang',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        width: 82,
                        height: 82,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 82,
                          height: 82,
                          color: Colors.grey[200],
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 82,
                          height: 82,
                          color: AppColors.primary.withAlpha(14),
                          child: Icon(
                            Icons.image_outlined,
                            color: AppColors.primary.withAlpha(90),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.category,
                            style: TextStyle(
                              fontFamily: 'Battambang',
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            product.title,
                            style: const TextStyle(
                              fontFamily: 'Battambang',
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            product.store,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Exchange Details',
                style: TextStyle(
                  fontFamily: 'Battambang',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  children: List.generate(detailRows.length, (index) {
                    final row = detailRows[index];
                    return _DetailRow(
                      label: row.label,
                      value: row.value,
                      valueColor: row.valueColor,
                      isLast: index == detailRows.length - 1,
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 58,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontFamily: 'Battambang',
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('យល់ព្រម'),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final month = _months[dateTime.month - 1];
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$month $day, ${dateTime.year}  $hour:$minute';
  }

  String _formatDate(DateTime date) {
    final month = _months[date.month - 1];
    final day = date.day.toString().padLeft(2, '0');
    return '$month $day, ${date.year}';
  }
}

class _DetailRowEntry {
  const _DetailRowEntry({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isLast;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : const Color(0xFFE8E8E8),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Battambang',
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Battambang',
                fontSize: 14,
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _months = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
