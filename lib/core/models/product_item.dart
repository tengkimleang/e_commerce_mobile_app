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
  final int? subCategoryId;
  final String? subCategoryName;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.discountPercent,
    this.isFavorite = false,
    this.subCategoryId,
    this.subCategoryName,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    double? originalPrice,
    String? imageUrl,
    int? discountPercent,
    bool? isFavorite,
    int? subCategoryId,
    String? subCategoryName,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      discountPercent: discountPercent ?? this.discountPercent,
      isFavorite: isFavorite ?? this.isFavorite,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      subCategoryName: subCategoryName ?? this.subCategoryName,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawOriginalPrice = (json['originalPrice'] as num?)?.toDouble();
    final rawDiscountPercent = (json['discountPercent'] as num?)?.toInt();
    final rawSubCategoryId = (json['subCategoryId'] as num?)?.toInt();
    final rawSubCategoryName = (json['subCategoryName'] as String? ?? '').trim();
    return ProductModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] as String?) ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (rawOriginalPrice != null && rawOriginalPrice > 0) ? rawOriginalPrice : null,
      imageUrl: (json['imageUrl'] as String?) ?? '',
      discountPercent: (rawDiscountPercent != null && rawDiscountPercent > 0) ? rawDiscountPercent : null,
      subCategoryId: rawSubCategoryId,
      subCategoryName: rawSubCategoryName.isNotEmpty ? rawSubCategoryName : null,
    );
  }
}

/// Backward-compatible alias — remove usages over time.
typedef ProductItem = ProductModel;
