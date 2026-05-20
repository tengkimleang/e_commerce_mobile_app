import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/models/repositories/shop_by_category_repository.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/models/shop_by_category_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserSession.init();
    UserSession.setSelectedShop('shop-001', name: 'Test Shop');
  });

  test('parses shop-by-category JSON independent from product categories', () {
    final category = ShopByCategoryModel.fromJson(const {
      'id': 7,
      'categoryId': 99,
      'titleEn': 'Customer Choice',
      'titleKm': '',
      'imageUrl': 'https://example.com/customer-choice.png',
      'displayOrder': 3,
      'isActive': true,
    });

    expect(category.id, 7);
    expect(category.categoryId, 99);
    expect(category.displayTitle, 'Customer Choice');
    expect(category.imageUrl, 'https://example.com/customer-choice.png');
  });

  test(
    'fetchCategories uses the dedicated shop-by-categories endpoint',
    () async {
      final requests = <RequestOptions>[];
      final repository = HttpShopByCategoryRepository(
        _dioRespondingWith(requests, const {
          'data': {
            'items': [
              {'id': 2, 'titleEn': 'Second', 'imageUrl': '', 'displayOrder': 2},
              {'id': 1, 'titleEn': 'First', 'imageUrl': '', 'displayOrder': 1},
            ],
          },
        }),
      );

      final categories = await repository.fetchCategories();

      expect(requests.single.path, '/shop-by-categories');
      expect(requests.single.queryParameters, {'shopId': 'shop-001'});
      expect(categories.map((category) => category.id), [1, 2]);
    },
  );

  test('fetchSubCategories sends the selected shop id', () async {
    final requests = <RequestOptions>[];
    final repository = HttpShopByCategoryRepository(
      _dioRespondingWith(requests, const {
        'data': {'items': []},
      }),
    );

    await repository.fetchSubCategories(7);

    expect(requests.single.path, '/shop-by-categories/7/subcategories');
    expect(requests.single.queryParameters, {'shopId': 'shop-001'});
  });

  test(
    'fetchProducts sends shop, pagination, keyword, and subcategory params',
    () async {
      final requests = <RequestOptions>[];
      final repository = HttpShopByCategoryRepository(
        _dioRespondingWith(requests, const {
          'data': {'items': [], 'total': 0},
        }),
      );

      await repository.fetchProducts(
        7,
        subCategoryId: 12,
        page: 3,
        pageSize: 8,
        keyword: ' milk ',
      );

      expect(requests.single.path, '/shop-by-categories/7/products');
      expect(requests.single.queryParameters, {
        'page': 3,
        'pageSize': 8,
        'shopId': 'shop-001',
        'subCategoryId': 12,
        'keyword': 'milk',
      });
    },
  );
}

Dio _dioRespondingWith(
  List<RequestOptions> requests,
  Map<String, dynamic> body,
) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        requests.add(options);
        handler.resolve(
          Response<dynamic>(
            requestOptions: options,
            statusCode: 200,
            data: body,
          ),
        );
      },
    ),
  );
  return dio;
}
