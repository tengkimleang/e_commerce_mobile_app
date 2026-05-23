import 'package:equatable/equatable.dart';

enum NotificationPromotionType { category, content }

class NotificationPromotionEntry extends Equatable {
  const NotificationPromotionEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
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
  final String imageUrl;
  final int? categoryId;
  final int? displayOrder;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime? publishedAt;
  final DateTime? createdDate;

  bool get isCategory => type == NotificationPromotionType.category;
  bool get isContent => type == NotificationPromotionType.content;

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
    imageUrl,
    categoryId,
    displayOrder,
    startsAt,
    endsAt,
    publishedAt,
    createdDate,
  ];
}
