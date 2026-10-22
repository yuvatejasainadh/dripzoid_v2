import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dripzoid_v2/core/models/result.dart';
import 'package:dripzoid_v2/features/home/data/models/banner_model.dart';
import 'package:dripzoid_v2/features/home/data/models/category_model.dart';
import 'package:dripzoid_v2/features/home/data/repositories/home_repository.dart';
import 'package:dripzoid_v2/features/home/presentation/providers/home_notifier.dart';
import 'package:dripzoid_v2/features/home/presentation/providers/search_notifier.dart';
import 'package:dripzoid_v2/features/home/presentation/widgets/search_results_view.dart';
import 'package:dripzoid_v2/features/navigation/presentation/providers/header_notifier.dart';
import 'package:dripzoid_v2/features/products/data/models/product_model.dart';
import 'package:dripzoid_v2/shared/widgets/header_search_bar.dart';

class FakeHomeRepository implements HomeRepository {
  Result<List<ProductModel>>? searchResult;
  int searchCallCount = 0;
  String? lastSearchQuery;

  @override
  Future<Result<List<ProductModel>>> searchProducts(String query) async {
    searchCallCount++;
    lastSearchQuery = query;
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
  group('Search UI & Results View Tests (DRZ-006 & DRZ-007)', () {
    late FakeHomeRepository fakeRepository;

    setUp(() {
      fakeRepository = FakeHomeRepository();
    });

    testWidgets('Displays idle state with suggestions when query is empty', (tester) async {
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: SearchResultsView(),
            ),
          ),
        ),
      );

      expect(find.text('Search Dripzoid'), findsOneWidget);
      expect(find.text('Search for hoodies, sneakers, oversized tees, and more'), findsOneWidget);
      expect(find.byType(ActionChip), findsWidgets);
      expect(find.text('Hoodies'), findsOneWidget);
      expect(find.text('No results found'), findsNothing);

      container.dispose();
    });

    testWidgets('Displays below-threshold prompt when query is 1 or 2 characters', (tester) async {
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      container.read(searchProvider.notifier).onQueryChanged('ab');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: SearchResultsView(),
            ),
          ),
        ),
      );

      expect(find.text('Keep typing...'), findsOneWidget);
      expect(find.text('Type at least 3 characters to search products'), findsOneWidget);
      expect(find.text('No results found'), findsNothing);

      container.dispose();
    });

    testWidgets('Displays error state with Try Again button on search failure', (tester) async {
      fakeRepository.searchResult = const Failure('Connection error', statusCode: 500);

      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );

      container.read(searchProvider.notifier).submitQuery('jacket');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: SearchResultsView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Search Failed'), findsOneWidget);
      expect(find.text('Connection error'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      container.dispose();
    });

    testWidgets('Displays empty results state when valid query returns no items', (tester) async {
      fakeRepository.searchResult = const Success(<ProductModel>[]);

      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );

      container.read(searchProvider.notifier).submitQuery('unknownitem');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: SearchResultsView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No results found'), findsOneWidget);
      expect(find.text('We couldn\'t find any products matching "unknownitem"'), findsOneWidget);

      container.dispose();
    });

    testWidgets('HeaderSearchBar reflects text input and clears properly', (tester) async {
      String? changedQuery;
      bool cleared = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderSearchBar(
              initialValue: 'hoodie',
              onChanged: (val) => changedQuery = val,
              onClear: () => cleared = true,
            ),
          ),
        ),
      );

      expect(find.text('hoodie'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'sneakers');
      await tester.pump();
      expect(changedQuery, equals('sneakers'));

      // Tap clear button
      final clearButton = find.byIcon(Icons.close_rounded);
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pump();

      expect(cleared, isTrue);
      expect(find.text('hoodie'), findsNothing);
    });

    testWidgets('Tapping a suggestion chip executes search with that term', (tester) async {
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: SearchResultsView(),
            ),
          ),
        ),
      );

      final hoodieChip = find.widgetWithText(ActionChip, 'Hoodies');
      expect(hoodieChip, findsOneWidget);

      await tester.tap(hoodieChip);
      await tester.pumpAndSettle();

      expect(container.read(headerProvider).searchQuery, equals('Hoodies'));
      expect(container.read(searchProvider).query, equals('Hoodies'));
      expect(fakeRepository.searchCallCount, equals(1));
      expect(fakeRepository.lastSearchQuery, equals('Hoodies'));

      container.dispose();
    });
  });
}
