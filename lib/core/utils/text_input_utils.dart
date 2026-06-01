import 'package:flutter/widgets.dart';

/// Returns whether the IME is still assembling a multi-stage text edit.
///
/// Search requests and expensive rebuilds should wait until this is false so
/// keyboards for complex scripts such as Khmer can finish composing a value.
bool hasActiveComposingRegion(TextEditingController controller) {
  final composing = controller.value.composing;
  return composing.isValid && !composing.isCollapsed;
}
