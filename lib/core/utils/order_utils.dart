import 'dart:math';

class OrderUtils {
  OrderUtils._();

  /// Generates a unique temporary order number for the initial payment state.
  /// Format: TMP-[milliseconds]-[random_string]
  static String generateTemporaryOrderNumber() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final randomString = String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
    
    return 'TMP-$now-$randomString';
  }
}
