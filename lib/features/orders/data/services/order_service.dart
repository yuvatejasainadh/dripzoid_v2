import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/models/result.dart';

class OrderService {
  final ApiClient _client;

  OrderService(this._client);

  Future<Result<Map<String, dynamic>>> placeOrder(Map<String, dynamic> data) async {
    return await _client.post(ApiEndpoints.placeOrder, data: data);
  }

  Future<Result<dynamic>> getUserOrders() async {
    return await _client.get("/api/user/orders");
  }

  Future<Result<dynamic>> getOrderDetails(String id) async {
    return await _client.get("/api/user/orders/$id");
  }

  Future<Result<dynamic>> trackOrder(String id) async {
    return await _client.get("/api/user/orders/$id/track");
  }

  Future<Result<dynamic>> cancelOrder(String id) async {
    return await _client.put("/api/user/orders/$id/cancel");
  }

  Future<Result<dynamic>> getInvoice(String id) async {
    return await _client.get("/api/user/orders/$id/invoice");
  }
}
