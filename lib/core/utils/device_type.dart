import 'dart:io';
import 'dart:ui';
import 'package:flutter/widgets.dart';

class DeviceType {
  bool isTablet, isPhone, isIos, isAndroid;
  DeviceType(
      {required this.isTablet,
      required this.isPhone,
      required this.isIos,
      required this.isAndroid});

  factory DeviceType.get() {
    bool isTablet, isPhone;
    bool isIos = Platform.isIOS;
    bool isAndroid = Platform.isAndroid;

    final data = MediaQueryData.fromView(PlatformDispatcher.instance.views.first);

    if (data.size.shortestSide < 550) {
      isTablet = false;
      isPhone = true;
    } else {
      isTablet = true;
      isPhone = false;
    }

    return DeviceType(
      isTablet: isTablet,
      isPhone: isPhone,
      isIos: isIos,
      isAndroid: isAndroid,
    );
  }
}
