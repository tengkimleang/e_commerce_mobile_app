import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/common/di.dart';
import 'package:e_commerce_mobile_app/modules/bottom_navigation/views/supermarket_bottom_navigation.dart';
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
