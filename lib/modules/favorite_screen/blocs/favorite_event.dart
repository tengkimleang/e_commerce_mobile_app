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

/// Dispatched right after a successful login.
/// Pushes any locally-stored guest favorites up to the backend
/// and then re-loads from the server as the source of truth.
class FavoriteMigrationRequested extends FavoriteEvent {
  const FavoriteMigrationRequested();
}
