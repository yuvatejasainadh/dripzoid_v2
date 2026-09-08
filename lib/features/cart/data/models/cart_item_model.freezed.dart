// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CartItemModel {

@JsonKey(name: 'cart_id') String get id;@JsonKey(name: 'product_id') String get productId; int get quantity; String? get selectedSize; String? get selectedColor; String? get name;@JsonKey(fromJson: JsonUtils.toDouble) double get price; List<String> get images; int? get stock;
/// Create a copy of CartItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartItemModelCopyWith<CartItemModel> get copyWith => _$CartItemModelCopyWithImpl<CartItemModel>(this as CartItemModel, _$identity);

  /// Serializes this CartItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.selectedSize, selectedSize) || other.selectedSize == selectedSize)&&(identical(other.selectedColor, selectedColor) || other.selectedColor == selectedColor)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.stock, stock) || other.stock == stock));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,quantity,selectedSize,selectedColor,name,price,const DeepCollectionEquality().hash(images),stock);

@override
String toString() {
  return 'CartItemModel(id: $id, productId: $productId, quantity: $quantity, selectedSize: $selectedSize, selectedColor: $selectedColor, name: $name, price: $price, images: $images, stock: $stock)';
}


}

/// @nodoc
abstract mixin class $CartItemModelCopyWith<$Res>  {
  factory $CartItemModelCopyWith(CartItemModel value, $Res Function(CartItemModel) _then) = _$CartItemModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'cart_id') String id,@JsonKey(name: 'product_id') String productId, int quantity, String? selectedSize, String? selectedColor, String? name,@JsonKey(fromJson: JsonUtils.toDouble) double price, List<String> images, int? stock
});




}
/// @nodoc
class _$CartItemModelCopyWithImpl<$Res>
    implements $CartItemModelCopyWith<$Res> {
  _$CartItemModelCopyWithImpl(this._self, this._then);

  final CartItemModel _self;
  final $Res Function(CartItemModel) _then;

/// Create a copy of CartItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? quantity = null,Object? selectedSize = freezed,Object? selectedColor = freezed,Object? name = freezed,Object? price = null,Object? images = null,Object? stock = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,selectedSize: freezed == selectedSize ? _self.selectedSize : selectedSize // ignore: cast_nullable_to_non_nullable
as String?,selectedColor: freezed == selectedColor ? _self.selectedColor : selectedColor // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<String>,stock: freezed == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CartItemModel].
extension CartItemModelPatterns on CartItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartItemModel value)  $default,){
final _that = this;
switch (_that) {
case _CartItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _CartItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'cart_id')  String id, @JsonKey(name: 'product_id')  String productId,  int quantity,  String? selectedSize,  String? selectedColor,  String? name, @JsonKey(fromJson: JsonUtils.toDouble)  double price,  List<String> images,  int? stock)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartItemModel() when $default != null:
return $default(_that.id,_that.productId,_that.quantity,_that.selectedSize,_that.selectedColor,_that.name,_that.price,_that.images,_that.stock);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'cart_id')  String id, @JsonKey(name: 'product_id')  String productId,  int quantity,  String? selectedSize,  String? selectedColor,  String? name, @JsonKey(fromJson: JsonUtils.toDouble)  double price,  List<String> images,  int? stock)  $default,) {final _that = this;
switch (_that) {
case _CartItemModel():
return $default(_that.id,_that.productId,_that.quantity,_that.selectedSize,_that.selectedColor,_that.name,_that.price,_that.images,_that.stock);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'cart_id')  String id, @JsonKey(name: 'product_id')  String productId,  int quantity,  String? selectedSize,  String? selectedColor,  String? name, @JsonKey(fromJson: JsonUtils.toDouble)  double price,  List<String> images,  int? stock)?  $default,) {final _that = this;
switch (_that) {
case _CartItemModel() when $default != null:
return $default(_that.id,_that.productId,_that.quantity,_that.selectedSize,_that.selectedColor,_that.name,_that.price,_that.images,_that.stock);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CartItemModel implements CartItemModel {
  const _CartItemModel({@JsonKey(name: 'cart_id') required this.id, @JsonKey(name: 'product_id') required this.productId, required this.quantity, this.selectedSize, this.selectedColor, this.name, @JsonKey(fromJson: JsonUtils.toDouble) required this.price, final  List<String> images = const [], this.stock}): _images = images;
  factory _CartItemModel.fromJson(Map<String, dynamic> json) => _$CartItemModelFromJson(json);

@override@JsonKey(name: 'cart_id') final  String id;
@override@JsonKey(name: 'product_id') final  String productId;
@override final  int quantity;
@override final  String? selectedSize;
@override final  String? selectedColor;
@override final  String? name;
@override@JsonKey(fromJson: JsonUtils.toDouble) final  double price;
 final  List<String> _images;
@override@JsonKey() List<String> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override final  int? stock;

/// Create a copy of CartItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartItemModelCopyWith<_CartItemModel> get copyWith => __$CartItemModelCopyWithImpl<_CartItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.selectedSize, selectedSize) || other.selectedSize == selectedSize)&&(identical(other.selectedColor, selectedColor) || other.selectedColor == selectedColor)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.stock, stock) || other.stock == stock));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,quantity,selectedSize,selectedColor,name,price,const DeepCollectionEquality().hash(_images),stock);

@override
String toString() {
  return 'CartItemModel(id: $id, productId: $productId, quantity: $quantity, selectedSize: $selectedSize, selectedColor: $selectedColor, name: $name, price: $price, images: $images, stock: $stock)';
}


}

/// @nodoc
abstract mixin class _$CartItemModelCopyWith<$Res> implements $CartItemModelCopyWith<$Res> {
  factory _$CartItemModelCopyWith(_CartItemModel value, $Res Function(_CartItemModel) _then) = __$CartItemModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'cart_id') String id,@JsonKey(name: 'product_id') String productId, int quantity, String? selectedSize, String? selectedColor, String? name,@JsonKey(fromJson: JsonUtils.toDouble) double price, List<String> images, int? stock
});




}
/// @nodoc
class __$CartItemModelCopyWithImpl<$Res>
    implements _$CartItemModelCopyWith<$Res> {
  __$CartItemModelCopyWithImpl(this._self, this._then);

  final _CartItemModel _self;
  final $Res Function(_CartItemModel) _then;

/// Create a copy of CartItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? quantity = null,Object? selectedSize = freezed,Object? selectedColor = freezed,Object? name = freezed,Object? price = null,Object? images = null,Object? stock = freezed,}) {
  return _then(_CartItemModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,selectedSize: freezed == selectedSize ? _self.selectedSize : selectedSize // ignore: cast_nullable_to_non_nullable
as String?,selectedColor: freezed == selectedColor ? _self.selectedColor : selectedColor // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<String>,stock: freezed == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
