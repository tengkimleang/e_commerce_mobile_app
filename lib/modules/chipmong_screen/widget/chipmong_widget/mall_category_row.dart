import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/chipmong_mall_model.dart';

class MallCategoryRow extends StatelessWidget {
  const MallCategoryRow({super.key, required this.categories});

  final List<ChipmongMallCategory> categories;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: categories
            .map((cat) => Expanded(child: _MallCategoryItem(category: cat)))
            .toList(),
      ),
    );
  }
}

class _MallCategoryItem extends StatelessWidget {
  const _MallCategoryItem({required this.category});

  final ChipmongMallCategory category;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: category.hasBadge
                      ? AppColors.primary.withAlpha(25)
                      : const Color(0xFFF0F0F0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  size: 26,
                  color: category.hasBadge ? AppColors.primary : Colors.grey[700],
                ),
              ),
              if (category.hasBadge && category.badgeLabel != null)
                Positioned(
                  top: -4,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category.badgeLabel!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              category.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontFamily: 'Battambang',
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
