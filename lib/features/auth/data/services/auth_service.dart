import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/models/result.dart';
import '../models/login_request.dart';

class AuthService {
  final ApiClient _client;

  AuthService(this._client);

  Future<Result<Map<String, dynamic>>> login(LoginRequest request) async {
    return await _client.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );
  }

  Future<Result<Map<String, dynamic>>> checkEmail(String email) async {
    return await _client.post(
      ApiEndpoints.checkEmail,
      data: {
        "email": email.trim().toLowerCase(),
      },
    );
  }

  Future<Result<Map<String, dynamic>>> register(
    Map<String, dynamic> body,
  ) async {
    return await _client.post(
      ApiEndpoints.register,
      data: body,
    );
  }

  Future<Result<Map<String, dynamic>>> resetPassword({
    required String email,
    required String password,
  }) async {
    return await _client.post(
      ApiEndpoints.resetPassword,
      data: {
        "email": email.trim(),
        "password": password,
      },
    );
  }

  Future<Result<Map<String, dynamic>>> getCurrentUser() async {
    return await _client.get(
      ApiEndpoints.me,
    );
  }

  Future<Result<Map<String, dynamic>>> logout() async {
    return await _client.post(
      ApiEndpoints.logout,
    );
  }

  Future<Result<Map<String, dynamic>>> sendOTP(String email) async {
    return await _client.post(
      ApiEndpoints.sendOtp,
      data: {"email": email},
    );
  }

  Future<Result<Map<String, dynamic>>> verifyOTP(String email, String otp) async {
    return await _client.post(
      ApiEndpoints.verifyOtp,
      data: {"email": email, "otp": otp},
    );
  }
}
