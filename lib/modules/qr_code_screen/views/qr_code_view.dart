import 'package:flutter/material.dart';

import 'package:e_commerce_mobile_app/modules/bottom_navigation/views/supermarket_bottom_navigation.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/views/order_history_view.dart';
import 'package:e_commerce_mobile_app/modules/promotion_screen/views/promotion_view.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/views/user_info_view.dart';

class QrCodeView extends StatelessWidget {
  const QrCodeView({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC407A);
    const username = 'Jame Taki';
    const phone = '0963267044';
    const points = '0';

    final qrData = Uri.encodeComponent(
      'user:$username;phone:$phone;points:$points',
    );
    final qrUrl =
        'https://api.qrserver.com/v1/create-qr-code/?size=500x500&data=$qrData';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(26),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.09),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 86,
                child: Center(
                  child: Text(
                    'QR Code',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 21,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
              child: Column(
                children: [
                  Image.network(
                    qrUrl,
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 300,
                      height: 300,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Icon(Icons.qr_code_2, size: 64),
                    ),
                  ),
                  const SizedBox(height: 34),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEDED),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    child: Column(
                      children: [
                        _InfoRow(label: 'Username:', value: username),
                        const SizedBox(height: 10),
                        const _DashedDivider(),
                        const SizedBox(height: 10),
                        _InfoRow(label: 'Phone number:', value: phone),
                        const SizedBox(height: 10),
                        const _DashedDivider(),
                        const SizedBox(height: 10),
                        const _InfoRow(
                          label: 'Supermarket Point:',
                          value: points,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SupermarketBottomNavigation(
        selectedIndex: 2,
        onTap: (index) => _onBottomNavTap(context, index),
      ),
    );
  }

  void _onBottomNavTap(BuildContext context, int index) {
    if (index == 2) return;

    if (index == 0) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      return;
    }

    if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PromotionView()),
      );
      return;
    }

    if (index == 3) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OrderHistoryView()),
      );
      return;
    }

    if (index == 4) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const UserInfoView()),
      );
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.black87, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashCount = (constraints.maxWidth / 10).floor();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            dashCount,
            (_) => Container(
              width: 6,
              height: 1.2,
              color: const Color(0xFFCACACA),
            ),
          ),
        );
      },
    );
  }
}
