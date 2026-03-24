import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'sort_icon_painter.dart';

class LoyaltyFilterBar extends StatelessWidget {
  const LoyaltyFilterBar({
    super.key,
    required this.filters,
    required this.selectedIndex,
    required this.sortDescending,
    required this.onFilterChanged,
    required this.onSortToggle,
  });

  final List<String> filters;
  final int selectedIndex;
  final bool sortDescending;
  final ValueChanged<int> onFilterChanged;
  final VoidCallback onSortToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(filters.length, (i) {
                  final isSelected = i == selectedIndex;
                  return GestureDetector(
                    onTap: () => onFilterChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 170),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey[350]!,
                        ),
                      ),
                      child: Text(
                        filters[i],
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Battambang',
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSortToggle,
            child: SizedBox(
              width: 28,
              height: 28,
              child: CustomPaint(
                painter: SortIconPainter(
                  descending: sortDescending,
                  color: Colors.grey[700]!,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
