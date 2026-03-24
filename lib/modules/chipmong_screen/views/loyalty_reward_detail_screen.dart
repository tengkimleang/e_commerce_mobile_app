import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../widget/loyalty_widget/loyalty_models.dart';

class LoyaltyRewardDetailScreen extends StatefulWidget {
  const LoyaltyRewardDetailScreen({super.key, required this.product});

  final LoyaltyProduct product;

  @override
  State<LoyaltyRewardDetailScreen> createState() =>
      _LoyaltyRewardDetailScreenState();
}

class _LoyaltyRewardDetailScreenState extends State<LoyaltyRewardDetailScreen> {
  int _selectedTab = 0;

  static const _tabs = ['ព័ត៌មានលម្អិត', 'គោលការណ៍ និង លក្ខខណ្ឌ'];

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
                  onPressed: () {},
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
  const _RewardSummaryCard({required this.product});

  final LoyaltyProduct product;

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
              height: 280,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(height: 280, color: Colors.grey[200]),
              errorWidget: (context, url, error) => Container(
                height: 280,
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
