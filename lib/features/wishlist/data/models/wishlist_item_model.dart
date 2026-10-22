import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/json_utils.dart';

part 'wishlist_item_model.freezed.dart';
part 'wishlist_item_model.g.dart';

@freezed
abstract class WishlistItemModel with _$WishlistItemModel {
  const factory WishlistItemModel({
    required String id,
    @JsonKey(name: 'product_id') required String productId,
    String? name,
    @JsonKey(fromJson: JsonUtils.toDouble) required double price,
    @Default([]) List<String> images,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _WishlistItemModel;

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> normalized = Map<String, dynamic>.from(json);

    // If item wraps a nested product object: { id: ..., product: { id: ..., name: ... } }
    if (normalized['product'] is Map) {
      final product = Map<String, dynamic>.from(normalized['product'] as Map);
      normalized['product_id'] ??= product['id'] ?? product['_id'];
      normalized['name'] ??= product['name'] ?? product['title'];
      normalized['price'] ??= product['price'];
      normalized['images'] ??= product['images'];
    }

    // Normalize ID
    final rawId = normalized['id'] ?? normalized['_id'];
    normalized['id'] = rawId?.toString() ?? '';

    // Normalize Product ID (fallback to id if productId / product_id not present)
    final rawProductId = normalized['product_id'] ?? normalized['productId'];
    normalized['product_id'] = (rawProductId != null && rawProductId is! Map)
        ? rawProductId.toString()
        : normalized['id'];

    if (normalized['name'] == null) {
      normalized['name'] = normalized['title'] ?? 'Product';
    }

    normalized['price'] = JsonUtils.toDouble(normalized['price']);

    if (normalized['images'] is! List) {
      normalized['images'] = <String>[];
    } else {
      normalized['images'] = (normalized['images'] as List).map((e) => e.toString()).toList();
    }

    return _$WishlistItemModelFromJson(normalized);
  }
}
