import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import '../logging/dio_logger_interceptor.dart';
import 'auth_interceptor.dart';
import 'app_interceptor.dart'; 
import 'token_storage.dart';

class NetworkInitializer {
  static Future<Dio> initialize(AppConfig config) async {
    final directory = await getApplicationDocumentsDirectory();
    final cookieJar = PersistCookieJar(
      storage: FileStorage('${directory.path}/.cookies_main/'),
    );

    final tokenStorage = TokenStorage(const FlutterSecureStorage());

    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectionTimeout,
        receiveTimeout: config.connectionTimeout,
        sendTimeout: config.connectionTimeout,
        responseType: ResponseType.json,
        contentType: Headers.jsonContentType,
        headers: {
          HttpHeaders.acceptHeader: "application/json",
        },
      ),
    );

    dio.interceptors.add(CookieManager(cookieJar));
    dio.interceptors.add(AuthInterceptor(tokenStorage));
    dio.interceptors.add(AppInterceptor());
    dio.interceptors.add(DioLoggerInterceptor());
    
    return dio;
  }

  static Future<Dio> initializeAi(AppConfig config) async {
    final directory = await getApplicationDocumentsDirectory();
    final cookieJar = PersistCookieJar(
      storage: FileStorage('${directory.path}/.cookies_ai/'),
    );

    final tokenStorage = TokenStorage(const FlutterSecureStorage());

    final dio = Dio(
      BaseOptions(
        baseUrl: config.aiBaseUrl,
        connectTimeout: config.connectionTimeout,
        receiveTimeout: config.connectionTimeout,
        sendTimeout: config.connectionTimeout,
        responseType: ResponseType.json,
        contentType: Headers.jsonContentType,
        headers: {
          HttpHeaders.acceptHeader: "application/json",
        },
      ),
    );

    dio.interceptors.add(CookieManager(cookieJar));
    dio.interceptors.add(AuthInterceptor(tokenStorage));
    dio.interceptors.add(AppInterceptor());
    dio.interceptors.add(DioLoggerInterceptor());

    return dio;
  }
}
