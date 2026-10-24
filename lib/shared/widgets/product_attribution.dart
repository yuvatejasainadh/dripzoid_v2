import 'package:flutter/material.dart';

/// A minimal product attribution widget attributing Dripzoid to SAI Labs.
///
/// Features a compact, refined bottom banner displaying "A Product of" and the
/// SAI Labs logo with a dark container treatment, ensuring crisp contrast and
/// legibility across both light and dark themes.
class ProductAttribution extends StatelessWidget {
  final bool showBrandText;
  const ProductAttribution({super.key, this.showBrandText = false});

  static const String logoAsset = 'assets/logos/sailabs_logo-dark.png';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141414) : const Color(0xFF121212),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black12,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'A Product of',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Image.asset(
              logoAsset,
              height: 28,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
            ),
          ],
        ),
      ),
    );
  }
}
