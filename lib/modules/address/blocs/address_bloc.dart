import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/address_repository.dart';
import 'address_event.dart';
import 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  AddressBloc(this._repository) : super(const AddressState()) {
    on<LoadAddresses>(_onLoad);
    on<AddAddress>(_onAdd);
    on<UpdateAddress>(_onUpdate);
    on<DeleteAddress>(_onDelete);
    on<SelectAddress>(_onSelect);
  }

  final IAddressRepository _repository;

  Future<void> _onLoad(LoadAddresses event, Emitter<AddressState> emit) async {
    emit(state.copyWith(status: AddressStatus.loading));
    try {
      final addresses = await _repository.getAll();
      final defaultAddress = addresses.where((a) => a.isDefault).firstOrNull;
      emit(state.copyWith(
        addresses: addresses,
        selectedAddress: defaultAddress,
        status: AddressStatus.success,
      ));
    } catch (_) {
      emit(state.copyWith(status: AddressStatus.failure));
    }
  }

  Future<void> _onAdd(AddAddress event, Emitter<AddressState> emit) async {
    try {
      await _repository.insert(event.address);
      final addresses = await _repository.getAll();
      emit(state.copyWith(
        addresses: addresses,
        selectedAddress: event.address.isDefault ? event.address : state.selectedAddress,
        status: AddressStatus.success,
      ));
    } catch (_) {
      emit(state.copyWith(status: AddressStatus.failure));
    }
  }

  Future<void> _onUpdate(UpdateAddress event, Emitter<AddressState> emit) async {
    try {
      await _repository.update(event.address);
      final addresses = await _repository.getAll();
      final updated = state.selectedAddress?.id == event.address.id
          ? event.address
          : state.selectedAddress;
      emit(state.copyWith(
        addresses: addresses,
        selectedAddress: updated,
        status: AddressStatus.success,
      ));
    } catch (_) {
      emit(state.copyWith(status: AddressStatus.failure));
    }
  }

  Future<void> _onDelete(DeleteAddress event, Emitter<AddressState> emit) async {
    try {
      await _repository.delete(event.id);
      final addresses = await _repository.getAll();
      final stillSelected = state.selectedAddress?.id == event.id
          ? null
          : state.selectedAddress;
      emit(state.copyWith(
        addresses: addresses,
        selectedAddress: stillSelected,
        clearSelected: stillSelected == null,
        status: AddressStatus.success,
      ));
    } catch (_) {
      emit(state.copyWith(status: AddressStatus.failure));
    }
  }

  void _onSelect(SelectAddress event, Emitter<AddressState> emit) {
    emit(state.copyWith(selectedAddress: event.address));
  }
}
