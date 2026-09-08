import 'package:flutter/material.dart';
import '../widgets/premium_dialog_widget.dart';

class PremiumAlert {
  PremiumAlert._();

  static Future<T?> _show<T>(
    BuildContext context, {
    required String title,
    required String message,
    required PremiumAlertType type,
    String? primaryActionText,
    String? secondaryActionText,
    bool isDestructive = false,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) => PremiumDialogWidget(
        title: title,
        message: message,
        type: type,
        primaryActionText: primaryActionText,
        secondaryActionText: secondaryActionText,
        isDestructive: isDestructive,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
  }) {
    return _show<void>(
      context,
      title: title,
      message: message,
      type: PremiumAlertType.error,
      primaryActionText: buttonText,
    );
  }

  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
  }) {
    return _show<void>(
      context,
      title: title,
      message: message,
      type: PremiumAlertType.success,
      primaryActionText: buttonText,
    );
  }

  static Future<void> showWarning(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
  }) {
    return _show<void>(
      context,
      title: title,
      message: message,
      type: PremiumAlertType.warning,
      primaryActionText: buttonText,
    );
  }

  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
  }) {
    return _show<void>(
      context,
      title: title,
      message: message,
      type: PremiumAlertType.info,
      primaryActionText: buttonText,
    );
  }

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await _show<bool>(
      context,
      title: title,
      message: message,
      type: PremiumAlertType.confirmation,
      primaryActionText: confirmText,
      secondaryActionText: cancelText,
      isDestructive: isDestructive,
    );
    return result ?? false;
  }
}
