import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  bool loading = false;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    if (!formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      PremiumSnackbar.showError(context, "Passwords do not match");
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
      PremiumSnackbar.showError(context, error ?? "Password reset failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.all(24),

            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 420,
              ),

              child: Form(
                key: formKey,

                child: Column(
                  children: [

                    const AuthHeader(
                      title:
                      "Reset Password",
                      subtitle:
                      "Create your new password",
                    ),

                    const SizedBox(
                        height: 40),

                    PasswordField(
                      controller:
                      passwordController,
                      hintText:
                      "New Password",
                      validator: (v) {
                        if (v == null ||
                            v.isEmpty) {
                          return "Required";
                        }

                        if (v.length < 8) {
                          return "Minimum 8 characters";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                        height: 18),

                    PasswordField(
                      controller:
                      confirmPasswordController,
                      hintText:
                      "Confirm Password",
                      validator: (v) {
                        if (v == null ||
                            v.isEmpty) {
                          return "Required";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                        height: 32),

                    PrimaryButton(
                      text:
                      "Update Password",
                      loading: loading,
                      onPressed:
                      resetPassword,
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
