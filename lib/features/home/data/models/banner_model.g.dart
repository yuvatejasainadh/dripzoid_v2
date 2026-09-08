// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BannerModel _$BannerModelFromJson(Map<String, dynamic> json) => _BannerModel(
  id: json['id'] as String,
  name: json['name'] as String,
  imageUrl: json['src'] as String,
  link: json['link'] as String?,
  orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$BannerModelToJson(_BannerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'src': instance.imageUrl,
      'link': instance.link,
      'order_index': instance.orderIndex,
    };
