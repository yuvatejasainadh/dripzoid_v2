import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/models/result.dart';

class WishlistService {
  final ApiClient _client;

  WishlistService(this._client);

  Future<Result<List<dynamic>>> getWishlist() async {
    final result = await _client.get(ApiEndpoints.wishlist);
    return switch (result) {
      Success(data: final data) => Success(data as List<dynamic>),
      Failure(message: final m, statusCode: final s, exception: final e) =>
        Failure(m, statusCode: s, exception: e),
    };
  }

  Future<Result<Map<String, dynamic>>> addToWishlist(String productId) async {
    return await _client.post("${ApiEndpoints.wishlist}/$productId");
  }

  Future<Result<Map<String, dynamic>>> removeFromWishlist(String productId) async {
    return await _client.delete("${ApiEndpoints.wishlist}/$productId");
  }

  Future<Result<Map<String, dynamic>>> moveToCart(List<String> productIds) async {
    return await _client.post(
      "${ApiEndpoints.wishlist}/move-to-cart",
      data: {'productIds': productIds},
    );
  }
}
