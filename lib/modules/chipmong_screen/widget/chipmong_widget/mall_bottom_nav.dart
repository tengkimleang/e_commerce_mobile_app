import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class MallNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const MallNavItem({
    required this.icon,
    IconData? selectedIcon,
    required this.label,
  }) : selectedIcon = selectedIcon ?? icon;
}

const chipmongMallNavItems = <MallNavItem>[
  MallNavItem(
    icon: CupertinoIcons.house,
    selectedIcon: CupertinoIcons.house_fill,
    label: 'Home',
  ),
  MallNavItem(icon: CupertinoIcons.qrcode, label: 'My QR'),
  MallNavItem(
    icon: CupertinoIcons.tag,
    selectedIcon: CupertinoIcons.tag_fill,
    label: 'Promotions',
  ),
  MallNavItem(
    icon: CupertinoIcons.star,
    selectedIcon: CupertinoIcons.star_fill,
    label: 'Loyalty',
  ),
];

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
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Container(
        height: 78,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
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
    const inactiveColor = Color(0xFF6F6A73);

    return InkResponse(
      onTap: onTap,
      mouseCursor: SystemMouseCursors.click,
      radius: 34,
      child: Semantics(
        button: true,
        selected: isSelected,
        label: item.label,
        child: Center(
          child: SizedBox(
            height: 64,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    isSelected ? item.selectedIcon : item.icon,
                    size: isSelected ? 23 : 25,
                    color: isSelected ? Colors.white : inactiveColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : inactiveColor,
                    fontSize: 11,
                    height: 1.1,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
