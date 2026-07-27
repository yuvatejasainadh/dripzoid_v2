import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../models/login_request.dart';

class AuthService {
  final Dio _dio = DioClient.instance;

  Future<Response> login(LoginRequest request) async {
    return await _dio.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );
  }

  Future<Response> checkEmail(String email) async {
    return await _dio.post(
      ApiEndpoints.checkEmail,
      data: {
        "email": email.trim().toLowerCase(),
      },
    );
  }

  Future<Response> register(
      Map<String, dynamic> body,
      ) async {
    return await _dio.post(
      ApiEndpoints.register,
      data: body,
    );
  }

  Future<Response> resetPassword({
    required String email,
    required String password,
  }) async {
    return await _dio.post(
      ApiEndpoints.resetPassword,
      data: {
        "email": email.trim(),
        "password": password,
      },
    );
  }

  Future<Response> getCurrentUser() async {
    return await _dio.get(
      ApiEndpoints.me,
    );
  }

  Future<Response> logout() async {
    return await _dio.post(
      ApiEndpoints.logout,
    );
  }
}