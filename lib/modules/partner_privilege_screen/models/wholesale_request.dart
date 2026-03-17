class WholesaleRequest {
  final int id;
  final String customerName;
  final String phoneNumber;
  final List<String> productImageUrls;
  final String remark;
  final String createdDate;

  const WholesaleRequest({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    required this.productImageUrls,
    required this.remark,
    required this.createdDate,
  });

  factory WholesaleRequest.fromJson(Map<String, dynamic> json) {
    return WholesaleRequest(
      id: (json['id'] as num).toInt(),
      customerName: (json['customerName'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      productImageUrls: (json['productImageUrl'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      remark: (json['remark'] ?? '').toString(),
      createdDate: (json['createdDate'] ?? '').toString(),
    );
  }
}
