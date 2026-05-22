import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/common/di.dart';
import 'package:e_commerce_mobile_app/modules/notification_screen/views/notification_view.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/cubits/order_history_cubit.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/views/order_details_view.dart';
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
          child: const NotificationView(),
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
            child: const NotificationView(),
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
}
