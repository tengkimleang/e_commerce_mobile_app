import 'package:e_commerce_mobile_app/core/models/product_item.dart';

class CartState {
  final Map<String, CartLine> lines;

  const CartState({this.lines = const {}});

  int get distinctItemCount => lines.length;

  bool contains(String productId) => lines.containsKey(productId);

  int quantityFor(String productId) => lines[productId]?.quantity ?? 0;

  List<CartItemViewModel> get items => lines.values
      .map((l) => CartItemViewModel(product: l.product, quantity: l.quantity))
      .toList(growable: false);

  double get totalAmount => lines.values.fold(
        0.0,
        (sum, l) => sum + (l.product.price * l.quantity),
      );

  CartState copyWith({Map<String, CartLine>? lines}) =>
      CartState(lines: lines ?? this.lines);
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

  const CartItemViewModel({required this.product, required this.quantity});
}
