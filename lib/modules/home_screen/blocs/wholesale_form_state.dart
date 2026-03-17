part of 'wholesale_form_bloc.dart';

class WholesaleFormState {
  final List<Map<String, String>> selectedProducts;
  final bool isPhoneValid;
  final bool isSubmitting;

  const WholesaleFormState({
    this.selectedProducts = const [],
    this.isPhoneValid = true,
    this.isSubmitting = false,
  });

  WholesaleFormState copyWith({
    List<Map<String, String>>? selectedProducts,
    bool? isPhoneValid,
    bool? isSubmitting,
  }) {
    return WholesaleFormState(
      selectedProducts: selectedProducts ?? this.selectedProducts,
      isPhoneValid: isPhoneValid ?? this.isPhoneValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
