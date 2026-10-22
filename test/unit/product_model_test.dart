import 'package:flutter_test/flutter_test.dart';
import 'package:dripzoid_v2/features/products/data/models/product_model.dart';

void main() {
  group('ProductModel JSON Parsing & Normalization Tests', () {
    test('Parses standard JSON with id and slug', () {
      final json = {
        'id': 'prod_123',
        'name': 'Oversized Hoodie',
        'slug': 'oversized-hoodie',
        'price': 1499.0,
      };

      final product = ProductModel.fromJson(json);
      expect(product.id, equals('prod_123'));
      expect(product.name, equals('Oversized Hoodie'));
      expect(product.slug, equals('oversized-hoodie'));
      expect(product.price, equals(1499.0));
    });

    test('Normalizes MongoDB _id when id is missing', () {
      final json = {
        '_id': 'mongo_67890',
        'name': 'Streetwear Jacket',
        'price': 2999,
      };

      final product = ProductModel.fromJson(json);
      expect(product.id, equals('mongo_67890'));
      expect(product.name, equals('Streetwear Jacket'));
      expect(product.slug, equals('streetwear-jacket'));
      expect(product.price, equals(2999.0));
    });

    test('Generates fallback slug when slug is missing or null', () {
      final json = {
        'id': 'p1',
        'name': 'Black Drip T-Shirt',
        'slug': null,
        'price': '799',
      };

      final product = ProductModel.fromJson(json);
      expect(product.id, equals('p1'));
      expect(product.slug, equals('black-drip-t-shirt'));
      expect(product.price, equals(799.0));
    });
  });
}
