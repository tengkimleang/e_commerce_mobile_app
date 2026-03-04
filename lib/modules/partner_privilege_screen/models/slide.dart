class SliderModel {
  final String imageUrl;
  final int orderId;

  const SliderModel({required this.imageUrl, required this.orderId});

  factory SliderModel.fromJson(Map<String, dynamic> json) {
    return SliderModel(
      imageUrl: (json['imageUrl'] ?? '').toString(),
      orderId: _toInt(json['orderId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'imageUrl': imageUrl, 'orderId': orderId};
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
