import 'package:flutter/material.dart';

class LayoutUtils {
  LayoutUtils._();

  static const double maxContentWidth = 1200.0;
  static const double maxFormWidth = 460.0;
  static const double maxChatWidth = 900.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 600 && width < 900;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 900;

  /// Calculates dynamic grid column count based on available screen width.
  static int getGridColumnCount(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return 2;
    if (width < 900) return 3;
    if (width < 1200) return 4;
    return 5;
  }

  /// Calculates a safe childAspectRatio for product cards based on screen width and text scale.
  static double getProductGridRatio(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    if (textScale > 1.4) return 0.42;
    if (textScale > 1.2) return 0.46;
    if (textScale > 1.1) return 0.48;

    if (width < 360) return 0.48;
    if (width >= 900) return 0.58;
    if (width >= 600) return 0.55;

    return 0.52;
  }

  /// Gets responsive horizontal padding based on viewport size.
  static double getContentMargin(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return 16.0;
    if (width < 900) return 24.0;
    return 32.0;
  }
}

/// A wrapper widget that centers content and constrains its maximum width on wide displays.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;
  final double? widthFactor;
  final double? heightFactor;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = LayoutUtils.maxContentWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
    this.widthFactor,
    this.heightFactor,
  });

  /// Specialized constructor for bottom bars / persistent navigation widgets
  /// that must hug their intrinsic height at the bottom of the screen.
  const ResponsiveContainer.bottomBar({
    super.key,
    required this.child,
    this.maxWidth = LayoutUtils.maxContentWidth,
    this.padding,
    this.alignment = Alignment.bottomCenter,
    this.widthFactor,
    this.heightFactor = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}
