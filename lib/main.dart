import 'package:e_commerce_mobile_app/core/common/di.dart';
import 'package:e_commerce_mobile_app/core/data/categories_repository.dart';
import 'package:e_commerce_mobile_app/core/router/app_router.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/core/theme/app_theme.dart';
import 'package:e_commerce_mobile_app/core/utils/responsive_layout.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_bloc.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/blocs/favorite_bloc.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/blocs/favorite_event.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/repositories/favorites_repository.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/blocs/supermarket_category_bloc.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/blocs/supermarket_category_event.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/cubits/order_history_cubit.dart';
import 'package:e_commerce_mobile_app/modules/partner_privilege_screen/repositories/di.dart';
import 'package:e_commerce_mobile_app/modules/checkout/repositories/orders_repository.dart';
import 'package:e_commerce_mobile_app/modules/shop_selector/blocs/shop_bloc.dart';
import 'package:e_commerce_mobile_app/modules/address/blocs/address_bloc.dart';
import 'package:e_commerce_mobile_app/modules/address/blocs/address_event.dart';
import 'package:e_commerce_mobile_app/modules/address/repositories/address_repository.dart';
import 'package:e_commerce_mobile_app/modules/shop_selector/blocs/shop_event.dart';
import 'package:e_commerce_mobile_app/modules/shop_selector/repositories/shop_repository.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/services/profile_image_pick_recovery.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env', isOptional: true);
  await initializeDependenciesInjection();
  await UserSession.init();
  await registerPartnerPrivilegeModuleDi();
  final initialRoute = UserSession.isAuthenticated
      ? (await ProfileImagePickRecovery.hasPendingPick()
            ? AppRoutes.profile
            : AppRoutes.index)
      : AppRoutes.login;
  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CartBloc()),
        BlocProvider(
          create: (_) =>
              FavoriteBloc(di<SharedPreferences>(), di<FavoritesRepository>())
                ..add(const FavoriteLoadRequested()),
        ),
        BlocProvider(
          create: (_) =>
              SupermarketCategoryBloc(di<CategoriesRepository>())
                ..add(LoadCategories(UserSession.selectedShopId)),
        ),
        BlocProvider(
          create: (_) =>
              ShopBloc(di<ShopRepository>())..add(const FetchStores()),
        ),
        BlocProvider(
          create: (_) =>
              AddressBloc(AddressRepository())..add(const LoadAddresses()),
        ),
        BlocProvider(
          create: (_) =>
              OrderHistoryCubit(ordersRepository: OrdersRepository(di<Dio>()))
                ..loadOrders(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chipmong Retail',
        theme: AppTheme.light,
        scrollBehavior: const AppScrollBehavior(),
        initialRoute: initialRoute,
        onGenerateRoute: onGenerateRoute,
      ),
    );
  }
}
