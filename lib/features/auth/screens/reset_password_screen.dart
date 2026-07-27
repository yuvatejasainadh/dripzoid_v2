import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/password_field.dart';
import '../widgets/primary_button.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends ConsumerState<ResetPasswordScreen> {
  final formKey = GlobalKey<FormState>();

  late final String email;

  final passwordController = TextEditingController();
  final confirmPasswordController =
  TextEditingController();

  bool loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    email =
    ModalRoute.of(context)!.settings.arguments
    as String;
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    if (!formKey.currentState!.validate()) return;

    if (passwordController.text !=
        confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text("Passwords do not match"),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .resetPassword(
        email: email,
        password:
        passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Password updated successfully",
          ),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        "/login",
            (_) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
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