import 'dart:io';
import 'package:dio/dio.dart';
import '../logging/app_logger.dart';
import 'api_exception.dart';

class AppInterceptor extends Interceptor {
  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    String message = "Something went wrong";

    // Log specific handshake/SSL issues
    if (err.error is HandshakeException || 
        err.error is CertificateException || 
        err.error is TlsException) {
      AppLogger.e(
        "SSL/TLS Handshake Error detected in AppInterceptor\n"
        "Error: ${err.error}\n"
        "Message: ${err.message}\n"
        "Endpoint: ${err.requestOptions.uri}",
        error: err.error,
        stackTrace: err.stackTrace,
      );
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        message = "Connection timeout";
        break;

      case DioExceptionType.receiveTimeout:
        message = "Server timeout";
        break;

      case DioExceptionType.connectionError:
        message = "No internet connection";
        break;

      case DioExceptionType.badResponse:
        final data = err.response?.data;

        if (data is Map<String, dynamic>) {
          message = data["message"]?.toString() ?? 
                    data["error"]?.toString() ??
                    data["detail"]?.toString() ?? 
                    "Server Error (${err.response?.statusCode})";
        } else {
          message = "Server Error (${err.response?.statusCode})";
        }
        break;

      default:
        if (err.type == DioExceptionType.unknown) {
          message = err.error?.toString() ?? err.message ?? "Unknown error occurred";
        } else {
          message = err.message ?? message;
        }
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: ApiException(
          message,
          statusCode: err.response?.statusCode,
        ),
      ),
    );
  }
}
