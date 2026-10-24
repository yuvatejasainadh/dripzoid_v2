import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/layout_utils.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../../core/ui/dialogs/premium_alert.dart';
import '../providers/order_details_notifier.dart';
import '../widgets/order_status_hero.dart';
import '../widgets/order_info_card.dart';
import '../widgets/order_item_tile.dart';
import '../widgets/tracking_timeline_widget.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderDetailsProvider(orderId));

    return Scaffold(
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 900,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: state.isLoading && state.order == null
                    ? _buildLoadingState()
                    : state.errorMessage != null && state.order == null
                        ? _buildErrorState(ref, state.errorMessage!)
                        : _buildContent(context, ref, state),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Order Details',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, OrderDetailsState state) {
    final order = state.order!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Status Hero
              OrderStatusHero(
                status: order.status,
                shipmentStatus: order.shipment?.currentStatus,
                deliveryDate: order.deliveryDate,
              ),
              const SizedBox(height: 24),

              // Info Card
              OrderInfoCard(
                orderNumber: order.orderNumber,
                createdAt: order.createdAt,
                paymentMethod: order.paymentMethod,
              ),
              const SizedBox(height: 24),

              // Items Section
              _buildSectionTitle('Items (${order.items.length})'),
              const SizedBox(height: 16),
              ...order.items.map((item) => OrderItemTile(item: item)),
              const SizedBox(height: 24),

              // Shipping Address
              _buildSectionTitle('Delivery Address'),
              const SizedBox(height: 16),
              _buildAddressCard(context, order),
              const SizedBox(height: 24),

              // Tracking Timeline
              _buildSectionTitle('Tracking'),
              const SizedBox(height: 16),
              TrackingTimelineWidget(
                activities: state.shipment?.activities ?? [],
              ),
              const SizedBox(height: 24),

              // Payment Summary
              _buildSectionTitle('Payment Summary'),
              const SizedBox(height: 16),
              _buildPaymentSummary(context, order),
              const SizedBox(height: 40),

              // Actions
              if (order.status.toLowerCase() != 'cancelled' && order.status.toLowerCase() != 'delivered')
                PrimaryButton(
                  text: 'Cancel Order',
                  onPressed: () => _confirmCancel(context, ref),
                  loading: state.isCancelling,
                ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final url = await ref.read(orderDetailsProvider(orderId).notifier).getInvoiceUrl();
                  if (url != null) {
                    launchUrl(Uri.parse(url));
                  }
                },
                icon: const Icon(Icons.download),
                label: const Text('Download Invoice'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.outlineVariant),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 60),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Builder(builder: (context) {
      return Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
      );
    });
  }

  Widget _buildAddressCard(BuildContext context, dynamic order) {
    final colorScheme = Theme.of(context).colorScheme;
    final address = order.address;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 18, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  address?.name ?? 'Customer Name',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Text(
            address?.line1 ?? 'Address line 1',
            style: const TextStyle(height: 1.4),
          ),
          if (address?.line2 != null && address!.line2!.isNotEmpty)
            Text(
              address.line2!,
              style: const TextStyle(height: 1.4),
            ),
          Text(
            '${address?.city}, ${address?.state} - ${address?.pincode}',
            style: const TextStyle(height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.phone_rounded, size: 14, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                address?.phone ?? 'N/A',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(BuildContext context, dynamic order) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          _buildPriceRow(context, 'Items Total', order.pricing?.total ?? order.totalAmount),
          _buildPriceRow(context, 'Discount', -(order.pricing?.couponDiscount ?? 0.0), isDiscount: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          _buildPriceRow(context, 'Grand Total', order.totalAmount, isBold: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context, String label, double value,
      {bool isDiscount = false, bool isBold = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (value == 0 && isDiscount) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            '₹${value.round()}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
              fontSize: isBold ? 18.0 : null,
              color: isDiscount ? Colors.green : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const OrderDetailsSkeleton();
  }

  Widget _buildErrorState(WidgetRef ref, String message) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              'Unable to load order',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(orderDetailsProvider(orderId).notifier).loadOrderDetails(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await PremiumAlert.confirm(
      context,
      title: 'Cancel Order?',
      message: 'Are you sure you want to cancel this order? This action cannot be undone.',
      confirmText: 'Yes, Cancel',
      isDestructive: true,
    );

    if (confirmed) {
      await ref.read(orderDetailsProvider(orderId).notifier).cancelOrder();
    }
  }
}
