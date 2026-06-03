import 'package:flutter/material.dart';

import 'package:e_commerce_mobile_app/l10n/generated/app_localizations.dart';

/// Shared pricing breakdown widget used in both CheckoutScreen and
/// OrderTrackScreen.
class OrderPricingSection extends StatelessWidget {
  const OrderPricingSection({
    super.key,
    required this.paymentMethod,
    required this.deliveryFee,
    required this.subtotal,
    required this.packageFees,
    required this.discount,
    required this.promoDiscount,
    required this.total,
  });

  final String paymentMethod;
  final double deliveryFee;
  final double subtotal;
  final double packageFees;
  final double discount;
  final double promoDiscount;
  final double total;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PricingRow(
            label: l10n?.paymentMethod ?? 'Payment method',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icons/cod_icon.png',
                  width: 24,
                  height: 24,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.local_shipping_outlined,
                    size: 20,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  paymentMethod,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          _PricingRow(
            label: l10n?.deliveryFee ?? 'Delivery Fee',
            trailing: _buildSubLabel(
              icon: const _FoodpandaIcon(),
              label: 'Foodpanda',
              value: '\$ ${deliveryFee.toStringAsFixed(2)}',
            ),
          ),
          const SizedBox(height: 8),
          _SimpleRow(
            label: l10n?.subtotal ?? 'Subtotal',
            value: '\$ ${subtotal.toStringAsFixed(2)}',
          ),
          _SimpleRow(
            label: l10n?.packageFees ?? 'Package fees',
            value: '\$ ${packageFees.toStringAsFixed(2)}',
          ),
          _SimpleRow(
            label: l10n?.discount ?? 'Discount',
            value: '-\$ ${discount.toStringAsFixed(2)}',
          ),
          _SimpleRow(
            label: l10n?.promoteCode ?? 'Promote Code',
            value: '-\$ ${promoDiscount.toStringAsFixed(2)}',
            labelSuffix: const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.info_outline, size: 14, color: Colors.black45),
            ),
          ),
          const Divider(height: 16, thickness: 0.5),
          Row(
            children: [
              Text(
                l10n?.total ?? 'Total',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Text(
                l10n?.includingVat ?? '(incl.VAT)',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const Spacer(),
              Text(
                '\$ ${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSubLabel({
    required Widget icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _PricingRow extends StatelessWidget {
  const _PricingRow({required this.label, required this.trailing});

  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }
}

class _SimpleRow extends StatelessWidget {
  const _SimpleRow({
    required this.label,
    required this.value,
    this.labelSuffix,
  });

  final String label;
  final String value;
  final Widget? labelSuffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          ?labelSuffix,
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class _FoodpandaIcon extends StatelessWidget {
  const _FoodpandaIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: Color(0xFFD70F64),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'f',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
