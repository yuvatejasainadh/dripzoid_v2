import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/services/product_service.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProductService(client);
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final service = ref.watch(productServiceProvider);
  return ProductRepository(service);
});
