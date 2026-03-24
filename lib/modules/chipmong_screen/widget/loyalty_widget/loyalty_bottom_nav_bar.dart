import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class LoyaltyNavItem {
  final IconData icon;
  final String label;

  const LoyaltyNavItem({required this.icon, required this.label});
}

class LoyaltyBottomNavBar extends StatelessWidget {
  const LoyaltyBottomNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<LoyaltyNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.white,
        elevation: 10,
        child: Row(
          children: List.generate(
            items.length,
            (i) => Expanded(
              child: _NavItemTile(
                item: items[i],
                isSelected: i == selectedIndex,
                onTap: () => onTap(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemTile extends StatelessWidget {
  const _NavItemTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final LoyaltyNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : Colors.grey;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 24, color: color),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontFamily: 'Battambang',
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
