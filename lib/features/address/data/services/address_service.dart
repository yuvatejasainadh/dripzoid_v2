import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/models/result.dart';
import '../../../../core/network/dio_provider.dart';

final addressServiceProvider = Provider<AddressService>((ref) {
  return AddressService(ref.watch(apiClientProvider));
});

class AddressService {
  final ApiClient _client;

  AddressService(this._client);

  Future<Result<List<dynamic>>> getAddresses() async {
    final result = await _client.get<dynamic>(ApiEndpoints.addresses);
    if (result is Success) {
      if (result.data is List) {
        return Success(result.data as List<dynamic>);
      } else if (result.data is Map && result.data['addresses'] is List) {
        return Success(result.data['addresses'] as List<dynamic>);
      }
      return const Success([]);
    }
    final failure = result as Failure;
    return Failure(
      failure.message,
      statusCode: failure.statusCode,
      exception: failure.exception,
    );
  }

  Future<Result<Map<String, dynamic>>> createAddress(
    Map<String, dynamic> data,
  ) async {
    return await _client.post(ApiEndpoints.addresses, data: data);
  }

  Future<Result<Map<String, dynamic>>> updateAddress(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await _client.put("${ApiEndpoints.addresses}/$id", data: data);
  }

  Future<Result<Map<String, dynamic>>> deleteAddress(String id) async {
    return await _client.delete("${ApiEndpoints.addresses}/$id");
  }

  Future<Result<Map<String, dynamic>>> setDefaultAddress(String id) async {
    return await _client.patch("${ApiEndpoints.addresses}/$id/default");
  }
}
