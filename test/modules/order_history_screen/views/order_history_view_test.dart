import 'package:e_commerce_mobile_app/modules/order_history_screen/cubits/order_history_cubit.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/views/order_details_view.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/views/order_history_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders fallback cards with cancel/ordered status chips', (
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
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Ordered'), findsOneWidget);
  });

  testWidgets('tapping an order opens order details screen', (tester) async {
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
