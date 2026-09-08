import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/json_utils.dart';

part 'cart_item_model.freezed.dart';
part 'cart_item_model.g.dart';

@freezed
abstract class CartItemModel with _$CartItemModel {
  const factory CartItemModel({
    @JsonKey(name: 'cart_id') required String id,
    @JsonKey(name: 'product_id') required String productId,
    required int quantity,
    String? selectedSize,
    String? selectedColor,
    String? name,
    @JsonKey(fromJson: JsonUtils.toDouble) required double price,
    @Default([]) List<String> images,
    int? stock,
  }) = _CartItemModel;

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);
}
