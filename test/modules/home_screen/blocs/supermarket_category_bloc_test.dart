import 'package:e_commerce_mobile_app/core/data/categories_repository.dart';
import 'package:e_commerce_mobile_app/core/models/product_item.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/blocs/supermarket_category_bloc.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/blocs/supermarket_category_event.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/blocs/supermarket_category_state.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/model/category_model.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/model/sub_category_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserSession.init();
  });

  test(
    'loads home sections from promotion categories for selected shop',
    () async {
      final repository = _FakeCategoriesRepository(
        promotionCategories: const [],
      );
      final bloc = SupermarketCategoryBloc(repository);

      final states = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<CategoriesLoading>(),
          isA<CategoriesLoaded>().having(
            (state) => state.categories,
            'categories',
            isEmpty,
          ),
        ]),
      );

      bloc.add(const LoadCategories('shop_271'));
      await states;

      expect(repository.fetchCategoriesCalls, 0);
      expect(repository.promotionCategoryShopIds, ['shop_271']);
      await bloc.close();
    },
  );

  test('falls back to session shop when load event has no shop id', () async {
    UserSession.setSelectedShop('shop_271', name: '271');
    final repository = _FakeCategoriesRepository(
      promotionCategories: const [_promotionCategory],
    );
    final bloc = SupermarketCategoryBloc(repository);

    final states = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<CategoriesLoading>(),
        isA<CategoriesLoaded>().having(
          (state) => state.categories,
          'categories',
          const [_promotionCategory],
        ),
      ]),
    );

    bloc.add(const LoadCategories());
    await states;

    expect(repository.fetchCategoriesCalls, 0);
    expect(repository.promotionCategoryShopIds, ['shop_271']);
    await bloc.close();
  });
}

const _promotionCategory = CategoryModel(
  id: 1,
  nameEn: 'Promotion',
  nameKm: '',
  bannerImageUrl: '',
  displayOrder: 1,
  showInPromotion: true,
);

class _FakeCategoriesRepository implements CategoriesRepository {
  _FakeCategoriesRepository({required this.promotionCategories});

  final List<CategoryModel> promotionCategories;
  final promotionCategoryShopIds = <String>[];
  var fetchCategoriesCalls = 0;

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    fetchCategoriesCalls++;
    return const [];
  }

  @override
  Future<List<CategoryModel>> fetchPromotionCategories(String shopId) async {
    promotionCategoryShopIds.add(shopId);
    return promotionCategories;
  }

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
  Future<(List<ProductModel>, int)> searchProducts(
    String keyword, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return (const <ProductModel>[], 0);
  }

  @override
  Future<ProductModel?> fetchProductByBarcode(String code) async => null;
}
