import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum AppWindowClass { compact, medium, expanded, large, extraLarge }

abstract final class AppBreakpoints {
  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 1200;
  static const double large = 1600;
}

abstract final class AppResponsive {
  static AppWindowClass windowClassForWidth(double width) {
    if (width >= AppBreakpoints.large) return AppWindowClass.extraLarge;
    if (width >= AppBreakpoints.expanded) return AppWindowClass.large;
    if (width >= AppBreakpoints.medium) return AppWindowClass.expanded;
    if (width >= AppBreakpoints.compact) return AppWindowClass.medium;
    return AppWindowClass.compact;
  }

  static AppWindowClass windowClassOf(BuildContext context) {
    return windowClassForWidth(MediaQuery.sizeOf(context).width);
  }

  static bool useNavigationRailForWidth(double width) {
    return width >= AppBreakpoints.compact;
  }

  static bool useNavigationRail(BuildContext context) {
    return useNavigationRailForWidth(MediaQuery.sizeOf(context).width);
  }

  static EdgeInsetsGeometry pagePaddingForWidth(double width) {
    final horizontal = switch (windowClassForWidth(width)) {
      AppWindowClass.compact => 16.0,
      AppWindowClass.medium => 24.0,
      AppWindowClass.expanded => 32.0,
      AppWindowClass.large => 40.0,
      AppWindowClass.extraLarge => 48.0,
    };
    return EdgeInsets.symmetric(horizontal: horizontal);
  }

  static double maxContentWidthForWidth(double width) {
    return switch (windowClassForWidth(width)) {
      AppWindowClass.compact => double.infinity,
      AppWindowClass.medium => 760,
      AppWindowClass.expanded => 1040,
      AppWindowClass.large => 1180,
      AppWindowClass.extraLarge => 1280,
    };
  }

  static double productCardMaxWidthForWidth(double width) {
    return switch (windowClassForWidth(width)) {
      AppWindowClass.compact => 210,
      AppWindowClass.medium => 220,
      AppWindowClass.expanded => 230,
      AppWindowClass.large => 240,
      AppWindowClass.extraLarge => 250,
    };
  }

  static double productCardAspectRatioForWidth(double width) {
    return switch (windowClassForWidth(width)) {
      AppWindowClass.compact => 0.76,
      AppWindowClass.medium => 0.78,
      AppWindowClass.expanded => 0.82,
      AppWindowClass.large => 0.84,
      AppWindowClass.extraLarge => 0.86,
    };
  }

  static SliverGridDelegate productGridDelegateForWidth(
    double width, {
    double? maxCrossAxisExtent,
    double? childAspectRatio,
  }) {
    return SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent:
          maxCrossAxisExtent ?? productCardMaxWidthForWidth(width),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio:
          childAspectRatio ?? productCardAspectRatioForWidth(width),
    );
  }

  static double homeHeroHeightForWidth(double width) {
    return switch (windowClassForWidth(width)) {
      AppWindowClass.compact => 300,
      AppWindowClass.medium => 340,
      AppWindowClass.expanded => 380,
      AppWindowClass.large => 420,
      AppWindowClass.extraLarge => 440,
    };
  }

  static double detailHeroHeightForWidth(double width) {
    return switch (windowClassForWidth(width)) {
      AppWindowClass.compact => 360,
      AppWindowClass.medium => 400,
      AppWindowClass.expanded => 440,
      AppWindowClass.large => 460,
      AppWindowClass.extraLarge => 480,
    };
  }

  static double carouselItemWidthForWidth(double width) {
    return switch (windowClassForWidth(width)) {
      AppWindowClass.compact => 160,
      AppWindowClass.medium => 176,
      AppWindowClass.expanded => 190,
      AppWindowClass.large => 204,
      AppWindowClass.extraLarge => 214,
    };
  }

  static double carouselHeightForWidth(double width, double compactHeight) {
    final scale = switch (windowClassForWidth(width)) {
      AppWindowClass.compact => 1.0,
      AppWindowClass.medium => 1.07,
      AppWindowClass.expanded => 1.14,
      AppWindowClass.large => 1.20,
      AppWindowClass.extraLarge => 1.24,
    };
    return compactHeight * scale;
  }
}

class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double? maxWidth;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final windowWidth = MediaQuery.sizeOf(context).width;
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : windowWidth;
        final effectiveWidth = maxWidth ??
            AppResponsive.maxContentWidthForWidth(availableWidth);

        return Align(
          alignment: alignment,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: effectiveWidth),
            child: child,
          ),
        );
      },
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        ...super.dragDevices,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
      };
}
