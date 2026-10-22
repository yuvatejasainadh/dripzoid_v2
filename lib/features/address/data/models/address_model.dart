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

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> normalized = Map<String, dynamic>.from(json);
    if ((normalized['id'] == null || normalized['id'].toString().isEmpty) && normalized['_id'] != null) {
      normalized['id'] = normalized['_id'].toString();
    }
    if (normalized.containsKey('isDefault')) {
      normalized['is_default'] = normalized['isDefault'];
    }
    return _$AddressModelFromJson(normalized);
  }
}

extension AddressX on AddressModel {
  String get fullAddress {
    final parts = [line1, line2, city, state, pincode, country]
        .where((p) => p != null && p.isNotEmpty)
        .toList();
    return parts.join(', ');
  }
}
