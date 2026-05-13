import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';

import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc()
    : super(
        CartState(
          activeBranchId: _normalizedBranchId(UserSession.selectedShopId),
        ),
      ) {
    on<AddToCart>(_onAdd);
    on<IncreaseQuantity>(_onIncrease);
    on<DecreaseQuantity>(_onDecrease);
    on<RemoveFromCart>(_onRemove);
    on<ClearCart>(_onClear);
    on<ChangeCartBranch>(_onChangeBranch);
  }

  void _onAdd(AddToCart event, Emitter<CartState> emit) {
    final updated = _cloneActiveLines();
    final existing = updated[event.product.id];
    if (existing != null) {
      final maxQty = existing.product.stockQty;
      if (maxQty != null && existing.quantity >= maxQty) return;
      updated[event.product.id] = existing.copyWith(
        quantity: existing.quantity + 1,
      );
    } else {
      updated[event.product.id] = CartLine(product: event.product, quantity: 1);
    }
    _emitActiveLines(emit, updated);
  }

  void _onIncrease(IncreaseQuantity event, Emitter<CartState> emit) {
    final existing = state.lines[event.productId];
    if (existing == null) return;
    final maxQty = existing.product.stockQty;
    if (maxQty != null && existing.quantity >= maxQty) return;
    final updated = _cloneActiveLines();
    updated[event.productId] = existing.copyWith(
      quantity: existing.quantity + 1,
    );
    _emitActiveLines(emit, updated);
  }

  void _onDecrease(DecreaseQuantity event, Emitter<CartState> emit) {
    final existing = state.lines[event.productId];
    if (existing == null) return;
    final updated = _cloneActiveLines();
    if (existing.quantity <= 1) {
      updated.remove(event.productId);
    } else {
      updated[event.productId] = existing.copyWith(
        quantity: existing.quantity - 1,
      );
    }
    _emitActiveLines(emit, updated);
  }

  void _onRemove(RemoveFromCart event, Emitter<CartState> emit) {
    final updated = _cloneActiveLines();
    updated.remove(event.productId);
    _emitActiveLines(emit, updated);
  }

  void _onClear(ClearCart event, Emitter<CartState> emit) {
    final activeBranchId = _activeBranchId();
    final updatedByBranch = Map<String, Map<String, CartLine>>.from(
      state.linesByBranch,
    )..remove(activeBranchId);
    emit(state.copyWith(linesByBranch: updatedByBranch));
  }

  void _onChangeBranch(ChangeCartBranch event, Emitter<CartState> emit) {
    final nextBranchId = _normalizedBranchId(event.branchId);
    if (nextBranchId == state.activeBranchId) return;
    emit(state.copyWith(activeBranchId: nextBranchId));
  }

  Map<String, CartLine> _cloneActiveLines() {
    final activeBranchId = _activeBranchId();
    return Map<String, CartLine>.from(
      state.linesByBranch[activeBranchId] ?? const {},
    );
  }

  void _emitActiveLines(
    Emitter<CartState> emit,
    Map<String, CartLine> activeLines,
  ) {
    final activeBranchId = _activeBranchId();
    final updatedByBranch = Map<String, Map<String, CartLine>>.from(
      state.linesByBranch,
    );
    if (activeLines.isEmpty) {
      updatedByBranch.remove(activeBranchId);
    } else {
      updatedByBranch[activeBranchId] = activeLines;
    }
    emit(
      state.copyWith(
        activeBranchId: activeBranchId,
        linesByBranch: updatedByBranch,
      ),
    );
  }

  String _activeBranchId() {
    final current = _normalizedBranchId(state.activeBranchId);
    if (current.isNotEmpty) return current;
    return _normalizedBranchId(UserSession.selectedShopId);
  }

  static String _normalizedBranchId(String raw) {
    return raw.trim();
  }
}
