import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/snackbars/premium_snackbar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/password_field.dart';
import '../providers/profile_notifier.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newController.text != _confirmController.text) {
      PremiumSnackbar.showError(context, 'Passwords do not match');
      return;
    }

    await ref.read(profileProvider.notifier).changePassword(
          _currentController.text,
          _newController.text,
          _confirmController.text,
        );

    if (mounted && !ref.read(profileProvider).hasError) {
      PremiumSnackbar.showSuccess(context, 'Password changed successfully');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change Password',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Ensure your account is using a long, random password to stay secure.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              PasswordField(
                controller: _currentController,
                hintText: 'Current Password',
                label: 'Current Password',
                validator: (val) => val == null || val.isEmpty ? 'Current password is required' : null,
              ),
              const SizedBox(height: 20),
              PasswordField(
                controller: _newController,
                hintText: 'New Password',
                label: 'New Password',
                validator: (val) {
                  if (val == null || val.isEmpty) return 'New password is required';
                  if (val.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              PasswordField(
                controller: _confirmController,
                hintText: 'Confirm New Password',
                label: 'Confirm New Password',
                validator: (val) => val == null || val.isEmpty ? 'Please confirm your password' : null,
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                onPressed: _changePassword,
                loading: profileState.isLoading,
                text: 'Update Password',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
