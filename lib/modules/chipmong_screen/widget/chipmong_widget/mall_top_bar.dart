import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../bloc/chipmong_mall_state.dart';

class MallTopBar extends StatelessWidget {
  const MallTopBar({super.key, required this.state, this.onSearchTap});

  final ChipmongMallState state;
  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return ColoredBox(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: const Icon(
                      Icons.store_mall_directory_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Shop at',
                            style: theme.labelSmall?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  state.selectedBranch,
                                  style: theme.labelMedium?.copyWith(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    height: 1.15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                size: 18,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                    tooltip: 'Profile',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: onSearchTap,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Search shops, offers and events',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
