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
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _BottomNavItem(
                index: 0,
                icon: Icons.home,
                selectedIndex: selectedIndex,
                onTap: onTap,
              ),
            ),
            Expanded(
              child: _BottomNavItem(
                index: 1,
                icon: Icons.local_offer,
                selectedIndex: selectedIndex,
                onTap: onTap,
              ),
            ),
            Expanded(
              child: _BottomNavItem(
                index: 2,
                icon: Icons.qr_code,
                selectedIndex: selectedIndex,
                onTap: onTap,
              ),
            ),
            Expanded(
              child: _BottomNavItem(
                index: 3,
                icon: Icons.list_alt,
                selectedIndex: selectedIndex,
                onTap: onTap,
              ),
            ),
            Expanded(
              child: _BottomNavItem(
                index: 4,
                icon: Icons.person,
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
    required this.selectedIndex,
    required this.onTap,
  });

  final int index;
  final IconData icon;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = selectedIndex == index;
    const accent = Color(0xFFEC407A);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: SizedBox(
          width: 42,
          height: 42,
          child: Center(
            child: Container(
              padding: selected
                  ? const EdgeInsets.all(10)
                  : const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: selected ? accent : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 22,
                color: selected ? Colors.white : accent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
