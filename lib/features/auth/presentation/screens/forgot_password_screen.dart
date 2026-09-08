import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../core/ui/snackbars/premium_snackbar.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends ConsumerState<ForgotPasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  Future<void> continueToOtp() async {
    if (!formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final sent = await ref.read(authProvider.notifier).sendOTP(email);

    if (!mounted) return;

    if (sent) {
      context.push('/forgot-otp', extra: email);
    } else {
      final error = ref.read(authProvider).errorMessage;
      PremiumSnackbar.showError(context, error ?? "Unable to send OTP");
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
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
                      title: "Forgot Password",
                      subtitle:
                      "Enter your registered email.",
                    ),

                    const SizedBox(height: 40),

                    AppTextField(
                      controller: emailController,

                      hintText:
                      "Registered Email",

                      keyboardType:
                      TextInputType.emailAddress,

                      prefixIcon: const Icon(
                        Icons.email_outlined,
                      ),

                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return "Email required";
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
                      text: "Send OTP",
                      loading: state.isLoading,
                      onPressed: continueToOtp,
                    ),

                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () {
                        context.pop();
                      },
                      child: const Text(
                        "Back to Login",
                      ),
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
