import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Full-screen barcode / QR-code scanner.
///
/// Push this screen and await a [String?] result:
/// ```dart
/// final code = await Navigator.pushNamed<String>(context, AppRoutes.scanBarcode);
/// ```
/// Returns the raw barcode value on success, or null when the user cancels.
class ScanBarcodeView extends StatefulWidget {
  const ScanBarcodeView({super.key});

  @override
  State<ScanBarcodeView> createState() => _ScanBarcodeViewState();
}

class _ScanBarcodeViewState extends State<ScanBarcodeView>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _scanner;
  late final AnimationController _lineController;
  late final Animation<double> _lineAnim;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _scanner = MobileScannerController();
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _lineAnim = CurvedAnimation(
      parent: _lineController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scanner.dispose();
    _lineController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_processing) return;
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null || value.isEmpty) return;
    _processing = true;
    Navigator.of(context).pop(value);
  }

  Future<void> _pickImageFromGallery() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final capture = await _scanner.analyzeImage(picked.path);
    if (!mounted) return;
    final value = capture?.barcodes.firstOrNull?.rawValue;
    if (value == null || value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No barcode found in the selected image')),
      );
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    const boxSize = 260.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Camera feed ──────────────────────────────────
          MobileScanner(
            controller: _scanner,
            onDetect: _onDetect,
          ),

          // ── Dark overlay with transparent scan box ───────
          CustomPaint(
            painter: _OverlayPainter(boxSize: boxSize),
            child: const SizedBox.expand(),
          ),

          // ── Animated pink scan line ───────────────────────
          Positioned.fill(
            child: Center(
              child: SizedBox(
                width: boxSize,
                height: boxSize,
                child: AnimatedBuilder(
                  animation: _lineAnim,
                  builder: (_, __) => Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: _lineAnim.value * (boxSize - 2),
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFEC407A).withOpacity(0),
                                const Color(0xFFEC407A),
                                const Color(0xFFEC407A).withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Top bar ──────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left,
                        color: Colors.white, size: 32),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Scan Barcode',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Balance back button width
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // ── Bottom buttons ────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.flashlight_on_outlined,
                        label: 'Flashlight',
                        onTap: () => _scanner.toggleTorch(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.image_outlined,
                        label: 'Upload Image',
                        onTap: _pickImageFromGallery,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────

class _OverlayPainter extends CustomPainter {
  final double boxSize;
  _OverlayPainter({required this.boxSize});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final half = boxSize / 2;
    const r = 12.0;
    const arm = 28.0;

    final boxRect = Rect.fromLTRB(cx - half, cy - half, cx + half, cy + half);

    // Dark overlay with cut-out
    final overlay = Paint()..color = Colors.black54;
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(boxRect, const Radius.circular(r)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, overlay);

    // Corner brackets
    final bracket = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    void drawCorner(double x, double y, double startAngle) {
      // Arc
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(x, y),
          width: r * 2,
          height: r * 2,
        ),
        startAngle,
        math.pi / 2,
        false,
        bracket,
      );
      // Two arms radiating from the corner arc endpoints
      final cosA = math.cos(startAngle);
      final sinA = math.sin(startAngle);
      final cosB = math.cos(startAngle + math.pi / 2);
      final sinB = math.sin(startAngle + math.pi / 2);
      canvas.drawLine(
        Offset(x + cosA * r, y + sinA * r),
        Offset(x + cosA * (r + arm), y + sinA * (r + arm)),
        bracket,
      );
      canvas.drawLine(
        Offset(x + cosB * r, y + sinB * r),
        Offset(x + cosB * (r + arm), y + sinB * (r + arm)),
        bracket,
      );
    }

    // Top-left  (arc at π, arms pointing up & left)
    drawCorner(cx - half + r, cy - half + r, math.pi);
    // Top-right (arc at 3π/2, arms pointing up & right)
    drawCorner(cx + half - r, cy - half + r, 3 * math.pi / 2);
    // Bottom-left (arc at π/2, arms pointing down & left)
    drawCorner(cx - half + r, cy + half - r, math.pi / 2);
    // Bottom-right (arc at 0, arms pointing down & right)
    drawCorner(cx + half - r, cy + half - r, 0);
  }

  @override
  bool shouldRepaint(_OverlayPainter old) => old.boxSize != boxSize;
}

// ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
