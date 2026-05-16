import 'dart:collection';
import 'dart:convert';

import 'package:e_commerce_mobile_app/core/models/product_item.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/blocs/favorite_bloc.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/blocs/favorite_event.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/repositories/favorites_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _drainEvents() async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
}

void main() {
  const storageKey = 'favorite_products';
  const product = ProductModel(
    id: '101',
    name: 'Vital Water',
    price: 100,
    imageUrl: 'https://example.com/vital-water.png',
    isFavorite: true,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserSession.init();
  });

  test(
    'keeps local favorites when the server unexpectedly returns empty',
    () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(storageKey, jsonEncode([product.toJson()]));
      await UserSession.markAuthenticated(
        token: 'token',
        refreshToken: 'refresh',
      );

      final repository = _FakeFavoritesRepository(
        loadResponses: [const [], const []],
      );
      final bloc = FavoriteBloc(prefs, repository);
      addTearDown(bloc.close);

      bloc.add(const FavoriteLoadRequested());
      await _drainEvents();

      expect(repository.syncedProductIds, [
        [product.id],
      ]);
      expect(bloc.state.contains(product.id), isTrue);
      expect(bloc.state.pendingSyncIds, contains(product.id));
      expect(prefs.getString(storageKey), contains(product.id));
    },
  );

  test(
    'restores server favorites from local cache when recovery succeeds',
    () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(storageKey, jsonEncode([product.toJson()]));
      await UserSession.markAuthenticated(
        token: 'token',
        refreshToken: 'refresh',
      );

      final repository = _FakeFavoritesRepository(
        loadResponses: [
          const [],
          [product.id],
        ],
      );
      final bloc = FavoriteBloc(prefs, repository);
      addTearDown(bloc.close);

      bloc.add(const FavoriteLoadRequested());
      await _drainEvents();

      expect(repository.syncedProductIds, [
        [product.id],
      ]);
      expect(bloc.state.contains(product.id), isTrue);
      expect(bloc.state.pendingSyncIds, isEmpty);
    },
  );
}

class _FakeFavoritesRepository implements FavoritesRepository {
  _FakeFavoritesRepository({required List<List<String>?> loadResponses})
    : _loadResponses = Queue<List<String>?>.of(loadResponses);

  final Queue<List<String>?> _loadResponses;
  final List<List<String>> syncedProductIds = [];

  @override
  Future<void> addFavorite(String productId) async {}

  @override
  Future<List<String>?> loadFavoriteIds() async {
    if (_loadResponses.isEmpty) return const [];
    return _loadResponses.removeFirst();
  }

  @override
  Future<void> removeFavorite(String productId) async {}

  @override
  Future<void> syncFavorites(List<String> productIds) async {
    syncedProductIds.add(productIds);
  }

  @override
  Future<void> toggleFavorite(String productId) async {}
}
