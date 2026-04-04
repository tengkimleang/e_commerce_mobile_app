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
    final imageUrl = product.imageUrl.trim();
    final hasValidImage = _isValidNetworkUrl(imageUrl);
    final statusMeta = _resolveStatusMeta(exchange.status);
    final statusColor = statusMeta.color;
    final headerText = statusMeta.headerText;
    final headerIcon = statusMeta.icon;
    final detailRows = <_DetailRowEntry>[
      _DetailRowEntry(label: 'Reference No', value: exchange.referenceNo),
      _DetailRowEntry(
        label: 'Exchange Date',
        value: _formatDateTime(exchange.exchangedAt),
      ),
      _DetailRowEntry(
        label: 'Status',
        value: exchange.status,
        valueColor: statusColor,
      ),
      _DetailRowEntry(
        label: 'Fulfillment Method',
        value: exchange.fulfillmentMethod.label,
      ),
      _DetailRowEntry(label: 'Receiver Name', value: exchange.receiverName),
      _DetailRowEntry(label: 'Receiver Phone', value: exchange.receiverPhone),
      _DetailRowEntry(
        label: 'Points Used',
        value: '-${exchange.exchangedPoints} Points',
        valueColor: const Color(0xFFD32F2F),
      ),
      _DetailRowEntry(
        label: 'Remaining Points',
        value: '${exchange.remainingPoints} Points',
        valueColor: AppColors.primary,
      ),
      _DetailRowEntry(
        label: 'Collect Before',
        value: _formatDate(exchange.collectBeforeDate),
      ),
    ];

    if (exchange.fulfillmentMethod == LoyaltyFulfillmentMethod.pickup) {
      if (exchange.pickupUserType != null) {
        detailRows.add(
          _DetailRowEntry(
            label: 'Pickup User Type',
            value: exchange.pickupUserType!.label,
          ),
        );
      }
      detailRows.add(
        _DetailRowEntry(
          label: 'Pickup Location',
          value: exchange.pickupLocation,
        ),
      );
    } else {
      detailRows.add(
        _DetailRowEntry(
          label: 'Delivery Address',
          value: exchange.deliveryAddress ?? '-',
        ),
      );
    }

    if (exchange.representativeName != null &&
        exchange.representativeName!.isNotEmpty) {
      detailRows.add(
        _DetailRowEntry(
          label: 'Representative Name',
          value: exchange.representativeName!,
        ),
      );
    }

    if (exchange.representativePhone != null &&
        exchange.representativePhone!.isNotEmpty) {
      detailRows.add(
        _DetailRowEntry(
          label: 'Representative Phone',
          value: exchange.representativePhone!,
        ),
      );
    }

    if (exchange.exchangeNote != null && exchange.exchangeNote!.isNotEmpty) {
      detailRows.add(
        _DetailRowEntry(label: 'Note', value: exchange.exchangeNote!),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.4,
        title: const Text(
          'Exchange Detail',
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
                      child: hasValidImage
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: 82,
                              height: 82,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 82,
                                height: 82,
                                color: Colors.grey[200],
                              ),
                              errorWidget: (context, url, error) =>
                                  _buildImageFallback(),
                            )
                          : _buildImageFallback(),
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
              child: const Text('OK'),
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

  _ExchangeStatusMeta _resolveStatusMeta(String status) {
    final normalized = status.trim().toLowerCase();
    final isPending =
        normalized.contains('pending') || normalized.contains('review');
    if (isPending) {
      return const _ExchangeStatusMeta(
        color: Color(0xFFF57C00),
        icon: Icons.hourglass_top_rounded,
        headerText: 'Redemption request is under review',
      );
    }

    final isRejected = normalized.contains('reject');
    if (isRejected) {
      return const _ExchangeStatusMeta(
        color: Color(0xFFD32F2F),
        icon: Icons.cancel_rounded,
        headerText: 'Redemption request was rejected',
      );
    }

    final isCancelled = normalized.contains('cancel');
    if (isCancelled) {
      return const _ExchangeStatusMeta(
        color: Color(0xFF757575),
        icon: Icons.remove_circle_rounded,
        headerText: 'Redemption request was cancelled',
      );
    }

    return const _ExchangeStatusMeta(
      color: Color(0xFF2E7D32),
      icon: Icons.check_circle_rounded,
      headerText: 'Redemption completed successfully',
    );
  }

  Widget _buildImageFallback() {
    return Container(
      width: 82,
      height: 82,
      color: AppColors.primary.withAlpha(14),
      child: Icon(
        Icons.image_outlined,
        color: AppColors.primary.withAlpha(90),
      ),
    );
  }

  bool _isValidNetworkUrl(String value) {
    if (value.isEmpty) return false;
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    return (uri.scheme == 'http' || uri.scheme == 'https') &&
        (uri.host.isNotEmpty);
  }
}

class _ExchangeStatusMeta {
  final Color color;
  final IconData icon;
  final String headerText;

  const _ExchangeStatusMeta({
    required this.color,
    required this.icon,
    required this.headerText,
  });
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
