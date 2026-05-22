import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_mobile_app/core/widgets/app_skeleton.dart';
import '../blocs/customer_loyalty_bloc.dart';
import '../blocs/customer_loyalty_event.dart';
import '../blocs/customer_loyalty_state.dart';
import '../../price_checking/views/price_checking_view.dart';
import 'widgets/loyalty_action_cards.dart';
import 'widgets/partner_qr_sheet.dart';
import 'widgets/shop_by_category_section.dart';
import 'widgets/shop_by_country_section.dart';

class CustomerLoyaltySection extends StatelessWidget {
  final bool isGuest;
  final String shopId;
  final String shopName;

  const CustomerLoyaltySection({
    super.key,
    this.isGuest = false,
    this.shopId = '',
    this.shopName = '',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomerLoyaltyBloc()..add(const CustomerLoyaltyStarted()),
      child: BlocBuilder<CustomerLoyaltyBloc, CustomerLoyaltyState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const _CustomerLoyaltySkeleton();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShopByCategorySection(shopId: shopId, shopName: shopName),
              const SizedBox(height: 24),
              ShopByCountrySection(),
              const SizedBox(height: 24),
              LoyaltyActionCards(
                exchangePointsImageUrl: state.exchangePointsImageUrl,
                priceCheckingImageUrl: state.priceCheckingImageUrl,
                onExchangePointsTap: () {
                  context.read<CustomerLoyaltyBloc>().add(
                    const ExchangePointsTapped(),
                  );
                  showPartnerQrSheet(
                    context,
                    username: isGuest ? '' : state.username,
                    phone: isGuest ? '' : state.phone,
                    points: isGuest ? '0' : state.points,
                  );
                },
                onPriceCheckingTap: () {
                  context.read<CustomerLoyaltyBloc>().add(
                    const PriceCheckingTapped(),
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PriceCheckingView(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CustomerLoyaltySkeleton extends StatelessWidget {
  const _CustomerLoyaltySkeleton();

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: Column(
        key: const ValueKey('customer-loyalty-section-skeleton'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SkeletonBox(width: 190, height: 20, radius: 8),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 134,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  const SizedBox(width: 112, child: SkeletonCategoryCard()),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SkeletonBox(width: 160, height: 18, radius: 6),
                Spacer(),
                SkeletonBox(width: 54, height: 14, radius: 6),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) => SkeletonBox(
                width: index == 0 ? 58 : 116,
                height: 34,
                radius: 18,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  const SizedBox(width: 160, child: SkeletonProductCard()),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                Expanded(child: SkeletonBox(height: 112, radius: 12)),
                SizedBox(width: 12),
                Expanded(child: SkeletonBox(height: 112, radius: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
