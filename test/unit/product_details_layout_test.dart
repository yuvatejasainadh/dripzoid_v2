import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dripzoid_v2/core/theme/app_theme.dart';
import 'package:dripzoid_v2/core/models/result.dart';
import 'package:dripzoid_v2/features/products/data/models/product_model.dart';
import 'package:dripzoid_v2/features/products/data/models/review_model.dart';
import 'package:dripzoid_v2/features/products/data/models/question_model.dart';
import 'package:dripzoid_v2/features/products/data/models/review_eligibility_model.dart';
import 'package:dripzoid_v2/features/products/presentation/screens/product_details_screen.dart';
import 'package:dripzoid_v2/features/products/data/repositories/product_repository.dart';
import 'package:dripzoid_v2/features/products/presentation/providers/product_providers.dart';
import 'package:dripzoid_v2/features/products/presentation/widgets/product_purchase_bar.dart';
import 'package:dripzoid_v2/shared/widgets/shimmer_loading.dart';

class MockProductRepository implements ProductRepository {
  final ProductModel? product;
  final String? error;
  final bool delay;

  MockProductRepository({this.product, this.error, this.delay = false});

  @override
  Future<Result<ProductModel>> getProductById(String id) async {
    if (delay) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    if (error != null) return Failure(error!);
    if (product != null) return Success(product!);
    return const Failure('Not found');
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

  final validProduct = ProductModel(
    id: 'prod_1',
    name: 'Oversized Vintage Acid Wash Tee',
    slug: 'oversized-vintage-acid-wash-tee',
    price: 999.0,
    originalPrice: 1499.0,
    rating: 4.5,
    stock: 10,
    description: 'High quality cotton tee with drop shoulders and premium wash.',
    colors: ['Vintage Black', 'Faded Grey'],
    sizes: ['S', 'M', 'L', 'XL'],
    category: 'Men',
    subcategory: 'T-Shirts',
    images: [],
  );

  final longContentProduct = ProductModel(
    id: 'prod_2',
    name: 'Ultra Premium Extreme Heavyweight Oversized Limited Edition Luxury Streetwear Hoodie with Hand-Embroidered Aesthetic Typography and Distressed Wash',
    slug: 'ultra-premium-hoodie',
    price: 3499.0,
    originalPrice: 5999.0,
    rating: 4.9,
    stock: 3,
    description: 'A' * 2000,
    colors: ['Jet Black', 'Off White', 'Washed Olive', 'Slate Gray', 'Oxblood Red'],
    sizes: ['XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL'],
    category: 'Streetwear',
    subcategory: 'Heavyweight Hoodies',
    images: [],
  );

  group('ProductDetailsScreen Layout & Rendering Tests', () {
    testWidgets('1. Renders main content and purchase bar is at the bottom', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productRepositoryProvider.overrideWithValue(MockProductRepository(product: validProduct)),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const ProductDetailsScreen(productId: 'prod_1'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Main content elements are rendered
      expect(find.text('Oversized Vintage Acid Wash Tee'), findsAtLeast(1));
      expect(find.text('₹999'), findsOneWidget);
      expect(find.text('₹1499'), findsOneWidget);
      expect(find.text('33% OFF'), findsOneWidget);
      expect(find.text('Select Color'), findsOneWidget);
      expect(find.text('Select Size'), findsOneWidget);
      expect(find.text('Quantity'), findsOneWidget);

      // Verify purchase bar is located at the bottom of the screen, NOT at the top
      final purchaseBarFinder = find.byType(ProductPurchaseBar);
      expect(purchaseBarFinder, findsOneWidget);

      final barTopY = tester.getTopLeft(purchaseBarFinder).dy;
      final screenHeight = 2400 / 2.0; // 1200 logical height
      // The bar should be positioned near the bottom (dy > 1000), never near dy == 0
      expect(barTopY, greaterThan(screenHeight - 200));

      // Buttons are visible and responsive
      expect(find.text('Add to Cart'), findsOneWidget);
      expect(find.text('Buy Now'), findsOneWidget);
    });

    testWidgets('2. Purchase bar stays at bottom in Light Theme', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productRepositoryProvider.overrideWithValue(MockProductRepository(product: validProduct)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ProductDetailsScreen(productId: 'prod_1'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final purchaseBarFinder = find.byType(ProductPurchaseBar);
      expect(purchaseBarFinder, findsOneWidget);

      final barTopY = tester.getTopLeft(purchaseBarFinder).dy;
      expect(barTopY, greaterThan(1000));
    });

    testWidgets('3. Loading state displays loading indicator and BackButton', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productRepositoryProvider.overrideWithValue(MockProductRepository(product: validProduct, delay: true)),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const ProductDetailsScreen(productId: 'prod_1'),
          ),
        ),
      );

      // During loading
      await tester.pump();
      expect(find.byType(ProductDetailsSkeleton), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(ProductDetailsSkeleton), findsNothing);
      expect(find.text('Oversized Vintage Acid Wash Tee'), findsAtLeast(1));
    });

    testWidgets('4. Error state displays clear message and retry action', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productRepositoryProvider.overrideWithValue(MockProductRepository(error: 'Network connection lost')),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const ProductDetailsScreen(productId: 'prod_1'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Failed to load product details'), findsOneWidget);
      expect(find.text('Network connection lost'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('5. Long product titles and massive descriptions render without overflow', (tester) async {
      tester.view.physicalSize = const Size(720, 1280);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      dynamic caught;
      final prevHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        caught = details;
      };

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productRepositoryProvider.overrideWithValue(MockProductRepository(product: longContentProduct)),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const ProductDetailsScreen(productId: 'prod_2'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      FlutterError.onError = prevHandler;
      expect(caught, isNull);
      expect(find.byType(ProductPurchaseBar), findsOneWidget);
    });

    testWidgets('6. Screen remains functional during provider updates and disposes cleanly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productRepositoryProvider.overrideWithValue(MockProductRepository(product: validProduct)),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const ProductDetailsScreen(productId: 'prod_1'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap on color picker
      final fadedGreyFinder = find.text('Faded Grey');
      if (fadedGreyFinder.evaluate().isNotEmpty) {
        await tester.tap(fadedGreyFinder);
        await tester.pump();
      }

      // Tap on size picker
      final sizeLFinder = find.text('L');
      if (sizeLFinder.evaluate().isNotEmpty) {
        await tester.tap(sizeLFinder.first);
        await tester.pump();
      }

      // Navigate away / unmount screen cleanly
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('Navigated away')),
        ),
      );
      await tester.pump();

      expect(find.text('Navigated away'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
