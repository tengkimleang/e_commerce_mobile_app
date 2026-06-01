import 'package:e_commerce_mobile_app/core/utils/text_input_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('detects active Khmer IME composition', () {
    const khmerText = 'ខ្មែរ';
    final controller = TextEditingController.fromValue(
      const TextEditingValue(
        text: khmerText,
        selection: TextSelection.collapsed(offset: khmerText.length),
        composing: TextRange(start: 0, end: khmerText.length),
      ),
    );
    addTearDown(controller.dispose);

    expect(hasActiveComposingRegion(controller), isTrue);

    controller.clearComposing();

    expect(hasActiveComposingRegion(controller), isFalse);
  });
}
