import 'package:equatable/equatable.dart';
import '../models/delivery_address.dart';

enum AddressStatus { initial, loading, success, failure }

class AddressState extends Equatable {
  const AddressState({
    this.addresses = const [],
    this.selectedAddress,
    this.status = AddressStatus.initial,
  });

  final List<DeliveryAddress> addresses;
  final DeliveryAddress? selectedAddress;
  final AddressStatus status;

  AddressState copyWith({
    List<DeliveryAddress>? addresses,
    DeliveryAddress? selectedAddress,
    bool clearSelected = false,
    AddressStatus? status,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      selectedAddress: clearSelected
          ? null
          : (selectedAddress ?? this.selectedAddress),
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [addresses, selectedAddress, status];
}
