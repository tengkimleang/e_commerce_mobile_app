import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/customer_loyalty_bloc.dart';
import '../blocs/customer_loyalty_event.dart';
import '../blocs/customer_loyalty_state.dart';
import 'price_checking_view.dart';
import 'widgets/loyalty_action_cards.dart';
import 'widgets/partner_qr_sheet.dart';

class CustomerLoyaltySection extends StatelessWidget {
  const CustomerLoyaltySection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomerLoyaltyBloc()..add(const CustomerLoyaltyStarted()),
      child: BlocBuilder<CustomerLoyaltyBloc, CustomerLoyaltyState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Loyalty',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(state.promoPeriodText),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              LoyaltyActionCards(
                exchangePointsImageUrl: state.exchangePointsImageUrl,
                priceCheckingImageUrl: state.priceCheckingImageUrl,
                onExchangePointsTap: () {
                  context.read<CustomerLoyaltyBloc>().add(
                    const ExchangePointsTapped(),
                  );
                  showPartnerQrSheet(
                    context,
                    username: state.username,
                    phone: state.phone,
                    points: state.points,
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
