import 'package:flutter/material.dart';

import 'package:e_commerce_mobile_app/modules/login_screen/views/login_view.dart';
import 'package:e_commerce_mobile_app/modules/login_screen/views/otp_view.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/supermarket_main_screen.dart';
import 'package:e_commerce_mobile_app/modules/cart/views/cart_view.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/views/user_info_view.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/views/favorite_view.dart';
import 'package:e_commerce_mobile_app/modules/notification_screen/views/notification_view.dart';
import 'package:e_commerce_mobile_app/modules/chipmong_screen/views/chipmong_mall_screen.dart';
import 'package:e_commerce_mobile_app/modules/price_checking/views/price_checking_view.dart';
import 'package:e_commerce_mobile_app/modules/signup_screen/views/signup_view.dart';
import 'package:e_commerce_mobile_app/modules/slash_screen/views/index.dart';
import 'package:e_commerce_mobile_app/modules/scan_barcode/views/scan_barcode_view.dart';

/// Named routes used throughout the app.
abstract final class AppRoutes {
  static const String login = '/login';
  static const String otp = '/otp';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String cart = '/cart';
  static const String profile = '/profile';
  static const String favorites = '/favorites';
  static const String notifications = '/notifications';
  static const String priceChecking = '/price-checking';
  static const String chipmongMall = '/chipmong-mall';
  static const String index = '/index';
  static const String scanBarcode = '/scan-barcode';
}

/// Generates a [Route] for the given [RouteSettings].
Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.login:
      return _page(const LoginView());
    case AppRoutes.index:
      return _page(const IndexView());
    case AppRoutes.otp:
      final phone = settings.arguments as String? ?? '';
      return _page(OtpView(phoneNumber: phone));
    case AppRoutes.signup:
      return _page(const SignupView());
    case AppRoutes.home:
      return _page(const SupermarketMainView());
    case AppRoutes.cart:
      return _page(const CartView());
    case AppRoutes.profile:
      return _page(const UserInfoView());
    case AppRoutes.favorites:
      return _page(const FavoriteView());
    case AppRoutes.notifications:
      return _page(const NotificationView());
    case AppRoutes.priceChecking:
      final selectionMode = settings.arguments as bool? ?? false;
      return _page(PriceCheckingView(selectionMode: selectionMode));
    case AppRoutes.chipmongMall:
      return _page(const ChipmongMallScreen());
    case AppRoutes.scanBarcode:
      return _page<String>(const ScanBarcodeView());
    default:
      return _page(const LoginView());
  }
}

MaterialPageRoute<T> _page<T>(Widget child) {
  return MaterialPageRoute<T>(builder: (_) => child);
}
