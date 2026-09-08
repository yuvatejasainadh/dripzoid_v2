import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/models/result.dart';

class PaymentService {
  final ApiClient _client;

  PaymentService(this._client);

  Future<Result<Map<String, dynamic>>> createRazorpayOrder(Map<String, dynamic> data) async {
    return await _client.post(ApiEndpoints.razorpayCreateOrder, data: data);
  }

  Future<Result<Map<String, dynamic>>> verifyRazorpayPayment(Map<String, dynamic> data) async {
    return await _client.post(ApiEndpoints.razorpayVerify, data: data);
  }
}
