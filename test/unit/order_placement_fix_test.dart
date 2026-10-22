import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dripzoid_v2/core/models/result.dart';
import 'package:dripzoid_v2/features/address/data/models/address_model.dart';
import 'package:dripzoid_v2/features/auth/data/models/user_model.dart';
import 'package:dripzoid_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:dripzoid_v2/features/cart/data/models/cart_item_model.dart';
import 'package:dripzoid_v2/features/checkout/presentation/providers/checkout_notifier.dart';
import 'package:dripzoid_v2/features/orders/data/repositories/order_repository.dart';
import 'package:dripzoid_v2/features/payments/data/repositories/payment_repository.dart';
import 'package:dripzoid_v2/features/products/data/models/product_model.dart';
import 'package:dripzoid_v2/features/products/data/models/review_model.dart';
import 'package:dripzoid_v2/features/products/data/models/review_eligibility_model.dart';
import 'package:dripzoid_v2/features/products/data/models/question_model.dart';
import 'package:dripzoid_v2/features/products/data/repositories/product_repository.dart';
import 'package:dripzoid_v2/features/products/presentation/providers/product_details_notifier.dart';
import 'package:dripzoid_v2/features/products/presentation/providers/product_providers.dart';

class MockOrderRepository implements OrderRepository {
  Map<String, dynamic>? lastPlacedPayload;
  Result<Map<String, dynamic>>? mockResult;

  @override
  Future<Result<Map<String, dynamic>>> placeOrder(Map<String, dynamic> data) async {
    lastPlacedPayload = data;
    return mockResult ??
        const Success({
          'success': true,
          'data': {
            'orderId': 'order_real_123',
            'orderNumber': 'DRIP-20261021-123',
          }
        });
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockPaymentRepository implements PaymentRepository {
  Map<String, dynamic>? lastCreatedRazorpayPayload;
  Result<Map<String, dynamic>>? mockCreateResult;

  @override
  Future<Result<Map<String, dynamic>>> createRazorpayOrder(Map<String, dynamic> data) async {
    lastCreatedRazorpayPayload = data;
    return mockCreateResult ??
        const Success({
          'internalOrderId': 'int_order_456',
          'razorpayOrderId': 'order_rzp_456',
          'amount': 99900,
        });
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthNotifier extends AuthNotifier {
  @override
  AuthState build() {
    return const AuthState(
      status: AuthStatus.authenticated,
      user: UserModel(
        id: 'usr-1',
        name: 'Dripzoid Customer',
        email: 'customer@dripzoid.com',
        phone: '9494038163',
      ),
    );
  }
}

class MockProductRepository implements ProductRepository {
  ProductModel? mockProduct;

  @override
  Future<Result<ProductModel>> getProductById(String id) async {
    return Success(mockProduct ??
        ProductModel(
          id: id,
          name: 'Test Product',
          slug: 'test-product',
          price: 599.0,
          stock: 5,
          sizes: ['M', 'L', 'XL'],
          sizeStock: {'M': 0, 'L': 5, 'XL': 0},
        ));
  }

  @override
  Future<Result<List<ProductModel>>> getRelatedProducts(String id) async => const Success([]);

  @override
  Future<Result<List<ReviewModel>>> getProductReviews(String id) async => const Success([]);

  @override
  Future<Result<List<QuestionModel>>> getProductQuestions(String id) async => const Success([]);

  @override
  Future<Result<ReviewEligibilityModel>> verifyPurchase(String id) async =>
      Success(ReviewEligibilityModel.empty());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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

  group('AddressModel Serialization & Default Resolution', () {
    test('AddressModel.fromJson correctly normalizes isDefault (from Prisma camelCase)', () {
      final json = {
        'id': 'addr_100',
        'label': 'Home',
        'name': 'Tester',
        'line1': 'Near Cattle Market',
        'city': 'Pithapuram',
        'state': 'Andhra Pradesh',
        'pincode': '533450',
        'isDefault': true,
      };

      final address = AddressModel.fromJson(json);
      expect(address.isDefault, isTrue);
      expect(address.id, 'addr_100');
    });

    test('AddressModel.fromJson correctly normalizes is_default (snake_case)', () {
      final json = {
        'id': 'addr_101',
        'label': 'Office',
        'line1': 'Main Road',
        'city': 'Kakinada',
        'state': 'Andhra Pradesh',
        'pincode': '533001',
        'is_default': true,
      };

      final address = AddressModel.fromJson(json);
      expect(address.isDefault, isTrue);
    });

    test('AddressModel maps _id to id when id is omitted', () {
      final json = {
        '_id': 'mongo_addr_102',
        'line1': 'Temple Street',
        'city': 'Pithapuram',
        'state': 'AP',
        'pincode': '533450',
      };

      final address = AddressModel.fromJson(json);
      expect(address.id, 'mongo_addr_102');
    });
  });

  group('Order Placement Payload & Sanitization Tests', () {
    late MockOrderRepository mockOrderRepo;
    late MockPaymentRepository mockPaymentRepo;
    late ProviderContainer container;

    setUp(() {
      mockOrderRepo = MockOrderRepository();
      mockPaymentRepo = MockPaymentRepository();
      container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(mockOrderRepo),
          paymentRepositoryProvider.overrideWithValue(mockPaymentRepo),
          authProvider.overrideWith(MockAuthNotifier.new),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('COD order payload omits empty id in shippingAddress to protect foreign key relation', () async {
      final notifier = container.read(checkoutProvider.notifier);
      notifier.initCheckout([
        const CartItemModel(
          id: 'cart-1',
          productId: 'prod-hoodie-1',
          name: 'Legend Hoodie',
          price: 799.0,
          quantity: 2,
          selectedSize: 'L',
          selectedColor: 'Black',
        ),
      ]);

      // Address without id (e.g. newly created or unsaved)
      notifier.selectAddress(const AddressModel(
        id: '', // empty id
        label: 'Home',
        name: 'Dripzoid Tester',
        line1: 'Near Cattle Market',
        city: 'Pithapuram',
        state: 'Andhra Pradesh',
        pincode: '533450',
        phone: '9494038163',
      ));
      notifier.selectPaymentType(PaymentType.cod);

      await notifier.placeOrder();

      expect(mockOrderRepo.lastPlacedPayload, isNotNull);
      final payload = mockOrderRepo.lastPlacedPayload!;
      final shipping = payload['shippingAddress'] as Map<String, dynamic>;

      // Confirm id is not passed as empty string
      expect(shipping.containsKey('id'), isFalse);
      expect(shipping['pincode'], '533450');
      expect(shipping['phone'], '9494038163');
      expect(payload['paymentMethod'], 'COD');
      expect(payload['totalAmount'], 799 * 2 + 25); // including COD fee
    });

    test('COD order preserves backend failure message rather than generic placeholder', () async {
      mockOrderRepo.mockResult = const Failure(
        'Insufficient stock for size L. Only 0 remaining.',
        statusCode: 400,
      );

      final notifier = container.read(checkoutProvider.notifier);
      notifier.initCheckout([
        const CartItemModel(
          id: 'cart-1',
          productId: 'prod-hoodie-1',
          name: 'Legend Hoodie',
          price: 799.0,
          quantity: 1,
          selectedSize: 'L',
        ),
      ]);

      notifier.selectAddress(const AddressModel(
        id: 'addr-valid',
        line1: 'Near Cattle Market',
        city: 'Pithapuram',
        state: 'Andhra Pradesh',
        pincode: '533450',
        phone: '9494038163',
      ));
      notifier.selectPaymentType(PaymentType.cod);

      await notifier.placeOrder();

      final state = container.read(checkoutProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, equals('Insufficient stock for size L. Only 0 remaining.'));
      expect(state.lastOrder, isNull);
    });

    test('Razorpay creation preserves backend failure message rather than generic placeholder', () async {
      mockPaymentRepo.mockCreateResult = const Failure(
        'Product prod-out-of-stock not found',
        statusCode: 404,
      );

      final notifier = container.read(checkoutProvider.notifier);
      notifier.initCheckout([
        const CartItemModel(
          id: 'cart-1',
          productId: 'prod-out-of-stock',
          name: 'Discontinued Item',
          price: 999.0,
          quantity: 1,
        ),
      ]);

      notifier.selectAddress(const AddressModel(
        id: 'addr-valid',
        line1: 'Near Cattle Market',
        city: 'Pithapuram',
        state: 'Andhra Pradesh',
        pincode: '533450',
        phone: '9494038163',
      ));
      notifier.selectPaymentType(PaymentType.razorpay);

      await notifier.placeOrder();

      final state = container.read(checkoutProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, equals('Product prod-out-of-stock not found'));
      expect(state.lastOrder, isNull);
    });
  });

  group('Product Size Stock Selection Tests', () {
    test('ProductDetailsNotifier selects the first size with stock > 0', () async {
      final mockRepo = MockProductRepository();
      mockRepo.mockProduct = const ProductModel(
        id: 'prod-jacket-1',
        name: 'Winter Bomber',
        slug: 'winter-bomber',
        price: 1999.0,
        stock: 5,
        sizes: ['S', 'M', 'L'],
        sizeStock: {'S': 0, 'M': 5, 'L': 2}, // S is out of stock, M has 5
      );

      final container = ProviderContainer(
        overrides: [
          productRepositoryProvider.overrideWithValue(mockRepo),
          authProvider.overrideWith(MockAuthNotifier.new),
        ],
      );

      // Read notifier
      final notifier = container.read(productDetailsProvider('prod-jacket-1').notifier);
      await notifier.loadProductDetails();

      final state = container.read(productDetailsProvider('prod-jacket-1'));
      // M should be selected because S is 0 stock
      expect(state.selectedSize, equals('M'));

      container.dispose();
    });
  });
}
