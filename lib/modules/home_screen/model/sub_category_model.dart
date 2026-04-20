import 'package:equatable/equatable.dart';

class SubCategoryModel extends Equatable {
  final int id;
  final String name;
  final String imageUrl;
  final int displayOrder;

  const SubCategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.displayOrder,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      imageUrl: (json['imageUrl'] as String?) ?? '',
      displayOrder: (json['displayOrder'] as int?) ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, imageUrl, displayOrder];
}
