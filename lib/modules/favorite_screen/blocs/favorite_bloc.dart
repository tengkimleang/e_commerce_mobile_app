import 'dart:convert';

import 'package:e_commerce_mobile_app/core/models/product_item.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/repositories/favorites_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'favorite_event.dart';
import 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  FavoriteBloc(this._prefs, this._repository) : super(const FavoriteState()) {
    on<FavoriteLoadRequested>(_onLoadRequested);
    on<FavoriteToggled>(_onToggled);
    on<FavoriteRemoved>(_onRemoved);
    on<FavoriteCleared>(_onCleared);
    on<FavoriteMigrationRequested>(_onMigrationRequested);
  }

  static const _storageKey = 'favorite_products';
  static const _pendingSyncKey = 'favorite_pending_sync';

  final SharedPreferences _prefs;
  final FavoritesRepository _repository;

  // ─── Load ────────────────────────────────────────────────────────────────

  Future<void> _onLoadRequested(
    FavoriteLoadRequested event,
    Emitter<FavoriteState> emit,
  ) async {
    // Step 1: Always hydrate from local storage first (instant, offline-safe).
    final localItems = _readLocalItems();

    emit(state.copyWith(itemsById: localItems, isLoaded: true));

    // Step 2: If the user is authenticated, sync with the server.
    if (!UserSession.isAuthenticated) return;

    // Step 2a: Fetch the authoritative list of favorite IDs from the server.
    // The server is the source of truth for which products are favorited;
    // local storage holds the full ProductModel data (names, images, prices).
    //
    // IMPORTANT: loadFavoriteIds returns null on any failure (network error,
    // auth error, unexpected response format). We must NOT overwrite local
    // storage in that case — only overwrite when the server call genuinely
    // succeeded (returned a List, even if empty).
    final serverIds = await _repository.loadFavoriteIds();
    if (serverIds == null) {
      // Request failed — keep the local state that was already emitted.
      return;
    }

    final serverIdSet = serverIds.toSet();
    var remainingPendingSyncIds = <String>{};

    // Step 2b: Retry pending sync safely.
    //
    // The backend endpoint is "toggle", not explicit add/remove. Replaying a
    // raw toggle can invert state if the original request actually succeeded
    // but the client treated it as failed (timeout / app killed / flaky network).
    //
    // To avoid accidental deletes, compare desired local state vs. current
    // server state first, and only toggle when they differ.
    final pending = _readPendingSyncIds();
    if (pending.isNotEmpty) {
      final stillFailing = <String>{};
      for (final productId in pending) {
        final shouldBeFavorite = localItems.containsKey(productId);
        final isFavoriteOnServer = serverIdSet.contains(productId);

        // Already aligned — nothing to retry.
        if (shouldBeFavorite == isFavoriteOnServer) continue;

        try {
          await _repository.toggleFavorite(productId);
          if (shouldBeFavorite) {
            serverIdSet.add(productId);
          } else {
            serverIdSet.remove(productId);
          }
        } catch (_) {
          stillFailing.add(productId);
        }
      }
      await _savePendingSyncIds(stillFailing);
      remainingPendingSyncIds = stillFailing;
    }

    // Rebuild the map: keep local product data but align the set of IDs
    // with whatever the server says is favorited.
    final merged = <String, ProductModel>{};

    // Products the server says are favorited — keep local data if available.
    for (final id in serverIdSet) {
      if (localItems.containsKey(id)) {
        merged[id] = localItems[id]!;
      }
      // If a product ID is on the server but not locally (e.g. favorited on
      // another device), we have no product data — skip for now.
      // It will appear once the user browses to that product and the UI
      // refreshes its isFavorite flag from the server IDs.
    }

    // Remove any products that are in local storage but NOT on the server
    // (they were un-favorited on another device or session).
    for (final id in localItems.keys) {
      if (serverIdSet.contains(id)) {
        merged[id] = localItems[id]!;
      }
    }

    emit(
      state.copyWith(
        itemsById: merged,
        isLoaded: true,
        pendingSyncIds: remainingPendingSyncIds,
      ),
    );
    await _persist(merged);
  }

  // ─── Toggle ──────────────────────────────────────────────────────────────

  Future<void> _onToggled(
    FavoriteToggled event,
    Emitter<FavoriteState> emit,
  ) async {
    final productId = event.product.id.trim();
    if (productId.isEmpty) return;

    // Optimistic update: update UI and local storage immediately.
    final updated = Map<String, ProductModel>.from(state.itemsById);
    if (updated.containsKey(productId)) {
      updated.remove(productId);
    } else {
      updated[productId] = event.product.copyWith(isFavorite: true);
    }

    emit(state.copyWith(itemsById: updated));
    await _persist(updated);

    // For authenticated users, tell the server.
    if (!UserSession.isAuthenticated) return;

    try {
      await _repository.toggleFavorite(productId);
    } catch (_) {
      // API failed — add to pending set so it will be retried on next load.
      final pending = {...state.pendingSyncIds, productId};
      emit(state.copyWith(pendingSyncIds: pending));
      await _savePendingSyncIds(pending);
    }
  }

  // ─── Remove ──────────────────────────────────────────────────────────────

  Future<void> _onRemoved(
    FavoriteRemoved event,
    Emitter<FavoriteState> emit,
  ) async {
    final productId = event.productId.trim();
    if (productId.isEmpty || !state.itemsById.containsKey(productId)) return;

    final updated = Map<String, ProductModel>.from(state.itemsById)
      ..remove(productId);
    emit(state.copyWith(itemsById: updated));
    await _persist(updated);

    if (!UserSession.isAuthenticated) return;

    try {
      await _repository.toggleFavorite(productId);
    } catch (_) {
      final pending = {...state.pendingSyncIds, productId};
      emit(state.copyWith(pendingSyncIds: pending));
      await _savePendingSyncIds(pending);
    }
  }

  // ─── Clear ───────────────────────────────────────────────────────────────

  Future<void> _onCleared(
    FavoriteCleared event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(state.copyWith(itemsById: const {}, pendingSyncIds: const {}));
    await _prefs.remove(_storageKey);
    await _prefs.remove(_pendingSyncKey);
  }

  // ─── Migration (called once after login) ─────────────────────────────────

  /// Pushes any locally-stored guest favorites to the backend, then reloads
  /// from the server so the state is authoritative.
  Future<void> _onMigrationRequested(
    FavoriteMigrationRequested event,
    Emitter<FavoriteState> emit,
  ) async {
    final localItems = _readLocalItems();

    if (localItems.isNotEmpty) {
      try {
        await _repository.syncFavorites(localItems.keys.toList());
      } catch (_) {
        // Sync failed — the next load will retry via pendingSyncIds.
        final pending = localItems.keys.toSet();
        emit(state.copyWith(pendingSyncIds: pending));
        await _savePendingSyncIds(pending);
      }
    }

    // Re-load from server as the new source of truth.
    add(const FavoriteLoadRequested());
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Map<String, ProductModel> _readLocalItems() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.trim().isEmpty) return const {};

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

      return loaded;
    } catch (_) {
      return const {};
    }
  }

  Set<String> _readPendingSyncIds() {
    final raw = _prefs.getString(_pendingSyncKey);
    if (raw == null || raw.trim().isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const {};
      return decoded.map((e) => e.toString()).toSet();
    } catch (_) {
      return const {};
    }
  }

  Future<void> _savePendingSyncIds(Set<String> ids) async {
    if (ids.isEmpty) {
      await _prefs.remove(_pendingSyncKey);
    } else {
      await _prefs.setString(_pendingSyncKey, jsonEncode(ids.toList()));
    }
  }

  Future<void> _persist(Map<String, ProductModel> itemsById) async {
    final payload = itemsById.values
        .map((product) => product.copyWith(isFavorite: true).toJson())
        .toList(growable: false);
    await _prefs.setString(_storageKey, jsonEncode(payload));
  }
}
