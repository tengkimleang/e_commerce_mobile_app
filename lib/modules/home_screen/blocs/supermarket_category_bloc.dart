import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/blocs/supermarket_category_event.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/blocs/supermarket_category_state.dart';
import 'package:e_commerce_mobile_app/core/data/categories_repository.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';

class SupermarketCategoryBloc
    extends Bloc<SupermarketCategoryEvent, SupermarketCategoryState> {
  final CategoriesRepository _repository;

  SupermarketCategoryBloc(this._repository) : super(CategoriesInitial()) {
    on<LoadCategories>(_onLoadCategories);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<SupermarketCategoryState> emit,
  ) async {
    emit(CategoriesLoading());
    try {
      final shopId = event.shopId.trim().isNotEmpty
          ? event.shopId.trim()
          : UserSession.selectedShopId.trim();
      final categories = await _repository.fetchPromotionCategories(shopId);
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }
}
