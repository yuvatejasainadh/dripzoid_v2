import 'package:flutter/material.dart';

class OrderTimeline extends StatelessWidget {
  final String status;
  final List<dynamic> history;

  const OrderTimeline({
    super.key,
    required this.status,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> allSteps = [
      'Order Confirmed',
      'Packed',
      'Shipped',
      'Out For Delivery',
      'Delivered'
    ];

    final Map<String, int> progressMap = {
      'pending': 0,
      'confirmed': 0,
      'processing': 1,
      'packed': 1,
      'shipped': 2,
      'out for delivery': 3,
      'delivered': 4,
      'cancelled': -1,
    };

    final int currentStep = progressMap[status.toLowerCase()] ?? 0;

    if (currentStep == -1) {
      return const ListTile(
        leading: Icon(Icons.cancel, color: Colors.red),
        title: Text('Order Cancelled', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      );
    }

    return Column(
      children: List.generate(allSteps.length, (index) {
        final theme = Theme.of(context);
        final bool isDone = index <= currentStep;
        final bool isLast = index == allSteps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isDone ? theme.colorScheme.primary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDone ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                      width: 2,
                    ),
                  ),
                  child: isDone
                      ? Icon(Icons.check, size: 12, color: theme.colorScheme.onPrimary)
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isDone ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    allSteps[index],
                    style: TextStyle(
                      fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                      color: isDone ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
