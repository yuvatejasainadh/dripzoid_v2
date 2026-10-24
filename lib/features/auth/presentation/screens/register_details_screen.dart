import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/dialogs/app_error_dialog.dart';
import '../../../../core/utils/layout_utils.dart';
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
    if (loading) return; // Prevent duplicate submissions
    if (!_formKey.currentState!.validate()) return;

    if (gender.isEmpty) {
      AppErrorDialog.showForError(context, error: "Please select gender");
      return;
    }

    if (dob == null) {
      AppErrorDialog.showForError(context, error: "Please select date of birth");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      AppErrorDialog.showForError(context, error: "Passwords do not match");
      return;
    }

    setState(() => loading = true);

    try {
      final success = await ref.read(authProvider.notifier).register({
        "name": nameController.text.trim(),
        "email": widget.email,
        "phone": phoneController.text.trim(),
        "password": passwordController.text,
        "gender": gender,
        "dateOfBirth": dob?.toIso8601String(),
      });

      if (!mounted) return;

      if (success) {
        context.go('/home');
      } else {
        final error = ref.read(authProvider).errorMessage;
        AppErrorDialog.showForError(
          context,
          error: error ?? "Registration failed. Please check your connection and try again.",
          onRetry: () => register(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Complete Profile")),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ResponsiveContainer(
              maxWidth: LayoutUtils.maxFormWidth,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      controller: nameController,
                      hintText: "Full Name",
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? "Name is required"
                              : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: emailController,
                      hintText: "Email",
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: phoneController,
                      hintText: "Phone Number",
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? "Phone is required"
                              : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Gender",
                        border: OutlineInputBorder(),
                      ),
                      initialValue: gender.isEmpty ? null : gender,
                      items: const [
                        DropdownMenuItem(value: "male", child: Text("Male")),
                        DropdownMenuItem(value: "female", child: Text("Female")),
                        DropdownMenuItem(value: "other", child: Text("Other")),
                      ],
                      onChanged: (val) {
                        setState(() {
                          gender = val ?? "";
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Text(
                        dob == null
                            ? "Select Date of Birth"
                            : "${dob!.day}/${dob!.month}/${dob!.year}",
                      ),
                      trailing: const Icon(Icons.calendar_today_outlined),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2000),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            dob = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    PasswordField(
                      controller: passwordController,
                      hintText: "Password",
                      validator: (val) {
                        if (val == null || val.length < 6) {
                          return "Min 6 characters";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    PasswordField(
                      controller: confirmPasswordController,
                      hintText: "Confirm Password",
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Confirm your password";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(
                      text: "Register",
                      loading: loading,
                      onPressed: register,
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
