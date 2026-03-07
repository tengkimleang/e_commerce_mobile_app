import 'package:e_commerce_mobile_app/modules/price_checking/models/price_checking_model.dart';

abstract class PriceCheckingState {
  const PriceCheckingState();
}

class PriceCheckingInitial extends PriceCheckingState {
  final PriceCheckingModel model;
  const PriceCheckingInitial(this.model);
}

class PriceCheckingLoading extends PriceCheckingState {
  const PriceCheckingLoading();
}

class PriceCheckingSuccess extends PriceCheckingState {
  final PriceCheckingResult result;
  const PriceCheckingSuccess(this.result);
}

class PriceCheckingError extends PriceCheckingState {
  final String message;
  const PriceCheckingError(this.message);
}
