import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_mobile_app/core/data/categories_repository.dart';
import 'package:e_commerce_mobile_app/modules/promotion_screen/blocs/promotion_event.dart';
import 'package:e_commerce_mobile_app/modules/promotion_screen/blocs/promotion_state.dart';

class PromotionBloc extends Bloc<PromotionEvent, PromotionState> {
  final CategoriesRepository _repository;

  PromotionBloc(this._repository) : super(PromotionInitial()) {
    on<LoadPromotionSections>(_onLoadPromotionSections);
  }

  Future<void> _onLoadPromotionSections(
    LoadPromotionSections event,
    Emitter<PromotionState> emit,
  ) async {
    emit(PromotionLoading());
    try {
      final sections = await _repository.fetchPromotionCategories(event.shopId);
      emit(PromotionLoaded(sections));
    } catch (e) {
      emit(PromotionError(e.toString()));
    }
  }
}
