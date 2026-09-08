import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/result.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepository(ref.watch(addressServiceProvider));
});

class AddressRepository {
  final AddressService _service;

  AddressRepository(this._service);

  Future<Result<List<AddressModel>>> getAddresses() async {
    final result = await _service.getAddresses();
    if (result is Success<List<dynamic>>) {
      return Success(
        result.data
            .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    final failure = result as Failure;
    return Failure(
      failure.message,
      statusCode: failure.statusCode,
      exception: failure.exception,
    );
  }

  Future<Result<AddressModel>> createAddress(Map<String, dynamic> data) async {
    final result = await _service.createAddress(data);
    if (result is Success<Map<String, dynamic>>) {
      final addressData = result.data['address'] ?? result.data;
      return Success(AddressModel.fromJson(addressData as Map<String, dynamic>));
    }
    final failure = result as Failure;
    return Failure(
      failure.message,
      statusCode: failure.statusCode,
      exception: failure.exception,
    );
  }

  Future<Result<AddressModel>> updateAddress(
    String id,
    Map<String, dynamic> data,
  ) async {
    final result = await _service.updateAddress(id, data);
    if (result is Success<Map<String, dynamic>>) {
      final addressData = result.data['address'] ?? result.data;
      return Success(AddressModel.fromJson(addressData as Map<String, dynamic>));
    }
    final failure = result as Failure;
    return Failure(
      failure.message,
      statusCode: failure.statusCode,
      exception: failure.exception,
    );
  }

  Future<Result<void>> deleteAddress(String id) async {
    final result = await _service.deleteAddress(id);
    if (result is Success) return const Success(null);
    final failure = result as Failure;
    return Failure(
      failure.message,
      statusCode: failure.statusCode,
      exception: failure.exception,
    );
  }

  Future<Result<void>> setDefaultAddress(String id) async {
    final result = await _service.setDefaultAddress(id);
    if (result is Success) return const Success(null);
    final failure = result as Failure;
    return Failure(
      failure.message,
      statusCode: failure.statusCode,
      exception: failure.exception,
    );
  }
}
