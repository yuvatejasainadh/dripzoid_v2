// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wishlist_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WishlistItemModel {

 String get id;@JsonKey(name: 'product_id') String get productId; String? get name;@JsonKey(fromJson: JsonUtils.toDouble) double get price; List<String> get images;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of WishlistItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WishlistItemModelCopyWith<WishlistItemModel> get copyWith => _$WishlistItemModelCopyWithImpl<WishlistItemModel>(this as WishlistItemModel, _$identity);

  /// Serializes this WishlistItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WishlistItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,name,price,const DeepCollectionEquality().hash(images),createdAt);

@override
String toString() {
  return 'WishlistItemModel(id: $id, productId: $productId, name: $name, price: $price, images: $images, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $WishlistItemModelCopyWith<$Res>  {
  factory $WishlistItemModelCopyWith(WishlistItemModel value, $Res Function(WishlistItemModel) _then) = _$WishlistItemModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'product_id') String productId, String? name,@JsonKey(fromJson: JsonUtils.toDouble) double price, List<String> images,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$WishlistItemModelCopyWithImpl<$Res>
    implements $WishlistItemModelCopyWith<$Res> {
  _$WishlistItemModelCopyWithImpl(this._self, this._then);

  final WishlistItemModel _self;
  final $Res Function(WishlistItemModel) _then;

/// Create a copy of WishlistItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? name = freezed,Object? price = null,Object? images = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WishlistItemModel].
extension WishlistItemModelPatterns on WishlistItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WishlistItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WishlistItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WishlistItemModel value)  $default,){
final _that = this;
switch (_that) {
case _WishlistItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WishlistItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _WishlistItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'product_id')  String productId,  String? name, @JsonKey(fromJson: JsonUtils.toDouble)  double price,  List<String> images, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WishlistItemModel() when $default != null:
return $default(_that.id,_that.productId,_that.name,_that.price,_that.images,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'product_id')  String productId,  String? name, @JsonKey(fromJson: JsonUtils.toDouble)  double price,  List<String> images, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _WishlistItemModel():
return $default(_that.id,_that.productId,_that.name,_that.price,_that.images,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'product_id')  String productId,  String? name, @JsonKey(fromJson: JsonUtils.toDouble)  double price,  List<String> images, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _WishlistItemModel() when $default != null:
return $default(_that.id,_that.productId,_that.name,_that.price,_that.images,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WishlistItemModel implements WishlistItemModel {
  const _WishlistItemModel({required this.id, @JsonKey(name: 'product_id') required this.productId, this.name, @JsonKey(fromJson: JsonUtils.toDouble) required this.price, final  List<String> images = const [], @JsonKey(name: 'created_at') this.createdAt}): _images = images;
  factory _WishlistItemModel.fromJson(Map<String, dynamic> json) => _$WishlistItemModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'product_id') final  String productId;
@override final  String? name;
@override@JsonKey(fromJson: JsonUtils.toDouble) final  double price;
 final  List<String> _images;
@override@JsonKey() List<String> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of WishlistItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WishlistItemModelCopyWith<_WishlistItemModel> get copyWith => __$WishlistItemModelCopyWithImpl<_WishlistItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WishlistItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WishlistItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,name,price,const DeepCollectionEquality().hash(_images),createdAt);

@override
String toString() {
  return 'WishlistItemModel(id: $id, productId: $productId, name: $name, price: $price, images: $images, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$WishlistItemModelCopyWith<$Res> implements $WishlistItemModelCopyWith<$Res> {
  factory _$WishlistItemModelCopyWith(_WishlistItemModel value, $Res Function(_WishlistItemModel) _then) = __$WishlistItemModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'product_id') String productId, String? name,@JsonKey(fromJson: JsonUtils.toDouble) double price, List<String> images,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$WishlistItemModelCopyWithImpl<$Res>
    implements _$WishlistItemModelCopyWith<$Res> {
  __$WishlistItemModelCopyWithImpl(this._self, this._then);

  final _WishlistItemModel _self;
  final $Res Function(_WishlistItemModel) _then;

/// Create a copy of WishlistItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? name = freezed,Object? price = null,Object? images = null,Object? createdAt = freezed,}) {
  return _then(_WishlistItemModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
