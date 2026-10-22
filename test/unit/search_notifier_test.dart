import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dripzoid_v2/core/models/result.dart';
import 'package:dripzoid_v2/features/home/data/models/banner_model.dart';
import 'package:dripzoid_v2/features/home/data/models/category_model.dart';
import 'package:dripzoid_v2/features/home/data/repositories/home_repository.dart';
import 'package:dripzoid_v2/features/home/presentation/providers/home_notifier.dart';
import 'package:dripzoid_v2/features/home/presentation/providers/search_notifier.dart';
import 'package:dripzoid_v2/features/products/data/models/product_model.dart';

class FakeHomeRepository implements HomeRepository {
  Result<List<ProductModel>>? searchResult;
  int searchCallCount = 0;
  String? lastSearchQuery;
  Duration? searchDelay;

  @override
  Future<Result<List<ProductModel>>> searchProducts(String query) async {
    searchCallCount++;
    lastSearchQuery = query;
    if (searchDelay != null) {
      await Future.delayed(searchDelay!);
    }
    return searchResult ?? const Success<List<ProductModel>>([]);
  }

  @override
  Future<Result<List<BannerModel>>> getBanners() async =>
      const Success<List<BannerModel>>([]);

  @override
  Future<Result<List<CategoryModel>>> getCategories() async =>
      const Success<List<CategoryModel>>([]);

  @override
  Future<Result<List<ProductModel>>> getFeaturedProducts() async =>
      const Success<List<ProductModel>>([]);

  @override
  Future<Result<List<ProductModel>>> getTrendingProducts() async =>
      const Success<List<ProductModel>>([]);
}

void main() {
  group('SearchNotifier Lifecycle & Safeguards (DRZ-006 & DRZ-007)', () {
    late FakeHomeRepository fakeRepository;
    late ProviderContainer container;

    setUp(() {
      fakeRepository = FakeHomeRepository();
      container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state has empty query, no results, and idle status', () {
      final state = container.read(searchProvider);
      expect(state.query, isEmpty);
      expect(state.results, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.hasValidQuery, isFalse);
      expect(state.isQueryTooShort, isFalse);
    });

    test('Query below minimum threshold (1 or 2 characters) does not call API and marks isQueryTooShort', () async {
      final notifier = container.read(searchProvider.notifier);
      notifier.onQueryChanged('ho');

      final state = container.read(searchProvider);
      expect(state.query, equals('ho'));
      expect(state.isQueryTooShort, isTrue);
      expect(state.hasValidQuery, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.results, isEmpty);

      // Wait beyond debounce duration to ensure no request is fired
      await Future.delayed(const Duration(milliseconds: 450));
      expect(fakeRepository.searchCallCount, equals(0));
    });

    test('Whitespace-only query does not trigger API request', () async {
      final notifier = container.read(searchProvider.notifier);
      notifier.onQueryChanged('   ');

      final state = container.read(searchProvider);
      expect(state.hasValidQuery, isFalse);
      expect(state.isLoading, isFalse);

      await Future.delayed(const Duration(milliseconds: 450));
      expect(fakeRepository.searchCallCount, equals(0));
    });

    test('Valid query (>= 3 chars) triggers debounce and loads matching products', () async {
      const testProducts = [
        ProductModel(id: 'p1', name: 'Black Hoodie', slug: 'black-hoodie', price: 1499.0),
        ProductModel(id: 'p2', name: 'White Hoodie', slug: 'white-hoodie', price: 1599.0),
      ];
      fakeRepository.searchResult = const Success(testProducts);

      final notifier = container.read(searchProvider.notifier);
      notifier.onQueryChanged('hoodie');

      expect(container.read(searchProvider).hasValidQuery, isTrue);

      // Before debounce fires
      expect(fakeRepository.searchCallCount, equals(0));

      // Wait for 400ms debounce
      await Future.delayed(const Duration(milliseconds: 450));

      expect(fakeRepository.searchCallCount, equals(1));
      expect(fakeRepository.lastSearchQuery, equals('hoodie'));

      final state = container.read(searchProvider);
      expect(state.isLoading, isFalse);
      expect(state.results.length, equals(2));
      expect(state.results[0].name, equals('Black Hoodie'));
      expect(state.errorMessage, isNull);
    });

    test('Valid query with zero matches produces genuine empty results state', () async {
      fakeRepository.searchResult = const Success(<ProductModel>[]);

      final notifier = container.read(searchProvider.notifier);
      notifier.onQueryChanged('nonexistentproduct');

      await Future.delayed(const Duration(milliseconds: 450));

      final state = container.read(searchProvider);
      expect(state.isLoading, isFalse);
      expect(state.results, isEmpty);
      expect(state.errorMessage, isNull);
      expect(state.hasValidQuery, isTrue);
    });

    test('API failure produces distinct error message and ends loading', () async {
      fakeRepository.searchResult = const Failure('Failed to connect to server', statusCode: 500);

      final notifier = container.read(searchProvider.notifier);
      notifier.onQueryChanged('jacket');

      await Future.delayed(const Duration(milliseconds: 450));

      final state = container.read(searchProvider);
      expect(state.isLoading, isFalse);
      expect(state.results, isEmpty);
      expect(state.errorMessage, equals('Failed to connect to server'));
    });

    test('submitQuery executes immediately without waiting for debounce timer', () async {
      const testProducts = [
        ProductModel(id: 'p1', name: 'Bomber Jacket', slug: 'bomber-jacket', price: 2999.0),
      ];
      fakeRepository.searchResult = const Success(testProducts);

      final notifier = container.read(searchProvider.notifier);
      notifier.submitQuery('jacket');

      // Immediate check: no delay needed for submitQuery
      await Future.delayed(const Duration(milliseconds: 50));

      expect(fakeRepository.searchCallCount, equals(1));
      expect(container.read(searchProvider).results.length, equals(1));
      expect(container.read(searchProvider).results[0].name, equals('Bomber Jacket'));
    });

    test('Outdated network response does not overwrite results of a newer query (race condition)', () async {
      // First search is slow
      fakeRepository.searchDelay = const Duration(milliseconds: 100);
      fakeRepository.searchResult = const Success([
        ProductModel(id: 'old', name: 'Old Result', slug: 'old-result', price: 100.0),
      ]);

      final notifier = container.read(searchProvider.notifier);
      notifier.submitQuery('first');

      // Immediately submit a second search with different results
      fakeRepository.searchDelay = Duration.zero;
      fakeRepository.searchResult = const Success([
        ProductModel(id: 'new', name: 'New Result', slug: 'new-result', price: 200.0),
      ]);
      notifier.submitQuery('second');

      // Wait for both to complete
      await Future.delayed(const Duration(milliseconds: 150));

      final state = container.read(searchProvider);
      expect(state.query, equals('second'));
      expect(state.results.length, equals(1));
      expect(state.results.first.name, equals('New Result'));
    });

    test('clearSearch cancels pending debounce and resets state to clean idle', () async {
      final notifier = container.read(searchProvider.notifier);
      notifier.onQueryChanged('sneakers');

      // Immediately clear before debounce fires
      notifier.clearSearch();

      await Future.delayed(const Duration(milliseconds: 450));

      // No network request should have been dispatched
      expect(fakeRepository.searchCallCount, equals(0));

      final state = container.read(searchProvider);
      expect(state.query, isEmpty);
      expect(state.results, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('retrySearch re-executes search for the active valid query', () async {
      fakeRepository.searchResult = const Failure('Initial network error', statusCode: 503);

      final notifier = container.read(searchProvider.notifier);
      notifier.submitQuery('hoodie');

      await Future.delayed(const Duration(milliseconds: 50));
      expect(container.read(searchProvider).errorMessage, equals('Initial network error'));

      // Set successful response for retry
      fakeRepository.searchResult = const Success([
        ProductModel(id: 'p1', name: 'Hoodie', slug: 'hoodie', price: 1299.0),
      ]);

      notifier.retrySearch();
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(searchProvider);
      expect(state.errorMessage, isNull);
      expect(state.results.length, equals(1));
      expect(state.results.first.name, equals('Hoodie'));
      expect(fakeRepository.searchCallCount, equals(2));
    });
  });
}
