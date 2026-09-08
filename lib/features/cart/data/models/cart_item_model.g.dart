// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CartItemModel _$CartItemModelFromJson(Map<String, dynamic> json) =>
    _CartItemModel(
      id: json['cart_id'] as String,
      productId: json['product_id'] as String,
      quantity: (json['quantity'] as num).toInt(),
      selectedSize: json['selectedSize'] as String?,
      selectedColor: json['selectedColor'] as String?,
      name: json['name'] as String?,
      price: JsonUtils.toDouble(json['price']),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      stock: (json['stock'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CartItemModelToJson(_CartItemModel instance) =>
    <String, dynamic>{
      'cart_id': instance.id,
      'product_id': instance.productId,
      'quantity': instance.quantity,
      'selectedSize': instance.selectedSize,
      'selectedColor': instance.selectedColor,
      'name': instance.name,
      'price': instance.price,
      'images': instance.images,
      'stock': instance.stock,
    };
