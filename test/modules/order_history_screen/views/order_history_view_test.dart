import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/common/di.dart';
import 'package:e_commerce_mobile_app/core/models/product_item.dart';
import 'package:e_commerce_mobile_app/core/router/app_router.dart';
import 'package:e_commerce_mobile_app/modules/address/models/delivery_address.dart';
import 'package:e_commerce_mobile_app/modules/bottom_navigation/views/supermarket_bottom_navigation.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_state.dart';
import 'package:e_commerce_mobile_app/modules/checkout/models/order_summary.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/cubits/order_history_cubit.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/views/order_details_view.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/views/order_history_view.dart';
import 'package:e_commerce_mobile_app/modules/order_track/views/order_track_screen.dart';
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

  testWidgets('renders refreshed fallback order list UI', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => OrderHistoryCubit(),
          child: const OrderHistoryView(showBottomNavigation: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Your recent purchase history'), findsOneWidget);
    expect(find.text('Search orders...'), findsOneWidget);
    expect(find.text('Filter'), findsOneWidget);
    expect(find.text('Order #00001'), findsOneWidget);
    expect(find.text('Order #00002'), findsOneWidget);
    expect(find.text('Canceled'), findsOneWidget);
    expect(find.text('Processing'), findsOneWidget);
    expect(find.text('Return'), findsNothing);
  });

  testWidgets('searches visible orders locally', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => OrderHistoryCubit(),
          child: const OrderHistoryView(showBottomNavigation: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('order-history-search-field')),
      '00002',
    );
    await tester.pumpAndSettle();

    expect(find.text('Order #00001'), findsNothing);
    expect(find.text('Order #00002'), findsOneWidget);
  });

  testWidgets('filters orders by selected status', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => OrderHistoryCubit(),
          child: const OrderHistoryView(showBottomNavigation: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('order-history-filter-button')));
    await tester.pumpAndSettle();

    expect(find.text('Filter by status'), findsOneWidget);

    final canceledFilter = find.byKey(
      const ValueKey('order-history-filter-canceled'),
    );
    await tester.ensureVisible(canceledFilter);
    await tester.tap(canceledFilter);
    await tester.pumpAndSettle();

    expect(find.text('Order #00001'), findsOneWidget);
    expect(find.text('Order #00002'), findsNothing);
  });

  testWidgets('tapping an active order opens order track screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => OrderHistoryCubit(),
          child: const OrderHistoryView(showBottomNavigation: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final activeOrder = find.text('Order #00002');
    await tester.ensureVisible(activeOrder);
    await tester.tap(activeOrder);
    await tester.pumpAndSettle();

    expect(find.byType(OrderTrackScreen), findsOneWidget);
  });

  testWidgets('order track back icon returns to the order list', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => OrderHistoryCubit(),
          child: const OrderHistoryView(showBottomNavigation: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final activeOrder = find.text('Order #00002');
    await tester.ensureVisible(activeOrder);
    await tester.tap(activeOrder);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    expect(find.byType(OrderHistoryView), findsOneWidget);
    expect(find.byType(OrderTrackScreen), findsNothing);
    expect(find.text('Orders'), findsOneWidget);
  });

  testWidgets('order track fallback back opens the orders route', (
    tester,
  ) async {
    var openedOrdersRoute = false;

    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.orders) {
            openedOrdersRoute = true;
            return MaterialPageRoute<void>(
              builder: (_) => const Scaffold(body: Text('Orders route')),
            );
          }
          return null;
        },
        home: OrderTrackScreen(
          order: _buildTrackOrder(),
          returnToOrderHistoryOnBack: true,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    expect(openedOrdersRoute, isTrue);
    expect(find.text('Orders route'), findsOneWidget);
  });

  testWidgets('tapping a canceled order opens order details screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => OrderHistoryCubit(),
          child: const OrderHistoryView(showBottomNavigation: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Order #00001'));
    await tester.pumpAndSettle();

    expect(find.byType(OrderDetailsView), findsOneWidget);
    expect(find.text('Product Order'), findsOneWidget);
  });

  testWidgets('shared supermarket bottom nav shows refreshed labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: SupermarketBottomNavigation(
            selectedIndex: 3,
            onTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Offers'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}

OrderSummary _buildTrackOrder() {
  return OrderSummary(
    orderId: '',
    orderNumber: '00003',
    orderDate: DateTime(2026, 5, 24, 10, 57),
    shopName: 'Chip Mong Supermarket Noro',
    items: const [
      CartItemViewModel(
        product: ProductModel(id: 'p1', name: '7 Up', price: 1.0, imageUrl: ''),
        quantity: 1,
      ),
    ],
    deliveryAddress: const DeliveryAddress(
      id: 'addr-1',
      nameAddress: 'Home',
      address: '100 Khang, Saensokh, Phnom Penh, Cambodia',
      phoneNumber: '0978464464',
      label: AddressLabel.home,
      isDefault: true,
      latitude: 11.5564,
      longitude: 104.9282,
    ),
    subtotal: 1,
    deliveryFee: 1.59,
    packageFees: 0.10,
    discount: 0,
    promoDiscount: 0,
    total: 2.69,
    paymentMethod: 'COD',
    statusCode: 'REQUESTING',
  );
}
