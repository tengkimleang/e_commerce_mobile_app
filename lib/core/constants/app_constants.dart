import 'package:flutter/foundation.dart';

class ApiUrl {
  static const _backendPort = 5058;
  static const _localhost = 'http://localhost:$_backendPort';
  static const _androidEmulatorHost = 'http://10.0.2.2:$_backendPort';

  // Optional override for physical devices or custom environments:
  // flutter run --dart-define=API_BASE_URL=http://<your-lan-ip>:5058
  static const _overrideBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) return _overrideBaseUrl;
    if (kIsWeb) return _localhost;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidEmulatorHost;
    }
    return _localhost;
  }

  static const promtionGetAll = "/promotion/getAll";
  static const promotionGetById = "/promotion/";
  static const newsGetAll = "/news";
  static const newsGetById = "/news/";
  static const notificationPromotions = "/notifications/promotions";
  static const requestOtp = "/auth/login/request-otp";
  static const verifyOtp = "/auth/login/verify-otp";

  // ── Stores ──
  static const stores = '/stores';

  // ── Categories & Products ──
  static const categories = '/categories';
  static const shopByCategories = '/shop-by-categories';
  static const products = '/products';
  static String categoryProducts(int id) => '/categories/$id/products';
  static String categorySubCategories(int categoryId) =>
      '/categories/$categoryId/subcategories';
  static String subCategoryProducts(int subCategoryId) =>
      '/subcategories/$subCategoryId/products';
  static String shopByCategorySubCategories(int shopByCategoryId) =>
      '/shop-by-categories/$shopByCategoryId/subcategories';
  static String shopByCategoryProducts(int shopByCategoryId) =>
      '/shop-by-categories/$shopByCategoryId/products';
  static String productDetail(int id) => '/products/$id';
  static String productByBarcode(String code) => '/products/by-barcode/$code';

  // ── Favorites ──
  // GET    /favorites              → list of favorited product IDs for the authenticated user
  // PUT    /favorites/{productId}  → idempotently add a favorite
  // DELETE /favorites/{productId}  → idempotently remove a favorite
  // POST   /favorites              → legacy toggle; avoid for new FE writes
  // POST   /favorites/sync         → bulk-upsert local guest favorites on first login
  static const favorites = '/favorites';
  static String favoriteByProductId(String productId) =>
      '/favorites/$productId';
  static const favoritesSync = '/favorites/sync';

  // ── Orders ──
  static const orders = '/orders';
  static const ordersPromoValidate = '/orders/promo/validate';
  static String orderApprove(String orderId) => '/orders/$orderId/approve';
  static String orderCancel(String orderId) => '/orders/$orderId/cancel';
  static String orderDeliverStart(String orderId) =>
      '/orders/$orderId/deliver-start';
  static String orderDeliverComplete(String orderId) =>
      '/orders/$orderId/deliver-complete';

  // ── Telegram linking ──
  static const telegramLinkRequest = '/auth/telegram/link-request';
  static const telegramLinkStatus = '/auth/telegram/link-status';
  static const telegramUnlink = '/auth/telegram/unlink';
}
