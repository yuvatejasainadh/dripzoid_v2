import 'package:flutter/material.dart';
import '../../theme/tokens/app_colors.dart';
import '../../theme/tokens/app_shapes.dart';

class PremiumSnackbar {
  PremiumSnackbar._();

  static void _show(
    BuildContext context, {
    required String message,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.surface,
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.radius12,
          side: BorderSide(color: color.withValues(alpha: 0.2)),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      color: AppColors.success,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  static void showError(BuildContext context, String message) {
    _show(
      context,
      message: message,
      color: AppColors.error,
      icon: Icons.error_outline_rounded,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message: message,
      color: Theme.of(context).colorScheme.primary,
      icon: Icons.info_outline_rounded,
    );
  }
}
