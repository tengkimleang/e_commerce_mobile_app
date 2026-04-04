import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class LoyaltyTabBar extends StatelessWidget {
  const LoyaltyTabBar({super.key, required this.controller});

  final TabController controller;

  static const _tabs = [
    (icon: Icons.card_giftcard_outlined, label: 'Rewards'),
    (icon: Icons.history_outlined, label: 'History'),
    (icon: Icons.schedule_outlined, label: 'Expiry'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          final selected = controller.index;
          return Row(
            children: List.generate(_tabs.length, (i) {
              final isSelected = i == selected;
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.animateTo(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
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
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _tabs[i].label,
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'Battambang',
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[600],
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
          );
        },
      ),
    );
  }
}
