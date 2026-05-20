import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/constants/app_constants.dart';
import 'package:e_commerce_mobile_app/core/data/categories_repository.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/models/repositories/shop_by_category_repository.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/repositories/favorites_repository.dart';
import 'package:e_commerce_mobile_app/modules/shop_selector/repositories/shop_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final di = GetIt.instance;

Future<void> initializeDependenciesInjection() async {
  //Local Key-Value
  final prefs = await SharedPreferences.getInstance();
  di.registerSingleton(prefs);
  //HTTPS
  di.registerFactory(() {
    final header = <String, dynamic>{};
    if (prefs.getString('token') != null) {
      header.addAll({'Authorization': "Bearer ${prefs.getString('token')}"});
    }
    final options = BaseOptions(baseUrl: ApiUrl.baseUrl, headers: header);
    return Dio(options);
  });

  // Categories repository — wired to the real ASP.NET Core API.
  di.registerSingleton<CategoriesRepository>(
    HttpCategoriesRepository(di<Dio>()),
  );

  // Shop-by-category repository — independent curated category API.
  di.registerSingleton<ShopByCategoryRepository>(
    HttpShopByCategoryRepository(di<Dio>()),
  );

  // Shop/Branch repository — fetches the live store list from GET /stores.
  di.registerSingleton<ShopRepository>(ShopRepository(di<Dio>()));

  // Favorites repository — syncs user favorites with the backend.
  di.registerSingleton<FavoritesRepository>(HttpFavoritesRepository(di<Dio>()));

  //repository
  // di.registerFactory(() => UserRepository());
}
