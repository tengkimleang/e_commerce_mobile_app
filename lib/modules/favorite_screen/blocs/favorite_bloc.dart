import 'dart:convert';

import 'package:e_commerce_mobile_app/core/models/product_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'favorite_event.dart';
import 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  FavoriteBloc(this._prefs) : super(const FavoriteState()) {
    on<FavoriteLoadRequested>(_onLoadRequested);
    on<FavoriteToggled>(_onToggled);
    on<FavoriteRemoved>(_onRemoved);
    on<FavoriteCleared>(_onCleared);
  }

  static const _storageKey = 'favorite_products';
  final SharedPreferences _prefs;

  Future<void> _onLoadRequested(
    FavoriteLoadRequested event,
    Emitter<FavoriteState> emit,
  ) async {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.trim().isEmpty) {
      emit(state.copyWith(itemsById: const {}, isLoaded: true));
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      final values = decoded is List ? decoded : const [];
      final loaded = <String, ProductModel>{};

      for (final item in values) {
        if (item is! Map) continue;
        final normalized = item.map(
          (key, value) => MapEntry(key.toString(), value),
        );
        final model = ProductModel.fromJson(
          normalized,
        ).copyWith(isFavorite: true);
        if (model.id.trim().isEmpty) continue;
        loaded[model.id] = model;
      }

      emit(state.copyWith(itemsById: loaded, isLoaded: true));
    } catch (_) {
      emit(state.copyWith(itemsById: const {}, isLoaded: true));
    }
  }

  Future<void> _onToggled(
    FavoriteToggled event,
    Emitter<FavoriteState> emit,
  ) async {
    final productId = event.product.id.trim();
    if (productId.isEmpty) return;

    final updated = Map<String, ProductModel>.from(state.itemsById);
    if (updated.containsKey(productId)) {
      updated.remove(productId);
    } else {
      updated[productId] = event.product.copyWith(isFavorite: true);
    }

    emit(state.copyWith(itemsById: updated, isLoaded: true));
    await _persist(updated);
  }

  Future<void> _onRemoved(
    FavoriteRemoved event,
    Emitter<FavoriteState> emit,
  ) async {
    final productId = event.productId.trim();
    if (productId.isEmpty || !state.itemsById.containsKey(productId)) return;

    final updated = Map<String, ProductModel>.from(state.itemsById)
      ..remove(productId);
    emit(state.copyWith(itemsById: updated, isLoaded: true));
    await _persist(updated);
  }

  Future<void> _onCleared(
    FavoriteCleared event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(state.copyWith(itemsById: const {}, isLoaded: true));
    await _prefs.remove(_storageKey);
  }

  Future<void> _persist(Map<String, ProductModel> itemsById) async {
    final payload = itemsById.values
        .map((product) => product.copyWith(isFavorite: true).toJson())
        .toList(growable: false);
    await _prefs.setString(_storageKey, jsonEncode(payload));
  }
}
