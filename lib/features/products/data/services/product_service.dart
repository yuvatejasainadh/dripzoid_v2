import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/models/result.dart';

class ProductService {
  final ApiClient _client;

  ProductService(this._client);

  Future<Result<dynamic>> getProductById(String id) async {
    return await _client.get("${ApiEndpoints.products}/$id");
  }

  Future<Result<dynamic>> getRelatedProducts(String id) async {
    return await _client.get("${ApiEndpoints.products}/$id/related");
  }

  Future<Result<dynamic>> getReviews(String productId) async {
    return await _client.get("/api/reviews/product/$productId");
  }

  Future<Result<dynamic>> verifyPurchase(String productId) async {
    return await _client.post("/api/user/orders/verify", data: {'productId': productId});
  }

  Future<Result<dynamic>> submitReview(Map<String, dynamic> data) async {
    return await _client.post("/api/reviews", data: data);
  }

  Future<Result<dynamic>> getQuestions(String productId) async {
    return await _client.get("/api/qa/$productId");
  }

  Future<Result<dynamic>> checkShipping(String pincode) async {
    return await _client.get("/api/shipping/estimate/$pincode");
  }

  Future<Result<dynamic>> getProducts({
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _client.get(
      ApiEndpoints.products,
      queryParameters: queryParameters,
    );
  }
}
