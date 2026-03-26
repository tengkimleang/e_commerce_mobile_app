import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../widget/loyalty_widget/loyalty_models.dart';

class LoyaltyRewardDetailScreen extends StatefulWidget {
  const LoyaltyRewardDetailScreen({
    super.key,
    required this.product,
    required this.availablePoints,
  });

  final LoyaltyProduct product;
  final int availablePoints;

  @override
  State<LoyaltyRewardDetailScreen> createState() =>
      _LoyaltyRewardDetailScreenState();
}

class _LoyaltyRewardDetailScreenState extends State<LoyaltyRewardDetailScreen> {
  int _selectedTab = 0;
  OverlayEntry? _errorBannerEntry;

  static const _tabs = ['ព័ត៌មានលម្អិត', 'គោលការណ៍ និង លក្ខខណ្ឌ'];

  @override
  void dispose() {
    _errorBannerEntry?.remove();
    _errorBannerEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.4,
        title: const Text(
          'ព័ត៌មានលម្អិតរង្វាន់',
          style: TextStyle(
            fontFamily: 'Battambang',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share action is coming soon')),
              );
            },
            icon: const Icon(Icons.ios_share_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RewardSummaryCard(product: product),
                    const SizedBox(height: 10),
                    _buildTabs(),
                    _buildTabContent(product),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _openRedeemConfirmationSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontFamily: 'Battambang',
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text('ប្តូររង្វាន់'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openRedeemConfirmationSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(130),
      builder: (sheetContext) {
        return _RedeemConfirmationSheet(
          product: widget.product,
          onConfirm: () {
            Navigator.of(sheetContext).pop();
            _handleRedeemConfirm();
          },
        );
      },
    );
  }

  void _handleRedeemConfirm() {
    final hasEnoughPoints = widget.availablePoints >= widget.product.points;
    if (!hasEnoughPoints) {
      _showTopErrorBanner();
      return;
    }

    final now = DateTime.now();
    final exchangedPoints = widget.product.points;
    final exchange = LoyaltyItemExchange(
      product: widget.product,
      exchangedAt: now,
      exchangedPoints: exchangedPoints,
      remainingPoints: widget.availablePoints - exchangedPoints,
      referenceNo: _buildExchangeReference(now),
      status: 'សម្រេចជោគជ័យ',
      pickupLocation: 'Information Counter, ផ្សារទំនើប Chip Mong 271 Mega Mall',
      collectBeforeDate: now.add(const Duration(days: 7)),
    );
    Navigator.of(context).pop(exchange);
  }

  String _buildExchangeReference(DateTime timestamp) {
    final brandSeed = widget.product.brandName.toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );
    final shortBrand = brandSeed.isEmpty
        ? 'CMR'
        : (brandSeed.length > 3 ? brandSeed.substring(0, 3) : brandSeed);
    final datePart =
        '${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}';
    final timePart =
        '${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}${timestamp.second.toString().padLeft(2, '0')}';
    return 'CMR-$datePart-$shortBrand$timePart';
  }

  void _showTopErrorBanner() {
    _errorBannerEntry?.remove();
    _errorBannerEntry = null;

    final overlay = Overlay.of(context);
    _errorBannerEntry = OverlayEntry(
      builder: (overlayContext) {
        final topInset = MediaQuery.of(overlayContext).padding.top;
        return Positioned(
          left: 12,
          right: 12,
          top: topInset + 12,
          child: const _RedeemErrorBanner(),
        );
      },
    );

    overlay.insert(_errorBannerEntry!);

    Future<void>.delayed(const Duration(seconds: 3), () {
      _errorBannerEntry?.remove();
      _errorBannerEntry = null;
    });
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? AppColors.primary : Colors.grey[300]!,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                ),
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    fontFamily: 'Battambang',
                    fontSize: 17,
                    color: isSelected ? AppColors.primary : Colors.grey[700],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent(LoyaltyProduct product) {
    final text = _selectedTab == 0
        ? (product.pointCondition.isEmpty
              ? product.title
              : product.pointCondition)
        : (product.termsAndConditions.isEmpty
              ? 'អាស្រ័យលើលក្ខខណ្ឌរបស់ហាង និងស្តុកជាក់ស្តែង។'
              : product.termsAndConditions);
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Battambang',
          fontSize: 16,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}

class _RewardSummaryCard extends StatelessWidget {
  const _RewardSummaryCard({required this.product, this.imageHeight = 280});

  final LoyaltyProduct product;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              height: imageHeight,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(height: imageHeight, color: Colors.grey[200]),
              errorWidget: (context, url, error) => Container(
                height: imageHeight,
                color: AppColors.primary.withAlpha(15),
                child: Icon(
                  Icons.image_outlined,
                  size: 44,
                  color: AppColors.primary.withAlpha(80),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            product.category,
            style: TextStyle(
              fontFamily: 'Battambang',
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            product.title,
            style: const TextStyle(
              fontFamily: 'Battambang',
              fontSize: 21,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'ពិន្ទុដើម្បីប្តូររង្វាន់:',
                      style: TextStyle(
                        fontFamily: 'Battambang',
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${product.points}ពិន្ទុ',
                      style: const TextStyle(
                        fontFamily: 'Battambang',
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CustomPaint(
                  size: const Size(double.infinity, 1),
                  painter: _DashedLinePainter(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _MetaInfoBox(
                        label: 'ថ្ងៃផុតកំណត់',
                        value: product.expiryDate,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetaInfoBox(
                        label: 'រង្វាន់ដែលនៅសល់',
                        value: '${product.redeemLimit}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaInfoBox extends StatelessWidget {
  const _MetaInfoBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Battambang',
              fontSize: 15,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Battambang',
              fontSize: 20,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 7.0;
    const dashSpace = 5.0;
    final paint = Paint()
      ..color = const Color(0xFFD2D2D2)
      ..strokeWidth = 2;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _RedeemConfirmationSheet extends StatelessWidget {
  const _RedeemConfirmationSheet({
    required this.product,
    required this.onConfirm,
  });

  final LoyaltyProduct product;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      decoration: const BoxDecoration(
        color: Color(0xFFF9F9F9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                'ប្តូររង្វាន់',
                style: TextStyle(
                  fontFamily: 'Battambang',
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
                child: _RewardSummaryCard(product: product, imageHeight: 180),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontFamily: 'Battambang',
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Text('បញ្ជាក់ការប្តូររង្វាន់'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RedeemErrorBanner extends StatelessWidget {
  const _RedeemErrorBanner();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(24),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ខុសប្រក្រតី',
                    style: TextStyle(
                      fontFamily: 'Battambang',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'You do not have enough points to redeem this voucher',
                    style: TextStyle(
                      fontSize: 34 / 3,
                      color: Colors.grey[700],
                      height: 1.3,
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
