import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dripzoid_v2/features/auth/data/models/user_model.dart';

part 'review_model.freezed.dart';
part 'review_model.g.dart';

@freezed
abstract class ReviewModel with _$ReviewModel {
  const factory ReviewModel({
    required String id,
    required String productId,
    required String userId,
    required int rating,
    String? text,
    String? imageUrl,
    UserModel? user,
    DateTime? createdAt,
  }) = _ReviewModel;

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);
}
