import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_mobile_app/modules/shop_selector/blocs/shop_event.dart';
import 'package:e_commerce_mobile_app/modules/shop_selector/blocs/shop_state.dart';
import 'package:e_commerce_mobile_app/modules/shop_selector/repositories/shop_repository.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  ShopBloc(this._repository) : super(const ShopsInitial()) {
    on<FetchStores>(_onFetchStores);
  }

  final ShopRepository _repository;

  Future<void> _onFetchStores(
    FetchStores event,
    Emitter<ShopState> emit,
  ) async {
    emit(const ShopsLoading());
    try {
      final shops = await _repository.fetchStores();
      emit(ShopsLoaded(shops));
    } catch (e) {
      emit(ShopsError(e.toString()));
    }
  }
}
