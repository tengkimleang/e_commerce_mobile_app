/// Unified product model used across the entire application.
/// Replaces both the old `ProductItem` and `ProductModel` duplicates.
class ProductModel {
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final int? discountPercent;
  final bool isFavorite;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.discountPercent,
    this.isFavorite = false,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    double? originalPrice,
    String? imageUrl,
    int? discountPercent,
    bool? isFavorite,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      discountPercent: discountPercent ?? this.discountPercent,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// Backward-compatible alias — remove usages over time.
typedef ProductItem = ProductModel;
