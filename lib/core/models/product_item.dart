class ProductItem {
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final int? discountPercent;
  final bool isFavorite;

  const ProductItem({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.discountPercent,
    this.isFavorite = false,
  });
}
