import 'package:flutter/material.dart';
import '../../theme/tokens/app_colors.dart';
import '../../theme/tokens/app_shapes.dart';

enum PremiumAlertType { error, success, warning, info, confirmation }

class PremiumDialogWidget extends StatelessWidget {
  final String title;
  final String message;
  final PremiumAlertType type;
  final String? primaryActionText;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionText;
  final VoidCallback? onSecondaryAction;
  final bool isDestructive;

  const PremiumDialogWidget({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    this.primaryActionText,
    this.onPrimaryAction,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final screenWidth = size.width;
    final maxDialogHeight = size.height * 0.85;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.88 > 420 ? 420 : screenWidth * 0.88,
          maxHeight: maxDialogHeight,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: AppShapes.radius20,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIcon(context),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                _buildActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case PremiumAlertType.error:
        iconData = Icons.error_outline_rounded;
        iconColor = AppColors.error;
      case PremiumAlertType.success:
        iconData = Icons.check_circle_outline_rounded;
        iconColor = AppColors.success;
      case PremiumAlertType.warning:
      case PremiumAlertType.confirmation:
        iconData = Icons.warning_amber_rounded;
        iconColor = Colors.orange;
      case PremiumAlertType.info:
        iconData = Icons.info_outline_rounded;
        iconColor = Theme.of(context).colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 32,
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final theme = Theme.of(context);

    if (secondaryActionText == null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPrimaryAction ?? () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive ? AppColors.error : theme.colorScheme.primary,
            foregroundColor: isDestructive ? Colors.white : theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: AppShapes.radius12),
            elevation: 0,
          ),
          child: Text(
            primaryActionText ?? 'Done',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: onSecondaryAction ?? () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: AppShapes.radius12),
            ),
            child: Text(
              secondaryActionText!,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onPrimaryAction ?? () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? AppColors.error : theme.colorScheme.primary,
              foregroundColor: isDestructive ? Colors.white : theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: AppShapes.radius12),
              elevation: 0,
            ),
            child: Text(
              primaryActionText ?? 'Confirm',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
