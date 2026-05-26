import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:e_commerce_mobile_app/core/utils/responsive_layout.dart';

class SupermarketAdaptiveScaffold extends StatelessWidget {
  const SupermarketAdaptiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.body,
    this.appBar,
    this.backgroundColor,
    this.extendBody = false,
    this.showNavigation = true,
    this.resizeToAvoidBottomInset,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;
  final bool extendBody;
  final bool showNavigation;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final useRail =
            showNavigation && AppResponsive.useNavigationRailForWidth(width);

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: appBar,
          extendBody: extendBody,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          body: useRail
              ? Row(
                  children: [
                    _SupermarketNavigationRail(
                      selectedIndex: selectedIndex,
                      onTap: onTap,
                      extended: width >= AppBreakpoints.medium,
                    ),
                    const VerticalDivider(width: 1, thickness: 1),
                    Expanded(child: body),
                  ],
                )
              : body,
          bottomNavigationBar: showNavigation && !useRail
              ? SupermarketBottomNavigation(
                  selectedIndex: selectedIndex,
                  onTap: onTap,
                )
              : null,
        );
      },
    );
  }
}

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
          children: _destinations
              .map(
                (destination) => Expanded(
                  child: _BottomNavItem(
                    destination: destination,
                    selectedIndex: selectedIndex,
                    onTap: onTap,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _SupermarketNavigationRail extends StatelessWidget {
  const _SupermarketNavigationRail({
    required this.selectedIndex,
    required this.onTap,
    required this.extended,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC407A);

    return SafeArea(
      right: false,
      child: NavigationRail(
        selectedIndex: selectedIndex,
        extended: extended,
        minWidth: 76,
        minExtendedWidth: 178,
        backgroundColor: Colors.white,
        indicatorColor: accent.withValues(alpha: 0.12),
        selectedIconTheme: const IconThemeData(color: accent, size: 26),
        unselectedIconTheme: const IconThemeData(
          color: Color(0xFF6F6A73),
          size: 24,
        ),
        selectedLabelTextStyle: const TextStyle(
          color: accent,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: Color(0xFF6F6A73),
          fontWeight: FontWeight.w500,
        ),
        onDestinationSelected: onTap,
        destinations: _destinations
            .map(
              (destination) => NavigationRailDestination(
                icon: Icon(destination.icon),
                selectedIcon: Icon(destination.selectedIcon),
                label: Text(destination.label),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.destination,
    required this.selectedIndex,
    required this.onTap,
  });

  final _SupermarketDestination destination;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = selectedIndex == destination.index;
    const accent = Color(0xFFEC407A);
    const inactiveColor = Color(0xFF6F6A73);

    return InkResponse(
      onTap: () => onTap(destination.index),
      mouseCursor: SystemMouseCursors.click,
      radius: 34,
      child: Semantics(
        button: true,
        selected: selected,
        label: destination.label,
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
                    selected ? destination.selectedIcon : destination.icon,
                    size: selected ? 23 : 25,
                    color: selected ? Colors.white : inactiveColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  destination.label,
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

class _SupermarketDestination {
  const _SupermarketDestination({
    required this.index,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final int index;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

const _destinations = [
  _SupermarketDestination(
    index: 0,
    icon: CupertinoIcons.house,
    selectedIcon: CupertinoIcons.house_fill,
    label: 'Home',
  ),
  _SupermarketDestination(
    index: 1,
    icon: CupertinoIcons.tag,
    selectedIcon: CupertinoIcons.tag_fill,
    label: 'Offers',
  ),
  _SupermarketDestination(
    index: 2,
    icon: CupertinoIcons.qrcode,
    selectedIcon: CupertinoIcons.qrcode,
    label: 'Scan',
  ),
  _SupermarketDestination(
    index: 3,
    icon: CupertinoIcons.doc_text,
    selectedIcon: CupertinoIcons.doc_text_fill,
    label: 'Orders',
  ),
  _SupermarketDestination(
    index: 4,
    icon: CupertinoIcons.person,
    selectedIcon: CupertinoIcons.person_fill,
    label: 'Profile',
  ),
];
