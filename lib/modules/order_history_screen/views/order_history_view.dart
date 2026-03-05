import 'package:flutter/material.dart';

import 'package:e_commerce_mobile_app/modules/bottom_navigation/views/supermarket_bottom_navigation.dart';
import 'package:e_commerce_mobile_app/modules/promotion_screen/views/promotion_view.dart';
import 'package:e_commerce_mobile_app/modules/qr_code_screen/views/qr_code_view.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/views/user_info_view.dart';

class OrderHistoryView extends StatelessWidget {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC407A);

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
                    'Ordering',
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
          const Expanded(child: Center(child: _EmptyOrderState())),
        ],
      ),
      bottomNavigationBar: SupermarketBottomNavigation(
        selectedIndex: 3,
        onTap: (index) => _onBottomNavTap(context, index),
      ),
    );
  }

  void _onBottomNavTap(BuildContext context, int index) {
    if (index == 3) return;

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

    if (index == 2) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const QrCodeView()));
      return;
    }

    if (index == 4) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const UserInfoView()),
      );
    }
  }
}

class _EmptyOrderState extends StatelessWidget {
  const _EmptyOrderState();

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC407A);

    return Column(
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
    );
  }
}
