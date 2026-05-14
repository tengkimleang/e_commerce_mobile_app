import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:e_commerce_mobile_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract final class MapMarkerIcons {
  static BitmapDescriptor? _pinkShopMarker;

  static Future<BitmapDescriptor> pinkShopMarker() async {
    if (_pinkShopMarker != null) {
      return _pinkShopMarker!;
    }
    _pinkShopMarker = await _buildPinkShopMarker();
    return _pinkShopMarker!;
  }

  static Future<BitmapDescriptor> _buildPinkShopMarker() async {
    const double imageSize = 120;
    const double circleRadius = 50;
    const double iconSize = 52;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = const Offset(imageSize / 2, imageSize / 2);

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center.translate(0, 4), circleRadius, shadowPaint);

    final fillPaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(center, circleRadius, fillPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, circleRadius, borderPaint);

    final icon = Icons.storefront_rounded;
    final textPainter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.white,
        ),
      )
      ..layout();

    final iconOffset = Offset(
      center.dx - (textPainter.width / 2),
      center.dy - (textPainter.height / 2),
    );
    textPainter.paint(canvas, iconOffset);

    final image = await recorder.endRecording().toImage(
      imageSize.toInt(),
      imageSize.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);
    }

    final Uint8List bytes = byteData.buffer.asUint8List();
    return BitmapDescriptor.bytes(
      bytes,
      width: 42,
      height: 42,
      bitmapScaling: MapBitmapScaling.auto,
    );
  }
}
