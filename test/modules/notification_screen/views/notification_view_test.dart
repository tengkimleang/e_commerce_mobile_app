import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/common/di.dart';
import 'package:e_commerce_mobile_app/core/data/categories_repository.dart';
import 'package:e_commerce_mobile_app/core/models/product_item.dart';
import 'package:e_commerce_mobile_app/modules/notification_screen/views/notification_view.dart';
import 'package:e_commerce_mobile_app/modules/notification_screen/models/notification_promotion_entry.dart';
import 'package:e_commerce_mobile_app/modules/notification_screen/repositories/notification_promotions_repository.dart';
import 'package:e_commerce_mobile_app/modules/notification_screen/views/notification_promotion_content_detail_view.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/cubits/order_history_cubit.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/views/order_details_view.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/model/category_model.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/model/sub_category_model.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/product_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await dotenv.load(fileName: '.env', isOptional: true);
    if (!di.isRegistered<Dio>()) {
      di.registerFactory<Dio>(() => Dio());
    }
  });

  testWidgets('order tab renders order notification rows', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => OrderHistoryCubit(),
          child: NotificationView(
            promotionsRepository: _FakeNotificationPromotionsRepository(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notification'), findsOneWidget);
    expect(
      find.textContaining('Your order #00001 has submitted.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Your order #00002 has submitted.'),
      findsOneWidget,
    );
    expect(find.text('12 May'), findsOneWidget);
  });

  testWidgets(
    'tapping an order notification opens details without cancel action',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => OrderHistoryCubit(),
            child: NotificationView(
              promotionsRepository: _FakeNotificationPromotionsRepository(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Your order #00002 has submitted.'));
      await tester.pumpAndSettle();

      expect(find.byType(OrderDetailsView), findsOneWidget);
      expect(find.text('Request'), findsOneWidget);
      expect(find.text('Cancel Order'), findsNothing);
      expect(find.text('Product Order'), findsOneWidget);
    },
  );

  testWidgets('promotion tab shows loading then feed cards', (tester) async {
    await _pumpNotification(
      tester,
      _FakeNotificationPromotionsRepository(
        items: _promotionEntries,
        delay: const Duration(seconds: 1),
      ),
      settle: false,
    );

    await _selectPromotionTab(tester);

    expect(
      find.byKey(const ValueKey('notification-promotion-skeleton')),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Category Promo'), findsOneWidget);
    expect(find.text('Content Promo'), findsOneWidget);
  });

  testWidgets('category promotion opens product list detail', (tester) async {
    await _registerCategoriesRepository(_FakeCategoriesRepository());
    await _pumpNotification(
      tester,
      _FakeNotificationPromotionsRepository(items: _promotionEntries),
    );

    await tester.tap(find.text('Promotion'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Category Promo'));
    await tester.pumpAndSettle();

    expect(find.byType(ProductListView), findsOneWidget);
    expect(find.text('Category Promo'), findsOneWidget);
  });

  testWidgets('content promotion opens content detail with dates', (
    tester,
  ) async {
    await _pumpNotification(
      tester,
      _FakeNotificationPromotionsRepository(items: _promotionEntries),
    );

    await tester.tap(find.text('Promotion'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Content Promo'));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationPromotionContentDetailView), findsOneWidget);
    expect(find.text('Content Promo'), findsOneWidget);
    expect(find.text('Content promo description'), findsOneWidget);
    expect(find.text('22, May, 2026 | 1:54 PM'), findsOneWidget);
    expect(find.text('22, May, 2026 | 10:54 PM'), findsOneWidget);
  });

  testWidgets('promotion tab shows empty state', (tester) async {
    await _pumpNotification(
      tester,
      _FakeNotificationPromotionsRepository(items: const []),
    );

    await tester.tap(find.text('Promotion'));
    await tester.pumpAndSettle();

    expect(find.text('No result found'), findsOneWidget);
  });

  testWidgets('promotion tab shows retry state on failure', (tester) async {
    await _pumpNotification(
      tester,
      _FakeNotificationPromotionsRepository(error: Exception('boom')),
    );

    await tester.tap(find.text('Promotion'));
    await tester.pumpAndSettle();

    expect(find.text('Failed to load promotions'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}

Future<void> _pumpNotification(
  WidgetTester tester,
  NotificationPromotionsRepository repository, {
  bool settle = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider(
        create: (_) => OrderHistoryCubit(),
        child: NotificationView(promotionsRepository: repository),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  }
}

Future<void> _selectPromotionTab(WidgetTester tester) async {
  final controller = DefaultTabController.of(
    tester.element(find.byType(TabBar)),
  );
  controller.animateTo(1);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _registerCategoriesRepository(
  CategoriesRepository repository,
) async {
  if (di.isRegistered<CategoriesRepository>()) {
    await di.unregister<CategoriesRepository>();
  }
  di.registerSingleton<CategoriesRepository>(repository);
}

final _promotionEntries = [
  NotificationPromotionEntry(
    id: 'category-1',
    type: NotificationPromotionType.category,
    title: 'Category Promo',
    description: 'Category promo description',
    imageUrl: 'https://example.com/category.jpg',
    categoryId: 12,
    displayOrder: 1,
    startsAt: DateTime(2026, 5, 22, 13, 54),
    endsAt: DateTime(2026, 5, 22, 22, 54),
    publishedAt: DateTime(2026, 5, 22, 13, 54),
  ),
  NotificationPromotionEntry(
    id: 'content-1',
    type: NotificationPromotionType.content,
    title: 'Content Promo',
    description: 'Content promo description',
    imageUrl: 'https://example.com/content.jpg',
    displayOrder: 2,
    startsAt: DateTime(2026, 5, 22, 13, 54),
    endsAt: DateTime(2026, 5, 22, 22, 54),
    publishedAt: DateTime(2026, 5, 22, 13, 54),
  ),
];

class _FakeNotificationPromotionsRepository
    implements NotificationPromotionsRepository {
  _FakeNotificationPromotionsRepository({
    this.items = const [],
    this.error,
    this.delay = Duration.zero,
  });

  final List<NotificationPromotionEntry> items;
  final Object? error;
  final Duration delay;

  @override
  Future<List<NotificationPromotionEntry>> fetchPromotions({
    String shopId = '',
  }) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    final error = this.error;
    if (error != null) throw error;
    return items;
  }
}

class _FakeCategoriesRepository implements CategoriesRepository {
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
