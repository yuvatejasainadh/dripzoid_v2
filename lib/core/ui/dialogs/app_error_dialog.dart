import 'package:flutter/material.dart';
import '../../models/result.dart';
import '../../network/api_exception.dart';
import '../../theme/tokens/app_shapes.dart';

class AppErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? retryText;
  final VoidCallback? onRetry;
  final String dismissText;
  final VoidCallback? onDismiss;

  const AppErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.info_outline_rounded,
    this.retryText,
    this.onRetry,
    this.dismissText = 'Dismiss',
    this.onDismiss,
  });

  static bool _isShowing = false;
  static bool get isShowing => _isShowing;

  @visibleForTesting
  static void resetForTesting() {
    _isShowing = false;
  }

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.info_outline_rounded,
    String? retryText,
    VoidCallback? onRetry,
    String dismissText = 'Dismiss',
    VoidCallback? onDismiss,
  }) async {
    if (_isShowing) return; // Deduplication: prevent stacking duplicate dialogs
    _isShowing = true;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => AppErrorDialog(
          title: title,
          message: message,
          icon: icon,
          retryText: retryText,
          onRetry: onRetry,
          dismissText: dismissText,
          onDismiss: onDismiss,
        ),
      );
    } finally {
      _isShowing = false;
    }
  }

  static Future<void> showForError(
    BuildContext context, {
    required dynamic error,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) async {
    final title = _deriveTitle(error);
    final message = _deriveMessage(error);
    final icon = _deriveIcon(error);
    final isRetryable = _deriveRetryable(error) && onRetry != null;

    await show(
      context,
      title: title,
      message: message,
      icon: icon,
      retryText: isRetryable ? 'Retry' : null,
      onRetry: isRetryable ? onRetry : null,
      dismissText: 'Dismiss',
      onDismiss: onDismiss,
    );
  }

  static String _deriveTitle(dynamic error) {
    if (error is Failure) {
      return switch (error.errorType) {
        ApiErrorType.networkUnavailable || ApiErrorType.corsOrBlocked => 'Connection Problem',
        ApiErrorType.serverError => 'Service Temporarily Unavailable',
        ApiErrorType.authentication => 'Authentication Error',
        ApiErrorType.validation => 'Validation Error',
        ApiErrorType.rateLimit => 'Too Many Requests',
        ApiErrorType.timeout => 'Request Timed Out',
        ApiErrorType.unknown => 'Something Went Wrong',
      };
    }

    if (error is ApiException) {
      return switch (error.type) {
        ApiErrorType.networkUnavailable || ApiErrorType.corsOrBlocked => 'Connection Problem',
        ApiErrorType.serverError => 'Service Temporarily Unavailable',
        ApiErrorType.authentication => 'Authentication Error',
        ApiErrorType.validation => 'Validation Error',
        ApiErrorType.rateLimit => 'Too Many Requests',
        ApiErrorType.timeout => 'Request Timed Out',
        ApiErrorType.unknown => 'Something Went Wrong',
      };
    }

    final str = error.toString().toLowerCase();
    if (str.contains('connection') || str.contains('internet') || str.contains('network') || str.contains('cors')) {
      return 'Connection Problem';
    }
    if (str.contains('timeout') || str.contains('timed out')) {
      return 'Request Timed Out';
    }
    if (str.contains('server') || str.contains('500') || str.contains('502') || str.contains('503')) {
      return 'Service Temporarily Unavailable';
    }
    if (str.contains('password') || str.contains('email') || str.contains('auth') || str.contains('unauthorized')) {
      return 'Authentication Error';
    }
    return 'Something Went Wrong';
  }

  static String _deriveMessage(dynamic error) {
    if (error is Failure) {
      if (error.errorType == ApiErrorType.networkUnavailable || error.errorType == ApiErrorType.corsOrBlocked) {
        return "We couldn't connect to Dripzoid. Check your connection and try again.";
      }
      if (error.errorType == ApiErrorType.serverError) {
        return "We couldn't complete your request right now. Please try again shortly.";
      }
      if (error.errorType == ApiErrorType.timeout) {
        return "The request took too long. Please try again.";
      }
      return error.message;
    }

    if (error is ApiException) {
      if (error.type == ApiErrorType.networkUnavailable || error.type == ApiErrorType.corsOrBlocked) {
        return "We couldn't connect to Dripzoid. Check your connection and try again.";
      }
      if (error.type == ApiErrorType.serverError) {
        return "We couldn't complete your request right now. Please try again shortly.";
      }
      if (error.type == ApiErrorType.timeout) {
        return "The request took too long. Please try again.";
      }
      return error.message;
    }

    final str = error.toString().replaceAll(RegExp(r'^Exception:\s*'), '');
    final lower = str.toLowerCase();
    if (lower.contains('connection') || lower.contains('internet') || lower.contains('network') || lower.contains('cors')) {
      return "We couldn't connect to Dripzoid. Check your connection and try again.";
    }
    if (lower.contains('timed out') || lower.contains('timeout')) {
      return "The request took too long. Please try again.";
    }
    if (lower.contains('server') || lower.contains('500') || lower.contains('503')) {
      return "We couldn't complete your request right now. Please try again shortly.";
    }
    return str.isNotEmpty ? str : "An unexpected error occurred. Please try again.";
  }

  static IconData _deriveIcon(dynamic error) {
    if (error is Failure) {
      return switch (error.errorType) {
        ApiErrorType.networkUnavailable || ApiErrorType.corsOrBlocked => Icons.wifi_off_rounded,
        ApiErrorType.serverError => Icons.cloud_off_rounded,
        ApiErrorType.authentication => Icons.lock_outline_rounded,
        ApiErrorType.validation => Icons.error_outline_rounded,
        ApiErrorType.rateLimit => Icons.speed_rounded,
        ApiErrorType.timeout => Icons.timer_outlined,
        ApiErrorType.unknown => Icons.info_outline_rounded,
      };
    }

    if (error is ApiException) {
      return switch (error.type) {
        ApiErrorType.networkUnavailable || ApiErrorType.corsOrBlocked => Icons.wifi_off_rounded,
        ApiErrorType.serverError => Icons.cloud_off_rounded,
        ApiErrorType.authentication => Icons.lock_outline_rounded,
        ApiErrorType.validation => Icons.error_outline_rounded,
        ApiErrorType.rateLimit => Icons.speed_rounded,
        ApiErrorType.timeout => Icons.timer_outlined,
        ApiErrorType.unknown => Icons.info_outline_rounded,
      };
    }

    final lower = error.toString().toLowerCase();
    if (lower.contains('connection') || lower.contains('internet') || lower.contains('network') || lower.contains('cors')) {
      return Icons.wifi_off_rounded;
    }
    if (lower.contains('timeout')) {
      return Icons.timer_outlined;
    }
    if (lower.contains('server')) {
      return Icons.cloud_off_rounded;
    }
    if (lower.contains('password') || lower.contains('email') || lower.contains('auth')) {
      return Icons.lock_outline_rounded;
    }
    return Icons.info_outline_rounded;
  }

  static bool _deriveRetryable(dynamic error) {
    if (error is Failure) {
      return error.errorType != ApiErrorType.authentication &&
             error.errorType != ApiErrorType.validation &&
             error.errorType != ApiErrorType.rateLimit;
    }
    if (error is ApiException) {
      return error.type != ApiErrorType.authentication &&
             error.type != ApiErrorType.validation &&
             error.type != ApiErrorType.rateLimit;
    }
    final lower = error.toString().toLowerCase();
    if (lower.contains('password') || lower.contains('invalid') || lower.contains('unauthorized')) {
      return false; // Never auto-retry authentication/credential errors
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      namesRoute: true,
      scopesRoute: true,
      explicitChildNodes: true,
      label: '$title dialog',
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.radius20,
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: isDark ? 0.25 : 0.12),
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 8,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400,
            minWidth: 280,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Header
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: isDark ? 0.4 : 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 26,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),

                // Message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                if (onRetry != null && retryText != null)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onDismiss?.call();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppShapes.radius12,
                            ),
                          ),
                          child: Text(dismissText),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onRetry!();
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppShapes.radius12,
                            ),
                          ),
                          child: Text(retryText!),
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onDismiss?.call();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppShapes.radius12,
                        ),
                      ),
                      child: Text(dismissText),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
