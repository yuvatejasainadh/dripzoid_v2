import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../products/data/models/product_model.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

@freezed
abstract class MessageModel with _$MessageModel {
  const factory MessageModel({
    required String id,
    required String conversationId,
    required String role, // user/assistant
    required String content,
    @Default([]) List<ProductModel> products,
    required DateTime createdAt,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);
}
