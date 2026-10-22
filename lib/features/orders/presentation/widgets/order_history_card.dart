import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/order_model.dart';
import 'order_status_badge.dart';

class OrderHistoryCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;
  final VoidCallback? onTrackTap;

  const OrderHistoryCard({
    super.key,
    required this.order,
    required this.onTap,
    this.onTrackTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Shorten order number
    final displayOrderNumber = order.orderNumber.length > 15 
        ? order.orderNumber.substring(0, 15) 
        : order.orderNumber;

    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final additionalItems = order.items.length - 1;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Order # and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#$displayOrderNumber',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.createdAt != null 
                            ? DateFormat('dd MMM yyyy').format(order.createdAt!)
                            : 'Date unavailable',
                        style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                OrderStatusBadge(
                  status: order.status,
                  shipmentStatus: order.shipment?.currentStatus,
                ),
              ],
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),

            // Product Preview Section
            if (firstItem != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: firstItem.productImage != null
                        ? CachedNetworkImage(
                            imageUrl: firstItem.productImage!,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: Icon(Icons.image_outlined, color: colorScheme.onSurfaceVariant),
                            ),
                          )
                        : Container(
                            width: 70,
                            height: 70,
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(Icons.image_outlined, color: colorScheme.onSurfaceVariant),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstItem.productName ?? 'Product',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${firstItem.selectedColor ?? "N/A"} • ${firstItem.selectedSize ?? "N/A"}',
                          style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Qty: ${firstItem.quantity}',
                          style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (additionalItems > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '+$additionalItems more items',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),

            // Bottom Section: Price and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount',
                        style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '₹${order.totalAmount.round()}',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onTrackTap != null && 
                        (order.status.toLowerCase() == 'shipped' || 
                         order.status.toLowerCase() == 'in transit'))
                      TextButton(
                        onPressed: onTrackTap,
                        child: const Text('Track Order'),
                      ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant, size: 20),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
