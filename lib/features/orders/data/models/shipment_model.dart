import 'package:freezed_annotation/freezed_annotation.dart';

part 'shipment_model.freezed.dart';
part 'shipment_model.g.dart';

@freezed
abstract class ShipmentModel with _$ShipmentModel {
  const factory ShipmentModel({
    String? courierName,
    String? awbCode,
    String? currentStatus,
    String? origin,
    String? destination,
    String? etd,
    @Default([]) List<TrackingActivityModel> activities,
  }) = _ShipmentModel;

  factory ShipmentModel.fromJson(Map<String, dynamic> json) =>
      _$ShipmentModelFromJson(json);
}

@freezed
abstract class TrackingActivityModel with _$TrackingActivityModel {
  const factory TrackingActivityModel({
    required String status,
    String? location,
    String? description,
    DateTime? timestamp,
  }) = _TrackingActivityModel;

  factory TrackingActivityModel.fromJson(Map<String, dynamic> json) =>
      _$TrackingActivityModelFromJson(json);
}
