// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductModel _$ProductModelFromJson(Map<String, dynamic> json) =>
    _ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      price: JsonUtils.toDouble(json['price']),
      originalPrice: JsonUtils.toDouble(json['originalPrice']),
      actualPrice: JsonUtils.toDouble(json['actualPrice']),
      rating: JsonUtils.toDouble(json['rating']),
      description: json['description'] as String?,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      sold: (json['sold'] as num?)?.toInt() ?? 0,
      featured: json['featured'] as bool? ?? false,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      colors: json['colors'] as List<dynamic>? ?? const [],
      sizes:
          (json['sizes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      sizeStock: (json['sizeStock'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      category: json['category'] as String?,
      subcategory: json['subcategory'] as String?,
      categorySlug: json['categorySlug'] as String?,
      totalStock: (json['totalStock'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      reviews: json['reviews'] as List<dynamic>? ?? const [],
    );

Map<String, dynamic> _$ProductModelToJson(_ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'price': instance.price,
      'originalPrice': instance.originalPrice,
      'actualPrice': instance.actualPrice,
      'rating': instance.rating,
      'description': instance.description,
      'stock': instance.stock,
      'sold': instance.sold,
      'featured': instance.featured,
      'images': instance.images,
      'colors': instance.colors,
      'sizes': instance.sizes,
      'sizeStock': instance.sizeStock,
      'category': instance.category,
      'subcategory': instance.subcategory,
      'categorySlug': instance.categorySlug,
      'totalStock': instance.totalStock,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'reviews': instance.reviews,
    };
