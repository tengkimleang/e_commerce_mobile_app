part of 'wholesale_form_bloc.dart';

abstract class WholesaleFormEvent {
  const WholesaleFormEvent();
}

/// Adds one or more products to the selected list (duplicates are skipped).
class AddSelectedProducts extends WholesaleFormEvent {
  final List<Map<String, String>> products;
  const AddSelectedProducts(this.products);
}

/// Removes a single product from the selected list by its id.
class RemoveSelectedProduct extends WholesaleFormEvent {
  final String id;
  const RemoveSelectedProduct(this.id);
}

/// Updates the phone-number validation flag shown under the field.
class SetPhoneValid extends WholesaleFormEvent {
  final bool isValid;
  const SetPhoneValid(this.isValid);
}

/// Toggles the submitting spinner on the submit button.
class SetSubmitting extends WholesaleFormEvent {
  final bool isSubmitting;
  const SetSubmitting(this.isSubmitting);
}
