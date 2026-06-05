import 'package:e_commerce_mobile_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('editable typography preserves Khmer IME composition', (
    tester,
  ) async {
    const khmerText = 'ខ្មែរ';
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: TextField(controller: controller, style: AppTypography.inputStyle(isKhmer: true)),
        ),
      ),
    );
    await tester.tap(find.byType(TextField));

    final composingValue = TextEditingValue(
      text: khmerText,
      selection: const TextSelection.collapsed(offset: khmerText.length),
      composing: const TextRange(start: 0, end: khmerText.length),
    );
    tester.testTextInput.updateEditingValue(composingValue);
    await tester.pump();

    expect(controller.value, composingValue);
    expect(AppTypography.inputStyle(isKhmer: true).fontFamily, 'Battambang');
  });
}
