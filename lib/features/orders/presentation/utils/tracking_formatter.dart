import 'package:intl/intl.dart';

class TrackingInfo {
  final String title;
  final String description;

  TrackingInfo({required this.title, required this.description});
}

class TrackingFormatter {
  TrackingFormatter._();

  static TrackingInfo formatStatus(String status) {
    final normalized = status.toLowerCase();

    if (normalized.contains('awb') || normalized.contains('assigned')) {
      return TrackingInfo(
        title: 'AWB Assigned',
        description: 'Shipment tracking number generated',
      );
    } else if (normalized.contains('pickup scheduled')) {
      return TrackingInfo(
        title: 'Pickup Scheduled',
        description: 'Your package is ready for courier pickup',
      );
    } else if (normalized.contains('transit') || normalized.contains('shipped')) {
      return TrackingInfo(
        title: 'In Transit',
        description: 'Package is moving through the delivery network',
      );
    } else if (normalized.contains('out for delivery')) {
      return TrackingInfo(
        title: 'Out for Delivery',
        description: 'Your package is arriving today',
      );
    } else if (normalized.contains('delivered')) {
      return TrackingInfo(
        title: 'Delivered',
        description: 'Your package has been delivered successfully',
      );
    } else if (normalized.contains('cancelled')) {
      return TrackingInfo(
        title: 'Order Cancelled',
        description: 'This order was cancelled',
      );
    } else if (normalized.contains('rto')) {
      return TrackingInfo(
        title: 'Returned to Origin',
        description: 'Package is being sent back to our warehouse',
      );
    }

    return TrackingInfo(
      title: status,
      description: 'Activity recorded in system',
    );
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('dd MMM • h:mm a').format(dateTime.toLocal());
  }

  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('dd MMM yyyy').format(dateTime.toLocal());
  }
}
