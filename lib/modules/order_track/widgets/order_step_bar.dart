import 'package:e_commerce_mobile_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum OrderStep { requesting, picking, delivering, delivered }

class OrderStepBar extends StatelessWidget {
  const OrderStepBar({
    super.key,
    required this.currentStep,
  });

  final OrderStep currentStep;

  static const _steps = [
    _StepConfig(icon: Icons.hourglass_top_rounded, label: 'Requesting'),
    _StepConfig(icon: Icons.shopping_cart_outlined, label: 'Picking'),
    _StepConfig(icon: Icons.delivery_dining_outlined, label: 'Delivering'),
    _StepConfig(icon: Icons.check_circle_outline_rounded, label: 'Delivered'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = OrderStep.values.indexOf(currentStep);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              for (int i = 0; i < _steps.length; i++) ...[
                _StepCircle(
                  icon: _steps[i].icon,
                  isActive: i <= currentIndex,
                  isCurrent: i == currentIndex,
                ),
                if (i < _steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 3,
                      color: i < currentIndex
                          ? AppColors.primary
                          : Colors.grey.shade300,
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 0; i < _steps.length; i++)
                SizedBox(
                  width: 60,
                  child: Text(
                    _steps[i].label,
                    textAlign: i == 0
                        ? TextAlign.left
                        : i == _steps.length - 1
                            ? TextAlign.right
                            : TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: i == currentIndex
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: i == currentIndex
                          ? AppColors.primary
                          : Colors.black45,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.icon,
    required this.isActive,
    required this.isCurrent,
  });

  final IconData icon;
  final bool isActive;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final bg = isActive ? AppColors.primary : Colors.grey.shade300;
    final fg = isActive ? Colors.white : Colors.grey.shade500;
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Icon(icon, color: fg, size: 20),
    );
  }
}

class _StepConfig {
  const _StepConfig({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
