// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    _CategoryModel(
      category: json['category'] as String,
      subcategories:
          (json['subcategories'] as List<dynamic>?)
              ?.map((e) => SubCategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CategoryModelToJson(_CategoryModel instance) =>
    <String, dynamic>{
      'category': instance.category,
      'subcategories': instance.subcategories,
    };

_SubCategoryModel _$SubCategoryModelFromJson(Map<String, dynamic> json) =>
    _SubCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      subcategory: json['subcategory'] as String,
      slug: json['slug'] as String,
    );

Map<String, dynamic> _$SubCategoryModelToJson(_SubCategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'subcategory': instance.subcategory,
      'slug': instance.slug,
    };
