class PriceCheckingResult {
  final String code;
  final String? name;
  final double? price;

  const PriceCheckingResult({required this.code, this.name, this.price});
}

class PriceCheckingModel {
  final String inputCode;
  final PriceCheckingResult? result;

  const PriceCheckingModel({this.inputCode = '', this.result});

  PriceCheckingModel copyWith({
    String? inputCode,
    PriceCheckingResult? result,
  }) {
    return PriceCheckingModel(
      inputCode: inputCode ?? this.inputCode,
      result: result ?? this.result,
    );
  }
}
