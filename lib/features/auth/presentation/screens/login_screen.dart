import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dripzoid_v2/core/constants/app_strings.dart';
import 'package:dripzoid_v2/core/ui/snackbars/premium_snackbar.dart';
import 'package:dripzoid_v2/shared/widgets/app_text_field.dart';
import 'package:dripzoid_v2/shared/widgets/password_field.dart';
import 'package:dripzoid_v2/shared/widgets/primary_button.dart';
import 'package:dripzoid_v2/shared/widgets/google_sign_in_button.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';

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

    final success = await ref.read(authProvider.notifier).login(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      if (!mounted) return;
      context.go('/home');
    } else {
      final state = ref.read(authProvider);
      PremiumSnackbar.showError(context, state.errorMessage ?? 'Login failed');
    }
  }

  Future<void> googleLogin() async {
    final success = await ref.read(authProvider.notifier).googleLogin();
    if (success && mounted) {
      context.go('/home');
    } else if (!success && mounted) {
      final state = ref.read(authProvider);
      if (state.errorMessage != null) {
        PremiumSnackbar.showError(context, state.errorMessage!);
      }
    }
  }

@override
Widget build(BuildContext context) {
final state = ref.watch(authProvider);

final theme = Theme.of(context);
final colors = theme.colorScheme;

return Scaffold(
backgroundColor: colors.surface,
resizeToAvoidBottomInset: true,
body: Center(
child: SingleChildScrollView(
padding: const EdgeInsets.symmetric(
horizontal: 24,
vertical: 30,
),

child: ConstrainedBox(
constraints: const BoxConstraints(
maxWidth: 430,
),

child: Form(
key: _formKey,

child: Container(
padding: const EdgeInsets.all(28),

decoration: BoxDecoration(
color: colors.surface,
borderRadius: BorderRadius.circular(24),
border: Border.all(
color: colors.outline.withValues(alpha: 0.1),
),
),

child: Column(
crossAxisAlignment:
CrossAxisAlignment.stretch,

children: [

const SizedBox(height: 10),

AuthHeader(
  title: AppStrings.welcomeBack,
  subtitle: AppStrings.loginSubtitle,
),

const SizedBox(height: 38),

AppTextField(
controller: emailController,
hintText: AppStrings.emailAddress,
keyboardType: TextInputType.emailAddress,
prefixIcon: const Icon(Icons.email_outlined),
validator: (value) {
if (value == null ||
value.trim().isEmpty) {
return "Email is required";
}
return null;
},
),

const SizedBox(height: 18),

PasswordField(
controller: passwordController,
hintText: AppStrings.password,
validator: (value) {
if (value == null ||
value.isEmpty) {
return "Password is required";
}
return null;
},
),

const SizedBox(height: 8),

Align(
alignment: Alignment.centerRight,
child: TextButton(
onPressed: () => context.push('/forgot-password'),
child: const Text(AppStrings.forgotPassword),
),
),

const SizedBox(height: 16),

PrimaryButton(
text: AppStrings.login,
loading: state.isLoading,
onPressed: login,
),

const SizedBox(height: 28),

Row(
children: [
Expanded(child: Divider(color: colors.outlineVariant)),
Padding(
padding: const EdgeInsets.symmetric(horizontal: 14),
child: Text(
AppStrings.or,
style: theme.textTheme.bodyMedium,
),
),
Expanded(child: Divider(color: colors.outlineVariant)),
],
),

const SizedBox(height: 26),
GoogleSignInButton(
  onPressed: googleLogin,
  loading: state.isLoading,
),

const SizedBox(height: 34),

Wrap(
alignment: WrapAlignment.center,
crossAxisAlignment: WrapCrossAlignment.center,
children: [
Text(
AppStrings.dontHaveAccount,
style: theme.textTheme.bodyMedium,
),
TextButton(
onPressed: () => context.push('/register-email'),
child: const Text(AppStrings.createAccount),
),
],
),

const SizedBox(height: 10),

Text(
AppStrings.termsAndPrivacy,
textAlign: TextAlign.center,
style: theme.textTheme.labelSmall,
),

const SizedBox(height: 8),
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
