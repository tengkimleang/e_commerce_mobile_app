import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_mobile_app/modules/price_checking/blocs/price_checking_event.dart';
import 'package:e_commerce_mobile_app/modules/price_checking/blocs/price_checking_state.dart';
import 'package:e_commerce_mobile_app/modules/price_checking/models/price_checking_model.dart';

class PriceCheckingBloc extends Bloc<PriceCheckingEvent, PriceCheckingState> {
  PriceCheckingBloc()
    : super(const PriceCheckingInitial(PriceCheckingModel())) {
    on<SubmitCode>(_onSubmitCode);
    on<ClearResult>(_onClearResult);
  }

  FutureOr<void> _onSubmitCode(
    SubmitCode event,
    Emitter<PriceCheckingState> emit,
  ) async {
    emit(const PriceCheckingLoading());

    try {
      // Simulated lookup - replace with real API or repository
      await Future.delayed(const Duration(seconds: 1));

      if (event.code.trim().isEmpty) {
        emit(const PriceCheckingError('Please enter a product code'));
        return;
      }

      // Fake result for demonstration
      final result = PriceCheckingResult(
        code: event.code.trim(),
        name: 'Sample Product',
        price: 9.99,
      );

      emit(PriceCheckingSuccess(result));
    } catch (e) {
      emit(PriceCheckingError(e.toString()));
    }
  }

  FutureOr<void> _onClearResult(
    ClearResult event,
    Emitter<PriceCheckingState> emit,
  ) {
    emit(const PriceCheckingInitial(PriceCheckingModel()));
  }
}
