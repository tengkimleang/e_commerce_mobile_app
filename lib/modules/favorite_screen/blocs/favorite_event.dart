import 'package:e_commerce_mobile_app/core/models/product_item.dart';

abstract class FavoriteEvent {
  const FavoriteEvent();
}

class FavoriteLoadRequested extends FavoriteEvent {
  const FavoriteLoadRequested();
}

class FavoriteToggled extends FavoriteEvent {
  const FavoriteToggled(this.product);

  final ProductModel product;
}

class FavoriteRemoved extends FavoriteEvent {
  const FavoriteRemoved(this.productId);

  final String productId;
}

class FavoriteCleared extends FavoriteEvent {
  const FavoriteCleared();
}
