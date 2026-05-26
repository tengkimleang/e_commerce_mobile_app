import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SupermarketBottomNavigation extends StatelessWidget {
  const SupermarketBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

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
          children: [
            Expanded(
              child: _BottomNavItem(
                index: 0,
                icon: CupertinoIcons.house,
                selectedIcon: CupertinoIcons.house_fill,
                label: 'Home',
                selectedIndex: selectedIndex,
                onTap: onTap,
              ),
            ),
            Expanded(
              child: _BottomNavItem(
                index: 1,
                icon: CupertinoIcons.tag,
                selectedIcon: CupertinoIcons.tag_fill,
                label: 'Offers',
                selectedIndex: selectedIndex,
                onTap: onTap,
              ),
            ),
            Expanded(
              child: _BottomNavItem(
                index: 2,
                icon: CupertinoIcons.qrcode,
                selectedIcon: CupertinoIcons.qrcode,
                label: 'Scan',
                selectedIndex: selectedIndex,
                onTap: onTap,
              ),
            ),
            Expanded(
              child: _BottomNavItem(
                index: 3,
                icon: CupertinoIcons.doc_text,
                selectedIcon: CupertinoIcons.doc_text_fill,
                label: 'Orders',
                selectedIndex: selectedIndex,
                onTap: onTap,
              ),
            ),
            Expanded(
              child: _BottomNavItem(
                index: 4,
                icon: CupertinoIcons.person,
                selectedIcon: CupertinoIcons.person_fill,
                label: 'Profile',
                selectedIndex: selectedIndex,
                onTap: onTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.index,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selectedIndex,
    required this.onTap,
  });

  final int index;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = selectedIndex == index;
    const accent = Color(0xFFEC407A);
    const inactiveColor = Color(0xFF6F6A73);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Semantics(
        selected: selected,
        label: label,
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
                    color: selected ? accent : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    selected ? selectedIcon : icon,
                    size: selected ? 23 : 25,
                    color: selected ? Colors.white : inactiveColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? accent : inactiveColor,
                    fontSize: 11,
                    height: 1.1,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
