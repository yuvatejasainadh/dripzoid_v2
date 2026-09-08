import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/dialogs/premium_alert.dart';

class LoginRequiredDialog {
  static Future<void> show(BuildContext context) async {
    final confirmed = await PremiumAlert.confirm(
      context,
      title: 'Login Required',
      message: 'Please login to continue.',
      confirmText: 'Login',
    );

    if (confirmed && context.mounted) {
      context.push('/login');
    }
  }
}
