import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../logging/app_logger.dart';
import 'api_exception.dart';

class AppInterceptor extends Interceptor {
  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    String message = "Something went wrong";
    ApiErrorType errorType = ApiErrorType.unknown;

    // Log specific handshake/SSL issues (non-web only)
    if (!kIsWeb &&
        (err.error is HandshakeException ||
         err.error is CertificateException ||
         err.error is TlsException)) {
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
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorType = ApiErrorType.timeout;
        message = "The request took too long. Please try again.";
        break;

      case DioExceptionType.connectionError:
        errorType = ApiErrorType.networkUnavailable;
        message = "We couldn't connect to Dripzoid. Check your connection and try again.";
        break;

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final data = err.response?.data;
        String? serverMsg;

        if (data is Map<String, dynamic>) {
          serverMsg = data["message"]?.toString() ??
                      data["error"]?.toString() ??
                      data["detail"]?.toString();
        } else if (data is String && data.isNotEmpty) {
          serverMsg = data;
        }

        if (statusCode != null) {
          if (statusCode == 401 || statusCode == 403) {
            errorType = ApiErrorType.authentication;
            message = serverMsg ?? (statusCode == 401 ? "Invalid email or password" : "Your session has expired. Please sign in again.");
          } else if (statusCode == 422 || statusCode == 400) {
            errorType = ApiErrorType.validation;
            message = serverMsg ?? "Validation error occurred";
          } else if (statusCode == 429) {
            errorType = ApiErrorType.rateLimit;
            message = serverMsg ?? "Too many requests. Please try again later.";
          } else if (statusCode >= 500) {
            if (serverMsg != null && serverMsg.toUpperCase().contains("CORS")) {
              errorType = ApiErrorType.corsOrBlocked;
              message = "We couldn't connect to Dripzoid. Check your connection and try again.";
            } else {
              errorType = ApiErrorType.serverError;
              message = serverMsg ?? "Service Temporarily Unavailable";
            }
          } else {
            message = serverMsg ?? "Request failed ($statusCode)";
          }
        } else {
          message = serverMsg ?? message;
        }
        break;

      case DioExceptionType.cancel:
        message = "Request cancelled";
        break;

      default:
        if (err.type == DioExceptionType.unknown) {
          final errStr = err.error?.toString() ?? err.message ?? "Unknown error occurred";
          if (errStr.contains("Failed to fetch") || errStr.contains("XMLHttpRequest error")) {
            errorType = ApiErrorType.networkUnavailable;
            message = "We couldn't connect to Dripzoid. Check your connection and try again.";
          } else {
            message = errStr;
          }
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
          type: errorType,
        ),
      ),
    );
  }
}
