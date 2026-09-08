import '../../../../core/logging/app_logger.dart';
import '../../../../core/models/result.dart';
import '../../../products/data/models/product_model.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../services/home_service.dart';

class HomeRepository {
  final HomeService _service;

  HomeRepository(this._service);

  Future<Result<List<BannerModel>>> getBanners() async {
    AppLogger.d('[HomeRepository] [getBanners] Fetching...');
    final result = await _service.getBanners();
    return switch (result) {
      Success(data: final data) => () {
          final rawList = data is List ? data : (data is Map ? (data['slides'] ?? data['data'] ?? []) : []);
          final list = (rawList as List)
              .map((e) => BannerModel.fromJson(e))
              .toList();
          AppLogger.d('[HomeRepository] [getBanners] Loaded ${list.length} slides');
          return Success<List<BannerModel>>(list);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.e('[HomeRepository] [getBanners] Failed: $m', error: e);
          return Failure<List<BannerModel>>(m, statusCode: s, exception: e);
        }(),
    };
  }

  Future<Result<List<CategoryModel>>> getCategories() async {
    AppLogger.d('[HomeRepository] [getCategories] Fetching...');
    final result = await _service.getCategories();
    return switch (result) {
      Success(data: final data) => () {
          final rawList = data is List ? data : (data is Map ? (data['categories'] ?? data['data'] ?? []) : []);
          final list = (rawList as List)
              .map((e) => CategoryModel.fromJson(e))
              .toList();
          AppLogger.d('[HomeRepository] [getCategories] Loaded ${list.length} categories');
          return Success<List<CategoryModel>>(list);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.e('[HomeRepository] [getCategories] Failed: $m', error: e);
          return Failure<List<CategoryModel>>(m, statusCode: s, exception: e);
        }(),
    };
  }

  Future<Result<List<ProductModel>>> getFeaturedProducts() async {
    AppLogger.d('[HomeRepository] [getFeaturedProducts] Fetching...');
    final result = await _service.getFeaturedProducts();
    return switch (result) {
      Success(data: final data) => () {
          final rawList = data is List ? data : (data is Map ? (data['products'] ?? data['data'] ?? []) : []);
          final list = (rawList as List)
              .map((e) => ProductModel.fromJson(e))
              .toList();
          AppLogger.d('[HomeRepository] [getFeaturedProducts] Loaded ${list.length} items');
          return Success<List<ProductModel>>(list);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.e('[HomeRepository] [getFeaturedProducts] Failed: $m', error: e);
          return Failure<List<ProductModel>>(m, statusCode: s, exception: e);
        }(),
    };
  }

  Future<Result<List<ProductModel>>> getTrendingProducts() async {
    AppLogger.d('[HomeRepository] [getTrendingProducts] Fetching...');
    final result = await _service.getTrendingProducts();
    return switch (result) {
      Success(data: final data) => () {
          final rawList = data is List ? data : (data is Map ? (data['products'] ?? data['data'] ?? []) : []);
          final list = (rawList as List)
              .map((e) => ProductModel.fromJson(e))
              .toList();
          AppLogger.d('[HomeRepository] [getTrendingProducts] Loaded ${list.length} items');
          return Success<List<ProductModel>>(list);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.e('[HomeRepository] [getTrendingProducts] Failed: $m', error: e);
          return Failure<List<ProductModel>>(m, statusCode: s, exception: e);
        }(),
    };
  }

  Future<Result<List<ProductModel>>> searchProducts(String query) async {
    AppLogger.i('[HomeRepository] [searchProducts] Query: $query');
    final result = await _service.searchProducts(query);
    return switch (result) {
      Success(data: final data) => () {
          final rawList = data is List ? data : (data is Map ? (data['products'] ?? data['data'] ?? []) : []);
          final list = (rawList as List)
              .map((e) => ProductModel.fromJson(e))
              .toList();
          AppLogger.i('[HomeRepository] [searchProducts] Found ${list.length} results');
          return Success<List<ProductModel>>(list);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.e('[HomeRepository] [searchProducts] Failed: $m', error: e);
          return Failure<List<ProductModel>>(m, statusCode: s, exception: e);
        }(),
    };
  }
}
