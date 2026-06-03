import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/constants/app_constants.dart';
import 'package:e_commerce_mobile_app/core/data/categories_repository.dart';
import 'package:e_commerce_mobile_app/core/localization/app_language.dart';
import 'package:e_commerce_mobile_app/core/localization/language_cache.dart';
import 'package:e_commerce_mobile_app/core/theme/theme_cache.dart';
import 'package:e_commerce_mobile_app/core/theme/theme_repository.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/models/repositories/shop_by_category_repository.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/repositories/favorites_repository.dart';
import 'package:e_commerce_mobile_app/modules/notification_screen/repositories/notification_promotions_repository.dart';
import 'package:e_commerce_mobile_app/modules/shop_selector/repositories/shop_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final di = GetIt.instance;

Future<void> initializeDependenciesInjection() async {
  //Local Key-Value
  final prefs = await SharedPreferences.getInstance();
  di.registerSingleton(prefs);
  di.registerSingleton(ThemeCache(prefs));
  di.registerSingleton(LanguageCache(prefs));
  AppLanguage.setCurrentLanguageCode(di<LanguageCache>().read());
  //HTTPS
  di.registerFactory(() {
    final header = <String, dynamic>{};
    if (prefs.getString('token') != null) {
      header.addAll({'Authorization': "Bearer ${prefs.getString('token')}"});
    }
    final options = BaseOptions(baseUrl: ApiUrl.baseUrl, headers: header);
    final dio = Dio(options);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Accept-Language'] = AppLanguage.currentLanguageCode;
          handler.next(options);
        },
      ),
    );
    return dio;
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

  // Notification promotions — admin-managed promotion feed.
  di.registerSingleton<NotificationPromotionsRepository>(
    HttpNotificationPromotionsRepository(di<Dio>()),
  );

  // Public holiday/event theme configuration with offline cache support.
  di.registerSingleton<ThemeRepository>(HttpThemeRepository(di<Dio>()));

  //repository
  // di.registerFactory(() => UserRepository());
}
