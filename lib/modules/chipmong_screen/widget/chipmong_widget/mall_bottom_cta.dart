import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class MallBottomCta extends StatelessWidget {
  const MallBottomCta({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: ElevatedButton.icon(
        onPressed: onTap ?? () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        icon: const Icon(Icons.edit_outlined, size: 18),
        label: const Text(
          'Customize Theme',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Battambang',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
