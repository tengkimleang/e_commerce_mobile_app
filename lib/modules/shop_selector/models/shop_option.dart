import 'package:e_commerce_mobile_app/core/localization/app_language.dart';

class ShopOption {
  const ShopOption({
    this.id = 0,
    this.shopId = '',
    required this.storeName,
    this.storeNameEn = '',
    this.storeNameKm = '',
    required this.branchLabel,
    this.branchLabelEn = '',
    this.branchLabelKm = '',
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
  final String storeNameEn;
  final String storeNameKm;
  final String branchLabel;
  final String branchLabelEn;
  final String branchLabelKm;
  final String imageUrl;
  final bool guestAllowed;
  final int displayOrder;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;

  factory ShopOption.fromJson(Map<String, dynamic> json) {
    final legacyStoreName = _readString(json['storeName']);
    final legacyBranchLabel = _readString(json['branchLabel']);

    return ShopOption(
      id: json['id'] as int? ?? 0,
      shopId: json['shopId'] as String? ?? '',
      storeName: legacyStoreName,
      storeNameEn: _readString(json['storeNameEn'], fallback: legacyStoreName),
      storeNameKm: _readString(json['storeNameKm']),
      branchLabel: legacyBranchLabel,
      branchLabelEn: _readString(
        json['branchLabelEn'],
        fallback: legacyBranchLabel,
      ),
      branchLabelKm: _readString(json['branchLabelKm']),
      imageUrl: json['imageUrl'] as String? ?? '',
      guestAllowed: json['guestAllowed'] as bool? ?? true,
      displayOrder: json['displayOrder'] as int? ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  String get displayStoreName =>
      displayStoreNameFor(AppLanguage.currentLanguageCode);

  String displayStoreNameFor(String languageCode) {
    if (languageCode == AppLanguage.khmer && storeNameKm.trim().isNotEmpty) {
      return storeNameKm.trim();
    }
    if (storeNameEn.trim().isNotEmpty) return storeNameEn.trim();
    if (storeName.trim().isNotEmpty) return storeName.trim();
    return storeNameKm.trim();
  }

  String get displayBranchLabel =>
      displayBranchLabelFor(AppLanguage.currentLanguageCode);

  String displayBranchLabelFor(String languageCode) {
    if (languageCode == AppLanguage.khmer && branchLabelKm.trim().isNotEmpty) {
      return branchLabelKm.trim();
    }
    if (branchLabelEn.trim().isNotEmpty) return branchLabelEn.trim();
    if (branchLabel.trim().isNotEmpty) return branchLabel.trim();
    return branchLabelKm.trim();
  }

  ShopOption withDistance(double? km) => ShopOption(
    id: id,
    shopId: shopId,
    storeName: storeName,
    storeNameEn: storeNameEn,
    storeNameKm: storeNameKm,
    branchLabel: branchLabel,
    branchLabelEn: branchLabelEn,
    branchLabelKm: branchLabelKm,
    imageUrl: imageUrl,
    guestAllowed: guestAllowed,
    displayOrder: displayOrder,
    latitude: latitude,
    longitude: longitude,
    distanceKm: km,
  );

  static String _readString(Object? value, {String fallback = ''}) {
    final text = value is String ? value.trim() : '';
    return text.isNotEmpty ? text : fallback;
  }
}
