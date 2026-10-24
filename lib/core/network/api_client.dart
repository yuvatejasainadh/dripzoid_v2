import 'package:dio/dio.dart';
import '../logging/app_logger.dart';
import '../models/result.dart';
import 'api_exception.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      if (fromJson != null && response.data is Map<String, dynamic>) {
        return Success(fromJson(response.data));
      }

      return Success(response.data as T);
    } catch (e) {
      return _handleError(e, path);
    }
  }

  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      if (fromJson != null && response.data is Map<String, dynamic>) {
        return Success(fromJson(response.data));
      }

      return Success(response.data as T);
    } catch (e) {
      return _handleError(e, path);
    }
  }

  Future<Result<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      if (fromJson != null && response.data is Map<String, dynamic>) {
        return Success(fromJson(response.data));
      }

      return Success(response.data as T);
    } catch (e) {
      return _handleError(e, path);
    }
  }

  Future<Result<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      if (fromJson != null && response.data is Map<String, dynamic>) {
        return Success(fromJson(response.data));
      }

      return Success(response.data as T);
    } catch (e) {
      return _handleError(e, path);
    }
  }

  Future<Result<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      if (fromJson != null && response.data is Map<String, dynamic>) {
        return Success(fromJson(response.data));
      }

      return Success(response.data as T);
    } catch (e) {
      return _handleError(e, path);
    }
  }

  Result<T> _handleError<T>(dynamic e, String path) {
    AppLogger.e('[ApiClient] Error on path: $path', error: e);
    if (e is DioException) {
      String message = "Something went wrong";
      
      // 1. Try to extract specific error message from backend response body
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        message = responseData['error'] ?? responseData['message'] ?? message;
      } else if (responseData is String && responseData.isNotEmpty) {
        message = responseData;
      } else {
        message = e.message ?? message;
      }

      final error = e.error;
      if (error is ApiException) {
        return Failure(
          error.message,
          statusCode: error.statusCode,
          errorType: error.type,
          exception: e,
          stackTrace: e.stackTrace,
          endpoint: path,
        );
      }

      final statusCode = e.response?.statusCode;
      ApiErrorType derivedType = ApiErrorType.unknown;
      if (statusCode != null) {
        if (statusCode == 401 || statusCode == 403) {
          derivedType = ApiErrorType.authentication;
        } else if (statusCode == 422 || statusCode == 400) {
          derivedType = ApiErrorType.validation;
        } else if (statusCode == 429) {
          derivedType = ApiErrorType.rateLimit;
        } else if (statusCode >= 500) {
          derivedType = ApiErrorType.serverError;
        }
      } else if (e.type == DioExceptionType.connectionError) {
        derivedType = ApiErrorType.networkUnavailable;
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.sendTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        derivedType = ApiErrorType.timeout;
      }
      
      return Failure(
        message,
        statusCode: statusCode,
        errorType: derivedType,
        exception: e,
        stackTrace: e.stackTrace,
        endpoint: path,
      );
    }
    return Failure(e.toString(), endpoint: path);
  }
}
