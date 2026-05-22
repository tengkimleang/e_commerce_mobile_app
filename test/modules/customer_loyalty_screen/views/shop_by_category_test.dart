import 'package:e_commerce_mobile_app/core/common/di.dart';
import 'package:e_commerce_mobile_app/core/data/categories_repository.dart';
import 'package:e_commerce_mobile_app/core/models/product_item.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_bloc.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/models/repositories/shop_by_category_repository.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/models/shop_by_category_model.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/views/customer_loyalty_screen.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/views/shop_category_product_view.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/views/widgets/shop_by_category_section.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/views/widgets/shop_category_card.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/blocs/favorite_bloc.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/repositories/favorites_repository.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/model/category_model.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/model/sub_category_model.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/product_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserSession.init();
    UserSession.setSelectedShop('shop-001', name: 'Supermarket Sorla');
    await di.reset();
  });

  testWidgets('category product screen loads All and subcategory tabs', (
    tester,
  ) async {
    final repository = _FakeShopByCategoryRepository();
    await _pumpProductView(tester, repository);

    expect(find.text('All'), findsOneWidget);
    expect(find.text('CHEESE'), findsOneWidget);
    expect(find.text('All Milk Product'), findsOneWidget);
    expect(repository.productCalls.last, const _ProductCall(1, null, ''));

    await tester.tap(find.text('CHEESE'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Cheese Product'), findsOneWidget);
    expect(repository.productCalls.last, const _ProductCall(1, 10, ''));
  });

  testWidgets('category product screen shows skeleton while first page loads', (
    tester,
  ) async {
    final repository = _FakeShopByCategoryRepository(
      delay: const Duration(milliseconds: 100),
    );
    await _pumpProductView(tester, repository, settle: false);

    expect(
      find.byKey(const ValueKey('shop-product-grid-skeleton')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('shop-category-tabs-skeleton')),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('shop-product-grid-skeleton')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('shop-category-tabs-skeleton')),
      findsNothing,
    );
    expect(find.text('All Milk Product'), findsOneWidget);
  });

  testWidgets('category product screen searches within the active tab', (
    tester,
  ) async {
    final repository = _FakeShopByCategoryRepository();
    await _pumpProductView(tester, repository);
    repository.productCalls.clear();

    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('shop-category-search-field')),
      'milk',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(repository.productCalls.last, const _ProductCall(1, null, 'milk'));
  });

  testWidgets('category product screen opens product detail on product tap', (
    tester,
  ) async {
    final repository = _FakeShopByCategoryRepository();
    final legacyRepository = _FakeLegacyCategoriesRepository();
    await _pumpProductView(
      tester,
      repository,
      legacyRepository: legacyRepository,
    );

    await tester.tap(find.text('All Milk Product'));
    await tester.pumpAndSettle();

    expect(find.byType(ProductDetailView), findsOneWidget);
    expect(legacyRepository.subCategoryProductCalls, 0);
  });

  testWidgets('category product screen shows an empty state', (tester) async {
    final repository = _FakeShopByCategoryRepository(
      categoryProducts: const [],
    );
    await _pumpProductView(tester, repository);

    expect(find.text('No products found'), findsOneWidget);
  });

  testWidgets('category card fits compact rail size without overflow', (
    tester,
  ) async {
    const compactCategory = ShopByCategoryModel(
      id: 99,
      titleEn: 'Recommend for you with long title',
      titleKm: 'មុខទំនិញណែនាំ សម្រាប់អ្នក',
      imageUrl: '',
      displayOrder: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 112,
              height: 118,
              child: ShopCategoryCard(category: compactCategory, onTap: () {}),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(ShopCategoryCard), findsOneWidget);
  });

  testWidgets('shop by category rail reloads when branch changes', (
    tester,
  ) async {
    const senSokCategory = ShopByCategoryModel(
      id: 2,
      titleEn: 'Sen Sok Special',
      titleKm: '',
      imageUrl: '',
      displayOrder: 1,
    );
    final repository = _FakeShopByCategoryRepository(
      categoriesByShop: const {
        'shop_271': [_category],
        'shop_sen_sok': [senSokCategory],
      },
      categoryDelaysByShop: const {'shop_sen_sok': Duration(milliseconds: 100)},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShopByCategorySection(
            shopId: 'shop_271',
            shopName: '271',
            repository: repository,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dairy & Non Dairy'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShopByCategorySection(
            shopId: 'shop_sen_sok',
            shopName: 'Sen Sok',
            repository: repository,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('shop-by-category-section-skeleton')),
      findsOneWidget,
    );
    expect(find.text('Dairy & Non Dairy'), findsNothing);
    expect(find.text('Sen Sok Special'), findsNothing);

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(repository.categoryCalls, ['shop_271', 'shop_sen_sok']);
    expect(find.text('Dairy & Non Dairy'), findsNothing);
    expect(find.text('Sen Sok Special'), findsOneWidget);
  });

  testWidgets('home places Shop by category before Shop by country', (
    tester,
  ) async {
    final shopByCategoryRepository = _FakeShopByCategoryRepository();
    final legacyCategoriesRepository = _FakeLegacyCategoriesRepository();
    final prefs = await SharedPreferences.getInstance();
    di.registerSingleton<ShopByCategoryRepository>(shopByCategoryRepository);
    di.registerSingleton<CategoriesRepository>(legacyCategoriesRepository);

    await tester.pumpWidget(
      _withAppProviders(
        prefs: prefs,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: CustomerLoyaltySection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final categoryTop = tester.getTopLeft(find.text('Shop by category')).dy;
    final countryTop = tester.getTopLeft(find.text('Shop by country')).dy;

    expect(categoryTop, lessThan(countryTop));
  });
}

Future<void> _pumpProductView(
  WidgetTester tester,
  _FakeShopByCategoryRepository repository, {
  _FakeLegacyCategoriesRepository? legacyRepository,
  bool settle = true,
}) async {
  di.registerSingleton<ShopByCategoryRepository>(repository);
  di.registerSingleton<CategoriesRepository>(
    legacyRepository ?? _FakeLegacyCategoriesRepository(),
  );
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    _withAppProviders(
      prefs: prefs,
      child: MaterialApp(
        home: ShopCategoryProductView(
          category: _category,
          repository: repository,
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

Widget _withAppProviders({
  required SharedPreferences prefs,
  required Widget child,
}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => CartBloc()),
      BlocProvider(
        create: (_) => FavoriteBloc(prefs, _FakeFavoritesRepository()),
      ),
    ],
    child: child,
  );
}

const _category = ShopByCategoryModel(
  id: 1,
  titleEn: 'Dairy & Non Dairy',
  titleKm: '',
  imageUrl: '',
  displayOrder: 1,
);

const _allMilkProduct = ProductModel(
  id: 'p1',
  name: 'All Milk Product',
  price: 2,
  imageUrl: 'https://example.com/milk.png',
  subCategoryId: 10,
);

const _cheeseProduct = ProductModel(
  id: 'p2',
  name: 'Cheese Product',
  price: 3,
  imageUrl: 'https://example.com/cheese.png',
  subCategoryId: 10,
);

class _FakeShopByCategoryRepository implements ShopByCategoryRepository {
  _FakeShopByCategoryRepository({
    List<ProductModel>? categoryProducts,
    Map<String, List<ShopByCategoryModel>>? categoriesByShop,
    Map<String, Duration>? categoryDelaysByShop,
    Duration delay = Duration.zero,
  }) : _categoryProducts = categoryProducts ?? const [_allMilkProduct],
       _categoriesByShop = categoriesByShop ?? const {},
       _categoryDelaysByShop = categoryDelaysByShop ?? const {},
       _delay = delay;

  final List<ProductModel> _categoryProducts;
  final Map<String, List<ShopByCategoryModel>> _categoriesByShop;
  final Map<String, Duration> _categoryDelaysByShop;
  final Duration _delay;
  final categoryCalls = <String?>[];
  final productCalls = <_ProductCall>[];

  @override
  Future<List<ShopByCategoryModel>> fetchCategories({String? shopId}) async {
    categoryCalls.add(shopId);
    await _wait(_categoryDelaysByShop[shopId] ?? _delay);
    return _categoriesByShop[shopId] ?? const [_category];
  }

  @override
  Future<(List<ProductModel>, int)> fetchProducts(
    int shopByCategoryId, {
    int? subCategoryId,
    int page = 1,
    int pageSize = 20,
    String keyword = '',
  }) async {
    productCalls.add(_ProductCall(shopByCategoryId, subCategoryId, keyword));
    await _wait(_delay);
    if (subCategoryId != null) {
      const items = [_cheeseProduct];
      return (items, items.length);
    }
    final items = keyword.trim().isEmpty
        ? _categoryProducts
        : _categoryProducts
              .where(
                (product) => product.name.toLowerCase().contains(
                  keyword.trim().toLowerCase(),
                ),
              )
              .toList();
    return (items, items.length);
  }

  @override
  Future<List<SubCategoryModel>> fetchSubCategories(
    int shopByCategoryId,
  ) async {
    await _wait(_delay);
    return const [
      SubCategoryModel(id: 10, name: 'CHEESE', imageUrl: '', displayOrder: 1),
    ];
  }

  Future<void> _wait(Duration duration) async {
    if (duration > Duration.zero) {
      await Future<void>.delayed(duration);
    }
  }
}

class _FakeLegacyCategoriesRepository implements CategoriesRepository {
  int subCategoryProductCalls = 0;

  @override
  Future<List<CategoryModel>> fetchCategories() async => const [];

  @override
  Future<(List<ProductModel>, int)> fetchCategoryProducts(
    int categoryId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return (const <ProductModel>[], 0);
  }

  @override
  Future<List<SubCategoryModel>> fetchSubCategories(int categoryId) async {
    return const [];
  }

  @override
  Future<(List<ProductModel>, int)> fetchSubCategoryProducts(
    int subCategoryId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    subCategoryProductCalls++;
    return (const <ProductModel>[], 0);
  }

  @override
  Future<(List<ProductModel>, int)> searchProducts(
    String keyword, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return (const <ProductModel>[], 0);
  }

  @override
  Future<(List<ProductModel>, int)> fetchProductsByCountry(
    String country, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return (const <ProductModel>[], 0);
  }

  @override
  Future<List<CategoryModel>> fetchPromotionCategories(String shopId) async {
    return const [];
  }

  @override
  Future<ProductModel?> fetchProductByBarcode(String code) async => null;
}

class _ProductCall {
  const _ProductCall(this.shopByCategoryId, this.subCategoryId, this.keyword);

  final int shopByCategoryId;
  final int? subCategoryId;
  final String keyword;

  @override
  bool operator ==(Object other) {
    return other is _ProductCall &&
        other.shopByCategoryId == shopByCategoryId &&
        other.subCategoryId == subCategoryId &&
        other.keyword == keyword;
  }

  @override
  int get hashCode => Object.hash(shopByCategoryId, subCategoryId, keyword);

  @override
  String toString() {
    return 'shopByCategory($shopByCategoryId, $subCategoryId, "$keyword")';
  }
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
