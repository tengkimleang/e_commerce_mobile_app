import 'package:flutter/material.dart';

/// Custom painter that renders a sort icon:
/// - A fixed down-arrow on the left
/// - 4 horizontal lines on the right whose lengths reflect sort direction:
///   [descending=true]  → longest→shortest (big to small)
///   [descending=false] → shortest→longest (small to big)
class SortIconPainter extends CustomPainter {
  final bool descending;
  final Color color;

  const SortIconPainter({required this.descending, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final arrowPaint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    // ── Arrow (always pointing down) on the left ──────────────────
    final arrowX = w * 0.18;
    final arrowTop = h * 0.08;
    final arrowBottom = h * 0.88;
    final arrowMid = h * 0.62;

    canvas.drawLine(Offset(arrowX, arrowTop), Offset(arrowX, arrowBottom), arrowPaint);
    canvas.drawLine(Offset(arrowX - w * 0.12, arrowMid), Offset(arrowX, arrowBottom), arrowPaint);
    canvas.drawLine(Offset(arrowX + w * 0.12, arrowMid), Offset(arrowX, arrowBottom), arrowPaint);

    // ── 4 horizontal lines ────────────────────────────────────────
    const lineLengths = [1.0, 0.78, 0.56, 0.34];
    final lineStart = w * 0.36;
    final maxLineWidth = w - lineStart - w * 0.04;
    final rowH = h / 4.5;

    for (int i = 0; i < 4; i++) {
      final fraction = descending ? lineLengths[i] : lineLengths[3 - i];
      final lineWidth = maxLineWidth * fraction;
      final y = h * 0.14 + i * rowH;
      canvas.drawLine(Offset(lineStart, y), Offset(lineStart + lineWidth, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(SortIconPainter old) => old.descending != descending;
}
