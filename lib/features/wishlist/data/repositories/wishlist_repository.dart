import '../../../../core/models/result.dart';
import '../models/wishlist_item_model.dart';
import '../services/wishlist_service.dart';

class WishlistRepository {
  final WishlistService _service;

  WishlistRepository(this._service);

  Future<Result<List<WishlistItemModel>>> getWishlist() async {
    final result = await _service.getWishlist();
    return switch (result) {
      Success(data: final data) => () {
          List<dynamic> rawList = [];
          if (data is List) {
            rawList = data;
          } else if (data is Map) {
            for (final key in ['wishlist', 'data', 'items', 'products']) {
              final val = data[key];
              if (val is List) {
                rawList = val;
                break;
              }
            }
          }
          final items = <WishlistItemModel>[];
          for (final item in rawList) {
            try {
              if (item is Map) {
                final map = item is Map<String, dynamic>
                    ? item
                    : Map<String, dynamic>.from(item);
                items.add(WishlistItemModel.fromJson(map));
              }
            } catch (_) {
              // Gracefully skip corrupted item so remaining valid items display
            }
          }
          return Success<List<WishlistItemModel>>(items);
        }(),
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
