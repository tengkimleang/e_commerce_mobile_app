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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawOriginalPrice = (json['originalPrice'] as num?)?.toDouble();
    final rawDiscountPercent = (json['discountPercent'] as num?)?.toInt();
    return ProductModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] as String?) ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (rawOriginalPrice != null && rawOriginalPrice > 0) ? rawOriginalPrice : null,
      imageUrl: (json['imageUrl'] as String?) ?? '',
      discountPercent: (rawDiscountPercent != null && rawDiscountPercent > 0) ? rawDiscountPercent : null,
    );
  }
}

/// Backward-compatible alias — remove usages over time.
typedef ProductItem = ProductModel;
