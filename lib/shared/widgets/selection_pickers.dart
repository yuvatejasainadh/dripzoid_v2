import 'package:flutter/material.dart';

class ColorPicker extends StatelessWidget {
  final List<dynamic> colors;
  final String selectedColor;
  final ValueChanged<String> onSelected;

  const ColorPicker({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((c) {
        final String label = c is Map ? (c['name'] ?? c['label'] ?? '') : c.toString();
        final bool isSelected = label == selectedColor;

        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => onSelected(label),
          showCheckmark: false,
          labelStyle: TextStyle(
            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          selectedColor: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class SizePicker extends StatelessWidget {
  final List<String> sizes;
  final Map<String, int>? sizeStock;
  final String selectedSize;
  final ValueChanged<String> onSelected;

  const SizePicker({
    super.key,
    required this.sizes,
    this.sizeStock,
    required this.selectedSize,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: sizes.map((s) {
        final bool isSelected = s == selectedSize;
        final int stock = sizeStock?[s] ?? 1; // Default to 1 if no stock info
        final bool isAvailable = stock > 0;

        return InkWell(
          onTap: isAvailable ? () => onSelected(s) : null,
          borderRadius: BorderRadius.circular(8),
          child: Opacity(
            opacity: isAvailable ? 1.0 : 0.4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                  width: 1.5,
                ),
              ),
              child: Text(
                s,
                style: TextStyle(
                  color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  decoration: isAvailable ? null : TextDecoration.lineThrough,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
