import 'package:flutter_bloc/flutter_bloc.dart';

part 'wholesale_form_event.dart';
part 'wholesale_form_state.dart';

class WholesaleFormBloc
    extends Bloc<WholesaleFormEvent, WholesaleFormState> {
  WholesaleFormBloc() : super(const WholesaleFormState()) {
    on<AddSelectedProducts>(_onAddSelectedProducts);
    on<RemoveSelectedProduct>(_onRemoveSelectedProduct);
    on<SetPhoneValid>(_onSetPhoneValid);
    on<SetSubmitting>(_onSetSubmitting);
  }

  void _onAddSelectedProducts(
    AddSelectedProducts event,
    Emitter<WholesaleFormState> emit,
  ) {
    final existing = List<Map<String, String>>.from(state.selectedProducts);
    for (final item in event.products) {
      final id = item['id'];
      if (id != null && !existing.any((e) => e['id'] == id)) {
        existing.add(item);
      }
    }
    emit(state.copyWith(selectedProducts: existing));
  }

  void _onRemoveSelectedProduct(
    RemoveSelectedProduct event,
    Emitter<WholesaleFormState> emit,
  ) {
    final updated =
        state.selectedProducts.where((e) => e['id'] != event.id).toList();
    emit(state.copyWith(selectedProducts: updated));
  }

  void _onSetPhoneValid(
    SetPhoneValid event,
    Emitter<WholesaleFormState> emit,
  ) {
    emit(state.copyWith(isPhoneValid: event.isValid));
  }

  void _onSetSubmitting(
    SetSubmitting event,
    Emitter<WholesaleFormState> emit,
  ) {
    emit(state.copyWith(isSubmitting: event.isSubmitting));
  }
}
