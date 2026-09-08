// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReviewModel _$ReviewModelFromJson(Map<String, dynamic> json) => _ReviewModel(
  id: json['id'] as String,
  productId: json['productId'] as String,
  userId: json['userId'] as String,
  rating: (json['rating'] as num).toInt(),
  text: json['text'] as String?,
  imageUrl: json['imageUrl'] as String?,
  user: json['user'] == null
      ? null
      : UserModel.fromJson(json['user'] as Map<String, dynamic>),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ReviewModelToJson(_ReviewModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'userId': instance.userId,
      'rating': instance.rating,
      'text': instance.text,
      'imageUrl': instance.imageUrl,
      'user': instance.user,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
