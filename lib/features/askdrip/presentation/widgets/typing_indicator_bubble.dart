import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_loader.dart';

class TypingIndicatorBubble extends StatelessWidget {
  const TypingIndicatorBubble({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: colorScheme.primary,
            child: Icon(Icons.auto_awesome, size: 16, color: colorScheme.onPrimary),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
              ),
              child: const SizedBox(
                width: 44,
                height: 20,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: AppLoader(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
