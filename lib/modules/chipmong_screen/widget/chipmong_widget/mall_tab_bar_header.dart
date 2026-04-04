import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class MallTabBarHeader extends StatefulWidget {
  const MallTabBarHeader({super.key, required this.controller});

  final TabController controller;

  @override
  State<MallTabBarHeader> createState() => _MallTabBarHeaderState();
}

class _MallTabBarHeaderState extends State<MallTabBarHeader> {
  static const _tabs = [
    (icon: Icons.local_offer_outlined, label: 'Promotions'),
    (icon: Icons.calendar_today_outlined, label: 'Events'),
    (icon: Icons.campaign_outlined, label: 'News'),
  ];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!widget.controller.indexIsChanging) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTabChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.controller.index;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final isSelected = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => widget.controller.animateTo(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _tabs[i].icon,
                      size: 15,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        _tabs[i].label,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Battambang',
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
