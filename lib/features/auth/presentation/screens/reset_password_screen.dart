import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/dialogs/app_error_dialog.dart';
import '../../../../core/ui/snackbars/premium_snackbar.dart';
import '../../../../shared/widgets/password_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends ConsumerState<ResetPasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    if (ref.read(authProvider).isLoading) return; // Prevent duplicate submissions
    if (!formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      AppErrorDialog.showForError(context, error: "Passwords do not match");
      return;
    }

    final success = await ref.read(authProvider.notifier).resetPassword(
          email: widget.email,
          password: passwordController.text,
        );

    if (!mounted) return;

    if (success) {
      PremiumSnackbar.showSuccess(context, "Password reset successfully. Please log in.");
      context.go('/login');
    } else {
      final error = ref.read(authProvider).errorMessage;
      AppErrorDialog.showForError(
        context,
        error: error ?? "Password reset failed. Please check your connection and try again.",
        onRetry: () => resetPassword(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    const AuthHeader(
                      title: "Reset Password",
                      subtitle: "Enter your new password.",
                    ),
                    const SizedBox(height: 40),
                    PasswordField(
                      controller: passwordController,
                      hintText: "New Password",
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return "Min 6 characters required";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    PasswordField(
                      controller: confirmPasswordController,
                      hintText: "Confirm Password",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Confirm your password";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      text: "Reset Password",
                      loading: state.isLoading,
                      onPressed: resetPassword,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
