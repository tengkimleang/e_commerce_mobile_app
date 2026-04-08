import 'package:e_commerce_mobile_app/core/common/di.dart';
import 'package:e_commerce_mobile_app/core/data/categories_repository.dart';
import 'package:e_commerce_mobile_app/core/router/app_router.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/core/theme/app_theme.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_bloc.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/blocs/supermarket_category_bloc.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/blocs/supermarket_category_event.dart';
import 'package:e_commerce_mobile_app/modules/partner_privilege_screen/repositories/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependenciesInjection();
  await UserSession.init();
  await registerPartnerPrivilegeModuleDi();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CartBloc()),
        BlocProvider(
          create: (_) =>
              SupermarketCategoryBloc(di<CategoriesRepository>())
                ..add(LoadCategories()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chipmong Retail',
        theme: AppTheme.light,
        initialRoute: UserSession.isAuthenticated
            ? AppRoutes.index
            : AppRoutes.login,
        onGenerateRoute: onGenerateRoute,
      ),
    );
  }
}
