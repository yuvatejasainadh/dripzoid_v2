import 'package:dio/dio.dart';
import '../logging/app_logger.dart';
import 'token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;

  AuthInterceptor(this._tokenStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokenStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      AppLogger.d('[AuthInterceptor] Attached Bearer token to request: ${options.uri.path}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // 1. Check for token in response body (primary for mobile and web)
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final bodyToken = data['token'] ?? data['accessToken'];
      if (bodyToken != null && bodyToken is String && bodyToken.isNotEmpty) {
        await _tokenStorage.saveToken(bodyToken);
        AppLogger.i('[AuthInterceptor] Token extracted from body and persisted');
      }
    }

    // 2. Check for Set-Cookie header to extract token (fallback/redundancy)
    final cookies = response.headers['set-cookie'];
    if (cookies != null && cookies.isNotEmpty) {
      for (var cookie in cookies) {
        if (cookie.contains('token=')) {
          final start = cookie.indexOf('token=') + 6;
          final end = cookie.indexOf(';', start);
          final token = end == -1 ? cookie.substring(start) : cookie.substring(start, end);

          if (token.isNotEmpty && token != 'deleted') {
            await _tokenStorage.saveToken(token);
            AppLogger.i('[AuthInterceptor] Token extracted from cookie and persisted');
          }
        }
      }
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      AppLogger.w('[AuthInterceptor] 401 Unauthorized detected, clearing token');
      await _tokenStorage.clearToken();
      // Note: Notifier will handle the state transition based on the next checkSession or API failure
    }
    super.onError(err, handler);
  }
}
