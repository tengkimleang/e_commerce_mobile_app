import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/address_bloc.dart';
import '../blocs/address_event.dart';
import '../blocs/address_state.dart';
import '../models/delivery_address.dart';
import 'add_address_screen.dart';
import 'package:e_commerce_mobile_app/l10n/generated/app_localizations.dart';

class ReceivingAddressScreen extends StatelessWidget {
  const ReceivingAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 22,
            color: Colors.black87,
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.receivingAddress,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: BlocBuilder<AddressBloc, AddressState>(
        builder: (context, state) {
          if (state.status == AddressStatus.loading &&
              state.addresses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.addresses.isEmpty) {
            return const _EmptyBody();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: state.addresses.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final addr = state.addresses[index];
              final isSelected = state.selectedAddress?.id == addr.id;
              return _AddressCard(
                address: addr,
                isSelected: isSelected,
                onTap: () {
                  context.read<AddressBloc>().add(SelectAddress(addr));
                  Navigator.of(context).pop(addr);
                },
                onEdit: () async {
                  await Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<AddressBloc>(),
                        child: AddAddressScreen(existingAddress: addr),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: _UseCurrentLocationButton(
        onTap: () async {
          await Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<AddressBloc>(),
                child: const AddAddressScreen(startWithCurrentLocation: true),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    return Container(width: double.infinity, color: const Color(0xFFF0F0F3));
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
  });

  final DeliveryAddress address;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primary : const Color(0xFFE5E5EA),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_labelIcon(address.label), color: primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.nameAddress,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.address,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_labelText(address.label)}, ${address.phoneNumber}',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: Icon(Icons.edit_rounded, color: primary, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }

  IconData _labelIcon(AddressLabel label) {
    switch (label) {
      case AddressLabel.work:
        return Icons.work_outline_rounded;
      case AddressLabel.home:
        return Icons.home_outlined;
      case AddressLabel.school:
        return Icons.school_outlined;
      case AddressLabel.other:
        return Icons.bookmark_border_rounded;
    }
  }

  String _labelText(AddressLabel label) {
    switch (label) {
      case AddressLabel.work:
        return 'Work';
      case AddressLabel.home:
        return 'Home';
      case AddressLabel.school:
        return 'School';
      case AddressLabel.other:
        return 'Other';
    }
  }
}

class _UseCurrentLocationButton extends StatelessWidget {
  const _UseCurrentLocationButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: 84,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
          ),
          child: Text(
            AppLocalizations.of(context)!.useCurrentLocation,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
