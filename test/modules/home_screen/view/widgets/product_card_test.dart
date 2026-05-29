import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_bloc.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/blocs/favorite_bloc.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/repositories/favorites_repository.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/model/product_model.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('ProductCard shows full images inside a stable frame', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => CartBloc()),
          BlocProvider(
            create: (_) => FavoriteBloc(prefs, _FakeFavoritesRepository()),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 180,
                height: 240,
                child: ProductCard(
                  product: ProductModel(
                    id: '1',
                    name: 'Sprite',
                    price: 300,
                    imageUrl: 'https://example.com/sprite.png',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(image.fit, BoxFit.contain);

    final imageFrameSize = tester.getSize(
      find.byKey(const ValueKey('product-card-image-frame')),
    );
    expect(imageFrameSize.width, 180);
    expect(imageFrameSize.height, moreOrLessEquals(152));
  });

  testWidgets('ProductCard avoids overflow in compact carousel cards', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => CartBloc()),
          BlocProvider(
            create: (_) => FavoriteBloc(prefs, _FakeFavoritesRepository()),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 160,
                height: 160,
                child: ProductCard(
                  product: ProductModel(
                    id: '1',
                    name: 'Energy Drink',
                    price: 300,
                    imageUrl: 'https://example.com/energy-drink.png',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    final imageFrameSize = tester.getSize(
      find.byKey(const ValueKey('product-card-image-frame')),
    );
    expect(imageFrameSize.width, 160);
    expect(imageFrameSize.height, moreOrLessEquals(72));
  });
}

class _FakeFavoritesRepository implements FavoritesRepository {
  @override
  Future<void> addFavorite(String productId) async {}

  @override
  Future<List<String>?> loadFavoriteIds() async => const [];

  @override
  Future<void> removeFavorite(String productId) async {}

  @override
  Future<void> syncFavorites(List<String> productIds) async {}

  @override
  Future<void> toggleFavorite(String productId) async {}
}
