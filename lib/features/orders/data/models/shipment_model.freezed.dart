// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shipment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShipmentModel {

 String? get courierName; String? get awbCode; String? get currentStatus; String? get origin; String? get destination; String? get etd; List<TrackingActivityModel> get activities;
/// Create a copy of ShipmentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShipmentModelCopyWith<ShipmentModel> get copyWith => _$ShipmentModelCopyWithImpl<ShipmentModel>(this as ShipmentModel, _$identity);

  /// Serializes this ShipmentModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShipmentModel&&(identical(other.courierName, courierName) || other.courierName == courierName)&&(identical(other.awbCode, awbCode) || other.awbCode == awbCode)&&(identical(other.currentStatus, currentStatus) || other.currentStatus == currentStatus)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.etd, etd) || other.etd == etd)&&const DeepCollectionEquality().equals(other.activities, activities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,courierName,awbCode,currentStatus,origin,destination,etd,const DeepCollectionEquality().hash(activities));

@override
String toString() {
  return 'ShipmentModel(courierName: $courierName, awbCode: $awbCode, currentStatus: $currentStatus, origin: $origin, destination: $destination, etd: $etd, activities: $activities)';
}


}

/// @nodoc
abstract mixin class $ShipmentModelCopyWith<$Res>  {
  factory $ShipmentModelCopyWith(ShipmentModel value, $Res Function(ShipmentModel) _then) = _$ShipmentModelCopyWithImpl;
@useResult
$Res call({
 String? courierName, String? awbCode, String? currentStatus, String? origin, String? destination, String? etd, List<TrackingActivityModel> activities
});




}
/// @nodoc
class _$ShipmentModelCopyWithImpl<$Res>
    implements $ShipmentModelCopyWith<$Res> {
  _$ShipmentModelCopyWithImpl(this._self, this._then);

  final ShipmentModel _self;
  final $Res Function(ShipmentModel) _then;

/// Create a copy of ShipmentModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? courierName = freezed,Object? awbCode = freezed,Object? currentStatus = freezed,Object? origin = freezed,Object? destination = freezed,Object? etd = freezed,Object? activities = null,}) {
  return _then(_self.copyWith(
courierName: freezed == courierName ? _self.courierName : courierName // ignore: cast_nullable_to_non_nullable
as String?,awbCode: freezed == awbCode ? _self.awbCode : awbCode // ignore: cast_nullable_to_non_nullable
as String?,currentStatus: freezed == currentStatus ? _self.currentStatus : currentStatus // ignore: cast_nullable_to_non_nullable
as String?,origin: freezed == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String?,etd: freezed == etd ? _self.etd : etd // ignore: cast_nullable_to_non_nullable
as String?,activities: null == activities ? _self.activities : activities // ignore: cast_nullable_to_non_nullable
as List<TrackingActivityModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [ShipmentModel].
extension ShipmentModelPatterns on ShipmentModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShipmentModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShipmentModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShipmentModel value)  $default,){
final _that = this;
switch (_that) {
case _ShipmentModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShipmentModel value)?  $default,){
final _that = this;
switch (_that) {
case _ShipmentModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? courierName,  String? awbCode,  String? currentStatus,  String? origin,  String? destination,  String? etd,  List<TrackingActivityModel> activities)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShipmentModel() when $default != null:
return $default(_that.courierName,_that.awbCode,_that.currentStatus,_that.origin,_that.destination,_that.etd,_that.activities);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? courierName,  String? awbCode,  String? currentStatus,  String? origin,  String? destination,  String? etd,  List<TrackingActivityModel> activities)  $default,) {final _that = this;
switch (_that) {
case _ShipmentModel():
return $default(_that.courierName,_that.awbCode,_that.currentStatus,_that.origin,_that.destination,_that.etd,_that.activities);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? courierName,  String? awbCode,  String? currentStatus,  String? origin,  String? destination,  String? etd,  List<TrackingActivityModel> activities)?  $default,) {final _that = this;
switch (_that) {
case _ShipmentModel() when $default != null:
return $default(_that.courierName,_that.awbCode,_that.currentStatus,_that.origin,_that.destination,_that.etd,_that.activities);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShipmentModel implements ShipmentModel {
  const _ShipmentModel({this.courierName, this.awbCode, this.currentStatus, this.origin, this.destination, this.etd, final  List<TrackingActivityModel> activities = const []}): _activities = activities;
  factory _ShipmentModel.fromJson(Map<String, dynamic> json) => _$ShipmentModelFromJson(json);

@override final  String? courierName;
@override final  String? awbCode;
@override final  String? currentStatus;
@override final  String? origin;
@override final  String? destination;
@override final  String? etd;
 final  List<TrackingActivityModel> _activities;
@override@JsonKey() List<TrackingActivityModel> get activities {
  if (_activities is EqualUnmodifiableListView) return _activities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_activities);
}


/// Create a copy of ShipmentModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShipmentModelCopyWith<_ShipmentModel> get copyWith => __$ShipmentModelCopyWithImpl<_ShipmentModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShipmentModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShipmentModel&&(identical(other.courierName, courierName) || other.courierName == courierName)&&(identical(other.awbCode, awbCode) || other.awbCode == awbCode)&&(identical(other.currentStatus, currentStatus) || other.currentStatus == currentStatus)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.etd, etd) || other.etd == etd)&&const DeepCollectionEquality().equals(other._activities, _activities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,courierName,awbCode,currentStatus,origin,destination,etd,const DeepCollectionEquality().hash(_activities));

@override
String toString() {
  return 'ShipmentModel(courierName: $courierName, awbCode: $awbCode, currentStatus: $currentStatus, origin: $origin, destination: $destination, etd: $etd, activities: $activities)';
}


}

/// @nodoc
abstract mixin class _$ShipmentModelCopyWith<$Res> implements $ShipmentModelCopyWith<$Res> {
  factory _$ShipmentModelCopyWith(_ShipmentModel value, $Res Function(_ShipmentModel) _then) = __$ShipmentModelCopyWithImpl;
@override @useResult
$Res call({
 String? courierName, String? awbCode, String? currentStatus, String? origin, String? destination, String? etd, List<TrackingActivityModel> activities
});




}
/// @nodoc
class __$ShipmentModelCopyWithImpl<$Res>
    implements _$ShipmentModelCopyWith<$Res> {
  __$ShipmentModelCopyWithImpl(this._self, this._then);

  final _ShipmentModel _self;
  final $Res Function(_ShipmentModel) _then;

/// Create a copy of ShipmentModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? courierName = freezed,Object? awbCode = freezed,Object? currentStatus = freezed,Object? origin = freezed,Object? destination = freezed,Object? etd = freezed,Object? activities = null,}) {
  return _then(_ShipmentModel(
courierName: freezed == courierName ? _self.courierName : courierName // ignore: cast_nullable_to_non_nullable
as String?,awbCode: freezed == awbCode ? _self.awbCode : awbCode // ignore: cast_nullable_to_non_nullable
as String?,currentStatus: freezed == currentStatus ? _self.currentStatus : currentStatus // ignore: cast_nullable_to_non_nullable
as String?,origin: freezed == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String?,etd: freezed == etd ? _self.etd : etd // ignore: cast_nullable_to_non_nullable
as String?,activities: null == activities ? _self._activities : activities // ignore: cast_nullable_to_non_nullable
as List<TrackingActivityModel>,
  ));
}


}


/// @nodoc
mixin _$TrackingActivityModel {

 String get status; String? get location; String? get description; DateTime? get timestamp;
/// Create a copy of TrackingActivityModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackingActivityModelCopyWith<TrackingActivityModel> get copyWith => _$TrackingActivityModelCopyWithImpl<TrackingActivityModel>(this as TrackingActivityModel, _$identity);

  /// Serializes this TrackingActivityModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackingActivityModel&&(identical(other.status, status) || other.status == status)&&(identical(other.location, location) || other.location == location)&&(identical(other.description, description) || other.description == description)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,location,description,timestamp);

@override
String toString() {
  return 'TrackingActivityModel(status: $status, location: $location, description: $description, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $TrackingActivityModelCopyWith<$Res>  {
  factory $TrackingActivityModelCopyWith(TrackingActivityModel value, $Res Function(TrackingActivityModel) _then) = _$TrackingActivityModelCopyWithImpl;
@useResult
$Res call({
 String status, String? location, String? description, DateTime? timestamp
});




}
/// @nodoc
class _$TrackingActivityModelCopyWithImpl<$Res>
    implements $TrackingActivityModelCopyWith<$Res> {
  _$TrackingActivityModelCopyWithImpl(this._self, this._then);

  final TrackingActivityModel _self;
  final $Res Function(TrackingActivityModel) _then;

/// Create a copy of TrackingActivityModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? location = freezed,Object? description = freezed,Object? timestamp = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrackingActivityModel].
extension TrackingActivityModelPatterns on TrackingActivityModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackingActivityModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackingActivityModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackingActivityModel value)  $default,){
final _that = this;
switch (_that) {
case _TrackingActivityModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackingActivityModel value)?  $default,){
final _that = this;
switch (_that) {
case _TrackingActivityModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String status,  String? location,  String? description,  DateTime? timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrackingActivityModel() when $default != null:
return $default(_that.status,_that.location,_that.description,_that.timestamp);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String status,  String? location,  String? description,  DateTime? timestamp)  $default,) {final _that = this;
switch (_that) {
case _TrackingActivityModel():
return $default(_that.status,_that.location,_that.description,_that.timestamp);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String status,  String? location,  String? description,  DateTime? timestamp)?  $default,) {final _that = this;
switch (_that) {
case _TrackingActivityModel() when $default != null:
return $default(_that.status,_that.location,_that.description,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrackingActivityModel implements TrackingActivityModel {
  const _TrackingActivityModel({required this.status, this.location, this.description, this.timestamp});
  factory _TrackingActivityModel.fromJson(Map<String, dynamic> json) => _$TrackingActivityModelFromJson(json);

@override final  String status;
@override final  String? location;
@override final  String? description;
@override final  DateTime? timestamp;

/// Create a copy of TrackingActivityModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackingActivityModelCopyWith<_TrackingActivityModel> get copyWith => __$TrackingActivityModelCopyWithImpl<_TrackingActivityModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrackingActivityModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackingActivityModel&&(identical(other.status, status) || other.status == status)&&(identical(other.location, location) || other.location == location)&&(identical(other.description, description) || other.description == description)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,location,description,timestamp);

@override
String toString() {
  return 'TrackingActivityModel(status: $status, location: $location, description: $description, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$TrackingActivityModelCopyWith<$Res> implements $TrackingActivityModelCopyWith<$Res> {
  factory _$TrackingActivityModelCopyWith(_TrackingActivityModel value, $Res Function(_TrackingActivityModel) _then) = __$TrackingActivityModelCopyWithImpl;
@override @useResult
$Res call({
 String status, String? location, String? description, DateTime? timestamp
});




}
/// @nodoc
class __$TrackingActivityModelCopyWithImpl<$Res>
    implements _$TrackingActivityModelCopyWith<$Res> {
  __$TrackingActivityModelCopyWithImpl(this._self, this._then);

  final _TrackingActivityModel _self;
  final $Res Function(_TrackingActivityModel) _then;

/// Create a copy of TrackingActivityModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? location = freezed,Object? description = freezed,Object? timestamp = freezed,}) {
  return _then(_TrackingActivityModel(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
