import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/snackbars/premium_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/password_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

class RegisterDetailsScreen extends ConsumerStatefulWidget {
  final String email;
  const RegisterDetailsScreen({super.key, required this.email});

  @override
  ConsumerState<RegisterDetailsScreen> createState() =>
      _RegisterDetailsScreenState();
}

class _RegisterDetailsScreenState
    extends ConsumerState<RegisterDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  late final TextEditingController emailController;
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String gender = "";
  DateTime? dob;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    if (gender.isEmpty) {
      PremiumSnackbar.showError(context, "Please select gender");
      return;
    }

    if (dob == null) {
      PremiumSnackbar.showError(context, "Please select date of birth");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      PremiumSnackbar.showError(context, "Passwords do not match");
      return;
    }

    final success = await ref.read(authProvider.notifier).register({
      "name": nameController.text.trim(),
      "email": widget.email,
      "phone": phoneController.text.trim(),
      "mobile": phoneController.text.trim(),
      "gender": gender,
      "dob": dob!.toIso8601String(),
      "password": passwordController.text,
    });

    if (!mounted) return;

    if (success) {
      context.go('/home');
    } else {
      final error = ref.read(authProvider).errorMessage;
      PremiumSnackbar.showError(context, error ?? "Registration failed");
    }
  }

  Future<void> pickDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      initialDate: DateTime(2000),
    );

    if (!mounted) return;

    if (selected != null) {
      setState(() {
        dob = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Form(
            key: _formKey,

            child: Column(
              children: [
                AppTextField(
                  controller: nameController,
                  hintText: "Full Name",
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Required";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                AppTextField(
                  controller: emailController,
                  hintText: "Email",
                  label: "Email",
                  enabled: false,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),

                const SizedBox(height: 18),

                AppTextField(
                  controller: phoneController,
                  hintText: "Phone Number",
                  label: "Phone",
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Required";
                    }

                    if (value.length != 10) {
                      return "Invalid phone number";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                DropdownButtonFormField<String>(
                  initialValue: gender.isEmpty ? null : gender,
                  decoration: const InputDecoration(
                    labelText: "Gender",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "male",
                      child: Text("Male"),
                    ),
                    DropdownMenuItem(
                      value: "female",
                      child: Text("Female"),
                    ),
                    DropdownMenuItem(
                      value: "other",
                      child: Text("Other"),
                    ),
                    DropdownMenuItem(
                      value: "prefer_not_to_say",
                      child: Text("Prefer not to say"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      gender = value ?? "";
                    });
                  },
                ),

                const SizedBox(height: 18),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    dob == null
                        ? "Select Date of Birth"
                        : "${dob!.day}/${dob!.month}/${dob!.year}",
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: pickDate,
                ),

                const SizedBox(height: 18),

                PasswordField(
                  controller: passwordController,
                  hintText: "Password",
                ),

                const SizedBox(height: 18),

                PasswordField(
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
                ),

                const SizedBox(height: 32),

                PrimaryButton(
                  text: "Create Account",
                  loading: loading,
                  onPressed: register,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
