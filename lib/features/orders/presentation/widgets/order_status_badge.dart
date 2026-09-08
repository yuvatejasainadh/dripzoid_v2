import 'package:flutter/material.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;
  final String? shipmentStatus;

  const OrderStatusBadge({
    super.key,
    required this.status,
    this.shipmentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Prioritize shipment status for display if available
    final displayStatus = shipmentStatus ?? status;
    final normalized = displayStatus.toLowerCase();

    Color color;
    IconData icon;

    if (normalized.contains('delivered')) {
      color = Colors.green;
      icon = Icons.check_circle_outline_rounded;
    } else if (normalized.contains('cancelled') || normalized.contains('rto')) {
      color = theme.colorScheme.error;
      icon = Icons.cancel_outlined;
    } else if (normalized.contains('transit') || normalized.contains('shipped') || normalized.contains('delivery')) {
      color = Colors.blue;
      icon = Icons.local_shipping_outlined;
    } else if (normalized.contains('processing') || normalized.contains('confirmed')) {
      color = Colors.orange;
      icon = Icons.pending_actions_rounded;
    } else {
      color = theme.colorScheme.outline;
      icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.0, color: color),
          const SizedBox(width: 6.0),
          Text(
            displayStatus.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
