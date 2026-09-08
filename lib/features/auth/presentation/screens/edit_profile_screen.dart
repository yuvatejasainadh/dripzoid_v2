import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../core/ui/snackbars/premium_snackbar.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_notifier.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String? _selectedGender;
  DateTime? _selectedDob;

  bool _isGenderLocked = false;
  bool _isDobLocked = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name);
    _emailController = TextEditingController(text: user?.email);
    _phoneController = TextEditingController(text: user?.phone);
    _selectedGender = user?.gender;
    _selectedDob = user?.dob;

    _isGenderLocked = _selectedGender != null && _selectedGender!.isNotEmpty;
    _isDobLocked = _selectedDob != null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    if (_isDobLocked) return;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authProvider).user;
    if (user == null) return;

    final Map<String, dynamic> data = {};

    // Always editable fields
    if (_nameController.text.trim() != (user.name ?? '')) {
      data['name'] = _nameController.text.trim();
    }
    
    if (_phoneController.text.trim() != (user.phone ?? '')) {
      data['phone'] = _phoneController.text.trim();
      data['mobile'] = _phoneController.text.trim(); // Supporting both naming conventions
    }

    // Lockable fields - only send if they were null and are now set
    if (!_isGenderLocked && _selectedGender != null) {
      data['gender'] = _selectedGender;
    }

    if (!_isDobLocked && _selectedDob != null) {
      data['dob'] = _selectedDob!.toIso8601String();
    }

    if (data.isEmpty) {
      context.pop();
      return;
    }

    await ref.read(profileProvider.notifier).updateProfile(data);
    
    if (mounted && !ref.read(profileProvider).hasError) {
      PremiumSnackbar.showSuccess(context, 'Profile updated successfully');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _nameController,
                hintText: 'Full Name',
                label: 'Name',
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Name is required';
                  if (val.trim().length < 2) return 'Name is too short';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _emailController,
                hintText: 'Email Address',
                label: 'Email',
                enabled: false,
                readOnly: true,
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _phoneController,
                hintText: 'Phone Number',
                label: 'Phone',
                keyboardType: TextInputType.phone,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Phone is required';
                  if (val.trim().length != 10) return 'Enter a valid 10-digit number';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Gender',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _isGenderLocked 
                      ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) 
                      : theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: ['male', 'female', 'other']
                    .map((g) => DropdownMenuItem(
                          value: g, 
                          child: Text(g[0].toUpperCase() + g.substring(1)),
                        ))
                    .toList(),
                onChanged: _isGenderLocked ? null : (val) => setState(() => _selectedGender = val),
              ),
              const SizedBox(height: 20),
              Text(
                'Date of Birth',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _isDobLocked 
                        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) 
                        : theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDob != null
                        ? DateFormat('dd MMM yyyy').format(_selectedDob!)
                        : 'Select Date',
                    style: TextStyle(
                      color: _isDobLocked ? theme.colorScheme.onSurface.withValues(alpha: 0.6) : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                onPressed: _saveProfile,
                loading: profileState.isLoading,
                text: 'Save Changes',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
