import 'package:e_commerce_mobile_app/core/models/product_item.dart';

class FavoriteState {
  const FavoriteState({
    Map<String, ProductModel> itemsById = const {},
    this.isLoaded = false,
    Set<String> pendingSyncIds = const {},
  }) : _itemsById = itemsById,
       _pendingSyncIds = pendingSyncIds;

  final Map<String, ProductModel> _itemsById;
  final bool isLoaded;

  /// Product IDs whose server-side toggle failed due to a network error.
  /// These will be retried silently on the next [FavoriteLoadRequested].
  final Set<String> _pendingSyncIds;

  Map<String, ProductModel> get itemsById => _itemsById;

  List<ProductModel> get items => _itemsById.values.toList(growable: false);

  Set<String> get pendingSyncIds => _pendingSyncIds;

  bool contains(String productId) => _itemsById.containsKey(productId);

  FavoriteState copyWith({
    Map<String, ProductModel>? itemsById,
    bool? isLoaded,
    Set<String>? pendingSyncIds,
  }) {
    return FavoriteState(
      itemsById: itemsById ?? _itemsById,
      isLoaded: isLoaded ?? this.isLoaded,
      pendingSyncIds: pendingSyncIds ?? _pendingSyncIds,
    );
  }
}
