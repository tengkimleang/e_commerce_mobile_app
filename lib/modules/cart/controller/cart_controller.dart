import 'package:flutter/foundation.dart';

import 'package:e_commerce_mobile_app/modules/home_screen/model/product_model.dart';

class CartController extends ChangeNotifier {
  CartController._();

  static final CartController instance = CartController._();

  final Map<String, _CartLine> _lines = {};

  int get distinctItemCount => _lines.length;

  int quantityFor(String productId) => _lines[productId]?.quantity ?? 0;

  bool contains(String productId) => _lines.containsKey(productId);

  List<CartItemViewModel> get items => _lines.values
      .map(
        (line) =>
            CartItemViewModel(product: line.product, quantity: line.quantity),
      )
      .toList(growable: false);

  double get totalAmount => _lines.values.fold(
    0.0,
    (sum, line) => sum + (line.product.price * line.quantity),
  );

  void addProduct(ProductModel product) {
    final line = _lines[product.id];
    if (line == null) {
      _lines[product.id] = _CartLine(product: product, quantity: 1);
    } else {
      line.quantity += 1;
    }
    notifyListeners();
  }

  void increase(String productId) {
    final line = _lines[productId];
    if (line == null) return;
    line.quantity += 1;
    notifyListeners();
  }

  void decrease(String productId) {
    final line = _lines[productId];
    if (line == null) return;

    if (line.quantity <= 1) {
      _lines.remove(productId);
    } else {
      line.quantity -= 1;
    }
    notifyListeners();
  }

  void remove(String productId) {
    if (_lines.remove(productId) != null) {
      notifyListeners();
    }
  }

  void clear() {
    if (_lines.isEmpty) return;
    _lines.clear();
    notifyListeners();
  }
}

class CartItemViewModel {
  const CartItemViewModel({required this.product, required this.quantity});

  final ProductModel product;
  final int quantity;
}

class _CartLine {
  _CartLine({required this.product, required this.quantity});

  final ProductModel product;
  int quantity;
}
