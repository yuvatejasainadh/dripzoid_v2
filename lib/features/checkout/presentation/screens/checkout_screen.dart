import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/tokens/app_colors.dart';
import '../../../../core/ui/snackbars/premium_snackbar.dart';
import '../../../../core/utils/layout_utils.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
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

    // Watch for address changes and auto-select default address if none selected
    ref.listen(addressProvider, (previous, next) {
      final addresses = next.value;
      if (addresses != null && addresses.isNotEmpty) {
        final currentSelected = ref.read(checkoutProvider).selectedAddress;
        if (currentSelected == null) {
          final defaultAddr = addresses.firstWhere(
            (a) => a.isDefault,
            orElse: () => addresses.first,
          );
          ref.read(checkoutProvider.notifier).selectAddress(defaultAddr);
        }
      }
    });

    // Watch for success
    ref.listen(checkoutProvider, (previous, next) {
      if (next.lastOrder != null) {
        final order = next.lastOrder!;
        ref.read(checkoutProvider.notifier).reset();
        context.go('/order-success', extra: order);
      }
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        PremiumSnackbar.showError(context, next.errorMessage!);
      }
    });

    return PopScope(
      canPop: state.step == CheckoutStep.review,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (state.step != CheckoutStep.review) {
          ref.read(checkoutProvider.notifier).previousStep();
        }
      },
      child: Scaffold(
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
        body: ResponsiveContainer(
          child: Column(
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
        ),
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
          style: theme.textTheme.bodyMedium?.copyWith(
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Order Items',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...state.items.map((it) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CartItemTile(
                item: it,
                onQuantityChanged: (_) {}, // Disabled in checkout review
                onRemove: () {}, // Disabled in checkout review
              ),
            )),
        const SizedBox(height: 16),
        _buildOrderSummaryCard(state),
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
            Text(
              'Shipping Address',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => _showAddressForm(),
              icon: const Icon(Icons.add),
              label: const Text('Add New'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (addressState.isLoading)
          const Column(
            children: [
              AddressCardSkeleton(),
              SizedBox(height: 12),
              AddressCardSkeleton(),
            ],
          )
        else if (addressState.hasError)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 40, color: theme.colorScheme.error),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load addresses',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref.read(addressProvider.notifier).loadAddresses(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else if ((addressState.value ?? []).isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.location_off_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No saved addresses yet',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add an address to proceed with checkout',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _showAddressForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Address'),
                  ),
                ],
              ),
            ),
          )
        else
          ...(addressState.value ?? []).map((addr) {
            final isSelected = state.selectedAddress?.id == addr.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => ref.read(checkoutProvider.notifier).selectAddress(addr),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                      width: isSelected ? 2 : 1,
                    ),
                    color: isSelected
                        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                        : theme.colorScheme.surface,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              addr.label ?? 'Address',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              addr.fullAddress,
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                            if (addr.phone != null && addr.phone!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                addr.phone!,
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildPaymentOption(
          type: PaymentType.razorpay,
          title: 'Online Payment (Razorpay)',
          sub: 'UPI, Credit/Debit Cards, NetBanking, Wallets',
          icon: Icons.payment,
          isSelected: state.paymentType == PaymentType.razorpay,
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          type: PaymentType.cod,
          title: 'Cash on Delivery (COD)',
          sub: 'Pay when your order arrives',
          icon: Icons.local_shipping_outlined,
          isSelected: state.paymentType == PaymentType.cod,
        ),
        if (state.selectedAddress != null) ...[
          const SizedBox(height: 24),
          Text(
            'Delivering to',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${state.selectedAddress!.label ?? "Address"}: ${state.selectedAddress!.fullAddress}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        _buildOrderSummaryCard(state),
      ],
    );
  }

  Widget _buildPaymentOption({
    required PaymentType type,
    required String title,
    required String sub,
    required IconData icon,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => ref.read(checkoutProvider.notifier).selectPaymentType(type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
              : theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(CheckoutState state) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Items Total', '₹${state.itemsTotal.round()}', theme),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Delivery',
            'FREE',
            theme,
            valueColor: AppColors.success,
          ),
          if (state.codCharge > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow('COD Handling Fee', '₹${state.codCharge.round()}', theme),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: theme.colorScheme.outlineVariant, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${state.grandTotal.round()}',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, ThemeData theme, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(CheckoutState state) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Amount',
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '₹${state.grandTotal.round()}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: PrimaryButton(
              text: state.step == CheckoutStep.payment
                  ? (state.paymentType == PaymentType.razorpay ? 'Pay Now' : 'Place Order')
                  : 'Continue',
              loading: state.isLoading,
              onPressed: state.isLoading
                  ? null
                  : () {
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

  void _showAddressForm() async {
    final created = await showModalBottomSheet<AddressModel?>(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: LayoutUtils.maxFormWidth),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => const AddressFormSheet(),
    );
    if (created != null) {
      ref.read(checkoutProvider.notifier).selectAddress(created);
    }
  }
}
