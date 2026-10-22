import 'package:flutter_test/flutter_test.dart';
import 'package:dripzoid_v2/core/models/result.dart';
import 'package:dripzoid_v2/features/home/data/repositories/home_repository.dart';
import 'package:dripzoid_v2/features/home/data/services/home_service.dart';
import 'package:dripzoid_v2/features/products/data/models/product_model.dart';

class FakeHomeService implements HomeService {
  Result<dynamic>? searchResult;
  String? capturedQuery;

  @override
  Future<Result<dynamic>> searchProducts(String query) async {
    capturedQuery = query;
    return searchResult ?? const Success<dynamic>([]);
  }

  @override
  Future<Result<dynamic>> getBanners() async => const Success([]);

  @override
  Future<Result<dynamic>> getCategories() async => const Success([]);

  @override
  Future<Result<dynamic>> getFeaturedProducts() async => const Success([]);

  @override
  Future<Result<dynamic>> getTrendingProducts() async => const Success([]);
}

void main() {
  group('HomeRepository Search API Contract & Parsing Tests', () {
    late FakeHomeService fakeService;
    late HomeRepository repository;

    setUp(() {
      fakeService = FakeHomeService();
      repository = HomeRepository(fakeService);
    });

    test('Parses raw top-level JSON list of products', () async {
      fakeService.searchResult = Success([
        {
          'id': 'p1',
          'name': 'Oversized Tee',
          'slug': 'oversized-tee',
          'price': 999.0,
        },
        {
          'id': 'p2',
          'name': 'Cargo Pants',
          'slug': 'cargo-pants',
          'price': 1999.0,
        },
      ]);

      final result = await repository.searchProducts('tee');
      expect(result, isA<Success<List<ProductModel>>>());

      final products = (result as Success<List<ProductModel>>).data;
      expect(products.length, equals(2));
      expect(products[0].id, equals('p1'));
      expect(products[0].name, equals('Oversized Tee'));
      expect(products[1].id, equals('p2'));
      expect(products[1].name, equals('Cargo Pants'));
      expect(fakeService.capturedQuery, equals('tee'));
    });

    test('Parses products key from enveloped JSON response', () async {
      fakeService.searchResult = Success({
        'success': true,
        'products': [
          {
            '_id': 'm123',
            'name': 'Denim Jacket',
            'price': 2499,
          },
        ],
      });

      final result = await repository.searchProducts('denim');
      expect(result, isA<Success<List<ProductModel>>>());

      final products = (result as Success<List<ProductModel>>).data;
      expect(products.length, equals(1));
      expect(products[0].id, equals('m123'));
      expect(products[0].name, equals('Denim Jacket'));
      expect(products[0].price, equals(2499.0));
    });

    test('Parses data key from enveloped JSON response', () async {
      fakeService.searchResult = Success({
        'status': 'ok',
        'data': [
          {
            'id': 'd1',
            'name': 'Varsity Jacket',
            'price': 3499.0,
          },
        ],
      });

      final result = await repository.searchProducts('varsity');
      expect(result, isA<Success<List<ProductModel>>>());

      final products = (result as Success<List<ProductModel>>).data;
      expect(products.length, equals(1));
      expect(products[0].id, equals('d1'));
      expect(products[0].name, equals('Varsity Jacket'));
    });

    test('Parses results key from enveloped JSON response', () async {
      fakeService.searchResult = Success({
        'count': 1,
        'results': [
          {
            'id': 'r1',
            'name': 'Street Hoodie',
            'price': 1599.0,
          },
        ],
      });

      final result = await repository.searchProducts('street');
      expect(result, isA<Success<List<ProductModel>>>());

      final products = (result as Success<List<ProductModel>>).data;
      expect(products.length, equals(1));
      expect(products[0].name, equals('Street Hoodie'));
    });

    test('Handles empty arrays in enveloped response gracefully', () async {
      fakeService.searchResult = Success({
        'products': [],
      });

      final result = await repository.searchProducts('emptyquery');
      expect(result, isA<Success<List<ProductModel>>>());

      final products = (result as Success<List<ProductModel>>).data;
      expect(products, isEmpty);
    });

    test('Defensively skips corrupted product record and preserves valid products', () async {
      fakeService.searchResult = Success([
        {
          'id': 'good1',
          'name': 'Valid Shirt',
          'price': 599.0,
        },
        'not_a_map_item_corrupted_data',
        {
          'id': 'good2',
          'name': 'Valid Jeans',
          'price': 1299.0,
        },
      ]);

      final result = await repository.searchProducts('shirt');
      expect(result, isA<Success<List<ProductModel>>>());

      final products = (result as Success<List<ProductModel>>).data;
      expect(products.length, equals(2));
      expect(products[0].id, equals('good1'));
      expect(products[1].id, equals('good2'));
    });

    test('Propagates Failure with message and status code on network or server errors', () async {
      fakeService.searchResult = const Failure('HTTP 502 Bad Gateway', statusCode: 502);

      final result = await repository.searchProducts('broken');
      expect(result, isA<Failure<List<ProductModel>>>());

      final failure = result as Failure<List<ProductModel>>;
      expect(failure.message, equals('HTTP 502 Bad Gateway'));
      expect(failure.statusCode, equals(502));
    });
  });
}
