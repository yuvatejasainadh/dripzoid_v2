import '../../../../core/models/result.dart';
import '../services/payment_service.dart';

class PaymentRepository {
  final PaymentService _service;

  PaymentRepository(this._service);

  Future<Result<Map<String, dynamic>>> createRazorpayOrder(Map<String, dynamic> data) async {
    return await _service.createRazorpayOrder(data);
  }

  Future<Result<Map<String, dynamic>>> verifyRazorpayPayment(Map<String, dynamic> data) async {
    return await _service.verifyRazorpayPayment(data);
  }
}
