import 'package:e_commerce_mobile_app/core/common/di.dart';
import 'package:e_commerce_mobile_app/core/data/categories_repository.dart';
import 'package:e_commerce_mobile_app/core/localization/language_cache.dart';
import 'package:e_commerce_mobile_app/core/localization/language_cubit.dart';
import 'package:e_commerce_mobile_app/core/router/app_router.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/core/theme/app_theme.dart';
import 'package:e_commerce_mobile_app/core/theme/theme_cache.dart';
import 'package:e_commerce_mobile_app/core/theme/theme_cubit.dart';
import 'package:e_commerce_mobile_app/core/theme/theme_repository.dart';
import 'package:e_commerce_mobile_app/core/localization/locale_cubit.dart';
import 'package:e_commerce_mobile_app/core/utils/responsive_layout.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
import 'package:e_commerce_mobile_app/l10n/generated/app_localizations.dart';
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
  runApp(
    MyApp(
      initialRoute: initialRoute,
      initialTheme: di<ThemeCache>().read(),
      initialLanguage: di<LanguageCache>().read(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.initialRoute,
    required this.initialLanguage,
    this.initialTheme,
  });

  final String initialRoute;
  final String initialLanguage;
  final CachedAppTheme? initialTheme;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ThemeCubit(
            repository: di<ThemeRepository>(),
            cache: di<ThemeCache>(),
            initialTheme: initialTheme,
          )..refreshIfStale(force: true),
        ),
        BlocProvider.value(value: di<LocaleCubit>()),
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
      child: _AppView(initialRoute: initialRoute),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView({required this.initialRoute});

  final String initialRoute;

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<ThemeCubit>().refreshIfStale();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return BlocBuilder<ThemeCubit, ThemeState>(
          buildWhen: (previous, current) =>
              previous.config.revision != current.config.revision,
          builder: (context, state) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Chipmong Retail',
            onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.fromConfig(state.config),
            scrollBehavior: const AppScrollBehavior(),
            initialRoute: widget.initialRoute,
            onGenerateRoute: onGenerateRoute,
          ),
        );
      },
    );
  }
}
