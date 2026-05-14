import 'package:e_commerce_mobile_app/core/models/product_item.dart';

class CartState {
  final String activeBranchId;
  final Map<String, Map<String, CartLine>> linesByBranch;

  const CartState({this.activeBranchId = '', this.linesByBranch = const {}});

  Map<String, CartLine> get lines => linesByBranch[activeBranchId] ?? const {};

  int get distinctItemCount => lines.length;

  bool contains(String productId) => lines.containsKey(productId);

  int quantityFor(String productId) => lines[productId]?.quantity ?? 0;

  List<CartItemViewModel> get items => lines.values
      .map((l) => CartItemViewModel(product: l.product, quantity: l.quantity))
      .toList(growable: false);

  double get totalAmount =>
      lines.values.fold(0.0, (sum, l) => sum + (l.product.price * l.quantity));

  CartState copyWith({
    String? activeBranchId,
    Map<String, Map<String, CartLine>>? linesByBranch,
  }) => CartState(
    activeBranchId: activeBranchId ?? this.activeBranchId,
    linesByBranch: linesByBranch ?? this.linesByBranch,
  );
}

class CartLine {
  final ProductModel product;
  final int quantity;

  const CartLine({required this.product, required this.quantity});

  CartLine copyWith({int? quantity}) =>
      CartLine(product: product, quantity: quantity ?? this.quantity);
}

class CartItemViewModel {
  final ProductModel product;
  final int quantity;
  final String cancelReasonCode;
  final String cancelReasonNote;

  const CartItemViewModel({
    required this.product,
    required this.quantity,
    this.cancelReasonCode = '',
    this.cancelReasonNote = '',
  });
}
