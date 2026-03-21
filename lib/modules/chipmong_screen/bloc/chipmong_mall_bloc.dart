import 'package:flutter_bloc/flutter_bloc.dart';

import 'chipmong_mall_event.dart';
import 'chipmong_mall_state.dart';
import '../models/chipmong_mall_model.dart';

class ChipmongMallBloc extends Bloc<ChipmongMallEvent, ChipmongMallState> {
  ChipmongMallBloc() : super(const ChipmongMallState.initial()) {
    on<ChipmongMallStarted>(_onStarted);
    on<ChipmongMallTabChanged>(_onTabChanged);
    on<ChipmongMallBottomNavChanged>(_onBottomNavChanged);
  }

  Future<void> _onStarted(
    ChipmongMallStarted event,
    Emitter<ChipmongMallState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    // Simulate a short network delay; replace with real repository call later.
    await Future.delayed(const Duration(milliseconds: 400));
    emit(
      state.copyWith(
        isLoading: false,
        promotions: chipmongMallPromotions,
        programs: chipmongMallPrograms,
        news: chipmongMallNews,
        bannerImages: chipmongMallBannerImages,
      ),
    );
  }

  void _onTabChanged(
    ChipmongMallTabChanged event,
    Emitter<ChipmongMallState> emit,
  ) {
    emit(state.copyWith(selectedTabIndex: event.tabIndex));
  }

  void _onBottomNavChanged(
    ChipmongMallBottomNavChanged event,
    Emitter<ChipmongMallState> emit,
  ) {
    emit(state.copyWith(bottomNavIndex: event.index));
  }
}
