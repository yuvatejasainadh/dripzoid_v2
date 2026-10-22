import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dripzoid_v2/core/models/result.dart';
import 'package:dripzoid_v2/features/cart/data/models/cart_item_model.dart';
import 'package:dripzoid_v2/features/cart/data/repositories/cart_repository.dart';
import 'package:dripzoid_v2/features/cart/presentation/providers/cart_notifier.dart';

class FakeCartRepository implements CartRepository {
  Result<List<CartItemModel>>? mockGetCartResult;
  Result<void>? mockAddResult;
  Result<void>? mockUpdateResult;
  Result<void>? mockDeleteResult;
  Result<void>? mockClearResult;

  int getCartCalls = 0;
  int addCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;
  int clearCalls = 0;
  Duration? delay;

  @override
  Future<Result<List<CartItemModel>>> getCart() async {
    getCartCalls++;
    if (delay != null) await Future.delayed(delay!);
    return mockGetCartResult ?? const Success<List<CartItemModel>>([]);
  }

  @override
  Future<Result<void>> addToCart({
    required String productId,
    required int quantity,
    String? selectedSize,
    String? selectedColor,
  }) async {
    addCalls++;
    if (delay != null) await Future.delayed(delay!);
    return mockAddResult ?? const Success<void>(null);
  }

  @override
  Future<Result<void>> updateCartItem({
    required String cartId,
    required int quantity,
  }) async {
    updateCalls++;
    if (delay != null) await Future.delayed(delay!);
    return mockUpdateResult ?? const Success<void>(null);
  }

  @override
  Future<Result<void>> deleteCartItem(String cartId) async {
    deleteCalls++;
    if (delay != null) await Future.delayed(delay!);
    return mockDeleteResult ?? const Success<void>(null);
  }

  @override
  Future<Result<void>> clearCart() async {
    clearCalls++;
    if (delay != null) await Future.delayed(delay!);
    return mockClearResult ?? const Success<void>(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('CartState Calculations & Validation', () {
    test('subtotal and totalItems compute correctly with numeric precision', () {
      const items = [
        CartItemModel(
          id: 'cart-1',
          productId: 'prod-1',
          name: 'Classic Tee',
          price: 499.0,
          quantity: 2,
        ),
        CartItemModel(
          id: 'cart-2',
          productId: 'prod-2',
          name: 'Cargo Shorts',
          price: 1250.50,
          quantity: 1,
        ),
      ];

      const state = CartState(items: items);

      expect(state.totalItems, 3);
      expect(state.subtotal, (499.0 * 2) + 1250.50);
      expect(state.isInCart('prod-1', null, null), true);
      expect(state.isInCart('prod-nonexistent', null, null), false);
    });
  });

  group('CartNotifier Lifecycle, Concurrency & Error Safeguards', () {
    late FakeCartRepository fakeRepository;
    late ProviderContainer container;

    setUp(() {
      fakeRepository = FakeCartRepository();
      container = ProviderContainer(
        overrides: [
          cartRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('fetchCart populates items and clears previous error on success', () async {
      fakeRepository.mockGetCartResult = const Success<List<CartItemModel>>([
        CartItemModel(
          id: 'c-1',
          productId: 'p-1',
          name: 'Item 1',
          price: 999.0,
          quantity: 1,
        )
      ]);

      final notifier = container.read(cartProvider.notifier);
      await notifier.fetchCart();

      final state = container.read(cartProvider);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
      expect(state.items.length, 1);
      expect(state.totalItems, 1);
      expect(state.subtotal, 999.0);
    });

    test('fetchCart captures failure and sets errorMessage without crashing', () async {
      fakeRepository.mockGetCartResult = const Failure('Backend timeout', statusCode: 504);

      final notifier = container.read(cartProvider.notifier);
      await notifier.fetchCart();

      final state = container.read(cartProvider);
      expect(state.isLoading, false);
      expect(state.errorMessage, 'Backend timeout');
      expect(state.items, isEmpty);
    });

    test('addToCart rejects zero or negative quantities without making network request', () async {
      final notifier = container.read(cartProvider.notifier);

      final zeroResult = await notifier.addToCart(productId: 'prod-1', quantity: 0);
      final negResult = await notifier.addToCart(productId: 'prod-1', quantity: -2);

      expect(zeroResult, false);
      expect(negResult, false);
      expect(fakeRepository.addCalls, 0);
    });

    test('addToCart guards against duplicate concurrent calls for identical product/variant', () async {
      fakeRepository.delay = const Duration(milliseconds: 50);

      final notifier = container.read(cartProvider.notifier);

      // Fire 2 concurrent add requests for identical product, size, and color
      final call1 = notifier.addToCart(productId: 'p-uniq', quantity: 1, size: 'M', color: 'Black');
      final call2 = notifier.addToCart(productId: 'p-uniq', quantity: 1, size: 'M', color: 'Black');

      final results = await Future.wait([call1, call2]);

      // One call must be processed and the duplicate dropped
      expect(results.contains(true), true);
      expect(results.contains(false), true);
      expect(fakeRepository.addCalls, 1);
    });

    test('updateQuantity rejects quantity < 1 by triggering removeFromCart', () async {
      final notifier = container.read(cartProvider.notifier);

      await notifier.updateQuantity('cart-item-123', 0);

      expect(fakeRepository.deleteCalls, 1);
      expect(fakeRepository.updateCalls, 0);
    });

    test('updateQuantity guards against concurrent duplicate calls for the same cartId', () async {
      fakeRepository.delay = const Duration(milliseconds: 50);

      final notifier = container.read(cartProvider.notifier);

      final call1 = notifier.updateQuantity('cart-dup-item', 2);
      final call2 = notifier.updateQuantity('cart-dup-item', 3);

      await Future.wait([call1, call2]);

      expect(fakeRepository.updateCalls, 1);
    });

    test('removeFromCart guards against concurrent duplicate deletions for the same cartId', () async {
      fakeRepository.delay = const Duration(milliseconds: 50);

      final notifier = container.read(cartProvider.notifier);

      final call1 = notifier.removeFromCart('cart-del-item');
      final call2 = notifier.removeFromCart('cart-del-item');

      await Future.wait([call1, call2]);

      expect(fakeRepository.deleteCalls, 1);
    });

    test('clearCart empties cart items on success', () async {
      fakeRepository.mockGetCartResult = const Success<List<CartItemModel>>([
        CartItemModel(
          id: 'c-1',
          productId: 'p-1',
          name: 'Item 1',
          price: 500.0,
          quantity: 2,
        )
      ]);

      final notifier = container.read(cartProvider.notifier);
      await notifier.fetchCart();
      expect(container.read(cartProvider).items.length, 1);

      await notifier.clearCart();

      final state = container.read(cartProvider);
      expect(state.items, isEmpty);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
    });

    test('reset clears all cart items and pending states', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.reset();

      final state = container.read(cartProvider);
      expect(state.items, isEmpty);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
    });
  });
}
