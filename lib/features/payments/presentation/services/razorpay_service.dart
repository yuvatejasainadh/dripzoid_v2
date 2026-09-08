import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../core/logging/app_logger.dart';

class RazorpayService {
  late Razorpay _razorpay;
  final String apiKey;
  final Function(PaymentSuccessResponse)? onSuccess;
  final Function(PaymentFailureResponse)? onError;
  final Function(ExternalWalletResponse)? onExternalWallet;

  RazorpayService({
    required this.apiKey,
    this.onSuccess,
    this.onError,
    this.onExternalWallet,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout({
    required String orderId,
    required double amount,
    required String name,
    required String description,
    required String email,
    required String contact,
  }) {
    var options = {
      'key': apiKey,
      'amount': (amount * 100).toInt(),
      'name': name,
      'order_id': orderId,
      'description': description,
      'prefill': {'contact': contact, 'email': email},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      AppLogger.i('[RazorpayService] [openCheckout] Opening Razorpay UI for: $orderId');
      _razorpay.open(options);
    } catch (e, stack) {
      AppLogger.f('[RazorpayService] [openCheckout] Critical failure', error: e, stackTrace: stack);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    AppLogger.i('[RazorpayService] [onSuccess] Payment successful: ${response.paymentId}');
    onSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    AppLogger.e('[RazorpayService] [onError] Payment failed: [${response.code}] ${response.message}');
    onError?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    onExternalWallet?.call(response);
  }

  void dispose() {
    _razorpay.clear();
  }
}
