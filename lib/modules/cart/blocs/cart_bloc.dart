import 'package:flutter_bloc/flutter_bloc.dart';

import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddToCart>(_onAdd);
    on<IncreaseQuantity>(_onIncrease);
    on<DecreaseQuantity>(_onDecrease);
    on<RemoveFromCart>(_onRemove);
    on<ClearCart>(_onClear);
  }

  void _onAdd(AddToCart event, Emitter<CartState> emit) {
    final updated = Map<String, CartLine>.from(state.lines);
    final existing = updated[event.product.id];
    if (existing != null) {
      updated[event.product.id] =
          existing.copyWith(quantity: existing.quantity + 1);
    } else {
      updated[event.product.id] =
          CartLine(product: event.product, quantity: 1);
    }
    emit(state.copyWith(lines: updated));
  }

  void _onIncrease(IncreaseQuantity event, Emitter<CartState> emit) {
    final existing = state.lines[event.productId];
    if (existing == null) return;
    final updated = Map<String, CartLine>.from(state.lines);
    updated[event.productId] =
        existing.copyWith(quantity: existing.quantity + 1);
    emit(state.copyWith(lines: updated));
  }

  void _onDecrease(DecreaseQuantity event, Emitter<CartState> emit) {
    final existing = state.lines[event.productId];
    if (existing == null) return;
    final updated = Map<String, CartLine>.from(state.lines);
    if (existing.quantity <= 1) {
      updated.remove(event.productId);
    } else {
      updated[event.productId] =
          existing.copyWith(quantity: existing.quantity - 1);
    }
    emit(state.copyWith(lines: updated));
  }

  void _onRemove(RemoveFromCart event, Emitter<CartState> emit) {
    final updated = Map<String, CartLine>.from(state.lines);
    updated.remove(event.productId);
    emit(state.copyWith(lines: updated));
  }

  void _onClear(ClearCart event, Emitter<CartState> emit) {
    emit(const CartState());
  }
}
