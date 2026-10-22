import 'package:flutter/material.dart';
import '../utils/tracking_formatter.dart';

class OrderStatusHero extends StatelessWidget {
  final String status;
  final String? shipmentStatus;
  final DateTime? deliveryDate;

  const OrderStatusHero({
    super.key,
    required this.status,
    this.shipmentStatus,
    this.deliveryDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final displayStatus = shipmentStatus ?? status;
    final normalized = displayStatus.toLowerCase();
    
    Color color;
    IconData icon;
    String subMessage = 'Your order is currently $displayStatus';

    if (normalized.contains('delivered')) {
      color = Colors.green;
      icon = Icons.check_circle_rounded;
      subMessage = 'Delivered successfully';
    } else if (normalized.contains('cancelled') || normalized.contains('rto')) {
      color = colorScheme.error;
      icon = Icons.cancel_rounded;
      subMessage = 'Order process stopped';
    } else if (normalized.contains('transit') || normalized.contains('shipped') || normalized.contains('delivery')) {
      color = Colors.blue;
      icon = Icons.local_shipping_rounded;
      subMessage = 'On the way to you';
    } else {
      color = colorScheme.primary;
      icon = Icons.pending_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 16),
          Text(
            displayStatus.toUpperCase(),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color == colorScheme.primary ? colorScheme.onSurfaceVariant : color.withValues(alpha: 0.85),
            ),
          ),
          if (deliveryDate != null && !normalized.contains('delivered') && !normalized.contains('cancelled')) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Text(
                'Expected by ${TrackingFormatter.formatDate(deliveryDate)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
