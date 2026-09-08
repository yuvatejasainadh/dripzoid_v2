// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WishlistItemModel _$WishlistItemModelFromJson(Map<String, dynamic> json) =>
    _WishlistItemModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      name: json['name'] as String?,
      price: JsonUtils.toDouble(json['price']),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$WishlistItemModelToJson(_WishlistItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'name': instance.name,
      'price': instance.price,
      'images': instance.images,
      'created_at': instance.createdAt?.toIso8601String(),
    };
