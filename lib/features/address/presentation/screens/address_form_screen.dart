import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/layout_utils.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../data/models/address_model.dart';
import '../providers/address_notifier.dart';

class AddressFormScreen extends ConsumerStatefulWidget {
  final AddressModel? address;
  const AddressFormScreen({super.key, this.address});

  @override
  ConsumerState<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends ConsumerState<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _line1Controller;
  late TextEditingController _line2Controller;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.address?.label ?? 'Home');
    _nameController = TextEditingController(text: widget.address?.name);
    _phoneController = TextEditingController(text: widget.address?.phone);
    _line1Controller = TextEditingController(text: widget.address?.line1);
    _line2Controller = TextEditingController(text: widget.address?.line2);
    _cityController = TextEditingController(text: widget.address?.city);
    _stateController = TextEditingController(text: widget.address?.state);
    _pincodeController = TextEditingController(text: widget.address?.pincode);
    _isDefault = widget.address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final addressData = AddressModel(
      id: widget.address?.id,
      label: _labelController.text.trim(),
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      line1: _line1Controller.text.trim(),
      line2: _line2Controller.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
      isDefault: _isDefault,
    );

    if (widget.address == null) {
      await ref.read(addressProvider.notifier).addAddress(addressData);
    } else {
      await ref.read(addressProvider.notifier).updateAddress(addressData);
    }

    if (mounted && !ref.read(addressProvider).hasError) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final addressState = ref.watch(addressProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address == null ? 'Add Address' : 'Edit Address'),
      ),
      body: ResponsiveContainer(
        maxWidth: 600,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _labelController,
                  hintText: 'Address Label (e.g., Home, Work)',
                  validator: (v) => v!.isEmpty ? 'Label required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _nameController,
                  hintText: 'Recipient Name',
                  validator: (v) => v!.isEmpty ? 'Name required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _phoneController,
                  hintText: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Phone required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _line1Controller,
                  hintText: 'Address Line 1',
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _line2Controller,
                  hintText: 'Address Line 2 (Optional)',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _cityController,
                        hintText: 'City',
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppTextField(
                        controller: _stateController,
                        hintText: 'State',
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _pincodeController,
                  hintText: 'Pincode',
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text('Set as Default Address', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                  value: _isDefault,
                  onChanged: (val) => setState(() => _isDefault = val),
                  activeTrackColor: theme.colorScheme.primary,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  onPressed: _submit,
                  loading: addressState.isLoading,
                  text: widget.address == null ? 'Save Address' : 'Update Address',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
