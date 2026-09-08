import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/ui/snackbars/premium_snackbar.dart';
import '../utils/tracking_formatter.dart';

class OrderInfoCard extends StatelessWidget {
  final String orderNumber;
  final DateTime? createdAt;
  final String? paymentMethod;

  const OrderInfoCard({
    super.key,
    required this.orderNumber,
    this.createdAt,
    this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Shorten order number for display
    final displayId = orderNumber.length > 15 ? orderNumber.substring(0, 15) : orderNumber;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Details',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildRow(
            context,
            'Order ID',
            '#$displayId',
            trailing: IconButton(
              icon: Icon(Icons.copy_rounded, size: 18, color: colorScheme.primary),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: orderNumber));
                PremiumSnackbar.showInfo(context, 'Order ID copied to clipboard');
              },
            ),
          ),
          _buildRow(context, 'Placed On', TrackingFormatter.formatDate(createdAt)),
          _buildRow(context, 'Payment', paymentMethod ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value, {Widget? trailing}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing ?? const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
