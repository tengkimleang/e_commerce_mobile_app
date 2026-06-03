import 'package:equatable/equatable.dart';
import 'package:e_commerce_mobile_app/core/localization/app_language.dart';

class ShopByCategoryModel extends Equatable {
  const ShopByCategoryModel({
    required this.id,
    this.categoryId,
    required this.titleEn,
    required this.titleKm,
    required this.imageUrl,
    required this.displayOrder,
    this.isActive = true,
  });

  final int id;
  final int? categoryId;
  final String titleEn;
  final String titleKm;
  final String imageUrl;
  final int displayOrder;
  final bool isActive;

  String get displayTitle => displayTitleFor(AppLanguage.currentLanguageCode);

  String displayTitleFor(String languageCode) => AppLanguage.localizedText(
    languageCode: languageCode,
    english: titleEn,
    khmer: titleKm,
  );

  factory ShopByCategoryModel.fromJson(Map<String, dynamic> json) {
    final titleEn = _firstNonEmpty([
      json['titleEn'],
      json['nameEn'],
      json['title'],
      json['name'],
    ]);
    final titleKm = _firstNonEmpty([json['titleKm'], json['nameKm']]);

    return ShopByCategoryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      categoryId: (json['categoryId'] as num?)?.toInt(),
      titleEn: titleEn,
      titleKm: titleKm,
      imageUrl: _firstNonEmpty([json['imageUrl'], json['bannerImageUrl']]),
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      isActive: (json['isActive'] as bool?) ?? true,
    );
  }

  static String _firstNonEmpty(List<Object?> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  @override
  List<Object?> get props => [
    id,
    categoryId,
    titleEn,
    titleKm,
    imageUrl,
    displayOrder,
    isActive,
  ];
}
