import 'package:e_commerce_mobile_app/core/models/product_item.dart';

class FavoriteState {
  const FavoriteState({
    Map<String, ProductModel> itemsById = const {},
    this.isLoaded = false,
  }) : _itemsById = itemsById;

  final Map<String, ProductModel> _itemsById;
  final bool isLoaded;

  Map<String, ProductModel> get itemsById => _itemsById;

  List<ProductModel> get items => _itemsById.values.toList(growable: false);

  bool contains(String productId) => _itemsById.containsKey(productId);

  FavoriteState copyWith({
    Map<String, ProductModel>? itemsById,
    bool? isLoaded,
  }) {
    return FavoriteState(
      itemsById: itemsById ?? _itemsById,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}
