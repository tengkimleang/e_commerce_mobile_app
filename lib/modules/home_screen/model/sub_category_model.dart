import 'package:equatable/equatable.dart';
import 'package:e_commerce_mobile_app/core/localization/app_language.dart';

class SubCategoryModel extends Equatable {
  final int id;
  final String name;
  final String nameEn;
  final String nameKm;
  final String imageUrl;
  final int displayOrder;

  const SubCategoryModel({
    required this.id,
    required this.name,
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
    legacy: name,
  );

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    final legacyName = (json['name'] as String?) ?? '';
    return SubCategoryModel(
      id: json['id'] as int,
      name: legacyName,
      nameEn: (json['nameEn'] as String?) ?? legacyName,
      nameKm: (json['nameKm'] as String?) ?? '',
      imageUrl: (json['imageUrl'] as String?) ?? '',
      displayOrder: (json['displayOrder'] as int?) ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, nameEn, nameKm, imageUrl, displayOrder];
}
