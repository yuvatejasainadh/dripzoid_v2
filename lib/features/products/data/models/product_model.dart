import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/json_utils.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
abstract class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    required String slug,
    @JsonKey(fromJson: JsonUtils.toDouble) required double price,
    @JsonKey(fromJson: JsonUtils.toDouble) double? originalPrice,
    @JsonKey(fromJson: JsonUtils.toDouble) double? actualPrice,
    @JsonKey(fromJson: JsonUtils.toDouble) double? rating,
    String? description,
    @Default(0) int stock,
    @Default(0) int sold,
    @Default(false) bool featured,
    @Default([]) List<String> images,
    @Default([]) List<dynamic> colors, 
    @Default([]) List<String> sizes,
    Map<String, int>? sizeStock,
    String? category,
    String? subcategory,
    String? categorySlug,
    @Default(0) int totalStock,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default([]) List<dynamic> reviews,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}

extension ProductX on ProductModel {
  bool get inStock => stock > 0 || totalStock > 0;
  
  double get discountPercentage {
    if (originalPrice == null || originalPrice! <= price) return 0.0;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }

  bool get hasDiscount => originalPrice != null && originalPrice! > price;
}
