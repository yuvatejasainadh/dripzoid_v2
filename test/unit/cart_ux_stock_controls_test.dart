import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dripzoid_v2/core/models/result.dart';
import 'package:dripzoid_v2/features/cart/data/models/cart_item_model.dart';
import 'package:dripzoid_v2/features/cart/data/repositories/cart_repository.dart';
import 'package:dripzoid_v2/features/cart/presentation/providers/cart_notifier.dart';
import 'package:dripzoid_v2/features/cart/presentation/widgets/cart_item_tile.dart';
import 'package:dripzoid_v2/features/products/data/models/product_model.dart';
import 'package:dripzoid_v2/features/products/data/models/review_model.dart';
import 'package:dripzoid_v2/features/products/data/models/question_model.dart';
import 'package:dripzoid_v2/features/products/data/models/review_eligibility_model.dart';
import 'package:dripzoid_v2/features/products/data/repositories/product_repository.dart';
import 'package:dripzoid_v2/features/products/presentation/providers/product_details_notifier.dart';
import 'package:dripzoid_v2/features/products/presentation/providers/product_providers.dart';
import 'package:dripzoid_v2/shared/widgets/selection_pickers.dart';

class MockCartRepository implements CartRepository {
  List<CartItemModel> items = [];
  int updateCalls = 0;
  int deleteCalls = 0;
  bool shouldFailUpdate = false;

  @override
  Future<Result<List<CartItemModel>>> getCart() async {
    return Success(items);
  }

  @override
  Future<Result<Map<String, dynamic>>> addToCart({
    required String productId,
    required int quantity,
    String? selectedSize,
    String? selectedColor,
  }) async {
    return const Success({'id': 'new-item'});
  }

  @override
  Future<Result<Map<String, dynamic>>> updateCartItem({
    required String cartId,
    required int quantity,
  }) async {
    updateCalls++;
    if (shouldFailUpdate) {
      return const Failure('Failed to update cart item', statusCode: 400);
    }
    final index = items.indexWhere((it) => it.id == cartId);
    if (index != -1) {
      items[index] = items[index].copyWith(quantity: quantity);
    }
    return const Success({'updated': true});
  }

  @override
  Future<Result<Map<String, dynamic>>> deleteCartItem(String cartId) async {
    deleteCalls++;
    items.removeWhere((it) => it.id == cartId);
    return const Success({'deleted': true});
  }

  @override
  Future<Result<Map<String, dynamic>>> clearCart() async {
    items.clear();
    return const Success({'cleared': true});
  }
}

class MockProductRepository implements ProductRepository {
  ProductModel? mockProduct;

  @override
  Future<Result<ProductModel>> getProductById(String id) async {
    if (mockProduct != null) return Success(mockProduct!);
    return Failure('Product not found: $id', statusCode: 404);
  }

  @override
  Future<Result<List<ProductModel>>> getProducts({Map<String, dynamic>? queryParameters}) async => const Success([]);

  @override
  Future<Result<List<ProductModel>>> getRelatedProducts(String productId) async => const Success([]);

  @override
  Future<Result<List<ReviewModel>>> getProductReviews(String productId) async => const Success([]);

  @override
  Future<Result<List<QuestionModel>>> getProductQuestions(String productId) async => const Success([]);

  @override
  Future<Result<ReviewEligibilityModel>> verifyPurchase(String productId) async => Success(ReviewEligibilityModel.empty());

  @override
  Future<Result<Map<String, dynamic>>> checkShipping(String pincode) async => const Success({'serviceable': true});

  @override
  Future<Result<Map<String, dynamic>>> submitReview(Map<String, dynamic> reviewData) async => const Success({});
}

void main() {
  group('CartItemTile Clickability & Isolation Tests', () {
    testWidgets('Tapping image or card text triggers onTap callback', (tester) async {
      bool tapped = false;
      const item = CartItemModel(
        id: 'c1',
        productId: 'prod-100',
        name: 'Oversized Hoodie',
        price: 1999.0,
        quantity: 2,
        selectedSize: 'L',
        selectedColor: 'Black',
        stock: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CartItemTile(
              item: item,
              onTap: () => tapped = true,
              onQuantityChanged: (_) {},
              onRemove: () {},
            ),
          ),
        ),
      );

      expect(find.text('Oversized Hoodie'), findsOneWidget);

      // Tap on title
      await tester.tap(find.text('Oversized Hoodie'));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });

    testWidgets('Tapping quantity buttons does NOT trigger card onTap', (tester) async {
      bool cardTapped = false;
      int newQuantity = 0;
      const item = CartItemModel(
        id: 'c1',
        productId: 'prod-100',
        name: 'Oversized Hoodie',
        price: 1999.0,
        quantity: 2,
        stock: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CartItemTile(
              item: item,
              onTap: () => cardTapped = true,
              onQuantityChanged: (q) => newQuantity = q,
              onRemove: () {},
            ),
          ),
        ),
      );

      // Tap the + button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(newQuantity, 3);
      expect(cardTapped, false, reason: 'QuantitySelector tap must not trigger tile navigation');

      // Tap the - button
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      expect(newQuantity, 1);
      expect(cardTapped, false, reason: 'QuantitySelector tap must not trigger tile navigation');
    });

    testWidgets('Tapping delete button calls onRemove and NOT card onTap', (tester) async {
      bool cardTapped = false;
      bool removed = false;
      const item = CartItemModel(
        id: 'c1',
        productId: 'prod-100',
        name: 'Oversized Hoodie',
        price: 1999.0,
        quantity: 2,
        stock: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CartItemTile(
              item: item,
              onTap: () => cardTapped = true,
              onQuantityChanged: (_) {},
              onRemove: () => removed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(removed, true);
      expect(cardTapped, false, reason: 'Delete button tap must not trigger tile navigation');
    });
  });

  group('CartNotifier Optimistic Quantity & Rollback Tests', () {
    late MockCartRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockCartRepository();
      container = ProviderContainer(
        overrides: [
          cartRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('updateQuantity optimistically updates state immediately and bounds to stock', () async {
      mockRepo.items = [
        const CartItemModel(
          id: 'c1',
          productId: 'p1',
          name: 'Shirt',
          price: 1000.0,
          quantity: 2,
          stock: 4,
        ),
      ];

      final notifier = container.read(cartProvider.notifier);
      await notifier.fetchCart();

      expect(container.read(cartProvider).items.first.quantity, 2);

      // Increase quantity to 3 (within stock of 4)
      await notifier.updateQuantity('c1', 3);
      expect(container.read(cartProvider).items.first.quantity, 3);
      expect(mockRepo.updateCalls, 1);

      // Attempt to increase beyond stock of 4 (e.g. 10) -> bounded to 4
      await notifier.updateQuantity('c1', 10);
      expect(container.read(cartProvider).items.first.quantity, 4);
    });

    test('updateQuantity safely rolls back to previous state on API failure', () async {
      mockRepo.items = [
        const CartItemModel(
          id: 'c1',
          productId: 'p1',
          name: 'Shirt',
          price: 1000.0,
          quantity: 2,
          stock: 5,
        ),
      ];

      final notifier = container.read(cartProvider.notifier);
      await notifier.fetchCart();

      // Configure repo failure
      mockRepo.shouldFailUpdate = true;

      await notifier.updateQuantity('c1', 3);

      final state = container.read(cartProvider);
      // Rolled back to 2
      expect(state.items.first.quantity, 2);
      expect(state.errorMessage, contains('Failed to update cart item'));
    });
  });

  group('ProductModel & Stock Resolution Semantics', () {
    test('Resolves stock correctly when sizeStock is actively tracked', () {
      final product = ProductModel.fromJson({
        'id': 'p1',
        'name': 'Active Tracked Tee',
        'price': 999,
        'stock': 15,
        'sizes': ['S', 'M', 'L'],
        'sizeStock': {'S': 0, 'M': 5, 'L': 10},
      });

      expect(product.hasActiveSizeStock, true);
      expect(product.getStockForSize('S'), 0);
      expect(product.getStockForSize('M'), 5);
      expect(product.getStockForSize('L'), 10);
      expect(product.isSizeInStock('S'), false);
      expect(product.isSizeInStock('M'), true);
      expect(product.inStock, true);
    });

    test('Resolves stock correctly when sizeStock is unseeded (all zeros but master stock > 0)', () {
      final product = ProductModel.fromJson({
        'id': 'p2',
        'name': 'Legacy Unseeded Tee',
        'price': 1299,
        'stock': 20,
        'sizes': ['S', 'M', 'L', 'XL'],
        'sizeStock': {'S': 0, 'M': 0, 'L': 0, 'XL': 0},
      });

      // All sizes zero -> not active size stock, falls back to master stock
      expect(product.hasActiveSizeStock, false);
      expect(product.getStockForSize('S'), 20);
      expect(product.getStockForSize('M'), 20);
      expect(product.isSizeInStock('S'), true);
      expect(product.isSizeInStock('M'), true);
      expect(product.inStock, true);
    });

    test('Resolves stock correctly for unsized product', () {
      final product = ProductModel.fromJson({
        'id': 'p3',
        'name': 'Unsized Beanie',
        'price': 499,
        'stock': 7,
      });

      expect(product.hasActiveSizeStock, false);
      expect(product.getStockForSize(null), 7);
      expect(product.inStock, true);
    });
  });

  group('SizePicker Widget Stock-Aware Availability', () {
    testWidgets('SizePicker enables all sizes when sizeStock is unseeded and masterStock > 0', (tester) async {
      String selected = 'M';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizePicker(
              sizes: const ['S', 'M', 'L'],
              sizeStock: const {'S': 0, 'M': 0, 'L': 0},
              masterStock: 10,
              selectedSize: selected,
              onSelected: (s) => selected = s,
            ),
          ),
        ),
      );

      // S should be selectable because masterStock > 0
      await tester.tap(find.text('S'));
      await tester.pumpAndSettle();

      expect(selected, 'S');
    });

    testWidgets('SizePicker disables size with 0 stock when sizeStock is actively tracked', (tester) async {
      String selected = 'M';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizePicker(
              sizes: const ['S', 'M', 'L'],
              sizeStock: const {'S': 0, 'M': 5, 'L': 10},
              masterStock: 15,
              selectedSize: selected,
              onSelected: (s) => selected = s,
            ),
          ),
        ),
      );

      // Tapping S (0 stock) must not change selection
      await tester.tap(find.text('S'));
      await tester.pumpAndSettle();

      expect(selected, 'M', reason: 'Size S has 0 stock in actively tracked sizeStock and must be disabled');

      // Tapping L (10 stock) should succeed
      await tester.tap(find.text('L'));
      await tester.pumpAndSettle();

      expect(selected, 'L');
    });
  });

  group('ProductDetailsNotifier Size Switching & Quantity Clamping', () {
    test('Clamps quantity down when switching to a size with lower stock', () async {
      final mockRepo = MockProductRepository();
      mockRepo.mockProduct = ProductModel.fromJson({
        'id': 'p-test',
        'name': 'Test Cargo',
        'price': 1500,
        'stock': 12,
        'sizes': ['M', 'L'],
        'sizeStock': {'M': 8, 'L': 2},
      });

      final container = ProviderContainer(
        overrides: [
          productRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(productDetailsProvider('p-test').notifier);
      await notifier.loadProductDetails();

      // Start with size M (stock 8) and set quantity to 5
      notifier.selectSize('M');
      notifier.updateQuantity(5);
      expect(container.read(productDetailsProvider('p-test')).quantity, 5);

      // Switch to size L (stock 2) -> quantity must be clamped to 2
      notifier.selectSize('L');
      expect(container.read(productDetailsProvider('p-test')).quantity, 2);
    });
  });
}
