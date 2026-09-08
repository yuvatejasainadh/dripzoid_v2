import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dripzoid_v2/features/auth/data/models/user_model.dart';

part 'question_model.freezed.dart';
part 'question_model.g.dart';

@freezed
abstract class QuestionModel with _$QuestionModel {
  const factory QuestionModel({
    required String id,
    required String productId,
    required String userId,
    required String text,
    UserModel? user,
    @Default([]) List<AnswerModel> answers,
    DateTime? createdAt,
  }) = _QuestionModel;

  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);
}

@freezed
abstract class AnswerModel with _$AnswerModel {
  const factory AnswerModel({
    required String id,
    required String questionId,
    required String userId,
    required String text,
    UserModel? user,
    DateTime? createdAt,
  }) = _AnswerModel;

  factory AnswerModel.fromJson(Map<String, dynamic> json) =>
      _$AnswerModelFromJson(json);
}
