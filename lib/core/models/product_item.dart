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

  /// Optional country of origin (e.g. "Cambodia", "USA", "Japan").
  /// When set, a country flag badge is shown on product cards and the detail view.
  /// BE contract: returned as nullable string field `countryOfOrigin` in the product JSON.
  final String? countryOfOrigin;

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
    this.countryOfOrigin,
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
    String? countryOfOrigin,
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
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawOriginalPrice = (json['originalPrice'] as num?)?.toDouble();
    final rawDiscountPercent = (json['discountPercent'] as num?)?.toInt();
    final rawSubCategoryId = (json['subCategoryId'] as num?)?.toInt();
    final rawSubCategoryName = (json['subCategoryName'] as String? ?? '')
        .trim();
    final rawCountryOfOrigin = (json['countryOfOrigin'] as String? ?? '')
        .trim();
    final rawIsFavorite = json['isFavorite'];
    final isFavorite = rawIsFavorite is bool
        ? rawIsFavorite
        : (rawIsFavorite is num ? rawIsFavorite != 0 : false);
    return ProductModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] as String?) ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (rawOriginalPrice != null && rawOriginalPrice > 0)
          ? rawOriginalPrice
          : null,
      imageUrl: (json['imageUrl'] as String?) ?? '',
      discountPercent: (rawDiscountPercent != null && rawDiscountPercent > 0)
          ? rawDiscountPercent
          : null,
      isFavorite: isFavorite,
      subCategoryId: rawSubCategoryId,
      subCategoryName: rawSubCategoryName.isNotEmpty
          ? rawSubCategoryName
          : null,
      countryOfOrigin: rawCountryOfOrigin.isNotEmpty
          ? rawCountryOfOrigin
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'discountPercent': discountPercent,
      'isFavorite': isFavorite,
      'subCategoryId': subCategoryId,
      'subCategoryName': subCategoryName,
      'countryOfOrigin': countryOfOrigin,
    };
  }
}

/// Backward-compatible alias — remove usages over time.
typedef ProductItem = ProductModel;
