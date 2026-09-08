import 'package:flutter/material.dart';

class LayoutUtils {
  LayoutUtils._();

  /// Calculates a safe childAspectRatio for the product grid based on 
  /// screen width and text scale factor to prevent vertical overflow.
  static double getProductGridRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    
    // We need more height (smaller ratio) as text scale increases.
    // Making ratios more conservative to prevent overflow.
    if (textScale > 1.4) return 0.42;
    if (textScale > 1.2) return 0.46;
    if (textScale > 1.1) return 0.48;
    if (width < 340) return 0.48; // Narrow screens need more height
    
    return 0.52; // Default more height than 0.55
  }
}
