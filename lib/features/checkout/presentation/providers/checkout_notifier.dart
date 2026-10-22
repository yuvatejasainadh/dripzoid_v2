import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/config/config_provider.dart';
import '../../../../core/config/environment.dart';
import '../../../../core/models/result.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/providers/cart_notifier.dart';
import '../../../address/data/models/address_model.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/data/repositories/order_repository.dart';
import '../../../orders/data/services/order_service.dart';
import '../../../payments/data/repositories/payment_repository.dart';
import '../../../payments/data/services/payment_service.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  final client = ref.watch(apiClientProvider);
  return OrderService(client);
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final service = ref.watch(orderServiceProvider);
  return OrderRepository(service);
});

final paymentServiceProvider = Provider<PaymentService>((ref) {
  final client = ref.watch(apiClientProvider);
  return PaymentService(client);
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final service = ref.watch(paymentServiceProvider);
  return PaymentRepository(service);
});

enum CheckoutStep { review, shipping, payment }

enum PaymentType { cod, razorpay }

class CheckoutState {
  final CheckoutStep step;
  final List<CartItemModel> items;
  final AddressModel? selectedAddress;
  final PaymentType paymentType;
  final bool isLoading;
  final String? errorMessage;
  final OrderModel? lastOrder;

  const CheckoutState({
    this.step = CheckoutStep.review,
    this.items = const [],
    this.selectedAddress,
    this.paymentType = PaymentType.razorpay,
    this.isLoading = false,
    this.errorMessage,
    this.lastOrder,
  });

  CheckoutState copyWith({
    CheckoutStep? step,
    List<CartItemModel>? items,
    AddressModel? selectedAddress,
    PaymentType? paymentType,
    bool? isLoading,
    String? errorMessage,
    OrderModel? lastOrder,
  }) {
    return CheckoutState(
      step: step ?? this.step,
      items: items ?? this.items,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      paymentType: paymentType ?? this.paymentType,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      lastOrder: lastOrder ?? this.lastOrder,
    );
  }

  double get itemsTotal => items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get codCharge => paymentType == PaymentType.cod ? 25 : 0;
  double get grandTotal => itemsTotal + codCharge;
}

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(ref);
});

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final Ref _ref;
  late Razorpay _razorpay;
  String? _internalOrderId;
  bool _isSubmitting = false;

  CheckoutNotifier(this._ref) : super(const CheckoutState()) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void initCheckout(List<CartItemModel> items) {
    _internalOrderId = null;
    state = CheckoutState(items: items);
  }

  void reset() {
    _internalOrderId = null;
    state = const CheckoutState();
  }

  void nextStep() {
    if (state.items.isEmpty) {
      state = state.copyWith(errorMessage: "Your cart is empty. Please add items to checkout.");
      return;
    }
    if (state.items.any((item) => item.quantity <= 0)) {
      state = state.copyWith(errorMessage: "Invalid item quantity in checkout.");
      return;
    }

    if (state.step == CheckoutStep.review) {
      state = state.copyWith(step: CheckoutStep.shipping, errorMessage: null);
    } else if (state.step == CheckoutStep.shipping) {
      if (state.selectedAddress == null) {
        state = state.copyWith(errorMessage: "Please select a shipping address");
        return;
      }
      final addr = state.selectedAddress!;
      if ((addr.line1?.trim().isEmpty ?? true) ||
          (addr.city?.trim().isEmpty ?? true) ||
          (addr.pincode?.trim().isEmpty ?? true) ||
          (addr.phone?.trim().isEmpty ?? true)) {
        state = state.copyWith(errorMessage: "Shipping address is incomplete. Please check required fields.");
        return;
      }
      state = state.copyWith(step: CheckoutStep.payment, errorMessage: null);
    }
  }

  void previousStep() {
    if (state.step == CheckoutStep.payment) {
      state = state.copyWith(step: CheckoutStep.shipping);
    } else if (state.step == CheckoutStep.shipping) {
      state = state.copyWith(step: CheckoutStep.review);
    }
  }

  void selectAddress(AddressModel address) {
    state = state.copyWith(selectedAddress: address, errorMessage: null);
  }

  void selectPaymentType(PaymentType type) {
    state = state.copyWith(paymentType: type, errorMessage: null);
  }

  Future<bool> _tryReconcileRecentOrder(DateTime checkoutStartTime) async {
    try {
      AppLogger.i('[CheckoutNotifier] Order submission timed out. Checking recent orders for reconciliation...');
      final recentOrdersRes = await _ref.read(orderRepositoryProvider).getUserOrders();
      if (recentOrdersRes is Success<List<OrderModel>>) {
        final orders = recentOrdersRes.data;
        if (orders.isNotEmpty) {
          final latestOrder = orders.first;

          // 1. Time window: Order must be created after checkout was initiated (with 15s clock skew margin)
          final orderTime = latestOrder.createdAt;
          final isRecent = orderTime == null ||
              orderTime.isAfter(checkoutStartTime.subtract(const Duration(seconds: 15)));

          // 2. Exact grand total match
          final isAmountMatch = (latestOrder.totalAmount - state.grandTotal).abs() < 1.0;

          // 3. Exact item count match
          final isCountMatch = latestOrder.items.length == state.items.length;

          // 4. Exact product item IDs and quantities match
          final isItemsMatch = isCountMatch && state.items.every((cartItem) {
            return latestOrder.items.any((orderItem) =>
                (orderItem.id == cartItem.productId || orderItem.productId == cartItem.productId) &&
                orderItem.quantity == cartItem.quantity &&
                (cartItem.selectedSize == null || orderItem.selectedSize == cartItem.selectedSize));
          });

          // 5. Shipping address match (pincode check)
          final orderPincode = latestOrder.address?.pincode?.trim();
          final currentPincode = state.selectedAddress?.pincode?.trim();
          final isAddressMatch = orderPincode == null ||
              currentPincode == null ||
              orderPincode == currentPincode;

          if (isRecent && isAmountMatch && isItemsMatch && isAddressMatch) {
            AppLogger.i('[CheckoutNotifier] Successfully verified and reconciled order #${latestOrder.orderNumber}');
            _ref.read(cartProvider.notifier).fetchCart();
            state = state.copyWith(isLoading: false, lastOrder: latestOrder);
            return true;
          } else {
            AppLogger.w('[CheckoutNotifier] Latest order does not match checkout fingerprint: '
                'isRecent=$isRecent, isAmountMatch=$isAmountMatch, isItemsMatch=$isItemsMatch, isAddressMatch=$isAddressMatch');
          }
        }
      }
    } catch (err) {
      AppLogger.w('[CheckoutNotifier] Order reconciliation check failed: $err');
    }
    return false;
  }

  Future<void> placeOrder() async {
    if (_isSubmitting || state.isLoading) return;
    _isSubmitting = true;
    final checkoutStartTime = DateTime.now();

    if (state.items.isEmpty) {
      state = state.copyWith(errorMessage: "Your cart is empty. Cannot place order.");
      return;
    }

    if (state.items.any((item) => item.quantity <= 0)) {
      state = state.copyWith(errorMessage: "Invalid quantity in order.");
      return;
    }

    if (state.selectedAddress == null) {
      state = state.copyWith(errorMessage: "Please select a shipping address");
      return;
    }

    final addr = state.selectedAddress!;
    if ((addr.line1?.trim().isEmpty ?? true) ||
        (addr.city?.trim().isEmpty ?? true) ||
        (addr.pincode?.trim().isEmpty ?? true) ||
        (addr.phone?.trim().isEmpty ?? true)) {
      state = state.copyWith(errorMessage: "Shipping address is incomplete. Please check required fields.");
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    _internalOrderId = null; // Reset for new attempt

    final user = _ref.read(authProvider).user;

    try {
      final addressId = state.selectedAddress!.id;
      final shippingAddress = {
        if (addressId != null && addressId.trim().isNotEmpty) 'id': addressId.trim(),
        'label': state.selectedAddress!.label ?? 'Home',
        'name': state.selectedAddress!.name ?? user?.name ?? 'Customer',
        'customerName': state.selectedAddress!.name ?? user?.name ?? 'Customer',
        'line1': state.selectedAddress!.line1 ?? '',
        'line2': state.selectedAddress!.line2 ?? '',
        'city': state.selectedAddress!.city ?? '',
        'state': state.selectedAddress!.state ?? '',
        'pincode': state.selectedAddress!.pincode ?? '',
        'country': state.selectedAddress!.country,
        'phone': state.selectedAddress!.phone ?? user?.phone ?? '',
        'email': user?.email ?? '',
      };

      final items = state.items.map((it) => {
        'product_id': it.productId,
        'productId': it.productId,
        'product_name': it.name ?? 'Product',
        'name': it.name ?? 'Product',
        'sku': 'SKU-${it.productId}',
        'quantity': it.quantity,
        'price': it.price.toInt(),
        'unit_price': it.price.toInt(),
        'selectedColor': it.selectedColor,
        'selectedSize': it.selectedSize,
      }).toList();

      if (state.paymentType == PaymentType.cod) {
        // Handle COD Flow
        final payload = {
          'buyNow': true,
          'items': items,
          'shippingAddress': shippingAddress,
          'paymentMethod': 'COD',
          'paymentDetails': {'method': 'COD'},
          'totalAmount': state.grandTotal.round(),
        };

        final result = await _ref.read(orderRepositoryProvider).placeOrder(payload);

        if (result is Success<Map<String, dynamic>>) {
          final responseBody = result.data;
          final responseData = responseBody['data'] as Map<String, dynamic>;

          final orderId = responseData['orderId'].toString();
          final orderNumber = responseData['orderNumber'].toString();

          AppLogger.i('[CheckoutNotifier] COD success. orderId=$orderId, orderNumber=$orderNumber');

          final confirmedOrder = OrderModel(
            id: orderId,
            orderNumber: orderNumber,
            totalAmount: state.grandTotal,
            status: 'Confirmed',
            paymentMethod: 'Cash on Delivery',
            address: state.selectedAddress,
            items: state.items.map((it) => OrderItemModel(
              id: it.productId,
              quantity: it.quantity,
              unitPrice: it.price,
              productName: it.name,
              productImage: it.images.isNotEmpty ? it.images.first : null,
              options: {
                'color': it.selectedColor,
                'size': it.selectedSize,
              },
            )).toList(),
          );

          // Refresh cart on success
          _ref.read(cartProvider.notifier).fetchCart();
          state = state.copyWith(isLoading: false, lastOrder: confirmedOrder);
        } else {
          final failure = result as Failure;
          AppLogger.e('[CheckoutNotifier] COD Order Failed: ${failure.message}', error: failure.exception);

          final isTimeout = failure.message.toLowerCase().contains('timeout') ||
                            failure.message.toLowerCase().contains('deadline');
          if (isTimeout && user != null) {
            final reconciled = await _tryReconcileRecentOrder(checkoutStartTime);
            if (reconciled) return;
          }

          final errorMsg = failure.message.trim().isNotEmpty
              ? failure.message.trim()
              : 'Unable to place your order. Please try again.';
          state = state.copyWith(
            isLoading: false,
            errorMessage: errorMsg,
          );
        }
      } else {
        // Handle Razorpay Flow
        final config = _ref.read(configProvider);
        String razorpayKey = config.razorpayKey;
        if (razorpayKey.isEmpty && config.environment == AppEnvironment.production) {
          razorpayKey = 'rzp_live_RfHNYKXeosg3XW';
        }

        if (razorpayKey.isEmpty) {
          AppLogger.e('[CheckoutNotifier] Razorpay key is not configured');
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Payment gateway configuration is missing. Please configure RAZORPAY_KEY.',
          );
          return;
        }

        if (config.environment != AppEnvironment.production && razorpayKey.startsWith('rzp_live_')) {
          AppLogger.e('[CheckoutNotifier] Security violation: Live Razorpay key in non-production environment');
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Security configuration error: Live payment keys are not allowed in ${config.environment.name}.',
          );
          return;
        }

        final result = await _ref.read(paymentRepositoryProvider).createRazorpayOrder({
          'items': items,
          'shipping': shippingAddress,
          'totalAmount': state.grandTotal.round(),
        });

        if (result is Success<Map<String, dynamic>>) {
          final data = result.data;

          _internalOrderId = data['internalOrderId']?.toString();
          final razorpayOrderId = data['razorpayOrderId']?.toString();
          final amountInPaise = data['amount'];

          if (razorpayOrderId == null || amountInPaise == null) {
            throw Exception('Server response missing Razorpay order details');
          }

          final options = {
            'key': razorpayKey,
            'amount': amountInPaise,
            'name': 'Dripzoid',
            'order_id': razorpayOrderId,
            'description': 'Payment for Order #${_internalOrderId ?? ""}',
            'prefill': {
              'contact': shippingAddress['phone'],
              'email': shippingAddress['email'],
            },
            'theme': {'color': '#000000'}
          };

          _razorpay.open(options);
          state = state.copyWith(isLoading: false);
        } else {
          final failure = result as Failure;
          AppLogger.e('[CheckoutNotifier] Razorpay order creation failed: ${failure.message}', error: failure.exception);
          final errorMsg = failure.message.trim().isNotEmpty
              ? failure.message.trim()
              : 'Unable to start payment. Please try again or select Cash on Delivery.';
          state = state.copyWith(
            isLoading: false,
            errorMessage: errorMsg,
          );
        }
      }
    } catch (e, stack) {
      AppLogger.e('[CheckoutNotifier] Unexpected error during checkout', error: e, stackTrace: stack);

      final isTimeout = e.toString().toLowerCase().contains('timeout') ||
                        e.toString().toLowerCase().contains('deadline');
      if (isTimeout && user != null) {
        final reconciled = await _tryReconcileRecentOrder(checkoutStartTime);
        if (reconciled) return;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: isTimeout
            ? 'Connection timed out while placing order. Please check your order history or try again.'
            : 'Something went wrong: ${e.toString().replaceFirst("Exception: ", "")}',
      );
    } finally {
      _isSubmitting = false;
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _ref.read(paymentRepositoryProvider).verifyRazorpayPayment({
      'razorpay_payment_id': response.paymentId,
      'razorpay_order_id': response.orderId,
      'razorpay_signature': response.signature,
      'internalOrderId': _internalOrderId,
    });

    if (result is Success<Map<String, dynamic>>) {
      // Fetch fresh order details for the success screen
      final orderRes = await _ref.read(orderRepositoryProvider).getOrderDetails(_internalOrderId!);
      if (orderRes is Success<OrderModel>) {
        _ref.read(cartProvider.notifier).fetchCart();
        state = state.copyWith(isLoading: false, lastOrder: orderRes.data);
      } else {
        // Fallback confirmed order
        final fallbackOrder = OrderModel(
          id: _internalOrderId ?? '',
          orderNumber: 'DRIP-PAID-${DateTime.now().millisecondsSinceEpoch}',
          totalAmount: state.grandTotal,
          status: 'Confirmed',
          paymentMethod: 'Online Payment (Razorpay)',
          address: state.selectedAddress,
          items: state.items.map((it) => OrderItemModel(
            id: it.productId,
            quantity: it.quantity,
            unitPrice: it.price,
            productName: it.name,
            productImage: it.images.isNotEmpty ? it.images.first : null,
            options: {
              'color': it.selectedColor,
              'size': it.selectedSize,
            },
          )).toList(),
        );
        _ref.read(cartProvider.notifier).fetchCart();
        state = state.copyWith(isLoading: false, lastOrder: fallbackOrder);
      }
    } else {
      final failure = result as Failure;
      final errorMsg = failure.message.trim().isNotEmpty
          ? failure.message.trim()
          : 'Payment verification failed. Please contact support with payment ID: ${response.paymentId}';
      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    String msg = 'Payment failed';
    if (response.code == Razorpay.PAYMENT_CANCELLED) {
      msg = 'Payment was cancelled. You can retry or choose Cash on Delivery.';
    } else if (response.message != null && response.message!.trim().isNotEmpty) {
      msg = response.message!.trim();
    }
    state = state.copyWith(isLoading: false, errorMessage: msg);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    state = state.copyWith(isLoading: false, errorMessage: 'External wallet selected: ${response.walletName}');
  }
}
