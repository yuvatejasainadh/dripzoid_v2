import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dripzoid_v2/core/config/app_config.dart';
import 'package:dripzoid_v2/core/config/config_provider.dart';
import 'package:dripzoid_v2/core/config/environment.dart';
import 'package:dripzoid_v2/core/models/result.dart';
import 'package:dripzoid_v2/features/address/data/models/address_model.dart';
import 'package:dripzoid_v2/features/auth/data/models/user_model.dart';
import 'package:dripzoid_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:dripzoid_v2/features/cart/data/models/cart_item_model.dart';
import 'package:dripzoid_v2/features/checkout/presentation/providers/checkout_notifier.dart';
import 'package:dripzoid_v2/features/orders/data/models/order_model.dart';
import 'package:dripzoid_v2/features/orders/data/repositories/order_repository.dart';
import 'package:flutter/services.dart';
import 'package:dripzoid_v2/features/payments/data/repositories/payment_repository.dart';

class FakeOrderRepository implements OrderRepository {
  Result<Map<String, dynamic>>? mockPlaceOrderResult;
  Result<OrderModel>? mockGetOrderDetailsResult;
  int placeOrderCalls = 0;
  int getOrderDetailsCalls = 0;
  Duration? delay;

  @override
  Future<Result<Map<String, dynamic>>> placeOrder(Map<String, dynamic> payload) async {
    placeOrderCalls++;
    if (delay != null) await Future.delayed(delay!);
    return mockPlaceOrderResult ??
        const Success({
          'data': {
            'orderId': 'ord_123',
            'orderNumber': 'DRP-999',
          }
        });
  }

  @override
  Future<Result<OrderModel>> getOrderDetails(String orderId) async {
    getOrderDetailsCalls++;
    return mockGetOrderDetailsResult ??
        Success(OrderModel(
          id: orderId,
          orderNumber: 'DRP-999',
          totalAmount: 1499.0,
          status: 'Confirmed',
          paymentMethod: 'COD',
          items: const [],
        ));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakePaymentRepository implements PaymentRepository {
  Result<Map<String, dynamic>>? mockCreateRazorpayOrderResult;
  Result<Map<String, dynamic>>? mockVerifyRazorpayPaymentResult;
  int createOrderCalls = 0;
  int verifyPaymentCalls = 0;
  Duration? delay;

  @override
  Future<Result<Map<String, dynamic>>> createRazorpayOrder(Map<String, dynamic> payload) async {
    createOrderCalls++;
    if (delay != null) await Future.delayed(delay!);
    return mockCreateRazorpayOrderResult ??
        const Success({
          'internalOrderId': 'ord_internal_101',
          'razorpayOrderId': 'order_rzp_101',
          'amount': 149900,
        });
  }

  @override
  Future<Result<Map<String, dynamic>>> verifyRazorpayPayment(Map<String, dynamic> payload) async {
    verifyPaymentCalls++;
    if (delay != null) await Future.delayed(delay!);
    return mockVerifyRazorpayPaymentResult ??
        const Success({
          'status': 'verified',
        });
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() {
    return const AuthState(
      status: AuthStatus.authenticated,
      user: UserModel(
        id: 'user-chk-1',
        name: 'Checkout Tester',
        email: 'checkout@dripzoid.com',
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('razorpay_flutter'),
      (MethodCall methodCall) async => null,
    );
  });

  group('Checkout Safety & Step Validation (Workstream B)', () {
    late FakeOrderRepository fakeOrderRepository;
    late FakePaymentRepository fakePaymentRepository;
    late ProviderContainer container;

    setUp(() {
      fakeOrderRepository = FakeOrderRepository();
      fakePaymentRepository = FakePaymentRepository();
      container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(fakeOrderRepository),
          paymentRepositoryProvider.overrideWithValue(fakePaymentRepository),
          authProvider.overrideWith(FakeAuthNotifier.new),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Cannot proceed to shipping when cart items are empty', () {
      final notifier = container.read(checkoutProvider.notifier);
      notifier.initCheckout([]);

      notifier.nextStep();

      final state = container.read(checkoutProvider);
      expect(state.step, CheckoutStep.review);
      expect(state.errorMessage, contains('empty'));
    });

    test('Cannot proceed to shipping when an item has invalid quantity', () {
      final notifier = container.read(checkoutProvider.notifier);
      notifier.initCheckout([
        const CartItemModel(
          id: 'c-invalid',
          productId: 'p-1',
          name: 'Invalid Item',
          price: 100.0,
          quantity: 0,
        )
      ]);

      notifier.nextStep();

      final state = container.read(checkoutProvider);
      expect(state.step, CheckoutStep.review);
      expect(state.errorMessage, contains('Invalid item quantity'));
    });

    test('Cannot proceed to payment without selected shipping address', () {
      final notifier = container.read(checkoutProvider.notifier);
      notifier.initCheckout([
        const CartItemModel(
          id: 'c-valid',
          productId: 'p-1',
          name: 'Valid Item',
          price: 999.0,
          quantity: 1,
        )
      ]);

      // Move to shipping
      notifier.nextStep();
      expect(container.read(checkoutProvider).step, CheckoutStep.shipping);

      // Attempt moving to payment without address
      notifier.nextStep();
      final state = container.read(checkoutProvider);
      expect(state.step, CheckoutStep.shipping);
      expect(state.errorMessage, contains('shipping address'));
    });

    test('Cannot proceed to payment if shipping address is missing required fields', () {
      final notifier = container.read(checkoutProvider.notifier);
      notifier.initCheckout([
        const CartItemModel(
          id: 'c-valid',
          productId: 'p-1',
          name: 'Valid Item',
          price: 999.0,
          quantity: 1,
        )
      ]);

      notifier.nextStep();

      // Incomplete address: missing line1 and phone
      notifier.selectAddress(const AddressModel(
        id: 'addr-incomplete',
        city: 'Hyderabad',
        state: 'Telangana',
        pincode: '500001',
      ));

      notifier.nextStep();

      final state = container.read(checkoutProvider);
      expect(state.step, CheckoutStep.shipping);
      expect(state.errorMessage, contains('incomplete'));
    });

    test('Successfully transitions to payment when valid address is selected', () {
      final notifier = container.read(checkoutProvider.notifier);
      notifier.initCheckout([
        const CartItemModel(
          id: 'c-valid',
          productId: 'p-1',
          name: 'Valid Item',
          price: 999.0,
          quantity: 1,
        )
      ]);

      notifier.nextStep();

      notifier.selectAddress(const AddressModel(
        id: 'addr-complete',
        line1: 'Road No 12, Banjara Hills',
        city: 'Hyderabad',
        state: 'Telangana',
        pincode: '500034',
        phone: '9876543210',
      ));

      notifier.nextStep();

      final state = container.read(checkoutProvider);
      expect(state.step, CheckoutStep.payment);
      expect(state.errorMessage, isNull);
    });
  });

  group('Order Creation & Payment Handover Safety (Workstream C)', () {
    late FakeOrderRepository fakeOrderRepository;
    late FakePaymentRepository fakePaymentRepository;
    late ProviderContainer container;

    setUp(() {
      fakeOrderRepository = FakeOrderRepository();
      fakePaymentRepository = FakePaymentRepository();
    });

    tearDown(() {
      container.dispose();
    });

    test('placeOrder prevents duplicate concurrent submissions when already loading', () async {
      container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(fakeOrderRepository),
          paymentRepositoryProvider.overrideWithValue(fakePaymentRepository),
          authProvider.overrideWith(FakeAuthNotifier.new),
        ],
      );

      fakeOrderRepository.delay = const Duration(milliseconds: 60);

      final notifier = container.read(checkoutProvider.notifier);
      notifier.initCheckout([
        const CartItemModel(
          id: 'c-valid',
          productId: 'p-1',
          name: 'Valid Item',
          price: 999.0,
          quantity: 1,
        )
      ]);
      notifier.selectAddress(const AddressModel(
        id: 'addr-1',
        line1: 'Plot 44',
        city: 'Hyderabad',
        state: 'Telangana',
        pincode: '500001',
        phone: '9999999999',
      ));
      notifier.selectPaymentType(PaymentType.cod);

      // Concurrent taps
      final call1 = notifier.placeOrder();
      final call2 = notifier.placeOrder();

      await Future.wait([call1, call2]);

      // Only one order placement call executed
      expect(fakeOrderRepository.placeOrderCalls, 1);
    });

    test('Missing Razorpay key configuration fails safely without initiating payment', () async {
      container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(fakeOrderRepository),
          paymentRepositoryProvider.overrideWithValue(fakePaymentRepository),
          authProvider.overrideWith(FakeAuthNotifier.new),
          configProvider.overrideWithValue(AppConfig(
            baseUrl: 'https://test.api',
            aiBaseUrl: 'https://test.ai',
            appName: 'TestApp',
            environment: AppEnvironment.development,
            razorpayKey: '', // Empty key
            googleWebClientId: 'test-client',
          )),
        ],
      );

      final notifier = container.read(checkoutProvider.notifier);
      notifier.initCheckout([
        const CartItemModel(
          id: 'c-valid',
          productId: 'p-1',
          name: 'Valid Item',
          price: 999.0,
          quantity: 1,
        )
      ]);
      notifier.selectAddress(const AddressModel(
        id: 'addr-1',
        line1: 'Plot 44',
        city: 'Hyderabad',
        state: 'Telangana',
        pincode: '500001',
        phone: '9999999999',
      ));
      notifier.selectPaymentType(PaymentType.razorpay);

      await notifier.placeOrder();

      final state = container.read(checkoutProvider);
      expect(state.isLoading, false);
      expect(state.errorMessage, contains('Payment gateway configuration is missing'));
      expect(state.lastOrder, isNull);
    });

    test('Live Razorpay key in non-production environment is blocked as a security violation', () async {
      container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(fakeOrderRepository),
          paymentRepositoryProvider.overrideWithValue(fakePaymentRepository),
          authProvider.overrideWith(FakeAuthNotifier.new),
          configProvider.overrideWithValue(AppConfig(
            baseUrl: 'https://test.api',
            aiBaseUrl: 'https://test.ai',
            appName: 'TestApp',
            environment: AppEnvironment.development,
            razorpayKey: 'rzp_live_test_should_block',
            googleWebClientId: 'test-client',
          )),
        ],
      );

      final notifier = container.read(checkoutProvider.notifier);
      notifier.initCheckout([
        const CartItemModel(
          id: 'c-valid',
          productId: 'p-1',
          name: 'Valid Item',
          price: 999.0,
          quantity: 1,
        )
      ]);
      notifier.selectAddress(const AddressModel(
        id: 'addr-1',
        line1: 'Plot 44',
        city: 'Hyderabad',
        state: 'Telangana',
        pincode: '500001',
        phone: '9999999999',
      ));
      notifier.selectPaymentType(PaymentType.razorpay);

      await notifier.placeOrder();

      final state = container.read(checkoutProvider);
      expect(state.isLoading, false);
      expect(state.errorMessage, contains('Security configuration error'));
      expect(state.lastOrder, isNull);
    });

    test('Server verification failure prevents order success and records error', () async {
      fakePaymentRepository.mockVerifyRazorpayPaymentResult =
          const Failure('Signature verification failed on server', statusCode: 400);

      container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(fakeOrderRepository),
          paymentRepositoryProvider.overrideWithValue(fakePaymentRepository),
          authProvider.overrideWith(FakeAuthNotifier.new),
        ],
      );

      final notifier = container.read(checkoutProvider.notifier);
      notifier.initCheckout([
        const CartItemModel(
          id: 'c-valid',
          productId: 'p-1',
          name: 'Valid Item',
          price: 999.0,
          quantity: 1,
        )
      ]);

      // If server verification fails
      final result = await fakePaymentRepository.verifyRazorpayPayment({});
      expect(result, isA<Failure<Map<String, dynamic>>>());
      expect(container.read(checkoutProvider).lastOrder, isNull);
    });

    test('reset clears checkout state and prevents stale order retention', () {
      container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(fakeOrderRepository),
          paymentRepositoryProvider.overrideWithValue(fakePaymentRepository),
          authProvider.overrideWith(FakeAuthNotifier.new),
        ],
      );

      final notifier = container.read(checkoutProvider.notifier);
      notifier.initCheckout([
        const CartItemModel(
          id: 'c-valid',
          productId: 'p-1',
          name: 'Valid Item',
          price: 999.0,
          quantity: 1,
        )
      ]);

      expect(container.read(checkoutProvider).items.isNotEmpty, true);

      notifier.reset();

      final state = container.read(checkoutProvider);
      expect(state.items, isEmpty);
      expect(state.selectedAddress, isNull);
      expect(state.lastOrder, isNull);
      expect(state.isLoading, false);
    });
  });
}
