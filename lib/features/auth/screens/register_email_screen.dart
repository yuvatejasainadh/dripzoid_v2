import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_header.dart';
import '../widgets/primary_button.dart';

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
    if (!formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    try {
      final exists = await ref
          .read(authRepositoryProvider)
          .checkEmail(emailController.text);

      if (!mounted) return;

      if (exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email already registered"),
          ),
        );

        return;
      }

      Navigator.pushNamed(
        context,
        "/register-otp",
        arguments: emailController.text.trim(),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
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
                      subtitle:
                      "Enter your email to receive an OTP.",
                    ),

                    const SizedBox(height: 40),

                    AppTextField(
                      controller: emailController,

                      hintText: "Email Address",

                      keyboardType:
                      TextInputType.emailAddress,

                      prefixIcon: const Icon(
                        Icons.email_outlined,
                      ),

                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
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

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Already have an account?",
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