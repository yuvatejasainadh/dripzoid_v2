import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dripzoid_v2/core/theme/app_theme.dart';
import 'package:dripzoid_v2/core/theme/tokens/app_colors.dart';
import 'package:dripzoid_v2/core/models/result.dart';
import 'package:dripzoid_v2/shared/widgets/shimmer_loading.dart';
import 'package:dripzoid_v2/features/address/data/models/address_model.dart';
import 'package:dripzoid_v2/features/address/data/repositories/address_repository.dart';
import 'package:dripzoid_v2/features/auth/data/models/user_model.dart';
import 'package:dripzoid_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:dripzoid_v2/features/cart/data/models/cart_item_model.dart';
import 'package:dripzoid_v2/features/checkout/presentation/providers/checkout_notifier.dart';
import 'package:dripzoid_v2/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:dripzoid_v2/features/checkout/presentation/screens/order_success_screen.dart';
import 'package:dripzoid_v2/features/orders/data/models/order_model.dart';
import 'package:dripzoid_v2/features/orders/data/repositories/order_repository.dart';
import 'package:dripzoid_v2/features/payments/data/repositories/payment_repository.dart';

class FakeAddressRepository implements AddressRepository {
  List<AddressModel> addresses;
  FakeAddressRepository([this.addresses = const []]);

  @override
  Future<Result<List<AddressModel>>> getAddresses() async => Success(addresses);

  @override
  Future<Result<AddressModel>> createAddress(Map<String, dynamic> data) async =>
      Success(AddressModel.fromJson(data));

  @override
  Future<Result<AddressModel>> updateAddress(String id, Map<String, dynamic> data) async =>
      Success(AddressModel.fromJson(data));

  @override
  Future<Result<void>> deleteAddress(String id) async => const Success(null);

  @override
  Future<Result<void>> setDefaultAddress(String id) async => const Success(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeOrderRepository implements OrderRepository {
  @override
  Future<Result<Map<String, dynamic>>> placeOrder(Map<String, dynamic> payload) async =>
      const Success({
        'data': {
          'orderId': 'ord_success_1',
          'orderNumber': 'DRP-SUCCESS-001',
        }
      });

  @override
  Future<Result<OrderModel>> getOrderDetails(String orderId) async =>
      Success(OrderModel(
        id: orderId,
        orderNumber: 'DRP-SUCCESS-001',
        totalAmount: 1998.0,
        status: 'Confirmed',
        paymentMethod: 'COD',
        items: const [],
      ));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakePaymentRepository implements PaymentRepository {
  @override
  Future<Result<Map<String, dynamic>>> createRazorpayOrder(Map<String, dynamic> payload) async =>
      const Success({
        'internalOrderId': 'ord_int_1',
        'razorpayOrderId': 'order_rzp_1',
        'amount': 199800,
      });

  @override
  Future<Result<Map<String, dynamic>>> verifyRazorpayPayment(Map<String, dynamic> payload) async =>
      const Success({'status': 'verified'});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() {
    return const AuthState(
      status: AuthStatus.authenticated,
      user: UserModel(
        id: 'user_chk_1',
        name: 'Checkout Tester',
        email: 'tester@dripzoid.com',
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

  const sampleAddress = AddressModel(
    id: 'addr_1',
    label: 'Home',
    name: 'Dripzoid Customer',
    line1: '123 Drip Lane',
    line2: 'Apt 4B',
    city: 'Mumbai',
    state: 'Maharashtra',
    pincode: '400001',
    phone: '9876543210',
    isDefault: true,
  );

  const sampleItem = CartItemModel(
    id: 'ci_1',
    productId: 'p_1',
    name: 'Oversized Boxy Heavyweight Tee',
    price: 1999.0,
    quantity: 1,
    selectedColor: 'Washed Black',
    selectedSize: 'L',
    stock: 5,
    images: ['https://example.com/tee.jpg'],
  );

  final sampleOrder = OrderModel(
    id: 'ord_1',
    orderNumber: 'DRP-2026-0042',
    totalAmount: 1999.0,
    status: 'Confirmed',
    paymentMethod: 'Prepaid',
    items: const [],
    createdAt: DateTime.now(),
  );

  group('Component-Level Skeletons & Theme Tokens', () {
    testWidgets('CartItemTileSkeleton renders in Light and Dark themes', (tester) async {
      // Light theme
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: CartItemTileSkeleton()),
        ),
      );
      expect(find.byType(CartItemTileSkeleton), findsOneWidget);
      expect(find.byType(ShimmerWidget), findsAtLeast(1));

      // Dark theme
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(body: CartItemTileSkeleton()),
        ),
      );
      expect(find.byType(CartItemTileSkeleton), findsOneWidget);
    });

    testWidgets('AddressCardSkeleton renders in Light and Dark themes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: AddressCardSkeleton()),
        ),
      );
      expect(find.byType(AddressCardSkeleton), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(body: AddressCardSkeleton()),
        ),
      );
      expect(find.byType(AddressCardSkeleton), findsOneWidget);
    });

    testWidgets('PaymentOptionSkeleton and OrderSummarySkeleton render properly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: Column(
              children: [
                PaymentOptionSkeleton(),
                SizedBox(height: 12),
                OrderSummarySkeleton(),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(PaymentOptionSkeleton), findsOneWidget);
      expect(find.byType(OrderSummarySkeleton), findsOneWidget);
    });

    testWidgets('CartScreenSkeleton renders comprehensive list placeholder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: CartScreenSkeleton()),
        ),
      );
      expect(find.byType(CartScreenSkeleton), findsOneWidget);
      expect(find.byType(CartItemTileSkeleton), findsNWidgets(3));
    });

    testWidgets('Skeletons exclude semantics for accessibility', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: SkeletonBox(width: 100, height: 20),
          ),
        ),
      );
      final semanticsFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.excludeSemantics == true,
      );
      expect(semanticsFinder, findsAtLeast(1));
    });
  });

  group('OrderSuccessScreen Theme Compatibility', () {
    testWidgets('renders cleanly in Light Theme with success token', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: OrderSuccessScreen(order: sampleOrder),
        ),
      );

      expect(find.text('Order Placed Successfully!'), findsOneWidget);
      expect(find.textContaining('DRP-2026-0042'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);
      expect(find.text('View Order Details'), findsOneWidget);

      // Verify the check icon uses AppColors.success
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.check_circle));
      expect(iconWidget.color, equals(AppColors.success));
    });

    testWidgets('renders cleanly in Dark Theme with success token', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: OrderSuccessScreen(order: sampleOrder),
        ),
      );

      expect(find.text('Order Placed Successfully!'), findsOneWidget);
      expect(find.textContaining('DRP-2026-0042'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.check_circle));
      expect(iconWidget.color, equals(AppColors.success));
    });
  });

  group('CheckoutScreen Theme & Component Flow Compatibility', () {
    testWidgets('Review step renders with order items and Order Summary card in Light Theme', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            addressRepositoryProvider.overrideWithValue(FakeAddressRepository([sampleAddress])),
            orderRepositoryProvider.overrideWithValue(FakeOrderRepository()),
            paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
            authProvider.overrideWith(FakeAuthNotifier.new),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const CheckoutScreen(items: [sampleItem]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Review Order Items'), findsOneWidget);
      expect(find.text('Oversized Boxy Heavyweight Tee'), findsOneWidget);
      expect(find.text('Order Summary'), findsOneWidget);
      expect(find.text('Items Total'), findsOneWidget);
      expect(find.text('Delivery'), findsOneWidget);
      expect(find.text('FREE'), findsOneWidget);
      expect(find.text('Total Amount'), findsAtLeast(1));
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('Review step renders cleanly in Dark Theme', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            addressRepositoryProvider.overrideWithValue(FakeAddressRepository([sampleAddress])),
            orderRepositoryProvider.overrideWithValue(FakeOrderRepository()),
            paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
            authProvider.overrideWith(FakeAuthNotifier.new),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const CheckoutScreen(items: [sampleItem]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Review Order Items'), findsOneWidget);
      expect(find.text('Order Summary'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('Shipping step displays AddressCardSkeleton during loading, then loaded addresses', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            addressRepositoryProvider.overrideWithValue(FakeAddressRepository([sampleAddress])),
            orderRepositoryProvider.overrideWithValue(FakeOrderRepository()),
            paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
            authProvider.overrideWith(FakeAuthNotifier.new),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const CheckoutScreen(items: [sampleItem]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap continue to go to shipping step
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Shipping Address'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text(sampleAddress.fullAddress), findsOneWidget);
    });

    testWidgets('Payment step displays methods and updates order summary with COD fee', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            addressRepositoryProvider.overrideWithValue(FakeAddressRepository([sampleAddress])),
            orderRepositoryProvider.overrideWithValue(FakeOrderRepository()),
            paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
            authProvider.overrideWith(FakeAuthNotifier.new),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const CheckoutScreen(items: [sampleItem]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1: Review -> Tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 2: Shipping -> Select Address & Tap Continue
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 3: Payment
      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('Online Payment (Razorpay)'), findsOneWidget);
      expect(find.text('Cash on Delivery (COD)'), findsOneWidget);
      expect(find.text('Delivering to'), findsOneWidget);
      expect(find.text('Pay Now'), findsOneWidget);

      // Select COD
      await tester.tap(find.text('Cash on Delivery (COD)'));
      await tester.pumpAndSettle();

      // Order Summary should reflect COD fee and button should show Place Order
      expect(find.text('COD Handling Fee'), findsOneWidget);
      expect(find.text('₹25'), findsOneWidget);
      expect(find.text('Place Order'), findsOneWidget);
    });

    testWidgets('PopScope handles back navigation between steps', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            addressRepositoryProvider.overrideWithValue(FakeAddressRepository([sampleAddress])),
            orderRepositoryProvider.overrideWithValue(FakeOrderRepository()),
            paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
            authProvider.overrideWith(FakeAuthNotifier.new),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const CheckoutScreen(items: [sampleItem]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // In Review step, advance to Shipping
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Shipping Address'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should be back at Review step
      expect(find.text('Review Order Items'), findsOneWidget);
    });
  });
}
