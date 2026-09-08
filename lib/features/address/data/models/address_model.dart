import 'package:freezed_annotation/freezed_annotation.dart';

part 'address_model.freezed.dart';
part 'address_model.g.dart';

@freezed
abstract class AddressModel with _$AddressModel {
  const factory AddressModel({
    String? id,
    String? label,
    String? name,
    String? line1,
    String? line2,
    String? city,
    String? state,
    String? pincode,
    @Default('India') String country,
    String? phone,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
    DateTime? createdAt,
  }) = _AddressModel;

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);
}

extension AddressX on AddressModel {
  String get fullAddress {
    final parts = [line1, line2, city, state, pincode, country]
        .where((p) => p != null && p.isNotEmpty)
        .toList();
    return parts.join(', ');
  }
}
