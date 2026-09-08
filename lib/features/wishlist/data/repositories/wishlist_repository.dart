import '../../../../core/models/result.dart';
import '../models/wishlist_item_model.dart';
import '../services/wishlist_service.dart';

class WishlistRepository {
  final WishlistService _service;

  WishlistRepository(this._service);

  Future<Result<List<WishlistItemModel>>> getWishlist() async {
    final result = await _service.getWishlist();
    return switch (result) {
      Success(data: final data) => Success(
          data.map((e) => WishlistItemModel.fromJson(e)).toList(),
        ),
      Failure(message: final m, statusCode: final s, exception: final e) =>
        Failure(m, statusCode: s, exception: e),
    };
  }

  Future<Result<void>> addToWishlist(String productId) async {
    final result = await _service.addToWishlist(productId);
    return switch (result) {
      Success() => const Success(null),
      Failure(message: final m, statusCode: final s, exception: final e) =>
        Failure(m, statusCode: s, exception: e),
    };
  }

  Future<Result<void>> removeFromWishlist(String productId) async {
    final result = await _service.removeFromWishlist(productId);
    return switch (result) {
      Success() => const Success(null),
      Failure(message: final m, statusCode: final s, exception: final e) =>
        Failure(m, statusCode: s, exception: e),
    };
  }

  Future<Result<void>> moveToCart(List<String> productIds) async {
    final result = await _service.moveToCart(productIds);
    return switch (result) {
      Success() => const Success(null),
      Failure(message: final m, statusCode: final s, exception: final e) =>
        Failure(m, statusCode: s, exception: e),
    };
  }
}
