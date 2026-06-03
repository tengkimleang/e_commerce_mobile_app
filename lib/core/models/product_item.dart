import 'package:e_commerce_mobile_app/core/localization/app_language.dart';

/// Unified product model used across the entire application.
/// Replaces both the old `ProductItem` and `ProductModel` duplicates.
class ProductModel {
  final String id;
  final String name;
  final String nameEn;
  final String nameKm;
  final String descriptionEn;
  final String descriptionKm;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final List<String> imageUrls;
  final int? discountPercent;
  final bool isFavorite;
  final int? subCategoryId;
  final String? subCategoryName;

  /// Optional country of origin (e.g. "Cambodia", "USA", "Japan").
  /// When set, a country flag badge is shown on product cards and the detail view.
  /// BE contract: returned as nullable string field `countryOfOrigin` in the product JSON.
  final String? countryOfOrigin;

  /// True when the selected branch has zero stock for this product.
  /// BE contract: `isOutOfStock` bool field in product JSON, resolved per `shopId`.
  /// Falls back to `!isAvailable` for backward-compat. Defaults to false when no shopId supplied.
  final bool isOutOfStock;

  /// Raw stock quantity for the selected branch. Null when shopId is omitted.
  /// BE contract: optional `stockQty` int field in product JSON.
  final int? stockQty;

  /// EAN-13 / UPC / QR barcode assigned to this product.
  /// BE contract: nullable string field `barcode` in the product JSON.
  final String? barcode;

  const ProductModel({
    required this.id,
    required this.name,
    this.nameEn = '',
    this.nameKm = '',
    this.descriptionEn = '',
    this.descriptionKm = '',
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.imageUrls = const [],
    this.discountPercent,
    this.isFavorite = false,
    this.subCategoryId,
    this.subCategoryName,
    this.countryOfOrigin,
    this.isOutOfStock = false,
    this.stockQty,
    this.barcode,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? nameKm,
    String? descriptionEn,
    String? descriptionKm,
    double? price,
    double? originalPrice,
    String? imageUrl,
    List<String>? imageUrls,
    int? discountPercent,
    bool? isFavorite,
    int? subCategoryId,
    String? subCategoryName,
    String? countryOfOrigin,
    bool? isOutOfStock,
    int? stockQty,
    String? barcode,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      nameKm: nameKm ?? this.nameKm,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionKm: descriptionKm ?? this.descriptionKm,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      discountPercent: discountPercent ?? this.discountPercent,
      isFavorite: isFavorite ?? this.isFavorite,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      subCategoryName: subCategoryName ?? this.subCategoryName,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      isOutOfStock: isOutOfStock ?? this.isOutOfStock,
      stockQty: stockQty ?? this.stockQty,
      barcode: barcode ?? this.barcode,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final parsedImageUrls = _parseImageUrls(json);
    final primaryImageUrl = ((json['imageUrl'] as String?) ?? '').trim();
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

    // isOutOfStock: prefer explicit field; fall back to !isAvailable for
    // backward-compat while both fields coexist in the BE response.
    final rawIsOutOfStock = json['isOutOfStock'];
    final rawIsAvailable = json['isAvailable'];
    final bool isOutOfStock;
    if (rawIsOutOfStock != null) {
      isOutOfStock = rawIsOutOfStock is bool
          ? rawIsOutOfStock
          : (rawIsOutOfStock is num ? rawIsOutOfStock != 0 : false);
    } else if (rawIsAvailable != null) {
      final isAvailable = rawIsAvailable is bool
          ? rawIsAvailable
          : (rawIsAvailable is num ? rawIsAvailable != 0 : true);
      isOutOfStock = !isAvailable;
    } else {
      isOutOfStock = false;
    }
    final rawStockQty = (json['stockQty'] as num?)?.toInt();

    final legacyName = (json['name'] as String?) ?? '';
    final nameEn = (json['nameEn'] as String?) ?? legacyName;
    final nameKm = (json['nameKm'] as String?) ?? '';

    return ProductModel(
      id: (json['id'] ?? '').toString(),
      name: legacyName,
      nameEn: nameEn,
      nameKm: nameKm,
      descriptionEn: (json['descriptionEn'] as String?) ?? '',
      descriptionKm: (json['descriptionKm'] as String?) ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (rawOriginalPrice != null && rawOriginalPrice > 0)
          ? rawOriginalPrice
          : null,
      imageUrl: primaryImageUrl.isNotEmpty
          ? primaryImageUrl
          : (parsedImageUrls.isNotEmpty ? parsedImageUrls.first : ''),
      imageUrls: parsedImageUrls,
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
      isOutOfStock: isOutOfStock,
      stockQty: rawStockQty,
      barcode: json['barcode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'nameKm': nameKm,
      'descriptionEn': descriptionEn,
      'descriptionKm': descriptionKm,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'discountPercent': discountPercent,
      'isFavorite': isFavorite,
      'subCategoryId': subCategoryId,
      'subCategoryName': subCategoryName,
      'countryOfOrigin': countryOfOrigin,
      'isOutOfStock': isOutOfStock,
      'stockQty': stockQty,
      'barcode': barcode,
    };
  }

  List<String> get galleryImages {
    final seen = <String>{};
    final images = <String>[];

    void addIfPresent(String value) {
      final trimmed = value.trim();
      if (trimmed.isEmpty || !seen.add(trimmed)) return;
      images.add(trimmed);
    }

    addIfPresent(imageUrl);
    for (final image in imageUrls) {
      addIfPresent(image);
    }

    return images;
  }

  String get displayName => displayNameFor(AppLanguage.currentLanguageCode);

  String displayNameFor(String languageCode) => AppLanguage.localizedText(
    languageCode: languageCode,
    english: nameEn,
    khmer: nameKm,
    legacy: name,
  );

  String displayDescriptionFor(String languageCode) =>
      AppLanguage.localizedText(
        languageCode: languageCode,
        english: descriptionEn,
        khmer: descriptionKm,
      );

  static List<String> _parseImageUrls(Map<String, dynamic> json) {
    final rawGallery =
        json['imageUrls'] ??
        json['images'] ??
        json['galleryImages'] ??
        json['productImages'];

    if (rawGallery is! List) return const [];

    return rawGallery
        .map(_imageUrlFromValue)
        .where((url) => url.isNotEmpty)
        .toList(growable: false);
  }

  static String _imageUrlFromValue(Object? value) {
    if (value is String) return value.trim();
    if (value is Map) {
      for (final key in const ['imageUrl', 'url', 'path']) {
        final rawUrl = value[key];
        if (rawUrl is String && rawUrl.trim().isNotEmpty) {
          return rawUrl.trim();
        }
      }
    }
    return '';
  }
}

/// Backward-compatible alias — remove usages over time.
typedef ProductItem = ProductModel;
