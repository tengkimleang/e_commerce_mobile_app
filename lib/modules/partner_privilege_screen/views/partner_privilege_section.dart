import 'package:e_commerce_mobile_app/core/common/di.dart';
import 'package:e_commerce_mobile_app/modules/partner_privilege_screen/repositories/privilege_partner.dart';
import 'package:e_commerce_mobile_app/modules/partner_privilege_screen/views/become_partner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/partner_privilege_bloc.dart';
import '../blocs/partner_privilege_event.dart';
import '../blocs/partner_privilege_state.dart';
// import 'become_partner_screendart';
import 'widgets/partner_carousel.dart';
import 'widgets/wholesale_price_card.dart';

class PartnerPrivilegeSection extends StatelessWidget {
  const PartnerPrivilegeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              PartnerPrivilegeBloc(di<PrivilegePartnerRepository>())
                ..add(const PartnerPrivilegeStarted()),
        ),
      ],
      child: BlocBuilder<PartnerPrivilegeBloc, PartnerPrivilegeState>(
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
                child: Text(
                  'Partner Privileges',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PartnerCarousel(
                images: state.partnerImages,
                onPageChanged: (index) {
                  context.read<PartnerPrivilegeBloc>().add(
                    PartnerPageChanged(index),
                  );
                },
              ),
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(state.partnerImages.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: state.currentIndex == i ? 12 : 8,
                      height: state.currentIndex == i ? 12 : 8,
                      decoration: BoxDecoration(
                        color: state.currentIndex == i
                            ? Colors.black87
                            : Colors.black26,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 10),
              WholesalePriceCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BecomePartnerView()),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
