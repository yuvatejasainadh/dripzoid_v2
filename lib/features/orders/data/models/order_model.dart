import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dripzoid_v2/features/address/data/models/address_model.dart';
import '../../../../core/utils/json_utils.dart';
import 'shipment_model.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

@freezed
abstract class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    required String orderNumber,
    @JsonKey(fromJson: JsonUtils.toDouble) required double totalAmount,
    required String status,
    String? paymentMethod,
    @JsonKey(name: 'shippingAddress') AddressModel? address,
    required List<OrderItemModel> items,
    ShipmentModel? shipment,
    OrderPricingModel? pricing,
    DateTime? deliveryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
}

@freezed
abstract class OrderPricingModel with _$OrderPricingModel {
  const factory OrderPricingModel({
    @JsonKey(fromJson: JsonUtils.toDouble) @Default(0.0) double productPrice,
    @JsonKey(fromJson: JsonUtils.toDouble) @Default(0.0) double fees,
    @JsonKey(fromJson: JsonUtils.toDouble) @Default(0.0) double codFee,
    @JsonKey(fromJson: JsonUtils.toDouble) @Default(0.0) double couponDiscount,
    @JsonKey(fromJson: JsonUtils.toDouble) @Default(0.0) double total,
  }) = _OrderPricingModel;

  factory OrderPricingModel.fromJson(Map<String, dynamic> json) =>
      _$OrderPricingModelFromJson(json);
}

@freezed
abstract class OrderItemModel with _$OrderItemModel {
  const factory OrderItemModel({
    required String id,
    required int quantity,
    @JsonKey(fromJson: JsonUtils.toDouble) @Default(0.0) double unitPrice,
    @JsonKey(fromJson: JsonUtils.toDouble) double? price,
    @JsonKey(name: 'options') Map<String, dynamic>? options,
    @JsonKey(name: 'name') String? productName,
    @JsonKey(name: 'image') String? productImage,
  }) = _OrderItemModel;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);
}

extension OrderItemX on OrderItemModel {
  String get productId => id;
  String? get selectedColor => options?['color'];
  String? get selectedSize => options?['size'];
}
