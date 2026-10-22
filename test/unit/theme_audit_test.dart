import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dripzoid_v2/core/theme/app_theme.dart';
import 'package:dripzoid_v2/core/models/result.dart';
import 'package:dripzoid_v2/features/address/data/models/address_model.dart';
import 'package:dripzoid_v2/features/products/data/models/product_model.dart';
import 'package:dripzoid_v2/features/products/data/models/review_model.dart';
import 'package:dripzoid_v2/features/products/data/models/question_model.dart';
import 'package:dripzoid_v2/features/products/data/models/review_eligibility_model.dart';
import 'package:dripzoid_v2/features/products/presentation/screens/product_details_screen.dart';
import 'package:dripzoid_v2/features/products/data/repositories/product_repository.dart';
import 'package:dripzoid_v2/features/products/presentation/providers/product_providers.dart';
import 'package:dripzoid_v2/features/orders/presentation/screens/order_details_screen.dart';
import 'package:dripzoid_v2/features/orders/data/models/order_model.dart';
import 'package:dripzoid_v2/features/orders/data/models/shipment_model.dart';
import 'package:dripzoid_v2/features/orders/data/repositories/order_repository.dart';
import 'package:dripzoid_v2/features/checkout/presentation/providers/checkout_notifier.dart';

class FakeProductRepository implements ProductRepository {
  final ProductModel product;
  FakeProductRepository(this.product);

  @override
  Future<Result<ProductModel>> getProductById(String id) async => Success(product);

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

class FakeOrderRepository implements OrderRepository {
  final OrderModel order;
  final ShipmentModel? shipment;
  FakeOrderRepository(this.order, [this.shipment]);

  @override
  Future<Result<OrderModel>> getOrderDetails(String orderId) async => Success(order);

  @override
  Future<Result<ShipmentModel>> trackOrder(String orderId) async =>
      shipment != null ? Success(shipment!) : Failure('No tracking');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testProduct = ProductModel(
    id: 'prod_1',
    name: 'Oversized Vintage Acid Wash Tee',
    slug: 'oversized-vintage-acid-wash-tee',
    price: 999.0,
    originalPrice: 1499.0,
    rating: 4.5,
    stock: 10,
    description: 'High quality cotton tee with drop shoulders.',
    colors: ['Vintage Black', 'Faded Grey'],
    sizes: ['S', 'M', 'L', 'XL'],
    category: 'Men',
    subcategory: 'T-Shirts',
  );

  final testOrder = OrderModel(
    id: 'ord_123',
    orderNumber: 'DRP-2026-9999',
    totalAmount: 1998.0,
    status: 'In Transit',
    paymentMethod: 'Prepaid (UPI)',
    createdAt: DateTime(2026, 10, 15, 10, 30),
    deliveryDate: DateTime(2026, 10, 22),
    items: [
      const OrderItemModel(
        id: 'item_1',
        productName: 'Oversized Vintage Acid Wash Tee',
        quantity: 2,
        price: 999.0,
        unitPrice: 999.0,
        options: {'size': 'L', 'color': 'Vintage Black'},
      ),
    ],
    address: const AddressModel(
      name: 'John Doe',
      line1: '123 Fashion Street, Suite 4',
      city: 'Bangalore',
      state: 'Karnataka',
      pincode: '560001',
      phone: '+91 9876543210',
    ),
  );

  final testShipment = ShipmentModel(
    currentStatus: 'In Transit',
    activities: [
      TrackingActivityModel(
        status: 'In Transit',
        description: 'Package departed fulfillment center',
        location: 'Bangalore Hub',
        timestamp: DateTime(2026, 10, 16, 14, 0),
      ),
      TrackingActivityModel(
        status: 'Order Placed',
        description: 'Order confirmed and verified',
        location: 'Merchant Facility',
        timestamp: DateTime(2026, 10, 15, 10, 35),
      ),
    ],
  );

  group('ProductDetailsScreen Theme Compatibility', () {
    testWidgets('renders cleanly in Light Theme without exceptions', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productRepositoryProvider.overrideWithValue(FakeProductRepository(testProduct)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ProductDetailsScreen(productId: 'prod_1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Oversized Vintage Acid Wash Tee'), findsAtLeast(1));
      expect(find.text('₹999'), findsOneWidget);
      expect(find.text('₹1499'), findsOneWidget);
      expect(find.text('Add to Cart'), findsOneWidget);
      expect(find.text('Buy Now'), findsOneWidget);
    });

    testWidgets('renders cleanly in Dark Theme without exceptions', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productRepositoryProvider.overrideWithValue(FakeProductRepository(testProduct)),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const ProductDetailsScreen(productId: 'prod_1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Oversized Vintage Acid Wash Tee'), findsAtLeast(1));
      expect(find.text('₹999'), findsOneWidget);
      expect(find.text('₹1499'), findsOneWidget);
      expect(find.text('Add to Cart'), findsOneWidget);
      expect(find.text('Buy Now'), findsOneWidget);
    });
  });

  group('OrderDetailsScreen Theme Compatibility', () {
    testWidgets('renders cleanly in Light Theme without exceptions', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderRepositoryProvider.overrideWithValue(FakeOrderRepository(testOrder, testShipment)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const OrderDetailsScreen(orderId: 'ord_123'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Order Details'), findsAtLeast(1));
      expect(find.text('Delivery Address'), findsOneWidget);
      expect(find.text('Payment Summary'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('+91 9876543210'), findsOneWidget);
    });

    testWidgets('renders cleanly in Dark Theme without exceptions', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderRepositoryProvider.overrideWithValue(FakeOrderRepository(testOrder, testShipment)),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const OrderDetailsScreen(orderId: 'ord_123'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Order Details'), findsAtLeast(1));
      expect(find.text('Delivery Address'), findsOneWidget);
      expect(find.text('Payment Summary'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('+91 9876543210'), findsOneWidget);
    });
  });
}
