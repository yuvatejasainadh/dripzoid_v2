import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_logo.dart';

import '../providers/auth_provider.dart';
import '../providers/google_provider.dart';
import '../providers/session_provider.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_header.dart';
import '../widgets/password_field.dart';
import '../widgets/primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);

    final success = await ref.read(authProvider.notifier).login(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      await ref.read(sessionProvider.notifier).initialize();

      if (!mounted) return;

      context.go('/home');
    } else {
      final state = ref.read(authProvider);

      messenger.showSnackBar(
        SnackBar(
          content: Text(state.error ?? 'Login failed'),
        ),
      );
    }
  }

  Future<void> googleLogin() async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final success = await ref.read(googleAuthProvider).signIn();

      if (!mounted) return;

      if (success) {
        await ref.read(sessionProvider.notifier).initialize();

        if (!mounted) return;

        context.go('/home');
      }
    } catch (e) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    //const AppLogo(size: 110),

                    const SizedBox(height: 24),

                    const AuthHeader(
                      title: "Welcome Back",
                      subtitle: "Login to continue shopping",
                    ),

                    const SizedBox(height: 40),

                    AppTextField(
                      controller: emailController,
                      hintText: "Email",
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Email is required";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    PasswordField(
                      controller: passwordController,
                      hintText: "Password",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          context.push('/forgot-password');
                        },
                        child: const Text("Forgot Password?"),
                      ),
                    ),

                    const SizedBox(height: 16),

                    PrimaryButton(
                      text: "Login",
                      loading: state.isLoading,
                      onPressed: login,
                    ),

                    const SizedBox(height: 24),

                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text("OR"),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: googleLogin,
                        icon: const Icon(Icons.g_mobiledata),
                        label: const Text(
                          "Continue with Google",
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                        ),
                        TextButton(
                          onPressed: () {
                            context.push('/register-email');
                          },
                          child: const Text(
                            "Register",
                          ),
                        ),
                      ],
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