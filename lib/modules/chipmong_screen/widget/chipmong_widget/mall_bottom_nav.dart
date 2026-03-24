import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class MallNavItem {
  final IconData icon;
  final String label;

  const MallNavItem({required this.icon, required this.label});
}

class MallBottomNav extends StatelessWidget {
  const MallBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<MallNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        items.length,
        (i) => Expanded(
          child: _MallBottomNavTile(
            item: items[i],
            isSelected: i == selectedIndex,
            onTap: () => onTap(i),
          ),
        ),
      ),
    );
  }
}

class _MallBottomNavTile extends StatelessWidget {
  const _MallBottomNavTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final MallNavItem item;
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
