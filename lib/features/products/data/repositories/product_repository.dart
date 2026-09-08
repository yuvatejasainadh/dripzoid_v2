import '../../../../core/logging/app_logger.dart';
import '../../../../core/models/result.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';
import '../models/review_eligibility_model.dart';
import '../models/question_model.dart';
import '../services/product_service.dart';

class ProductRepository {
  final ProductService _service;

  ProductRepository(this._service);

  Future<Result<ProductModel>> getProductById(String id) async {
    AppLogger.d('[ProductRepository] [getProductById] ID: $id');
    final result = await _service.getProductById(id);
    return switch (result) {
      Success(data: final data) => () {
          final p = ProductModel.fromJson(data['product'] ?? data);
          AppLogger.d('[ProductRepository] [getProductById] Loaded: ${p.name}');
          return Success<ProductModel>(p);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.e('[ProductRepository] [getProductById] Failed: $m', error: e);
          return Failure<ProductModel>(m, statusCode: s, exception: e);
        }(),
    };
  }

  Future<Result<List<ProductModel>>> getRelatedProducts(String id) async {
    AppLogger.d('[ProductRepository] [getRelatedProducts] ID: $id');
    final result = await _service.getRelatedProducts(id);
    return switch (result) {
      Success(data: final data) => () {
          final list = (data['products'] as List)
              .map((e) => ProductModel.fromJson(e))
              .toList();
          AppLogger.d('[ProductRepository] [getRelatedProducts] Found ${list.length} items');
          return Success<List<ProductModel>>(list);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.e('[ProductRepository] [getRelatedProducts] Failed: $m', error: e);
          return Failure<List<ProductModel>>(m, statusCode: s, exception: e);
        }(),
    };
  }

  Future<Result<List<ReviewModel>>> getProductReviews(String productId) async {
    AppLogger.d('[ProductRepository] [getProductReviews] Product: $productId');
    final result = await _service.getReviews(productId);
    return switch (result) {
      Success(data: final data) => () {
          final rawList = data is List ? data : (data is Map ? (data['reviews'] ?? data['data'] ?? []) : []);
          final list = (rawList as List)
              .map((e) => ReviewModel.fromJson(e))
              .toList();
          AppLogger.d('[ProductRepository] [getProductReviews] Found ${list.length} reviews');
          return Success<List<ReviewModel>>(list);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.e('[ProductRepository] [getProductReviews] Failed: $m', error: e);
          return Failure<List<ReviewModel>>(m, statusCode: s, exception: e);
        }(),
    };
  }

  Future<Result<List<QuestionModel>>> getProductQuestions(String productId) async {
    AppLogger.d('[ProductRepository] [getProductQuestions] Product: $productId');
    final result = await _service.getQuestions(productId);
    return switch (result) {
      Success(data: final data) => () {
          final rawList = data is List ? data : (data is Map ? (data['questions'] ?? data['data'] ?? []) : []);
          final list = (rawList as List)
              .map((e) => QuestionModel.fromJson(e))
              .toList();
          AppLogger.d('[ProductRepository] [getProductQuestions] Found ${list.length} questions');
          return Success<List<QuestionModel>>(list);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.e('[ProductRepository] [getProductQuestions] Failed: $m', error: e);
          return Failure<List<QuestionModel>>(m, statusCode: s, exception: e);
        }(),
    };
  }

  Future<Result<ReviewEligibilityModel>> verifyPurchase(String productId) async {
    AppLogger.d('[ProductRepository] [verifyPurchase] Product: $productId');
    final result = await _service.verifyPurchase(productId);
    return switch (result) {
      Success(data: final data) => Success<ReviewEligibilityModel>(ReviewEligibilityModel.fromJson(data)),
      Failure(message: final m, statusCode: final s, exception: final e) =>
        Failure<ReviewEligibilityModel>(m, statusCode: s, exception: e),
    };
  }

  Future<Result<Map<String, dynamic>>> submitReview(Map<String, dynamic> data) async {
    AppLogger.i('[ProductRepository] [submitReview] Submitting...');
    final result = await _service.submitReview(data);
    return switch (result) {
      Success(data: final data) => Success<Map<String, dynamic>>(data['data'] ?? data),
      Failure(message: final m, statusCode: final s, exception: final e) =>
        Failure<Map<String, dynamic>>(m, statusCode: s, exception: e),
    };
  }

  Future<Result<Map<String, dynamic>>> checkShipping(String pincode) async {
    AppLogger.d('[ProductRepository] [checkShipping] Pincode: $pincode');
    final result = await _service.checkShipping(pincode);
    return switch (result) {
      Success(data: final data) => Success<Map<String, dynamic>>(data as Map<String, dynamic>),
      Failure(message: final m, statusCode: final s, exception: final e) => 
        Failure<Map<String, dynamic>>(m, statusCode: s, exception: e),
    };
  }

  Future<Result<List<ProductModel>>> getProducts({
    Map<String, dynamic>? queryParameters,
  }) async {
    AppLogger.d('[ProductRepository] [getProducts] Params: $queryParameters');
    final result = await _service.getProducts(queryParameters: queryParameters);
    return switch (result) {
      Success(data: final data) => () {
          final list = ((data['products'] ?? data['data'] ?? data) as List)
              .map((e) => ProductModel.fromJson(e))
              .toList();
          AppLogger.d('[ProductRepository] [getProducts] Found ${list.length} items');
          return Success<List<ProductModel>>(list);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.e('[ProductRepository] [getProducts] Failed: $m', error: e);
          return Failure<List<ProductModel>>(m, statusCode: s, exception: e);
        }(),
    };
  }
}
