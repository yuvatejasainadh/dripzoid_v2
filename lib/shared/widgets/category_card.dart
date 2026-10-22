import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'shimmer_loading.dart';

class CategoryCard extends StatelessWidget {
  final String label;
  final String? imageUrl;
  final IconData? icon;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.label,
    this.imageUrl,
    this.icon,
    this.onTap,
  });

  IconData _resolveIcon() {
    if (icon != null) return icon!;
    final lower = label.trim().toLowerCase();
    if (lower == 'men' || lower == 'man' || lower == 'male') {
      return Icons.man;
    } else if (lower == 'women' || lower == 'woman' || lower == 'female') {
      return Icons.woman;
    } else if (lower == 'kids' || lower == 'kid' || lower == 'children') {
      return Icons.child_care;
    } else if (lower == 'shoes' || lower == 'footwear') {
      return Icons.roller_skating_outlined;
    } else if (lower == 'accessories' || lower == 'accessory') {
      return Icons.watch_outlined;
    }
    return Icons.checkroom_outlined;
  }

  String get _displayLabel {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedIcon = _resolveIcon();

    Widget tileContent;
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      tileContent = ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!.trim(),
          fit: BoxFit.cover,
          placeholder: (context, url) => const ShimmerWidget.circular(width: 80, height: 80),
          errorWidget: (context, url, error) => Center(
            child: Icon(
              resolvedIcon,
              size: 38,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      );
    } else {
      tileContent = Center(
        child: Icon(
          resolvedIcon,
          size: 38,
          color: theme.colorScheme.onSurface,
        ),
      );
    }

    return Semantics(
      button: true,
      label: '$_displayLabel category',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                border: Border.all(color: theme.colorScheme.outlineVariant, width: 1.5),
              ),
              child: tileContent,
            ),
            const SizedBox(height: 10),
            Text(
              _displayLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
