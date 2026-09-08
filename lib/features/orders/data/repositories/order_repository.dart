import '../../../../core/logging/app_logger.dart';
import '../../../../core/models/result.dart';
import '../models/order_model.dart';
import '../models/shipment_model.dart';
import '../services/order_service.dart';

class OrderRepository {
  final OrderService _service;

  OrderRepository(this._service);

  Future<Result<Map<String, dynamic>>> placeOrder(Map<String, dynamic> data) async {
    AppLogger.i('[OrderRepository] [placeOrder] Request initiated');
    final result = await _service.placeOrder(data);

    return switch (result) {
      Success(data: final body) => () {
          final responseData = body['data'];
          if (responseData == null || responseData is! Map) {
            return const Failure<Map<String, dynamic>>('Server response missing data block');
          }

          final orderId = responseData['orderId']?.toString();
          if (orderId == null || orderId.isEmpty) {
            return const Failure<Map<String, dynamic>>('Order created, but no order ID was returned');
          }

          AppLogger.d('[OrderRepository] [placeOrder] Success. orderId=$orderId');
          return Success<Map<String, dynamic>>(Map<String, dynamic>.from(body));
        }(),
      Failure(message: final m, statusCode: final s, exception: final e, endpoint: final ep) => () {
          AppLogger.e('[OrderRepository] [placeOrder] API Failure: $m', error: e);
          return Failure<Map<String, dynamic>>(m, statusCode: s, exception: e, endpoint: ep);
        }(),
    };
  }

  Future<Result<List<OrderModel>>> getUserOrders() async {
    AppLogger.d('[OrderRepository] [getUserOrders] Fetching orders...');
    final result = await _service.getUserOrders();
    return switch (result) {
      Success(data: final data) => () {
          List<dynamic> rawList = [];
          if (data is List) {
            rawList = data;
          } else if (data is Map) {
            rawList = data['data'] ?? data['orders'] ?? [];
          }
          final list = rawList.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
          AppLogger.d('[OrderRepository] [getUserOrders] Found ${list.length} orders');
          return Success<List<OrderModel>>(list);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.e('[OrderRepository] [getUserOrders] Failed: $m', error: e);
          return Failure<List<OrderModel>>(m, statusCode: s, exception: e);
        }(),
    };
  }

  Future<Result<OrderModel>> getOrderDetails(String id) async {
    AppLogger.d('[OrderRepository] [getOrderDetails] ID: $id');
    final result = await _service.getOrderDetails(id);
    return switch (result) {
      Success(data: final data) => () {
          final orderData = data is Map ? (data['order'] ?? data['data'] ?? data) : data;
          final order = OrderModel.fromJson(orderData as Map<String, dynamic>);
          AppLogger.d('[OrderRepository] [getOrderDetails] Loaded: ${order.orderNumber}');
          return Success<OrderModel>(order);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.e('[OrderRepository] [getOrderDetails] Failed: $m', error: e);
          return Failure<OrderModel>(m, statusCode: s, exception: e);
        }(),
    };
  }

  Future<Result<ShipmentModel>> trackOrder(String id) async {
    AppLogger.d('[OrderRepository] [trackOrder] ID: $id');
    final result = await _service.trackOrder(id);
    return switch (result) {
      Success(data: final data) => () {
          final tracking = ShipmentModel.fromJson(data['tracking'] ?? data['tracking_data'] ?? data);
          AppLogger.d('[OrderRepository] [trackOrder] Status: ${tracking.currentStatus}');
          return Success<ShipmentModel>(tracking);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.e('[OrderRepository] [trackOrder] Failed: $m', error: e);
          return Failure<ShipmentModel>(m, statusCode: s, exception: e);
        }(),
    };
  }

  Future<Result<void>> cancelOrder(String id) async {
    AppLogger.w('[OrderRepository] [cancelOrder] Cancelling ID: $id');
    final result = await _service.cancelOrder(id);
    return switch (result) {
      Success() => () {
          AppLogger.i('[OrderRepository] [cancelOrder] Cancelled successfully');
          return const Success<void>(null);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.e('[OrderRepository] [cancelOrder] Failed: $m', error: e);
          return Failure<void>(m, statusCode: s, exception: e);
        }(),
    };
  }

  Future<Result<String>> getInvoiceUrl(String id) async {
    AppLogger.d('[OrderRepository] [getInvoiceUrl] ID: $id');
    final result = await _service.getInvoice(id);
    return switch (result) {
      Success(data: final data) => () {
          final url = data['invoice']?['invoice_url'] as String;
          AppLogger.d('[OrderRepository] [getInvoiceUrl] URL: $url');
          return Success<String>(url);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.e('[OrderRepository] [getInvoiceUrl] Failed: $m', error: e);
          return Failure<String>(m, statusCode: s, exception: e);
        }(),
    };
  }
}
