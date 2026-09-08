import 'package:flutter/material.dart';
import '../../data/models/shipment_model.dart';
import '../utils/tracking_formatter.dart';

class TrackingTimelineWidget extends StatelessWidget {
  final List<TrackingActivityModel> activities;

  const TrackingTimelineWidget({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (activities.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(Icons.history_rounded, size: 32, color: colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              'No tracking updates yet',
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
            ),
          ],
        ),
      );
    }

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
            'Tracking History',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              final isFirst = index == 0;
              final isLast = index == activities.length - 1;
              final info = TrackingFormatter.formatStatus(activity.status);

              return _TrackingStep(
                info: info,
                location: activity.location,
                timestamp: activity.timestamp,
                isFirst: isFirst,
                isLast: isLast,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TrackingStep extends StatelessWidget {
  final TrackingInfo info;
  final String? location;
  final DateTime? timestamp;
  final bool isFirst;
  final bool isLast;

  const _TrackingStep({
    required this.info,
    this.location,
    this.timestamp,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = isFirst ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.5);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 16.0,
                height: 16.0,
                decoration: BoxDecoration(
                  color: isFirst ? colorScheme.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryColor,
                    width: 3.0,
                  ),
                  boxShadow: isFirst ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8.0,
                      spreadRadius: 2.0,
                    )
                  ] : null,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.0,
                    color: colorScheme.outline.withValues(alpha: 0.15),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isFirst ? FontWeight.bold : FontWeight.w600,
                    color: isFirst ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info.description,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    height: 1.3,
                  ),
                ),
                if (location != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        location!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  TrackingFormatter.formatDateTime(timestamp),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.outline,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
