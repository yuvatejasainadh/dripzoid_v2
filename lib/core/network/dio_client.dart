import 'dart:io';

import 'package:dio/dio.dart';

import 'api_endpoints.dart';
import 'api_exception.dart';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

class AppInterceptor extends Interceptor {
  @override
  void onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) {
    String message = "Something went wrong";

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
          message = data["message"]?.toString() ?? "Server Error";
        } else {
          message = "Server Error";
        }
        break;

      default:
        message = err.message ?? message;
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

class DioClient {
  DioClient._();

  static late Dio instance;

  static Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();

    final cookieJar = PersistCookieJar(
      storage: FileStorage(
        '${directory.path}/.cookies/',
      ),
    );

    instance = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
        contentType: Headers.jsonContentType,
        headers: {
          HttpHeaders.acceptHeader: "application/json",
        },
      ),
    );

    instance.interceptors.add(
      CookieManager(cookieJar),
    );

    instance.interceptors.add(AppInterceptor());

    instance.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }
}