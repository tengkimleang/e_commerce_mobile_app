import 'package:equatable/equatable.dart';
import 'package:e_commerce_mobile_app/core/models/product_item.dart';

   class CategoryModel extends Equatable {
  final int id;
  final String nameEn;
  final String nameKm;
  final String bannerImageUrl;
  final int displayOrder;
  final bool isActive;
  final DateTime? promoStartAt;
  final DateTime? promoEndAt;
  final List<ProductModel> previewProducts;

  const CategoryModel({
    required this.id,
    required this.nameEn,
    required this.nameKm,
    required this.bannerImageUrl,
    required this.displayOrder,
    this.isActive = true,
    this.promoStartAt,
    this.promoEndAt,
    this.previewProducts = const [],
  });

  /// Shows Khmer name when available, falls back to English.
  String get displayTitle => nameKm.isNotEmpty ? nameKm : nameEn;

  /// Formats promo date range as "1-31 មេសា" using the exact end day from BE.
  String? get promoLabel {
    if (promoStartAt == null || promoEndAt == null) return null;
    const khmerMonths = [
      'មករា', 'កុម្ភៈ', 'មីនា', 'មេសា', 'ឧសភា', 'មិថុនា',
      'កក្កដា', 'សីហា', 'កញ្ញា', 'តុលា', 'វិច្ឆិកា', 'ធ្នូ',
    ];
    return '1-${promoEndAt!.day} ${khmerMonths[promoEndAt!.month - 1]}';
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      nameEn: (json['nameEn'] as String?) ?? '',
      nameKm: (json['nameKm'] as String?) ?? '',
      bannerImageUrl: (json['bannerImageUrl'] as String?) ?? '',
      displayOrder: (json['displayOrder'] as int?) ?? 0,
      isActive: (json['isActive'] as bool?) ?? true,
      promoStartAt: json['promoStartAt'] != null      
          ? DateTime.tryParse(json['promoStartAt'] as String)
          : null,
      promoEndAt: json['promoEndAt'] != null
          ? DateTime.tryParse(json['promoEndAt'] as String)
          : null,
      previewProducts: (json['previewProducts'] as List<dynamic>?)
              ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  @override
  List<Object?> get props => [
        id, nameEn, nameKm, bannerImageUrl, displayOrder, isActive,
        promoStartAt, promoEndAt,
      ];
}

