// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShipmentModel _$ShipmentModelFromJson(Map<String, dynamic> json) =>
    _ShipmentModel(
      courierName: json['courierName'] as String?,
      awbCode: json['awbCode'] as String?,
      currentStatus: json['currentStatus'] as String?,
      origin: json['origin'] as String?,
      destination: json['destination'] as String?,
      etd: json['etd'] as String?,
      activities:
          (json['activities'] as List<dynamic>?)
              ?.map(
                (e) =>
                    TrackingActivityModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ShipmentModelToJson(_ShipmentModel instance) =>
    <String, dynamic>{
      'courierName': instance.courierName,
      'awbCode': instance.awbCode,
      'currentStatus': instance.currentStatus,
      'origin': instance.origin,
      'destination': instance.destination,
      'etd': instance.etd,
      'activities': instance.activities,
    };

_TrackingActivityModel _$TrackingActivityModelFromJson(
  Map<String, dynamic> json,
) => _TrackingActivityModel(
  status: json['status'] as String,
  location: json['location'] as String?,
  description: json['description'] as String?,
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$TrackingActivityModelToJson(
  _TrackingActivityModel instance,
) => <String, dynamic>{
  'status': instance.status,
  'location': instance.location,
  'description': instance.description,
  'timestamp': instance.timestamp?.toIso8601String(),
};
