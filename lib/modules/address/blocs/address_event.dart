import 'package:equatable/equatable.dart';
import '../models/delivery_address.dart';

abstract class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

class LoadAddresses extends AddressEvent {
  const LoadAddresses();
}

class AddAddress extends AddressEvent {
  const AddAddress(this.address);
  final DeliveryAddress address;

  @override
  List<Object?> get props => [address];
}

class UpdateAddress extends AddressEvent {
  const UpdateAddress(this.address);
  final DeliveryAddress address;

  @override
  List<Object?> get props => [address];
}

class DeleteAddress extends AddressEvent {
  const DeleteAddress(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

class SelectAddress extends AddressEvent {
  const SelectAddress(this.address);
  final DeliveryAddress address;

  @override
  List<Object?> get props => [address];
}
