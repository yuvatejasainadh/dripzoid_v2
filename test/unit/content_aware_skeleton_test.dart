import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dripzoid_v2/core/models/result.dart';
import 'package:dripzoid_v2/core/theme/app_theme.dart';
import 'package:dripzoid_v2/features/address/data/models/address_model.dart';
import 'package:dripzoid_v2/features/checkout/presentation/providers/checkout_notifier.dart';
import 'package:dripzoid_v2/features/home/data/repositories/home_repository.dart';
import 'package:dripzoid_v2/features/home/presentation/providers/home_notifier.dart';
import 'package:dripzoid_v2/features/home/presentation/providers/search_notifier.dart';
import 'package:dripzoid_v2/features/home/presentation/widgets/search_results_view.dart';
import 'package:dripzoid_v2/features/orders/data/models/order_model.dart';
import 'package:dripzoid_v2/features/orders/data/models/shipment_model.dart';
import 'package:dripzoid_v2/features/orders/data/repositories/order_repository.dart';
import 'package:dripzoid_v2/features/orders/presentation/screens/order_details_screen.dart';
import 'package:dripzoid_v2/features/products/data/models/product_model.dart';
import 'package:dripzoid_v2/features/products/data/models/question_model.dart';
import 'package:dripzoid_v2/features/products/data/models/review_eligibility_model.dart';
import 'package:dripzoid_v2/features/products/data/models/review_model.dart';
import 'package:dripzoid_v2/features/products/data/repositories/product_repository.dart';
import 'package:dripzoid_v2/features/products/presentation/providers/product_providers.dart';
import 'package:dripzoid_v2/features/products/presentation/screens/product_details_screen.dart';
import 'package:dripzoid_v2/features/products/presentation/screens/shop_screen.dart';
import 'package:dripzoid_v2/shared/widgets/product_card.dart';
import 'package:dripzoid_v2/shared/widgets/shimmer_loading.dart';

class DelayedProductRepository implements ProductRepository {
  final ProductModel product;
  final bool delay;
  final String? error;

  DelayedProductRepository(this.product, {this.delay = false, this.error});

  @override
  Future<Result<ProductModel>> getProductById(String id) async {
    if (delay) await Future.delayed(const Duration(milliseconds: 100));
    if (error != null) return Failure(error!);
    return Success(product);
  }

  @override
  Future<Result<List<ProductModel>>> getProducts({Map<String, dynamic>? queryParameters}) async {
    if (delay) await Future.delayed(const Duration(milliseconds: 100));
    if (error != null) return Failure(error!);
    return Success([product]);
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

class DelayedOrderRepository implements OrderRepository {
  final OrderModel order;
  final bool delay;
  final String? error;
  int loadCalls = 0;

  DelayedOrderRepository(this.order, {this.delay = false, this.error});

  @override
  Future<Result<OrderModel>> getOrderDetails(String orderId) async {
    loadCalls++;
    if (delay) await Future.delayed(const Duration(milliseconds: 100));
    if (error != null) return Failure(error!);
    return Success(order);
  }

  @override
  Future<Result<List<OrderModel>>> getUserOrders() async {
    if (delay) await Future.delayed(const Duration(milliseconds: 100));
    if (error != null) return Failure(error!);
    return Success([order]);
  }

  @override
  Future<Result<ShipmentModel>> trackOrder(String orderId) async =>
      const Failure('No tracking data');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHomeRepository implements HomeRepository {
  final List<ProductModel> results;
  final bool delay;
  final String? error;

  FakeHomeRepository({this.results = const [], this.delay = false, this.error});

  @override
  Future<Result<List<ProductModel>>> searchProducts(String query) async {
    if (delay) await Future.delayed(const Duration(milliseconds: 100));
    if (error != null) return Failure(error!);
    return Success(results);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testProduct = ProductModel(
    id: 'prod_101',
    name: 'Dripzoid Heavyweight Acid Wash Hoodie',
    slug: 'dripzoid-heavyweight-acid-wash-hoodie',
    price: 1299.0,
    originalPrice: 1999.0,
    rating: 4.8,
    stock: 8,
    description: 'Heavyweight custom combed fleece hoodie.',
    colors: ['Jet Black', 'Heather Grey'],
    sizes: ['M', 'L', 'XL'],
    category: 'Men',
    subcategory: 'Hoodies',
    images: ['https://example.com/hoodie_1.jpg'],
  );

  final testOrder = OrderModel(
    id: 'ord_9001',
    orderNumber: 'DRP-9001-XYZ',
    totalAmount: 2598.0,
    status: 'Confirmed',
    paymentMethod: 'Prepaid (UPI)',
    createdAt: DateTime(2026, 10, 20, 14, 0),
    deliveryDate: DateTime(2026, 10, 26),
    items: [
      const OrderItemModel(
        id: 'item_101',
        productName: 'Dripzoid Heavyweight Acid Wash Hoodie',
        quantity: 2,
        price: 1299.0,
        unitPrice: 1299.0,
        options: {'size': 'L', 'color': 'Jet Black'},
      ),
    ],
    address: AddressModel(
      name: 'Alex Rivera',
      line1: '42 Cyberpunk Boulevard',
      city: 'Bangalore',
      state: 'Karnataka',
      pincode: '560001',
      phone: '+91 9988776655',
    ),
  );

  group('Content-Aware Skeleton UI Sprint Tests', () {
    testWidgets('1. ProductDetailsSkeleton renders all major structural placeholders', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const ProductDetailsSkeleton(),
        ),
      );

      // Verify BackButton is present for quick navigation
      expect(find.byType(BackButton), findsOneWidget);

      // Verify Shimmer base widgets render for gallery, title, selectors
      expect(find.byType(ShimmerWidget), findsWidgets);
      expect(find.byType(SkeletonLine), findsWidgets);
      expect(find.byType(SkeletonCircle), findsWidgets);
      expect(find.byType(SkeletonBox), findsWidgets);

      // Verify bottom purchase bar has two disabled action skeleton buttons
      expect(find.byType(SkeletonButton), findsNWidgets(2));
    });

    testWidgets('2. ProductDetailsScreen transitions smoothly from skeleton to real product', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = DelayedProductRepository(testProduct, delay: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productRepositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const ProductDetailsScreen(productId: 'prod_101'),
          ),
        ),
      );

      // Step 1: Initial loading state must show ProductDetailsSkeleton
      await tester.pump();
      expect(find.byType(ProductDetailsSkeleton), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(find.text('Dripzoid Heavyweight Acid Wash Hoodie'), findsNothing);

      // Step 2: Once repository resolves, skeleton must transition cleanly to real content
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ProductDetailsSkeleton), findsNothing);
      expect(find.text('Dripzoid Heavyweight Acid Wash Hoodie'), findsAtLeast(1));
      expect(find.text('₹1299'), findsAtLeast(1));
      expect(find.text('Add to Cart'), findsOneWidget);
    });

    testWidgets('3. ProductCardSkeleton accurately mirrors grid card layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 340,
                child: ProductCardSkeleton(mode: ProductCardSkeletonMode.grid),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ProductCardSkeleton), findsOneWidget);
      expect(find.byType(AspectRatio), findsOneWidget);
      expect(find.byType(SkeletonCircle), findsWidgets);
      expect(find.byType(SkeletonLine), findsWidgets);
    });

    testWidgets('4. ProductGridSkeleton renders responsive column counts', (tester) async {
      // Test mobile phone viewport (< 600px width)
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: ProductGridSkeleton(itemCount: 4),
          ),
        ),
      );

      expect(find.byType(ProductCardSkeleton), findsNWidgets(4));
    });

    testWidgets('5. ShopScreen displays ProductGridSkeleton during initial loading', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = DelayedProductRepository(testProduct, delay: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productRepositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const ShopScreen(),
          ),
        ),
      );

      // Loading grid must show ProductGridSkeleton
      await tester.pump();
      expect(find.byType(ProductGridSkeleton), findsOneWidget);
      expect(find.byType(ProductCardSkeleton), findsWidgets);

      // Once resolved, real products display
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ProductGridSkeleton), findsNothing);
      expect(find.byType(ProductCard), findsOneWidget);
    });

    testWidgets('6. SearchResultsView displays SliverProductGridSkeleton during search query loading', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final homeRepo = FakeHomeRepository(results: [testProduct], delay: true);
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(homeRepo),
        ],
      );
      addTearDown(container.dispose);

      container.read(searchProvider.notifier).submitQuery('hoodie');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: SearchResultsView(),
            ),
          ),
        ),
      );

      // During search loading, SliverProductGridSkeleton is visible
      await tester.pump();
      expect(find.byType(SliverProductGridSkeleton), findsOneWidget);
      expect(find.byType(ProductCardSkeleton), findsWidgets);

      // When resolved, results render
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SliverProductGridSkeleton), findsNothing);
      expect(find.byType(ProductCard), findsOneWidget);
    });

    testWidgets('7. OrderDetailsSkeleton mirrors full order details layout without fake data', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: OrderDetailsSkeleton(),
          ),
        ),
      );

      // Order status hero skeleton
      expect(find.byType(OrderStatusHeroSkeleton), findsOneWidget);
      // Order info card skeleton
      expect(find.byType(OrderInfoCardSkeleton), findsOneWidget);
      // Multiple order items skeleton
      expect(find.byType(OrderItemTileSkeleton), findsAtLeast(2));
      // Action button placeholders
      expect(find.byType(SkeletonButton), findsNWidgets(2));

      // Must never display misleading or fake monetary strings
      expect(find.text('₹1999'), findsNothing);
      expect(find.text('₹0'), findsNothing);
      expect(find.text('DRP-'), findsNothing);
    });

    testWidgets('8. OrderDetailsScreen displays skeleton during loading and recovers on success', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final orderRepo = DelayedOrderRepository(testOrder, delay: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderRepositoryProvider.overrideWithValue(orderRepo),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const OrderDetailsScreen(orderId: 'ord_9001'),
          ),
        ),
      );

      // Initial loading state displays OrderDetailsSkeleton
      await tester.pump();
      expect(find.byType(OrderDetailsSkeleton), findsOneWidget);
      expect(find.text('Order Details'), findsOneWidget);
      expect(find.text('DRP-9001-XYZ'), findsNothing);

      // Once resolved, real content appears
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(OrderDetailsSkeleton), findsNothing);
      expect(find.text('#DRP-9001-XYZ'), findsOneWidget);
      expect(find.text('Alex Rivera'), findsOneWidget);
      expect(find.text('₹2598'), findsAtLeast(1));
    });

    testWidgets('9. OrderDetailsScreen displays actionable Retry button on failure', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final orderRepo = DelayedOrderRepository(testOrder, error: 'Connection timed out');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderRepositoryProvider.overrideWithValue(orderRepo),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const OrderDetailsScreen(orderId: 'ord_9001'),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Unable to load order'), findsOneWidget);
      expect(find.text('Connection timed out'), findsOneWidget);
      final retryButton = find.widgetWithText(ElevatedButton, 'Retry');
      expect(retryButton, findsOneWidget);

      // Tapping retry calls loadOrderDetails again
      await tester.tap(retryButton);
      await tester.pump();
      expect(orderRepo.loadCalls, greaterThanOrEqualTo(2));
    });

    testWidgets('10. Skeletons respect reduced-motion accessibility preference', (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 200,
                  height: 320,
                  child: ProductCardSkeleton(),
                ),
              ),
            ),
          ),
        ),
      );

      // ShimmerWidget renders without creating an active animation controller when animations are disabled
      expect(find.byType(ShimmerWidget), findsWidgets);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('11. Skeletons render cleanly in Light and Dark themes', (tester) async {
      // Light theme
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ProductCardSkeleton(),
                  SizedBox(height: 16),
                  OrderHistoryCardSkeleton(),
                ],
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);

      // Dark theme
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ProductCardSkeleton(),
                  SizedBox(height: 16),
                  OrderHistoryCardSkeleton(),
                ],
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
