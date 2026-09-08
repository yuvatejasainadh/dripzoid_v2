import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/config/config_provider.dart';
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
    state = CheckoutState(items: items);
  }

  void nextStep() {
    if (state.step == CheckoutStep.review) {
      state = state.copyWith(step: CheckoutStep.shipping);
    } else if (state.step == CheckoutStep.shipping) {
      if (state.selectedAddress == null) {
        state = state.copyWith(errorMessage: "Please select a shipping address");
        return;
      }
      state = state.copyWith(step: CheckoutStep.payment);
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
    state = state.copyWith(selectedAddress: address);
  }

  void selectPaymentType(PaymentType type) {
    state = state.copyWith(paymentType: type);
  }

  Future<void> placeOrder() async {
    if (state.selectedAddress == null || state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);
    _internalOrderId = null; // Reset for new attempt

    final user = _ref.read(authProvider).user;

    try {
      if (state.paymentType == PaymentType.cod) {
        // Handle COD (Full React Parity Flow)
        final items = state.items.map((it) => {
          'product_id': it.productId,
          'product_name': it.name ?? 'Product',
          'sku': 'SKU-${it.productId}',
          'quantity': it.quantity,
          'price': it.price.toInt(),
          'unit_price': it.price.toInt(),
          'selectedColor': it.selectedColor,
          'selectedSize': it.selectedSize,
        }).toList();

        final shippingAddress = {
          'id': state.selectedAddress!.id,
          'label': state.selectedAddress!.label ?? 'Home',
          'name': state.selectedAddress!.name ?? user?.name ?? 'Customer',
          'customerName': state.selectedAddress!.name ?? user?.name ?? 'Customer',
          'line1': state.selectedAddress!.line1 ?? '',
          'line2': state.selectedAddress!.line2 ?? '',
          'city': state.selectedAddress!.city ?? '',
          'state': state.selectedAddress!.state ?? '',
          'pincode': state.selectedAddress!.pincode ?? '',
          'country': state.selectedAddress!.country,
          'phone': state.selectedAddress!.phone ?? '',
        };

        final payload = {
          'buyNow': true, // Synchronized with React contract
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

          AppLogger.d('[CheckoutNotifier] COD success. orderId=$orderId');

          // Construct a skeleton OrderModel for the success screen
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

          _ref.read(cartProvider.notifier).fetchCart();
          state = state.copyWith(isLoading: false, lastOrder: confirmedOrder);
        } else {
          final failure = result as Failure;
          AppLogger.e('[CheckoutNotifier] COD Order Failed', error: failure.exception);
          state = state.copyWith(
            isLoading: false, 
            errorMessage: 'Unable to place your order. Please try again.',
          );
        }
      } else {
        // Handle Razorpay (Verified React Parity Flow)
        final items = state.items.map((it) => {
          'product_id': it.productId,
          'product_name': it.name ?? 'Product',
          'sku': 'SKU-${it.productId}',
          'quantity': it.quantity,
          'unit_price': it.price.toInt(),
          'selectedColor': it.selectedColor,
          'selectedSize': it.selectedSize,
        }).toList();

        final shipping = {
          'name': state.selectedAddress!.name ?? user?.name ?? 'Customer',
          'customerName': state.selectedAddress!.name ?? user?.name ?? 'Customer',
          'line1': state.selectedAddress!.line1 ?? '',
          'line2': state.selectedAddress!.line2 ?? '',
          'city': state.selectedAddress!.city ?? '',
          'state': state.selectedAddress!.state ?? '',
          'pincode': state.selectedAddress!.pincode ?? '',
          'country': state.selectedAddress!.country,
          'phone': state.selectedAddress!.phone ?? '',
          'email': user?.email ?? '',
        };

        final result = await _ref.read(paymentRepositoryProvider).createRazorpayOrder({
          'items': items,
          'shipping': shipping,
          'totalAmount': state.grandTotal.round(),
        });

        if (result is Success<Map<String, dynamic>>) {
          final data = result.data;
          
          _internalOrderId = data['internalOrderId']?.toString();
          final razorpayOrderId = data['razorpayOrderId']?.toString();
          final amountInPaise = data['amount'];

          if (razorpayOrderId == null || amountInPaise == null) {
            throw Exception('Server response missing Razorpay IDs');
          }
          
          final config = _ref.read(configProvider);

          final options = {
            'key': config.razorpayKey,
            'amount': amountInPaise, 
            'name': 'Dripzoid',
            'order_id': razorpayOrderId,
            'description': 'Payment for Order #${_internalOrderId ?? ""}',
            'prefill': {
              'contact': shipping['phone'],
              'email': shipping['email'],
            },
            'theme': {'color': '#000000'}
          };

          _razorpay.open(options);
          state = state.copyWith(isLoading: false);
        } else {
          final failure = result as Failure;
          AppLogger.e('[CheckoutNotifier] Razorpay order creation failed', error: failure.exception);
          state = state.copyWith(
            isLoading: false, 
            errorMessage: 'Unable to start payment. Please try again.',
          );
        }
      }
    } catch (e) {
      AppLogger.e('[CheckoutNotifier] Unexpected error during checkout', error: e);
      state = state.copyWith(
        isLoading: false, 
        errorMessage: 'Something went wrong. Please try again.',
      );
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
        state = state.copyWith(isLoading: false, errorMessage: 'Payment verified, but failed to fetch order details');
      }
    } else {
      state = state.copyWith(isLoading: false, errorMessage: (result as Failure).message);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    String msg = 'Payment failed';
    if (response.code == Razorpay.PAYMENT_CANCELLED) {
      msg = 'Payment cancelled';
    } else if (response.message != null) {
      msg = response.message!;
    }
    state = state.copyWith(isLoading: false, errorMessage: msg);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    state = state.copyWith(isLoading: false, errorMessage: 'External wallet selected: ${response.walletName}');
  }
}
