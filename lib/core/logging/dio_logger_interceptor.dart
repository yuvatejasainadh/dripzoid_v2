import 'dart:convert';
import 'package:dio/dio.dart';
import 'app_logger.dart';

class DioLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String queryParams = options.queryParameters.isNotEmpty
        ? '\nQuery Params: ${const JsonEncoder.withIndent('  ').convert(options.queryParameters)}'
        : '';
    
    // Redact sensitive data in body
    dynamic data = options.data;
    if (data is Map) {
      data = _redactMap(Map.from(data));
    }

    final String body = data != null
        ? '\nBody: ${data is Map || data is List ? const JsonEncoder.withIndent('  ').convert(data) : data}'
        : '';

    // Redact sensitive headers
    final Map<String, dynamic> redactedHeaders = Map.from(options.headers);
    if (redactedHeaders.containsKey('Authorization')) {
      redactedHeaders['Authorization'] = 'Bearer [REDACTED]';
    }
    if (redactedHeaders.containsKey('Authorization')) {
      redactedHeaders['authorization'] = 'Bearer [REDACTED]';
    }
    if (redactedHeaders.containsKey('cookie')) {
      redactedHeaders['cookie'] = '[REDACTED]';
    }
    if (redactedHeaders.containsKey('Cookie')) {
      redactedHeaders['Cookie'] = '[REDACTED]';
    }

    AppLogger.i(
      '🚀 REQUEST [${options.method}] => ${options.uri}\n'
      'Headers: $redactedHeaders$queryParams$body',
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    dynamic data = response.data;
    if (data is Map) {
      data = _redactMap(Map.from(data));
    }

    final String body = data != null
        ? '\nBody: ${data is Map || data is List ? const JsonEncoder.withIndent('  ').convert(data) : data}'
        : '';

    AppLogger.i(
      '✅ RESPONSE [${response.statusCode}] <= ${response.requestOptions.uri}$body',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final String responseBody = err.response?.data != null
        ? '\nResponse Body: ${err.response?.data is Map || err.response?.data is List ? const JsonEncoder.withIndent('  ').convert(err.response?.data) : err.response?.data}'
        : '';

    AppLogger.e(
      '❌ ERROR [${err.response?.statusCode}] <= ${err.requestOptions.uri}\n'
      'Message: ${err.message}\n'
      'Type: ${err.type}$responseBody',
      error: err.error,
      stackTrace: err.stackTrace,
    );
    super.onError(err, handler);
  }

  Map<String, dynamic> _redactMap(Map<String, dynamic> map) {
    final sensitiveKeys = {
      'token',
      'accessToken',
      'refreshToken',
      'access_token',
      'refresh_token',
      'jwt',
      'password',
      'secret'
    };
    
    for (final key in map.keys) {
      if (sensitiveKeys.contains(key.toLowerCase())) {
        map[key] = '[REDACTED]';
      } else if (map[key] is Map) {
        map[key] = _redactMap(Map<String, dynamic>.from(map[key] as Map));
      } else if (map[key] is List) {
        map[key] = (map[key] as List).map((item) {
          if (item is Map) {
            return _redactMap(Map<String, dynamic>.from(item));
          }
          return item;
        }).toList();
      }
    }
    return map;
  }
}
