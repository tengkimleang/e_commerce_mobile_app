import 'package:equatable/equatable.dart';
import 'package:e_commerce_mobile_app/core/localization/app_language.dart';

enum NotificationPromotionType { category, content }

class NotificationPromotionEntry extends Equatable {
  const NotificationPromotionEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.titleEn = '',
    this.titleKm = '',
    this.descriptionEn = '',
    this.descriptionKm = '',
    this.contentEn = '',
    this.contentKm = '',
    required this.imageUrl,
    this.categoryId,
    this.displayOrder,
    this.startsAt,
    this.endsAt,
    this.publishedAt,
    this.createdDate,
  });

  final String id;
  final NotificationPromotionType type;
  final String title;
  final String description;
  final String titleEn;
  final String titleKm;
  final String descriptionEn;
  final String descriptionKm;
  final String contentEn;
  final String contentKm;
  final String imageUrl;
  final int? categoryId;
  final int? displayOrder;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime? publishedAt;
  final DateTime? createdDate;

  bool get isCategory => type == NotificationPromotionType.category;
  bool get isContent => type == NotificationPromotionType.content;
  String get displayTitle => displayTitleFor(AppLanguage.currentLanguageCode);
  String get displayDescription =>
      displayDescriptionFor(AppLanguage.currentLanguageCode);

  String displayTitleFor(String languageCode) => AppLanguage.localizedText(
    languageCode: languageCode,
    english: titleEn,
    khmer: titleKm,
    legacy: title,
  );

  String displayDescriptionFor(String languageCode) =>
      AppLanguage.localizedText(
        languageCode: languageCode,
        english: descriptionEn,
        khmer: descriptionKm,
        legacy: description,
      );

  String displayContentFor(String languageCode) => AppLanguage.localizedText(
    languageCode: languageCode,
    english: contentEn,
    khmer: contentKm,
  );

  factory NotificationPromotionEntry.fromJson(Map<String, dynamic> json) {
    final typeText = _asString(json['type']).toLowerCase();
    final type = switch (typeText) {
      'category' => NotificationPromotionType.category,
      'content' => NotificationPromotionType.content,
      _ => throw FormatException('Unsupported promotion type: $typeText'),
    };

    return NotificationPromotionEntry(
      id: _asString(json['id']),
      type: type,
      title: _asString(json['title']),
      description: _asString(json['description']),
      titleEn: _firstNonEmpty([json['titleEn'], json['title']]),
      titleKm: _asString(json['titleKm']),
      descriptionEn: _firstNonEmpty([
        json['descriptionEn'],
        json['description'],
      ]),
      descriptionKm: _asString(json['descriptionKm']),
      contentEn: _asString(json['contentEn']),
      contentKm: _asString(json['contentKm']),
      imageUrl: _asString(json['imageUrl']),
      categoryId: _asInt(json['categoryId']),
      displayOrder: _asInt(json['displayOrder']),
      startsAt: _asDate(json['startsAt']),
      endsAt: _asDate(json['endsAt']),
      publishedAt: _asDate(json['publishedAt']),
      createdDate: _asDate(json['createdDate']),
    );
  }

  DateTime? get sortDate => publishedAt ?? startsAt ?? createdDate;

  static String _asString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = _asString(value);
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(_asString(value));
  }

  static DateTime? _asDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }

    final text = _asString(value);
    if (text.isEmpty) return null;
    return DateTime.tryParse(text)?.toLocal();
  }

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    description,
    titleEn,
    titleKm,
    descriptionEn,
    descriptionKm,
    contentEn,
    contentKm,
    imageUrl,
    categoryId,
    displayOrder,
    startsAt,
    endsAt,
    publishedAt,
    createdDate,
  ];
}
