import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dripzoid_v2/core/models/result.dart';
import 'package:dripzoid_v2/features/wishlist/data/models/wishlist_item_model.dart';
import 'package:dripzoid_v2/features/wishlist/data/repositories/wishlist_repository.dart';
import 'package:dripzoid_v2/features/wishlist/data/services/wishlist_service.dart';
import 'package:dripzoid_v2/features/wishlist/presentation/providers/wishlist_notifier.dart';
import 'package:dripzoid_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:dripzoid_v2/features/auth/data/repositories/auth_repository.dart';
import 'package:dripzoid_v2/features/auth/data/services/google_auth_service.dart';
import 'package:dripzoid_v2/core/network/token_storage.dart';
import 'package:dripzoid_v2/features/auth/presentation/providers/google_provider.dart';

class FakeWishlistService implements WishlistService {
  Result<dynamic>? mockGetWishlistResult;
  Result<Map<String, dynamic>>? mockAddResult;
  Result<Map<String, dynamic>>? mockRemoveResult;
  Result<Map<String, dynamic>>? mockMoveResult;

  int getWishlistCalls = 0;
  int addCalls = 0;
  int removeCalls = 0;
  Duration? delay;

  @override
  Future<Result<dynamic>> getWishlist() async {
    getWishlistCalls++;
    if (delay != null) await Future.delayed(delay!);
    return mockGetWishlistResult ?? const Success<dynamic>([]);
  }

  @override
  Future<Result<Map<String, dynamic>>> addToWishlist(String productId) async {
    addCalls++;
    if (delay != null) await Future.delayed(delay!);
    return mockAddResult ?? const Success(<String, dynamic>{});
  }

  @override
  Future<Result<Map<String, dynamic>>> removeFromWishlist(String productId) async {
    removeCalls++;
    if (delay != null) await Future.delayed(delay!);
    return mockRemoveResult ?? const Success(<String, dynamic>{});
  }

  @override
  Future<Result<Map<String, dynamic>>> moveToCart(List<String> productIds) async {
    if (delay != null) await Future.delayed(delay!);
    return mockMoveResult ?? const Success(<String, dynamic>{});
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthRepository implements AuthRepository {
  int logoutCalls = 0;

  @override
  Future<Result<void>> logout() async {
    logoutCalls++;
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeGoogleAuthService implements GoogleAuthService {
  @override
  Future<void> signOut() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeTokenStorage implements TokenStorage {
  @override
  Future<void> clearToken() async {}

  @override
  Future<String?> getToken() async => 'fake-token';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('WishlistItemModel Deserialization & Normalization', () {
    test('parses nested product payload correctly', () {
      final json = {
        'id': 'wish-1',
        'product': {
          '_id': 'prod-99',
          'name': 'Oversized Street Hoodie',
          'price': '1499.50',
          'images': ['https://example.com/img1.png', 'https://example.com/img2.png'],
        },
      };

      final item = WishlistItemModel.fromJson(json);

      expect(item.id, 'wish-1');
      expect(item.productId, 'prod-99');
      expect(item.name, 'Oversized Street Hoodie');
      expect(item.price, 1499.50);
      expect(item.images.length, 2);
      expect(item.images.first, 'https://example.com/img1.png');
    });

    test('parses flat payload with alternate key names and string price', () {
      final json = {
        '_id': 'wish-2',
        'productId': 'prod-102',
        'title': 'Graphic T-Shirt',
        'price': 799,
        'images': null,
      };

      final item = WishlistItemModel.fromJson(json);

      expect(item.id, 'wish-2');
      expect(item.productId, 'prod-102');
      expect(item.name, 'Graphic T-Shirt');
      expect(item.price, 799.0);
      expect(item.images, isEmpty);
    });

    test('falls back safely on missing name and product ID', () {
      final json = {
        'id': 'wish-fallback',
        'price': null,
      };

      final item = WishlistItemModel.fromJson(json);

      expect(item.id, 'wish-fallback');
      expect(item.productId, 'wish-fallback');
      expect(item.name, 'Product');
      expect(item.price, 0.0);
      expect(item.images, isEmpty);
    });
  });

  group('WishlistRepository Multi-Envelope & Fault Tolerance', () {
    late FakeWishlistService fakeService;
    late WishlistRepository repository;

    setUp(() {
      fakeService = FakeWishlistService();
      repository = WishlistRepository(fakeService);
    });

    test('unpacks { "wishlist": [...] } envelope successfully', () async {
      fakeService.mockGetWishlistResult = Success<dynamic>({
        'wishlist': [
          {
            'id': 'w-1',
            'product_id': 'p-1',
            'name': 'Puff Jacket',
            'price': 2499.0,
            'images': ['img1.png'],
          }
        ]
      });

      final result = await repository.getWishlist();

      expect(result, isA<Success<List<WishlistItemModel>>>());
      final items = (result as Success<List<WishlistItemModel>>).data;
      expect(items.length, 1);
      expect(items.first.productId, 'p-1');
      expect(items.first.name, 'Puff Jacket');
    });

    test('unpacks { "data": [...] } envelope successfully', () async {
      fakeService.mockGetWishlistResult = Success<dynamic>({
        'data': [
          {
            'id': 'w-2',
            'product_id': 'p-2',
            'name': 'Sneakers',
            'price': 3999.0,
          }
        ]
      });

      final result = await repository.getWishlist();

      expect(result, isA<Success<List<WishlistItemModel>>>());
      final items = (result as Success<List<WishlistItemModel>>).data;
      expect(items.length, 1);
      expect(items.first.productId, 'p-2');
    });

    test('gracefully ignores corrupted items without failing entire wishlist', () async {
      fakeService.mockGetWishlistResult = Success<dynamic>([
        {
          'id': 'valid-1',
          'product_id': 'prod-1',
          'name': 'Cargo Pants',
          'price': 1200.0,
        },
        'corrupted-string-entry', // corrupted element
        12345, // corrupted element
        {
          'id': 'valid-2',
          'product_id': 'prod-2',
          'name': 'Beanie Hat',
          'price': 499.0,
        },
      ]);

      final result = await repository.getWishlist();

      expect(result, isA<Success<List<WishlistItemModel>>>());
      final items = (result as Success<List<WishlistItemModel>>).data;
      expect(items.length, 2);
      expect(items[0].productId, 'prod-1');
      expect(items[1].productId, 'prod-2');
    });

    test('propagates service failure', () async {
      fakeService.mockGetWishlistResult = const Failure('500 Server Error', statusCode: 500);

      final result = await repository.getWishlist();

      expect(result, isA<Failure<List<WishlistItemModel>>>());
      expect((result as Failure<List<WishlistItemModel>>).message, '500 Server Error');
    });
  });

  group('WishlistNotifier Concurrency, State & Session Cleansing', () {
    late FakeWishlistService fakeService;
    late ProviderContainer container;

    setUp(() {
      fakeService = FakeWishlistService();
      container = ProviderContainer(
        overrides: [
          wishlistServiceProvider.overrideWithValue(fakeService),
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          googleAuthProvider.overrideWithValue(FakeGoogleAuthService()),
          tokenStorageProvider.overrideWithValue(FakeTokenStorage()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('fetchWishlist updates state with items and clears error on success', () async {
      fakeService.mockGetWishlistResult = Success<dynamic>([
        {
          'id': 'w-1',
          'product_id': 'prod-1',
          'name': 'Varsity Jacket',
          'price': 3499.0,
        }
      ]);

      final notifier = container.read(wishlistProvider.notifier);
      await notifier.fetchWishlist();

      final state = container.read(wishlistProvider);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
      expect(state.items.length, 1);
      expect(state.isWishlisted('prod-1'), true);
      expect(state.isWishlisted('prod-nonexistent'), false);
    });

    test('fetchWishlist records error on failure without crashing', () async {
      fakeService.mockGetWishlistResult = const Failure('Network unreachable', statusCode: 503);

      final notifier = container.read(wishlistProvider.notifier);
      await notifier.fetchWishlist();

      final state = container.read(wishlistProvider);
      expect(state.isLoading, false);
      expect(state.errorMessage, 'Network unreachable');
      expect(state.items, isEmpty);
    });

    test('toggleWishlist guards against concurrent duplicate calls for same product', () async {
      fakeService.delay = const Duration(milliseconds: 50);
      fakeService.mockAddResult = const Success(<String, dynamic>{});
      fakeService.mockGetWishlistResult = const Success<dynamic>([]);

      final notifier = container.read(wishlistProvider.notifier);

      // Fire 3 simultaneous toggles for the exact same product
      final future1 = notifier.toggleWishlist('prod-dup');
      final future2 = notifier.toggleWishlist('prod-dup');
      final future3 = notifier.toggleWishlist('prod-dup');

      await Future.wait([future1, future2, future3]);

      // Only the first toggle should have executed; duplicates were discarded by the guard
      expect(fakeService.addCalls, 1);
    });

    test('reset clears items and error message', () async {
      fakeService.mockGetWishlistResult = Success<dynamic>([
        {
          'id': 'w-1',
          'product_id': 'prod-1',
          'name': 'Varsity Jacket',
          'price': 3499.0,
        }
      ]);

      final notifier = container.read(wishlistProvider.notifier);
      await notifier.fetchWishlist();
      expect(container.read(wishlistProvider).items.length, 1);

      notifier.reset();

      final state = container.read(wishlistProvider);
      expect(state.items, isEmpty);
      expect(state.errorMessage, isNull);
      expect(state.isLoading, false);
    });

    test('AuthNotifier logout cleanses wishlist state to prevent session leakage', () async {
      fakeService.mockGetWishlistResult = Success<dynamic>([
        {
          'id': 'w-private',
          'product_id': 'prod-private',
          'name': 'Private Item',
          'price': 1999.0,
        }
      ]);

      final wishlistNotifier = container.read(wishlistProvider.notifier);
      await wishlistNotifier.fetchWishlist();
      expect(container.read(wishlistProvider).items.isNotEmpty, true);

      // Perform auth logout
      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.logout();

      // Verify wishlist state was reset
      final finalWishlist = container.read(wishlistProvider);
      expect(finalWishlist.items, isEmpty);
      expect(finalWishlist.errorMessage, isNull);
    });
  });
}
