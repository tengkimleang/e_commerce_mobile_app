import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:e_commerce_mobile_app/modules/shop_selector/blocs/shop_event.dart';
import 'package:e_commerce_mobile_app/modules/shop_selector/blocs/shop_state.dart';
import 'package:e_commerce_mobile_app/modules/shop_selector/models/shop_option.dart';
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
      final results = await Future.wait([
        _repository.fetchStores(),
        _tryGetPosition(),
      ]);
      final shops = results[0] as List<ShopOption>;
      final position = results[1] as Position?;

      final List<ShopOption> shopsWithDistance = shops.map((shop) {
        if (position == null ||
            shop.latitude == null ||
            shop.longitude == null) {
          return shop;
        }
        final meters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          shop.latitude!,
          shop.longitude!,
        );
        return shop.withDistance(meters / 1000);
      }).toList();

      shopsWithDistance.sort((a, b) {
        if (a.distanceKm == null && b.distanceKm == null) return 0;
        if (a.distanceKm == null) return 1;
        if (b.distanceKm == null) return -1;
        return a.distanceKm!.compareTo(b.distanceKm!);
      });

      emit(ShopsLoaded(shopsWithDistance));
    } catch (e) {
      emit(ShopsError(e.toString()));
    }
  }

  Future<Position?> _tryGetPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      return await Geolocator.getCurrentPosition();
    } catch (_) {
      return null;
    }
  }
}
