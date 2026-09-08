import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/snackbars/premium_snackbar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../address/data/models/address_model.dart';
import '../../../address/presentation/providers/address_notifier.dart';
import '../../../address/presentation/widgets/address_form_sheet.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/presentation/widgets/cart_item_tile.dart';
import '../providers/checkout_notifier.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final List<CartItemModel> items;

  const CheckoutScreen({super.key, required this.items});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(checkoutProvider.notifier).initCheckout(widget.items);
      ref.read(addressProvider.notifier).loadAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutProvider);

    // Watch for success
    ref.listen(checkoutProvider, (previous, next) {
      if (next.lastOrder != null) {
        context.go('/order-success', extra: next.lastOrder!);
      }
      if (next.errorMessage != null) {
        PremiumSnackbar.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (state.step == CheckoutStep.review) {
              Navigator.pop(context);
            } else {
              ref.read(checkoutProvider.notifier).previousStep();
            }
          },
        ),
      ),
      body: Column(
        children: [
          _buildStepProgress(state.step),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: () {
                switch (state.step) {
                  case CheckoutStep.review:
                    return _buildReviewStep(state);
                  case CheckoutStep.shipping:
                    return _buildShippingStep(state);
                  case CheckoutStep.payment:
                    return _buildPaymentStep(state);
                }
              }(),
            ),
          ),
          _buildBottomBar(state),
        ],
      ),
    );
  }

  Widget _buildStepProgress(CheckoutStep currentStep) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      child: Row(
        children: [
          _buildStepCircle('1', currentStep.index >= 0),
          _buildStepDivider(currentStep.index >= 1),
          _buildStepCircle('2', currentStep.index >= 1),
          _buildStepDivider(currentStep.index >= 2),
          _buildStepCircle('3', currentStep.index >= 2),
        ],
      ),
    );
  }

  Widget _buildStepCircle(String label, bool active) {
    final theme = Theme.of(context);
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: active ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: active ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStepDivider(bool active) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        height: 2,
        color: active ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
      ),
    );
  }

  Widget _buildReviewStep(CheckoutState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Review Order Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...state.items.map((it) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CartItemTile(
                item: it,
                onQuantityChanged: (_) {}, // Disabled in checkout review
                onRemove: () {}, // Disabled in checkout review
              ),
            )),
      ],
    );
  }

  Widget _buildShippingStep(CheckoutState state) {
    final theme = Theme.of(context);
    final addressState = ref.watch(addressProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Shipping Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: () => _showAddressForm(),
              icon: const Icon(Icons.add),
              label: const Text('Add New'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (addressState.isLoading)
          const Center(child: CircularProgressIndicator())
        else if ((addressState.value ?? []).isEmpty)
          const Center(child: Text('No saved addresses. Please add one.'))
        else
          ...(addressState.value ?? []).map((addr) {
            final isSelected = state.selectedAddress?.id == addr.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => ref.read(checkoutProvider.notifier).selectAddress(addr),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                      width: isSelected ? 2 : 1,
                    ),
                    color: isSelected ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : theme.colorScheme.surface,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(addr.label ?? 'Address', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(addr.fullAddress, style: theme.textTheme.bodySmall),
                            Text(addr.phone ?? '', style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildPaymentStep(CheckoutState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildPaymentOption(
          'Online Payment',
          'Pay securely with Razorpay (Cards, UPI, Netbanking)',
          Icons.payment,
          PaymentType.razorpay,
          state.paymentType,
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          'Cash on Delivery',
          'Pay with cash at your doorstep. ₹25 fee applies.',
          Icons.money,
          PaymentType.cod,
          state.paymentType,
        ),
      ],
    );
  }

  Widget _buildPaymentOption(String title, String sub, IconData icon, PaymentType type, PaymentType selected) {
    final theme = Theme.of(context);
    final isSelected = type == selected;
    return InkWell(
      onTap: () => ref.read(checkoutProvider.notifier).selectPaymentType(type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(sub, style: theme.textTheme.labelSmall),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(CheckoutState state) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Amount', style: theme.textTheme.labelSmall),
              Text('₹${state.grandTotal.round()}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: PrimaryButton(
              text: state.step == CheckoutStep.payment
                  ? (state.paymentType == PaymentType.razorpay ? 'Pay Now' : 'Place Order')
                  : 'Continue',
              loading: state.isLoading,
              onPressed: () {
                if (state.step == CheckoutStep.payment) {
                  ref.read(checkoutProvider.notifier).placeOrder();
                } else {
                  ref.read(checkoutProvider.notifier).nextStep();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => const AddressFormSheet(),
    );
  }
}
