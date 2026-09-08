// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => _OrderModel(
  id: json['id'] as String,
  orderNumber: json['orderNumber'] as String,
  totalAmount: JsonUtils.toDouble(json['totalAmount']),
  status: json['status'] as String,
  paymentMethod: json['paymentMethod'] as String?,
  address: json['shippingAddress'] == null
      ? null
      : AddressModel.fromJson(json['shippingAddress'] as Map<String, dynamic>),
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  shipment: json['shipment'] == null
      ? null
      : ShipmentModel.fromJson(json['shipment'] as Map<String, dynamic>),
  pricing: json['pricing'] == null
      ? null
      : OrderPricingModel.fromJson(json['pricing'] as Map<String, dynamic>),
  deliveryDate: json['deliveryDate'] == null
      ? null
      : DateTime.parse(json['deliveryDate'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$OrderModelToJson(_OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'totalAmount': instance.totalAmount,
      'status': instance.status,
      'paymentMethod': instance.paymentMethod,
      'shippingAddress': instance.address,
      'items': instance.items,
      'shipment': instance.shipment,
      'pricing': instance.pricing,
      'deliveryDate': instance.deliveryDate?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_OrderPricingModel _$OrderPricingModelFromJson(Map<String, dynamic> json) =>
    _OrderPricingModel(
      productPrice: json['productPrice'] == null
          ? 0.0
          : JsonUtils.toDouble(json['productPrice']),
      fees: json['fees'] == null ? 0.0 : JsonUtils.toDouble(json['fees']),
      codFee: json['codFee'] == null ? 0.0 : JsonUtils.toDouble(json['codFee']),
      couponDiscount: json['couponDiscount'] == null
          ? 0.0
          : JsonUtils.toDouble(json['couponDiscount']),
      total: json['total'] == null ? 0.0 : JsonUtils.toDouble(json['total']),
    );

Map<String, dynamic> _$OrderPricingModelToJson(_OrderPricingModel instance) =>
    <String, dynamic>{
      'productPrice': instance.productPrice,
      'fees': instance.fees,
      'codFee': instance.codFee,
      'couponDiscount': instance.couponDiscount,
      'total': instance.total,
    };

_OrderItemModel _$OrderItemModelFromJson(Map<String, dynamic> json) =>
    _OrderItemModel(
      id: json['id'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: json['unitPrice'] == null
          ? 0.0
          : JsonUtils.toDouble(json['unitPrice']),
      price: JsonUtils.toDouble(json['price']),
      options: json['options'] as Map<String, dynamic>?,
      productName: json['name'] as String?,
      productImage: json['image'] as String?,
    );

Map<String, dynamic> _$OrderItemModelToJson(_OrderItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'price': instance.price,
      'options': instance.options,
      'name': instance.productName,
      'image': instance.productImage,
    };
