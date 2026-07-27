import '../../../core/network/api_exception.dart';
import '../../../core/network/network_info.dart';

import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _service;
  final NetworkInfo _network;

  AuthRepository(
      this._service,
      this._network,
      );

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    if (!await _network.isConnected) {
      throw ApiException("No Internet Connection");
    }

    final response = await _service.login(
      LoginRequest(
        email: email,
        password: password,
      ),
    );

    return LoginResponse.fromJson(response.data);
  }

  Future<bool> checkEmail(String email) async {
    if (!await _network.isConnected) {
      throw ApiException("No Internet Connection");
    }

    final response = await _service.checkEmail(email);

    return response.data["exists"] == true;
  }

  Future<UserModel> getCurrentUser() async {
    if (!await _network.isConnected) {
      throw ApiException("No Internet Connection");
    }

    final response = await _service.getCurrentUser();

    return UserModel.fromJson(response.data["user"]);
  }

  Future<void> register(
      Map<String, dynamic> body,
      ) async {
    if (!await _network.isConnected) {
      throw ApiException("No Internet Connection");
    }

    await _service.register(body);
  }

  Future<void> resetPassword({
    required String email,
    required String password,
  }) async {
    if (!await _network.isConnected) {
      throw ApiException("No Internet Connection");
    }

    await _service.resetPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    if (!await _network.isConnected) {
      throw ApiException("No Internet Connection");
    }

    await _service.logout();
  }
}