class ShopOption {
  const ShopOption({
    this.id = 0,
    this.shopId = '',
    required this.storeName,
    required this.branchLabel,
    required this.imageUrl,
    this.guestAllowed = true,
    this.displayOrder = 0,
  });

  final int id;
  final String shopId;
  final String storeName;
  final String branchLabel;
  final String imageUrl;
  final bool guestAllowed;
  final int displayOrder;

  factory ShopOption.fromJson(Map<String, dynamic> json) => ShopOption(
        id: json['id'] as int? ?? 0,
        shopId: json['shopId'] as String? ?? '',
        storeName: json['storeName'] as String? ?? '',
        branchLabel: json['branchLabel'] as String? ?? '',
        imageUrl: json['imageUrl'] as String? ?? '',
        guestAllowed: json['guestAllowed'] as bool? ?? true,
        displayOrder: json['displayOrder'] as int? ?? 0,
      );
}
