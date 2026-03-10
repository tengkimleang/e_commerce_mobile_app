import 'package:e_commerce_mobile_app/core/models/product_item.dart';

abstract class CartEvent {
  const CartEvent();
}

class AddToCart extends CartEvent {
  final ProductModel product;
  const AddToCart(this.product);
}

class IncreaseQuantity extends CartEvent {
  final String productId;
  const IncreaseQuantity(this.productId);
}

class DecreaseQuantity extends CartEvent {
  final String productId;
  const DecreaseQuantity(this.productId);
}

class RemoveFromCart extends CartEvent {
  final String productId;
  const RemoveFromCart(this.productId);
}

class ClearCart extends CartEvent {
  const ClearCart();
}
