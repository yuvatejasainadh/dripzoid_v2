import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/models/address_model.dart';
import '../providers/address_notifier.dart';

class AddressFormSheet extends ConsumerStatefulWidget {
  const AddressFormSheet({super.key});

  @override
  ConsumerState<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends ConsumerState<AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  
  final _labelController = TextEditingController();
  final _nameController = TextEditingController();
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _labelController.dispose();
    _nameController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final address = AddressModel(
      label: _labelController.text.trim(),
      name: _nameController.text.trim(),
      line1: _line1Controller.text.trim(),
      line2: _line2Controller.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    final created = await ref.read(addressProvider.notifier).addAddress(address);
    if (created != null && mounted) {
      Navigator.pop(context, created);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add New Address',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _labelController,
                hintText: 'Address Label (e.g. Home, Office)',
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _nameController,
                hintText: 'Full Name',
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _line1Controller,
                hintText: 'Address Line 1',
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _line2Controller,
                hintText: 'Address Line 2 (Optional)',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _cityController,
                      hintText: 'City',
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _stateController,
                      hintText: 'State',
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _pincodeController,
                      hintText: 'Pincode',
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      validator: (v) => v?.length != 6 ? 'Invalid' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _phoneController,
                      hintText: 'Phone Number',
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      validator: (v) => v?.length != 10 ? 'Invalid' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Save Address',
                onPressed: _submit,
                loading: ref.watch(addressProvider).isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
