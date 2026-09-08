import 'package:freezed_annotation/freezed_annotation.dart';

part 'banner_model.freezed.dart';
part 'banner_model.g.dart';

@freezed
abstract class BannerModel with _$BannerModel {
  const factory BannerModel({
    required String id,
    required String name,
    @JsonKey(name: 'src') required String imageUrl,
    String? link,
    @JsonKey(name: 'order_index') @Default(0) int orderIndex,
  }) = _BannerModel;

  factory BannerModel.fromJson(Map<String, dynamic> json) =>
      _$BannerModelFromJson(json);
}
