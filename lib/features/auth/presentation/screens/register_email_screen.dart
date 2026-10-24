import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/dialogs/app_error_dialog.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';

class RegisterEmailScreen extends ConsumerStatefulWidget {
  const RegisterEmailScreen({super.key});

  @override
  ConsumerState<RegisterEmailScreen> createState() =>
      _RegisterEmailScreenState();
}

class _RegisterEmailScreenState
    extends ConsumerState<RegisterEmailScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool loading = false;

  Future<void> continueToOtp() async {
    if (loading) return; // Prevent duplicate submission
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final email = emailController.text.trim();
      final exists = await ref.read(authProvider.notifier).checkEmail(email);

      if (!mounted) return;

      if (exists) {
        AppErrorDialog.showForError(context, error: "Email already registered. Please sign in instead.");
        return;
      }

      final sent = await ref.read(authProvider.notifier).sendOTP(email);

      if (!mounted) return;

      if (sent) {
        context.push('/register-otp', extra: email);
      } else {
        final error = ref.read(authProvider).errorMessage;
        AppErrorDialog.showForError(
          context,
          error: error ?? "Failed to send OTP. Please check your connection and try again.",
          onRetry: () => continueToOtp(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      title: "Create Account",
                      subtitle: "Enter your email to receive an OTP.",
                    ),
                    const SizedBox(height: 40),
                    AppTextField(
                      controller: emailController,
                      hintText: "Email Address",
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Email is required";
                        }
                        final regex = RegExp(
                          r'^[^@]+@[^@]+\.[^@]+$',
                        );
                        if (!regex.hasMatch(value)) {
                          return "Invalid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      text: "Continue",
                      loading: loading,
                      onPressed: continueToOtp,
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
