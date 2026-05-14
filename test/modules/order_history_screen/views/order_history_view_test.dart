import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/common/di.dart';
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

  testWidgets('renders fallback cards with expected status chips', (
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

    expect(find.text('Ordering'), findsOneWidget);
    expect(find.text('Order: # 00001'), findsOneWidget);
    expect(find.text('Order: # 00002'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Request'), findsOneWidget);
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

    final activeOrder = find.text('Order: # 00002');
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

    await tester.tap(find.text('Order: # 00001'));
    await tester.pumpAndSettle();

    expect(find.byType(OrderDetailsView), findsOneWidget);
    expect(find.text('Product Order'), findsOneWidget);
  });
}
