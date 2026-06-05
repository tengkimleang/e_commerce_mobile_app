import 'package:equatable/equatable.dart';
import 'package:e_commerce_mobile_app/core/localization/app_language.dart';

class SubCategoryModel extends Equatable {
  final int id;
  final String nameEn;
  final String nameKm;
  final String imageUrl;
  final int displayOrder;

  const SubCategoryModel({
    required this.id,
    this.nameEn = '',
    this.nameKm = '',
    required this.imageUrl,
    required this.displayOrder,
  });

  String get displayName => displayNameFor(AppLanguage.currentLanguageCode);

  String displayNameFor(String languageCode) => AppLanguage.localizedText(
    languageCode: languageCode,
    english: nameEn,
    khmer: nameKm,
  );

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'] as int,
      nameEn: (json['nameEn'] as String? ?? '').trim(),
      nameKm: (json['nameKm'] as String? ?? '').trim(),
      imageUrl: (json['imageUrl'] as String?) ?? '',
      displayOrder: (json['displayOrder'] as int?) ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, nameEn, nameKm, imageUrl, displayOrder];
}
