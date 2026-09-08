// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductModel {

 String get id; String get name; String get slug;@JsonKey(fromJson: JsonUtils.toDouble) double get price;@JsonKey(fromJson: JsonUtils.toDouble) double? get originalPrice;@JsonKey(fromJson: JsonUtils.toDouble) double? get actualPrice;@JsonKey(fromJson: JsonUtils.toDouble) double? get rating; String? get description; int get stock; int get sold; bool get featured; List<String> get images; List<dynamic> get colors; List<String> get sizes; Map<String, int>? get sizeStock; String? get category; String? get subcategory; String? get categorySlug; int get totalStock; DateTime? get createdAt; DateTime? get updatedAt; List<dynamic> get reviews;
/// Create a copy of ProductModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductModelCopyWith<ProductModel> get copyWith => _$ProductModelCopyWithImpl<ProductModel>(this as ProductModel, _$identity);

  /// Serializes this ProductModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.price, price) || other.price == price)&&(identical(other.originalPrice, originalPrice) || other.originalPrice == originalPrice)&&(identical(other.actualPrice, actualPrice) || other.actualPrice == actualPrice)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.description, description) || other.description == description)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.sold, sold) || other.sold == sold)&&(identical(other.featured, featured) || other.featured == featured)&&const DeepCollectionEquality().equals(other.images, images)&&const DeepCollectionEquality().equals(other.colors, colors)&&const DeepCollectionEquality().equals(other.sizes, sizes)&&const DeepCollectionEquality().equals(other.sizeStock, sizeStock)&&(identical(other.category, category) || other.category == category)&&(identical(other.subcategory, subcategory) || other.subcategory == subcategory)&&(identical(other.categorySlug, categorySlug) || other.categorySlug == categorySlug)&&(identical(other.totalStock, totalStock) || other.totalStock == totalStock)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.reviews, reviews));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,slug,price,originalPrice,actualPrice,rating,description,stock,sold,featured,const DeepCollectionEquality().hash(images),const DeepCollectionEquality().hash(colors),const DeepCollectionEquality().hash(sizes),const DeepCollectionEquality().hash(sizeStock),category,subcategory,categorySlug,totalStock,createdAt,updatedAt,const DeepCollectionEquality().hash(reviews)]);

@override
String toString() {
  return 'ProductModel(id: $id, name: $name, slug: $slug, price: $price, originalPrice: $originalPrice, actualPrice: $actualPrice, rating: $rating, description: $description, stock: $stock, sold: $sold, featured: $featured, images: $images, colors: $colors, sizes: $sizes, sizeStock: $sizeStock, category: $category, subcategory: $subcategory, categorySlug: $categorySlug, totalStock: $totalStock, createdAt: $createdAt, updatedAt: $updatedAt, reviews: $reviews)';
}


}

/// @nodoc
abstract mixin class $ProductModelCopyWith<$Res>  {
  factory $ProductModelCopyWith(ProductModel value, $Res Function(ProductModel) _then) = _$ProductModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String slug,@JsonKey(fromJson: JsonUtils.toDouble) double price,@JsonKey(fromJson: JsonUtils.toDouble) double? originalPrice,@JsonKey(fromJson: JsonUtils.toDouble) double? actualPrice,@JsonKey(fromJson: JsonUtils.toDouble) double? rating, String? description, int stock, int sold, bool featured, List<String> images, List<dynamic> colors, List<String> sizes, Map<String, int>? sizeStock, String? category, String? subcategory, String? categorySlug, int totalStock, DateTime? createdAt, DateTime? updatedAt, List<dynamic> reviews
});




}
/// @nodoc
class _$ProductModelCopyWithImpl<$Res>
    implements $ProductModelCopyWith<$Res> {
  _$ProductModelCopyWithImpl(this._self, this._then);

  final ProductModel _self;
  final $Res Function(ProductModel) _then;

/// Create a copy of ProductModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? slug = null,Object? price = null,Object? originalPrice = freezed,Object? actualPrice = freezed,Object? rating = freezed,Object? description = freezed,Object? stock = null,Object? sold = null,Object? featured = null,Object? images = null,Object? colors = null,Object? sizes = null,Object? sizeStock = freezed,Object? category = freezed,Object? subcategory = freezed,Object? categorySlug = freezed,Object? totalStock = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? reviews = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,originalPrice: freezed == originalPrice ? _self.originalPrice : originalPrice // ignore: cast_nullable_to_non_nullable
as double?,actualPrice: freezed == actualPrice ? _self.actualPrice : actualPrice // ignore: cast_nullable_to_non_nullable
as double?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int,sold: null == sold ? _self.sold : sold // ignore: cast_nullable_to_non_nullable
as int,featured: null == featured ? _self.featured : featured // ignore: cast_nullable_to_non_nullable
as bool,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<String>,colors: null == colors ? _self.colors : colors // ignore: cast_nullable_to_non_nullable
as List<dynamic>,sizes: null == sizes ? _self.sizes : sizes // ignore: cast_nullable_to_non_nullable
as List<String>,sizeStock: freezed == sizeStock ? _self.sizeStock : sizeStock // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,subcategory: freezed == subcategory ? _self.subcategory : subcategory // ignore: cast_nullable_to_non_nullable
as String?,categorySlug: freezed == categorySlug ? _self.categorySlug : categorySlug // ignore: cast_nullable_to_non_nullable
as String?,totalStock: null == totalStock ? _self.totalStock : totalStock // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviews: null == reviews ? _self.reviews : reviews // ignore: cast_nullable_to_non_nullable
as List<dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductModel].
extension ProductModelPatterns on ProductModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductModel value)  $default,){
final _that = this;
switch (_that) {
case _ProductModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductModel value)?  $default,){
final _that = this;
switch (_that) {
case _ProductModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String slug, @JsonKey(fromJson: JsonUtils.toDouble)  double price, @JsonKey(fromJson: JsonUtils.toDouble)  double? originalPrice, @JsonKey(fromJson: JsonUtils.toDouble)  double? actualPrice, @JsonKey(fromJson: JsonUtils.toDouble)  double? rating,  String? description,  int stock,  int sold,  bool featured,  List<String> images,  List<dynamic> colors,  List<String> sizes,  Map<String, int>? sizeStock,  String? category,  String? subcategory,  String? categorySlug,  int totalStock,  DateTime? createdAt,  DateTime? updatedAt,  List<dynamic> reviews)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductModel() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.price,_that.originalPrice,_that.actualPrice,_that.rating,_that.description,_that.stock,_that.sold,_that.featured,_that.images,_that.colors,_that.sizes,_that.sizeStock,_that.category,_that.subcategory,_that.categorySlug,_that.totalStock,_that.createdAt,_that.updatedAt,_that.reviews);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String slug, @JsonKey(fromJson: JsonUtils.toDouble)  double price, @JsonKey(fromJson: JsonUtils.toDouble)  double? originalPrice, @JsonKey(fromJson: JsonUtils.toDouble)  double? actualPrice, @JsonKey(fromJson: JsonUtils.toDouble)  double? rating,  String? description,  int stock,  int sold,  bool featured,  List<String> images,  List<dynamic> colors,  List<String> sizes,  Map<String, int>? sizeStock,  String? category,  String? subcategory,  String? categorySlug,  int totalStock,  DateTime? createdAt,  DateTime? updatedAt,  List<dynamic> reviews)  $default,) {final _that = this;
switch (_that) {
case _ProductModel():
return $default(_that.id,_that.name,_that.slug,_that.price,_that.originalPrice,_that.actualPrice,_that.rating,_that.description,_that.stock,_that.sold,_that.featured,_that.images,_that.colors,_that.sizes,_that.sizeStock,_that.category,_that.subcategory,_that.categorySlug,_that.totalStock,_that.createdAt,_that.updatedAt,_that.reviews);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String slug, @JsonKey(fromJson: JsonUtils.toDouble)  double price, @JsonKey(fromJson: JsonUtils.toDouble)  double? originalPrice, @JsonKey(fromJson: JsonUtils.toDouble)  double? actualPrice, @JsonKey(fromJson: JsonUtils.toDouble)  double? rating,  String? description,  int stock,  int sold,  bool featured,  List<String> images,  List<dynamic> colors,  List<String> sizes,  Map<String, int>? sizeStock,  String? category,  String? subcategory,  String? categorySlug,  int totalStock,  DateTime? createdAt,  DateTime? updatedAt,  List<dynamic> reviews)?  $default,) {final _that = this;
switch (_that) {
case _ProductModel() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.price,_that.originalPrice,_that.actualPrice,_that.rating,_that.description,_that.stock,_that.sold,_that.featured,_that.images,_that.colors,_that.sizes,_that.sizeStock,_that.category,_that.subcategory,_that.categorySlug,_that.totalStock,_that.createdAt,_that.updatedAt,_that.reviews);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductModel implements ProductModel {
  const _ProductModel({required this.id, required this.name, required this.slug, @JsonKey(fromJson: JsonUtils.toDouble) required this.price, @JsonKey(fromJson: JsonUtils.toDouble) this.originalPrice, @JsonKey(fromJson: JsonUtils.toDouble) this.actualPrice, @JsonKey(fromJson: JsonUtils.toDouble) this.rating, this.description, this.stock = 0, this.sold = 0, this.featured = false, final  List<String> images = const [], final  List<dynamic> colors = const [], final  List<String> sizes = const [], final  Map<String, int>? sizeStock, this.category, this.subcategory, this.categorySlug, this.totalStock = 0, this.createdAt, this.updatedAt, final  List<dynamic> reviews = const []}): _images = images,_colors = colors,_sizes = sizes,_sizeStock = sizeStock,_reviews = reviews;
  factory _ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String slug;
@override@JsonKey(fromJson: JsonUtils.toDouble) final  double price;
@override@JsonKey(fromJson: JsonUtils.toDouble) final  double? originalPrice;
@override@JsonKey(fromJson: JsonUtils.toDouble) final  double? actualPrice;
@override@JsonKey(fromJson: JsonUtils.toDouble) final  double? rating;
@override final  String? description;
@override@JsonKey() final  int stock;
@override@JsonKey() final  int sold;
@override@JsonKey() final  bool featured;
 final  List<String> _images;
@override@JsonKey() List<String> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

 final  List<dynamic> _colors;
@override@JsonKey() List<dynamic> get colors {
  if (_colors is EqualUnmodifiableListView) return _colors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_colors);
}

 final  List<String> _sizes;
@override@JsonKey() List<String> get sizes {
  if (_sizes is EqualUnmodifiableListView) return _sizes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sizes);
}

 final  Map<String, int>? _sizeStock;
@override Map<String, int>? get sizeStock {
  final value = _sizeStock;
  if (value == null) return null;
  if (_sizeStock is EqualUnmodifiableMapView) return _sizeStock;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? category;
@override final  String? subcategory;
@override final  String? categorySlug;
@override@JsonKey() final  int totalStock;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
 final  List<dynamic> _reviews;
@override@JsonKey() List<dynamic> get reviews {
  if (_reviews is EqualUnmodifiableListView) return _reviews;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reviews);
}


/// Create a copy of ProductModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductModelCopyWith<_ProductModel> get copyWith => __$ProductModelCopyWithImpl<_ProductModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.price, price) || other.price == price)&&(identical(other.originalPrice, originalPrice) || other.originalPrice == originalPrice)&&(identical(other.actualPrice, actualPrice) || other.actualPrice == actualPrice)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.description, description) || other.description == description)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.sold, sold) || other.sold == sold)&&(identical(other.featured, featured) || other.featured == featured)&&const DeepCollectionEquality().equals(other._images, _images)&&const DeepCollectionEquality().equals(other._colors, _colors)&&const DeepCollectionEquality().equals(other._sizes, _sizes)&&const DeepCollectionEquality().equals(other._sizeStock, _sizeStock)&&(identical(other.category, category) || other.category == category)&&(identical(other.subcategory, subcategory) || other.subcategory == subcategory)&&(identical(other.categorySlug, categorySlug) || other.categorySlug == categorySlug)&&(identical(other.totalStock, totalStock) || other.totalStock == totalStock)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._reviews, _reviews));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,slug,price,originalPrice,actualPrice,rating,description,stock,sold,featured,const DeepCollectionEquality().hash(_images),const DeepCollectionEquality().hash(_colors),const DeepCollectionEquality().hash(_sizes),const DeepCollectionEquality().hash(_sizeStock),category,subcategory,categorySlug,totalStock,createdAt,updatedAt,const DeepCollectionEquality().hash(_reviews)]);

@override
String toString() {
  return 'ProductModel(id: $id, name: $name, slug: $slug, price: $price, originalPrice: $originalPrice, actualPrice: $actualPrice, rating: $rating, description: $description, stock: $stock, sold: $sold, featured: $featured, images: $images, colors: $colors, sizes: $sizes, sizeStock: $sizeStock, category: $category, subcategory: $subcategory, categorySlug: $categorySlug, totalStock: $totalStock, createdAt: $createdAt, updatedAt: $updatedAt, reviews: $reviews)';
}


}

/// @nodoc
abstract mixin class _$ProductModelCopyWith<$Res> implements $ProductModelCopyWith<$Res> {
  factory _$ProductModelCopyWith(_ProductModel value, $Res Function(_ProductModel) _then) = __$ProductModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String slug,@JsonKey(fromJson: JsonUtils.toDouble) double price,@JsonKey(fromJson: JsonUtils.toDouble) double? originalPrice,@JsonKey(fromJson: JsonUtils.toDouble) double? actualPrice,@JsonKey(fromJson: JsonUtils.toDouble) double? rating, String? description, int stock, int sold, bool featured, List<String> images, List<dynamic> colors, List<String> sizes, Map<String, int>? sizeStock, String? category, String? subcategory, String? categorySlug, int totalStock, DateTime? createdAt, DateTime? updatedAt, List<dynamic> reviews
});




}
/// @nodoc
class __$ProductModelCopyWithImpl<$Res>
    implements _$ProductModelCopyWith<$Res> {
  __$ProductModelCopyWithImpl(this._self, this._then);

  final _ProductModel _self;
  final $Res Function(_ProductModel) _then;

/// Create a copy of ProductModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? slug = null,Object? price = null,Object? originalPrice = freezed,Object? actualPrice = freezed,Object? rating = freezed,Object? description = freezed,Object? stock = null,Object? sold = null,Object? featured = null,Object? images = null,Object? colors = null,Object? sizes = null,Object? sizeStock = freezed,Object? category = freezed,Object? subcategory = freezed,Object? categorySlug = freezed,Object? totalStock = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? reviews = null,}) {
  return _then(_ProductModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,originalPrice: freezed == originalPrice ? _self.originalPrice : originalPrice // ignore: cast_nullable_to_non_nullable
as double?,actualPrice: freezed == actualPrice ? _self.actualPrice : actualPrice // ignore: cast_nullable_to_non_nullable
as double?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int,sold: null == sold ? _self.sold : sold // ignore: cast_nullable_to_non_nullable
as int,featured: null == featured ? _self.featured : featured // ignore: cast_nullable_to_non_nullable
as bool,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<String>,colors: null == colors ? _self._colors : colors // ignore: cast_nullable_to_non_nullable
as List<dynamic>,sizes: null == sizes ? _self._sizes : sizes // ignore: cast_nullable_to_non_nullable
as List<String>,sizeStock: freezed == sizeStock ? _self._sizeStock : sizeStock // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,subcategory: freezed == subcategory ? _self.subcategory : subcategory // ignore: cast_nullable_to_non_nullable
as String?,categorySlug: freezed == categorySlug ? _self.categorySlug : categorySlug // ignore: cast_nullable_to_non_nullable
as String?,totalStock: null == totalStock ? _self.totalStock : totalStock // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviews: null == reviews ? _self._reviews : reviews // ignore: cast_nullable_to_non_nullable
as List<dynamic>,
  ));
}


}

// dart format on
