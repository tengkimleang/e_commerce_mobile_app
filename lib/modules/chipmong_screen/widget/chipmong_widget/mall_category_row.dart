import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/chipmong_mall_model.dart';

class MallCategoryRow extends StatelessWidget {
  const MallCategoryRow({super.key, required this.categories});

  final List<ChipmongMallCategory> categories;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 4),
      child: SizedBox(
        height: 82,
        child: Row(
          children: categories
              .map((cat) => Expanded(child: _MallCategoryItem(category: cat)))
              .toList(),
        ),
      ),
    );
  }
}

class _MallCategoryItem extends StatelessWidget {
  const _MallCategoryItem({required this.category});

  final ChipmongMallCategory category;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: AppColors.textPrimary,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      height: 1.2,
    );

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: category.hasBadge
                      ? AppColors.primary.withAlpha(25)
                      : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  category.icon,
                  size: 24,
                  color: category.hasBadge
                      ? AppColors.primary
                      : const Color(0xFF6F6A73),
                ),
              ),
              if (category.hasBadge && category.badgeLabel != null)
                Positioned(
                  top: -4,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category.badgeLabel!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 7),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              category.label,
              textAlign: TextAlign.center,
              style: labelStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
