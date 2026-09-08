import '../../../../core/logging/app_logger.dart';
import '../../../../core/models/result.dart';
import '../models/cart_item_model.dart';
import '../services/cart_service.dart';

class CartRepository {
  final CartService _service;

  CartRepository(this._service);

  Future<Result<List<CartItemModel>>> getCart() async {
    AppLogger.d('[CartRepository] [getCart] Fetching cart...');
    final result = await _service.getCart();
    return switch (result) {
      Success(data: final data) => () {
          final rawList = data is List ? data : (data is Map ? (data['items'] ?? data['data'] ?? data['cartItems'] ?? []) : []);
          final list = (rawList as List).map((e) => CartItemModel.fromJson(e)).toList();
          AppLogger.d('[CartRepository] [getCart] Found ${list.length} items');
          return Success<List<CartItemModel>>(list);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.e('[CartRepository] [getCart] Failed: $m', error: e);
          return Failure<List<CartItemModel>>(m, statusCode: s, exception: e);
        }(),
    };
  }

  Future<Result<void>> addToCart({
    required String productId,
    required int quantity,
    String? selectedSize,
    String? selectedColor,
  }) async {
    AppLogger.i('[CartRepository] [addToCart] Product: $productId, Qty: $quantity');
    final result = await _service.addToCart(
      productId: productId,
      quantity: quantity,
      selectedSize: selectedSize,
      selectedColor: selectedColor,
    );

    return switch (result) {
      Success() => () {
          AppLogger.i('[CartRepository] [addToCart] Added successfully');
          return const Success<void>(null);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.e('[CartRepository] [addToCart] Failed: $m', error: e);
          return Failure<void>(m, statusCode: s, exception: e);
        }(),
    };
  }

  Future<Result<void>> updateCartItem({
    required String cartId,
    required int quantity,
  }) async {
    AppLogger.d('[CartRepository] [updateCartItem] ID: $cartId, Qty: $quantity');
    final result = await _service.updateCartItem(
      cartId: cartId,
      quantity: quantity,
    );

    return switch (result) {
      Success() => () {
          AppLogger.d('[CartRepository] [updateCartItem] Updated');
          return const Success<void>(null);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.e('[CartRepository] [updateCartItem] Failed: $m', error: e);
          return Failure<void>(m, statusCode: s, exception: e);
        }(),
    };
  }

  Future<Result<void>> deleteCartItem(String cartId) async {
    AppLogger.w('[CartRepository] [deleteCartItem] ID: $cartId');
    final result = await _service.deleteCartItem(cartId);
    return switch (result) {
      Success() => () {
          AppLogger.i('[CartRepository] [deleteCartItem] Removed');
          return const Success<void>(null);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.e('[CartRepository] [deleteCartItem] Failed: $m', error: e);
          return Failure<void>(m, statusCode: s, exception: e);
        }(),
    };
  }

  Future<Result<void>> clearCart() async {
    AppLogger.w('[CartRepository] [clearCart] Clearing all items...');
    final result = await _service.clearCart();
    return switch (result) {
      Success() => () {
          AppLogger.i('[CartRepository] [clearCart] Cart cleared');
          return const Success<void>(null);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.e('[CartRepository] [clearCart] Failed: $m', error: e);
          return Failure<void>(m, statusCode: s, exception: e);
        }(),
    };
  }
}
