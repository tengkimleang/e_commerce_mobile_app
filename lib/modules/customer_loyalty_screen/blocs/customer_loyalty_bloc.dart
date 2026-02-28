import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/customer_loyalty_data.dart';
import 'customer_loyalty_event.dart';
import 'customer_loyalty_state.dart';

class CustomerLoyaltyBloc
    extends Bloc<CustomerLoyaltyEvent, CustomerLoyaltyState> {
  final CustomerLoyaltyData _data;

  CustomerLoyaltyBloc({CustomerLoyaltyData? data})
    : _data = data ?? customerLoyaltyDefaultData,
      super(const CustomerLoyaltyState.initial()) {
    on<CustomerLoyaltyStarted>(_onStarted);
    on<ExchangePointsTapped>((event, emit) {});
    on<PriceCheckingTapped>((event, emit) {});
  }

  void _onStarted(
    CustomerLoyaltyStarted event,
    Emitter<CustomerLoyaltyState> emit,
  ) {
    emit(
      state.copyWith(
        username: _data.username,
        phone: _data.phone,
        points: _data.points,
        promoPeriodText: _data.promoPeriodText,
        exchangePointsImageUrl: _data.exchangePointsImageUrl,
        priceCheckingImageUrl: _data.priceCheckingImageUrl,
        isLoading: false,
        errorMessage: null,
      ),
    );
  }
}
