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

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) =>
      _$WishlistItemModelFromJson(json);
}
