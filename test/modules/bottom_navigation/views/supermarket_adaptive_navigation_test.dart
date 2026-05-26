import 'package:e_commerce_mobile_app/modules/bottom_navigation/views/supermarket_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpAdaptiveScaffold(
    WidgetTester tester, {
    required Size size,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: SupermarketAdaptiveScaffold(
          selectedIndex: 0,
          onTap: (_) {},
          body: const Text('Adaptive body'),
        ),
      ),
    );
  }

  testWidgets('uses bottom navigation on compact windows', (tester) async {
    await pumpAdaptiveScaffold(tester, size: const Size(390, 844));

    expect(find.byType(SupermarketBottomNavigation), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('Adaptive body'), findsOneWidget);
  });

  testWidgets('uses navigation rail on medium and wider windows', (
    tester,
  ) async {
    await pumpAdaptiveScaffold(tester, size: const Size(900, 700));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(SupermarketBottomNavigation), findsNothing);
    expect(find.text('Adaptive body'), findsOneWidget);
  });
}
