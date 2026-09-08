import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/result.dart';
import '../../data/models/address_model.dart';
import '../../data/repositories/address_repository.dart';

final addressProvider =
    AsyncNotifierProvider<AddressNotifier, List<AddressModel>>(() {
  return AddressNotifier();
});

class AddressNotifier extends AsyncNotifier<List<AddressModel>> {
  @override
  FutureOr<List<AddressModel>> build() async {
    return loadAddresses();
  }

  AddressRepository get _repository => ref.read(addressRepositoryProvider);

  Future<List<AddressModel>> loadAddresses() async {
    final result = await _repository.getAddresses();
    return switch (result) {
      Success(data: final list) => list,
      Failure(message: final msg) => throw msg,
    };
  }

  Future<bool> addAddress(AddressModel address) async {
    state = const AsyncLoading();
    final result = await _repository.createAddress(address.toJson());
    state = await AsyncValue.guard(() async {
      switch (result) {
        case Success():
          return loadAddresses();
        case Failure(message: final m):
          throw m;
      }
    });
    return result is Success;
  }

  Future<bool> updateAddress(AddressModel address) async {
    if (address.id == null) return false;
    state = const AsyncLoading();
    final result =
        await _repository.updateAddress(address.id!, address.toJson());
    state = await AsyncValue.guard(() async {
      switch (result) {
        case Success():
          return loadAddresses();
        case Failure(message: final m):
          throw m;
      }
    });
    return result is Success;
  }

  Future<bool> deleteAddress(String id) async {
    state = const AsyncLoading();
    final result = await _repository.deleteAddress(id);
    state = await AsyncValue.guard(() async {
      switch (result) {
        case Success():
          return loadAddresses();
        case Failure(message: final m):
          throw m;
      }
    });
    return result is Success;
  }

  Future<bool> toggleDefault(String id) async {
    state = const AsyncLoading();
    final result = await _repository.setDefaultAddress(id);
    state = await AsyncValue.guard(() async {
      switch (result) {
        case Success():
          return loadAddresses();
        case Failure(message: final m):
          throw m;
      }
    });
    return result is Success;
  }
}
