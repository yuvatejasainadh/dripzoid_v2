import 'package:flutter/material.dart';

import '../widgets/app_text_field.dart';
import '../widgets/auth_header.dart';
import '../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();

  bool loading = false;

  Future<void> continueToOtp() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    try {
      // TODO:
      // Call Send OTP API

      if (!mounted) return;

      Navigator.pushNamed(
        context,
        "/forgot-otp",
        arguments: emailController.text.trim(),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Unable to send OTP",
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
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
                      loading: loading,
                      onPressed: continueToOtp,
                    ),

                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
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