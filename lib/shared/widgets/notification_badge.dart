import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;

  const NotificationBadge({
    super.key,
    required this.count,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;

    final theme = Theme.of(context);

    return Badge(
      backgroundColor: theme.colorScheme.primary,
      label: Text(
        '$count',
        style: TextStyle(
          color: theme.colorScheme.onPrimary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: child,
    );
  }
}
