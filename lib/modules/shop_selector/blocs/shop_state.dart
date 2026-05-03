import 'package:e_commerce_mobile_app/modules/shop_selector/models/shop_option.dart';

abstract class ShopState {
  const ShopState();
}

class ShopsInitial extends ShopState {
  const ShopsInitial();
}

class ShopsLoading extends ShopState {
  const ShopsLoading();
}

class ShopsLoaded extends ShopState {
  const ShopsLoaded(this.shops);
  final List<ShopOption> shops;
}

class ShopsError extends ShopState {
  const ShopsError(this.message);
  final String message;
}
