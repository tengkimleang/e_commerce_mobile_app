import 'package:flutter_bloc/flutter_bloc.dart';

import 'customer_loyalty_event.dart';
import 'customer_loyalty_state.dart';
import '../models/repositories/customer_loyalty_local_repository.dart';
import '../models/repositories/customer_loyalty_repository.dart';

class CustomerLoyaltyBloc
    extends Bloc<CustomerLoyaltyEvent, CustomerLoyaltyState> {
  final CustomerLoyaltyRepository _repository;

  CustomerLoyaltyBloc({CustomerLoyaltyRepository? repository})
    : _repository = repository ?? CustomerLoyaltyLocalRepository(),
      super(const CustomerLoyaltyState.initial()) {
    on<CustomerLoyaltyStarted>(_onStarted);
    on<ExchangePointsTapped>((event, emit) {});
    on<PriceCheckingTapped>((event, emit) {});
  }

  Future<void> _onStarted(
    CustomerLoyaltyStarted event,
    Emitter<CustomerLoyaltyState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final data = await _repository.fetchLoyaltyData();
      emit(
        state.copyWith(
          username: data.username,
          phone: data.phone,
          points: data.points,
          promoPeriodText: data.promoPeriodText,
          exchangePointsImageUrl: data.exchangePointsImageUrl,
          priceCheckingImageUrl: data.priceCheckingImageUrl,
          isLoading: false,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load customer loyalty data.',
        ),
      );
    }
  }
}
