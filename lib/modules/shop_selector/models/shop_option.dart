class ShopOption {
  const ShopOption({
    this.id = 0,
    this.shopId = '',
    required this.storeName,
    required this.branchLabel,
    required this.imageUrl,
    this.guestAllowed = true,
    this.displayOrder = 0,
    this.latitude,
    this.longitude,
    this.distanceKm,
  });

  final int id;
  final String shopId;
  final String storeName;
  final String branchLabel;
  final String imageUrl;
  final bool guestAllowed;
  final int displayOrder;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;

  factory ShopOption.fromJson(Map<String, dynamic> json) => ShopOption(
        id: json['id'] as int? ?? 0,
        shopId: json['shopId'] as String? ?? '',
        storeName: json['storeName'] as String? ?? '',
        branchLabel: json['branchLabel'] as String? ?? '',
        imageUrl: json['imageUrl'] as String? ?? '',
        guestAllowed: json['guestAllowed'] as bool? ?? true,
        displayOrder: json['displayOrder'] as int? ?? 0,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );

  ShopOption withDistance(double? km) => ShopOption(
        id: id,
        shopId: shopId,
        storeName: storeName,
        branchLabel: branchLabel,
        imageUrl: imageUrl,
        guestAllowed: guestAllowed,
        displayOrder: displayOrder,
        latitude: latitude,
        longitude: longitude,
        distanceKm: km,
      );
}
