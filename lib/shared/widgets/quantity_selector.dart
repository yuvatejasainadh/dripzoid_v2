import 'package:flutter/material.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final int maxQuantity;
  final ValueChanged<int> onChanged;
  final VoidCallback? onDecreaseBelowMin;
  final VoidCallback? onMaxReached;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.maxQuantity = 99,
    this.onDecreaseBelowMin,
    this.onMaxReached,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool canDecrease = quantity > 1;
    final bool canIncrease = quantity < maxQuantity;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            context,
            icon: Icons.remove,
            tooltip: canDecrease
                ? 'Decrease quantity'
                : (onDecreaseBelowMin != null ? 'Remove item' : 'Minimum quantity is 1'),
            onPressed: canDecrease
                ? () => onChanged(quantity - 1)
                : onDecreaseBelowMin,
            isEnabled: canDecrease || onDecreaseBelowMin != null,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              quantity.toString(),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          _buildButton(
            context,
            icon: Icons.add,
            tooltip: canIncrease
                ? 'Increase quantity'
                : 'Maximum stock ($maxQuantity) reached',
            onPressed: canIncrease
                ? () => onChanged(quantity + 1)
                : onMaxReached,
            isEnabled: canIncrease || onMaxReached != null,
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isEnabled,
    String? tooltip,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 16,
        color: isEnabled
            ? colorScheme.primary
            : colorScheme.onSurface.withValues(alpha: 0.38),
      ),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      padding: EdgeInsets.zero,
    );
  }
}
