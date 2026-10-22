import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/models/result.dart';

class WishlistService {
  final ApiClient _client;

  WishlistService(this._client);

  Future<Result<dynamic>> getWishlist() async {
    return await _client.get(ApiEndpoints.wishlist);
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
