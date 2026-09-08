// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QuestionModel _$QuestionModelFromJson(Map<String, dynamic> json) =>
    _QuestionModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      userId: json['userId'] as String,
      text: json['text'] as String,
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
      answers:
          (json['answers'] as List<dynamic>?)
              ?.map((e) => AnswerModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$QuestionModelToJson(_QuestionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'userId': instance.userId,
      'text': instance.text,
      'user': instance.user,
      'answers': instance.answers,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_AnswerModel _$AnswerModelFromJson(Map<String, dynamic> json) => _AnswerModel(
  id: json['id'] as String,
  questionId: json['questionId'] as String,
  userId: json['userId'] as String,
  text: json['text'] as String,
  user: json['user'] == null
      ? null
      : UserModel.fromJson(json['user'] as Map<String, dynamic>),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$AnswerModelToJson(_AnswerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'questionId': instance.questionId,
      'userId': instance.userId,
      'text': instance.text,
      'user': instance.user,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
