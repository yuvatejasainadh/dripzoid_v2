// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderModel {

 String get id; String get orderNumber;@JsonKey(fromJson: JsonUtils.toDouble) double get totalAmount; String get status; String? get paymentMethod;@JsonKey(name: 'shippingAddress') AddressModel? get address; List<OrderItemModel> get items; ShipmentModel? get shipment; OrderPricingModel? get pricing; DateTime? get deliveryDate; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderModelCopyWith<OrderModel> get copyWith => _$OrderModelCopyWithImpl<OrderModel>(this as OrderModel, _$identity);

  /// Serializes this OrderModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderModel&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.address, address) || other.address == address)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.shipment, shipment) || other.shipment == shipment)&&(identical(other.pricing, pricing) || other.pricing == pricing)&&(identical(other.deliveryDate, deliveryDate) || other.deliveryDate == deliveryDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderNumber,totalAmount,status,paymentMethod,address,const DeepCollectionEquality().hash(items),shipment,pricing,deliveryDate,createdAt,updatedAt);

@override
String toString() {
  return 'OrderModel(id: $id, orderNumber: $orderNumber, totalAmount: $totalAmount, status: $status, paymentMethod: $paymentMethod, address: $address, items: $items, shipment: $shipment, pricing: $pricing, deliveryDate: $deliveryDate, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $OrderModelCopyWith<$Res>  {
  factory $OrderModelCopyWith(OrderModel value, $Res Function(OrderModel) _then) = _$OrderModelCopyWithImpl;
@useResult
$Res call({
 String id, String orderNumber,@JsonKey(fromJson: JsonUtils.toDouble) double totalAmount, String status, String? paymentMethod,@JsonKey(name: 'shippingAddress') AddressModel? address, List<OrderItemModel> items, ShipmentModel? shipment, OrderPricingModel? pricing, DateTime? deliveryDate, DateTime? createdAt, DateTime? updatedAt
});


$AddressModelCopyWith<$Res>? get address;$ShipmentModelCopyWith<$Res>? get shipment;$OrderPricingModelCopyWith<$Res>? get pricing;

}
/// @nodoc
class _$OrderModelCopyWithImpl<$Res>
    implements $OrderModelCopyWith<$Res> {
  _$OrderModelCopyWithImpl(this._self, this._then);

  final OrderModel _self;
  final $Res Function(OrderModel) _then;

/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderNumber = null,Object? totalAmount = null,Object? status = null,Object? paymentMethod = freezed,Object? address = freezed,Object? items = null,Object? shipment = freezed,Object? pricing = freezed,Object? deliveryDate = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as AddressModel?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItemModel>,shipment: freezed == shipment ? _self.shipment : shipment // ignore: cast_nullable_to_non_nullable
as ShipmentModel?,pricing: freezed == pricing ? _self.pricing : pricing // ignore: cast_nullable_to_non_nullable
as OrderPricingModel?,deliveryDate: freezed == deliveryDate ? _self.deliveryDate : deliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressModelCopyWith<$Res>? get address {
    if (_self.address == null) {
    return null;
  }

  return $AddressModelCopyWith<$Res>(_self.address!, (value) {
    return _then(_self.copyWith(address: value));
  });
}/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShipmentModelCopyWith<$Res>? get shipment {
    if (_self.shipment == null) {
    return null;
  }

  return $ShipmentModelCopyWith<$Res>(_self.shipment!, (value) {
    return _then(_self.copyWith(shipment: value));
  });
}/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderPricingModelCopyWith<$Res>? get pricing {
    if (_self.pricing == null) {
    return null;
  }

  return $OrderPricingModelCopyWith<$Res>(_self.pricing!, (value) {
    return _then(_self.copyWith(pricing: value));
  });
}
}


/// Adds pattern-matching-related methods to [OrderModel].
extension OrderModelPatterns on OrderModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderModel value)  $default,){
final _that = this;
switch (_that) {
case _OrderModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderModel value)?  $default,){
final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orderNumber, @JsonKey(fromJson: JsonUtils.toDouble)  double totalAmount,  String status,  String? paymentMethod, @JsonKey(name: 'shippingAddress')  AddressModel? address,  List<OrderItemModel> items,  ShipmentModel? shipment,  OrderPricingModel? pricing,  DateTime? deliveryDate,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
return $default(_that.id,_that.orderNumber,_that.totalAmount,_that.status,_that.paymentMethod,_that.address,_that.items,_that.shipment,_that.pricing,_that.deliveryDate,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orderNumber, @JsonKey(fromJson: JsonUtils.toDouble)  double totalAmount,  String status,  String? paymentMethod, @JsonKey(name: 'shippingAddress')  AddressModel? address,  List<OrderItemModel> items,  ShipmentModel? shipment,  OrderPricingModel? pricing,  DateTime? deliveryDate,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _OrderModel():
return $default(_that.id,_that.orderNumber,_that.totalAmount,_that.status,_that.paymentMethod,_that.address,_that.items,_that.shipment,_that.pricing,_that.deliveryDate,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orderNumber, @JsonKey(fromJson: JsonUtils.toDouble)  double totalAmount,  String status,  String? paymentMethod, @JsonKey(name: 'shippingAddress')  AddressModel? address,  List<OrderItemModel> items,  ShipmentModel? shipment,  OrderPricingModel? pricing,  DateTime? deliveryDate,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
return $default(_that.id,_that.orderNumber,_that.totalAmount,_that.status,_that.paymentMethod,_that.address,_that.items,_that.shipment,_that.pricing,_that.deliveryDate,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderModel implements OrderModel {
  const _OrderModel({required this.id, required this.orderNumber, @JsonKey(fromJson: JsonUtils.toDouble) required this.totalAmount, required this.status, this.paymentMethod, @JsonKey(name: 'shippingAddress') this.address, required final  List<OrderItemModel> items, this.shipment, this.pricing, this.deliveryDate, this.createdAt, this.updatedAt}): _items = items;
  factory _OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);

@override final  String id;
@override final  String orderNumber;
@override@JsonKey(fromJson: JsonUtils.toDouble) final  double totalAmount;
@override final  String status;
@override final  String? paymentMethod;
@override@JsonKey(name: 'shippingAddress') final  AddressModel? address;
 final  List<OrderItemModel> _items;
@override List<OrderItemModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  ShipmentModel? shipment;
@override final  OrderPricingModel? pricing;
@override final  DateTime? deliveryDate;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderModelCopyWith<_OrderModel> get copyWith => __$OrderModelCopyWithImpl<_OrderModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderModel&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.address, address) || other.address == address)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.shipment, shipment) || other.shipment == shipment)&&(identical(other.pricing, pricing) || other.pricing == pricing)&&(identical(other.deliveryDate, deliveryDate) || other.deliveryDate == deliveryDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderNumber,totalAmount,status,paymentMethod,address,const DeepCollectionEquality().hash(_items),shipment,pricing,deliveryDate,createdAt,updatedAt);

@override
String toString() {
  return 'OrderModel(id: $id, orderNumber: $orderNumber, totalAmount: $totalAmount, status: $status, paymentMethod: $paymentMethod, address: $address, items: $items, shipment: $shipment, pricing: $pricing, deliveryDate: $deliveryDate, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$OrderModelCopyWith<$Res> implements $OrderModelCopyWith<$Res> {
  factory _$OrderModelCopyWith(_OrderModel value, $Res Function(_OrderModel) _then) = __$OrderModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String orderNumber,@JsonKey(fromJson: JsonUtils.toDouble) double totalAmount, String status, String? paymentMethod,@JsonKey(name: 'shippingAddress') AddressModel? address, List<OrderItemModel> items, ShipmentModel? shipment, OrderPricingModel? pricing, DateTime? deliveryDate, DateTime? createdAt, DateTime? updatedAt
});


@override $AddressModelCopyWith<$Res>? get address;@override $ShipmentModelCopyWith<$Res>? get shipment;@override $OrderPricingModelCopyWith<$Res>? get pricing;

}
/// @nodoc
class __$OrderModelCopyWithImpl<$Res>
    implements _$OrderModelCopyWith<$Res> {
  __$OrderModelCopyWithImpl(this._self, this._then);

  final _OrderModel _self;
  final $Res Function(_OrderModel) _then;

/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderNumber = null,Object? totalAmount = null,Object? status = null,Object? paymentMethod = freezed,Object? address = freezed,Object? items = null,Object? shipment = freezed,Object? pricing = freezed,Object? deliveryDate = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_OrderModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as AddressModel?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItemModel>,shipment: freezed == shipment ? _self.shipment : shipment // ignore: cast_nullable_to_non_nullable
as ShipmentModel?,pricing: freezed == pricing ? _self.pricing : pricing // ignore: cast_nullable_to_non_nullable
as OrderPricingModel?,deliveryDate: freezed == deliveryDate ? _self.deliveryDate : deliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressModelCopyWith<$Res>? get address {
    if (_self.address == null) {
    return null;
  }

  return $AddressModelCopyWith<$Res>(_self.address!, (value) {
    return _then(_self.copyWith(address: value));
  });
}/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShipmentModelCopyWith<$Res>? get shipment {
    if (_self.shipment == null) {
    return null;
  }

  return $ShipmentModelCopyWith<$Res>(_self.shipment!, (value) {
    return _then(_self.copyWith(shipment: value));
  });
}/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderPricingModelCopyWith<$Res>? get pricing {
    if (_self.pricing == null) {
    return null;
  }

  return $OrderPricingModelCopyWith<$Res>(_self.pricing!, (value) {
    return _then(_self.copyWith(pricing: value));
  });
}
}


/// @nodoc
mixin _$OrderPricingModel {

@JsonKey(fromJson: JsonUtils.toDouble) double get productPrice;@JsonKey(fromJson: JsonUtils.toDouble) double get fees;@JsonKey(fromJson: JsonUtils.toDouble) double get codFee;@JsonKey(fromJson: JsonUtils.toDouble) double get couponDiscount;@JsonKey(fromJson: JsonUtils.toDouble) double get total;
/// Create a copy of OrderPricingModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderPricingModelCopyWith<OrderPricingModel> get copyWith => _$OrderPricingModelCopyWithImpl<OrderPricingModel>(this as OrderPricingModel, _$identity);

  /// Serializes this OrderPricingModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderPricingModel&&(identical(other.productPrice, productPrice) || other.productPrice == productPrice)&&(identical(other.fees, fees) || other.fees == fees)&&(identical(other.codFee, codFee) || other.codFee == codFee)&&(identical(other.couponDiscount, couponDiscount) || other.couponDiscount == couponDiscount)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productPrice,fees,codFee,couponDiscount,total);

@override
String toString() {
  return 'OrderPricingModel(productPrice: $productPrice, fees: $fees, codFee: $codFee, couponDiscount: $couponDiscount, total: $total)';
}


}

/// @nodoc
abstract mixin class $OrderPricingModelCopyWith<$Res>  {
  factory $OrderPricingModelCopyWith(OrderPricingModel value, $Res Function(OrderPricingModel) _then) = _$OrderPricingModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: JsonUtils.toDouble) double productPrice,@JsonKey(fromJson: JsonUtils.toDouble) double fees,@JsonKey(fromJson: JsonUtils.toDouble) double codFee,@JsonKey(fromJson: JsonUtils.toDouble) double couponDiscount,@JsonKey(fromJson: JsonUtils.toDouble) double total
});




}
/// @nodoc
class _$OrderPricingModelCopyWithImpl<$Res>
    implements $OrderPricingModelCopyWith<$Res> {
  _$OrderPricingModelCopyWithImpl(this._self, this._then);

  final OrderPricingModel _self;
  final $Res Function(OrderPricingModel) _then;

/// Create a copy of OrderPricingModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productPrice = null,Object? fees = null,Object? codFee = null,Object? couponDiscount = null,Object? total = null,}) {
  return _then(_self.copyWith(
productPrice: null == productPrice ? _self.productPrice : productPrice // ignore: cast_nullable_to_non_nullable
as double,fees: null == fees ? _self.fees : fees // ignore: cast_nullable_to_non_nullable
as double,codFee: null == codFee ? _self.codFee : codFee // ignore: cast_nullable_to_non_nullable
as double,couponDiscount: null == couponDiscount ? _self.couponDiscount : couponDiscount // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderPricingModel].
extension OrderPricingModelPatterns on OrderPricingModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderPricingModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderPricingModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderPricingModel value)  $default,){
final _that = this;
switch (_that) {
case _OrderPricingModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderPricingModel value)?  $default,){
final _that = this;
switch (_that) {
case _OrderPricingModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: JsonUtils.toDouble)  double productPrice, @JsonKey(fromJson: JsonUtils.toDouble)  double fees, @JsonKey(fromJson: JsonUtils.toDouble)  double codFee, @JsonKey(fromJson: JsonUtils.toDouble)  double couponDiscount, @JsonKey(fromJson: JsonUtils.toDouble)  double total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderPricingModel() when $default != null:
return $default(_that.productPrice,_that.fees,_that.codFee,_that.couponDiscount,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: JsonUtils.toDouble)  double productPrice, @JsonKey(fromJson: JsonUtils.toDouble)  double fees, @JsonKey(fromJson: JsonUtils.toDouble)  double codFee, @JsonKey(fromJson: JsonUtils.toDouble)  double couponDiscount, @JsonKey(fromJson: JsonUtils.toDouble)  double total)  $default,) {final _that = this;
switch (_that) {
case _OrderPricingModel():
return $default(_that.productPrice,_that.fees,_that.codFee,_that.couponDiscount,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: JsonUtils.toDouble)  double productPrice, @JsonKey(fromJson: JsonUtils.toDouble)  double fees, @JsonKey(fromJson: JsonUtils.toDouble)  double codFee, @JsonKey(fromJson: JsonUtils.toDouble)  double couponDiscount, @JsonKey(fromJson: JsonUtils.toDouble)  double total)?  $default,) {final _that = this;
switch (_that) {
case _OrderPricingModel() when $default != null:
return $default(_that.productPrice,_that.fees,_that.codFee,_that.couponDiscount,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderPricingModel implements OrderPricingModel {
  const _OrderPricingModel({@JsonKey(fromJson: JsonUtils.toDouble) this.productPrice = 0.0, @JsonKey(fromJson: JsonUtils.toDouble) this.fees = 0.0, @JsonKey(fromJson: JsonUtils.toDouble) this.codFee = 0.0, @JsonKey(fromJson: JsonUtils.toDouble) this.couponDiscount = 0.0, @JsonKey(fromJson: JsonUtils.toDouble) this.total = 0.0});
  factory _OrderPricingModel.fromJson(Map<String, dynamic> json) => _$OrderPricingModelFromJson(json);

@override@JsonKey(fromJson: JsonUtils.toDouble) final  double productPrice;
@override@JsonKey(fromJson: JsonUtils.toDouble) final  double fees;
@override@JsonKey(fromJson: JsonUtils.toDouble) final  double codFee;
@override@JsonKey(fromJson: JsonUtils.toDouble) final  double couponDiscount;
@override@JsonKey(fromJson: JsonUtils.toDouble) final  double total;

/// Create a copy of OrderPricingModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderPricingModelCopyWith<_OrderPricingModel> get copyWith => __$OrderPricingModelCopyWithImpl<_OrderPricingModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderPricingModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderPricingModel&&(identical(other.productPrice, productPrice) || other.productPrice == productPrice)&&(identical(other.fees, fees) || other.fees == fees)&&(identical(other.codFee, codFee) || other.codFee == codFee)&&(identical(other.couponDiscount, couponDiscount) || other.couponDiscount == couponDiscount)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productPrice,fees,codFee,couponDiscount,total);

@override
String toString() {
  return 'OrderPricingModel(productPrice: $productPrice, fees: $fees, codFee: $codFee, couponDiscount: $couponDiscount, total: $total)';
}


}

/// @nodoc
abstract mixin class _$OrderPricingModelCopyWith<$Res> implements $OrderPricingModelCopyWith<$Res> {
  factory _$OrderPricingModelCopyWith(_OrderPricingModel value, $Res Function(_OrderPricingModel) _then) = __$OrderPricingModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: JsonUtils.toDouble) double productPrice,@JsonKey(fromJson: JsonUtils.toDouble) double fees,@JsonKey(fromJson: JsonUtils.toDouble) double codFee,@JsonKey(fromJson: JsonUtils.toDouble) double couponDiscount,@JsonKey(fromJson: JsonUtils.toDouble) double total
});




}
/// @nodoc
class __$OrderPricingModelCopyWithImpl<$Res>
    implements _$OrderPricingModelCopyWith<$Res> {
  __$OrderPricingModelCopyWithImpl(this._self, this._then);

  final _OrderPricingModel _self;
  final $Res Function(_OrderPricingModel) _then;

/// Create a copy of OrderPricingModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productPrice = null,Object? fees = null,Object? codFee = null,Object? couponDiscount = null,Object? total = null,}) {
  return _then(_OrderPricingModel(
productPrice: null == productPrice ? _self.productPrice : productPrice // ignore: cast_nullable_to_non_nullable
as double,fees: null == fees ? _self.fees : fees // ignore: cast_nullable_to_non_nullable
as double,codFee: null == codFee ? _self.codFee : codFee // ignore: cast_nullable_to_non_nullable
as double,couponDiscount: null == couponDiscount ? _self.couponDiscount : couponDiscount // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$OrderItemModel {

 String get id; int get quantity;@JsonKey(fromJson: JsonUtils.toDouble) double get unitPrice;@JsonKey(fromJson: JsonUtils.toDouble) double? get price;@JsonKey(name: 'options') Map<String, dynamic>? get options;@JsonKey(name: 'name') String? get productName;@JsonKey(name: 'image') String? get productImage;
/// Create a copy of OrderItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderItemModelCopyWith<OrderItemModel> get copyWith => _$OrderItemModelCopyWithImpl<OrderItemModel>(this as OrderItemModel, _$identity);

  /// Serializes this OrderItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other.options, options)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.productImage, productImage) || other.productImage == productImage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,quantity,unitPrice,price,const DeepCollectionEquality().hash(options),productName,productImage);

@override
String toString() {
  return 'OrderItemModel(id: $id, quantity: $quantity, unitPrice: $unitPrice, price: $price, options: $options, productName: $productName, productImage: $productImage)';
}


}

/// @nodoc
abstract mixin class $OrderItemModelCopyWith<$Res>  {
  factory $OrderItemModelCopyWith(OrderItemModel value, $Res Function(OrderItemModel) _then) = _$OrderItemModelCopyWithImpl;
@useResult
$Res call({
 String id, int quantity,@JsonKey(fromJson: JsonUtils.toDouble) double unitPrice,@JsonKey(fromJson: JsonUtils.toDouble) double? price,@JsonKey(name: 'options') Map<String, dynamic>? options,@JsonKey(name: 'name') String? productName,@JsonKey(name: 'image') String? productImage
});




}
/// @nodoc
class _$OrderItemModelCopyWithImpl<$Res>
    implements $OrderItemModelCopyWith<$Res> {
  _$OrderItemModelCopyWithImpl(this._self, this._then);

  final OrderItemModel _self;
  final $Res Function(OrderItemModel) _then;

/// Create a copy of OrderItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? quantity = null,Object? unitPrice = null,Object? price = freezed,Object? options = freezed,Object? productName = freezed,Object? productImage = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,options: freezed == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,productImage: freezed == productImage ? _self.productImage : productImage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderItemModel].
extension OrderItemModelPatterns on OrderItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderItemModel value)  $default,){
final _that = this;
switch (_that) {
case _OrderItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _OrderItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int quantity, @JsonKey(fromJson: JsonUtils.toDouble)  double unitPrice, @JsonKey(fromJson: JsonUtils.toDouble)  double? price, @JsonKey(name: 'options')  Map<String, dynamic>? options, @JsonKey(name: 'name')  String? productName, @JsonKey(name: 'image')  String? productImage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderItemModel() when $default != null:
return $default(_that.id,_that.quantity,_that.unitPrice,_that.price,_that.options,_that.productName,_that.productImage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int quantity, @JsonKey(fromJson: JsonUtils.toDouble)  double unitPrice, @JsonKey(fromJson: JsonUtils.toDouble)  double? price, @JsonKey(name: 'options')  Map<String, dynamic>? options, @JsonKey(name: 'name')  String? productName, @JsonKey(name: 'image')  String? productImage)  $default,) {final _that = this;
switch (_that) {
case _OrderItemModel():
return $default(_that.id,_that.quantity,_that.unitPrice,_that.price,_that.options,_that.productName,_that.productImage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int quantity, @JsonKey(fromJson: JsonUtils.toDouble)  double unitPrice, @JsonKey(fromJson: JsonUtils.toDouble)  double? price, @JsonKey(name: 'options')  Map<String, dynamic>? options, @JsonKey(name: 'name')  String? productName, @JsonKey(name: 'image')  String? productImage)?  $default,) {final _that = this;
switch (_that) {
case _OrderItemModel() when $default != null:
return $default(_that.id,_that.quantity,_that.unitPrice,_that.price,_that.options,_that.productName,_that.productImage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderItemModel implements OrderItemModel {
  const _OrderItemModel({required this.id, required this.quantity, @JsonKey(fromJson: JsonUtils.toDouble) this.unitPrice = 0.0, @JsonKey(fromJson: JsonUtils.toDouble) this.price, @JsonKey(name: 'options') final  Map<String, dynamic>? options, @JsonKey(name: 'name') this.productName, @JsonKey(name: 'image') this.productImage}): _options = options;
  factory _OrderItemModel.fromJson(Map<String, dynamic> json) => _$OrderItemModelFromJson(json);

@override final  String id;
@override final  int quantity;
@override@JsonKey(fromJson: JsonUtils.toDouble) final  double unitPrice;
@override@JsonKey(fromJson: JsonUtils.toDouble) final  double? price;
 final  Map<String, dynamic>? _options;
@override@JsonKey(name: 'options') Map<String, dynamic>? get options {
  final value = _options;
  if (value == null) return null;
  if (_options is EqualUnmodifiableMapView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'name') final  String? productName;
@override@JsonKey(name: 'image') final  String? productImage;

/// Create a copy of OrderItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderItemModelCopyWith<_OrderItemModel> get copyWith => __$OrderItemModelCopyWithImpl<_OrderItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other._options, _options)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.productImage, productImage) || other.productImage == productImage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,quantity,unitPrice,price,const DeepCollectionEquality().hash(_options),productName,productImage);

@override
String toString() {
  return 'OrderItemModel(id: $id, quantity: $quantity, unitPrice: $unitPrice, price: $price, options: $options, productName: $productName, productImage: $productImage)';
}


}

/// @nodoc
abstract mixin class _$OrderItemModelCopyWith<$Res> implements $OrderItemModelCopyWith<$Res> {
  factory _$OrderItemModelCopyWith(_OrderItemModel value, $Res Function(_OrderItemModel) _then) = __$OrderItemModelCopyWithImpl;
@override @useResult
$Res call({
 String id, int quantity,@JsonKey(fromJson: JsonUtils.toDouble) double unitPrice,@JsonKey(fromJson: JsonUtils.toDouble) double? price,@JsonKey(name: 'options') Map<String, dynamic>? options,@JsonKey(name: 'name') String? productName,@JsonKey(name: 'image') String? productImage
});




}
/// @nodoc
class __$OrderItemModelCopyWithImpl<$Res>
    implements _$OrderItemModelCopyWith<$Res> {
  __$OrderItemModelCopyWithImpl(this._self, this._then);

  final _OrderItemModel _self;
  final $Res Function(_OrderItemModel) _then;

/// Create a copy of OrderItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? quantity = null,Object? unitPrice = null,Object? price = freezed,Object? options = freezed,Object? productName = freezed,Object? productImage = freezed,}) {
  return _then(_OrderItemModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,options: freezed == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,productImage: freezed == productImage ? _self.productImage : productImage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
