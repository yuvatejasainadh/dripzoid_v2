import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/models/result.dart';

class CartService {
  final ApiClient _client;

  CartService(this._client);

  Future<Result<dynamic>> getCart() async {
    return await _client.get(ApiEndpoints.cart);
  }

  Future<Result<Map<String, dynamic>>> addToCart({
    required String productId,
    required int quantity,
    String? selectedSize,
    String? selectedColor,
  }) async {
    return await _client.post(
      ApiEndpoints.cart,
      data: {
        'product_id': productId,
        'quantity': quantity,
        'selectedSize': selectedSize,
        'selectedColor': selectedColor,
      },
    );
  }

  Future<Result<Map<String, dynamic>>> updateCartItem({
    required String cartId,
    required int quantity,
  }) async {
    return await _client.put(
      "${ApiEndpoints.cart}/$cartId",
      data: {'quantity': quantity},
    );
  }

  Future<Result<Map<String, dynamic>>> deleteCartItem(String cartId) async {
    return await _client.delete("${ApiEndpoints.cart}/$cartId");
  }

  Future<Result<Map<String, dynamic>>> clearCart() async {
    return await _client.delete(ApiEndpoints.cart);
  }
}
