import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioInstanceProvider);
  return ApiClient(dio);
});

final aiApiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(aiDioInstanceProvider);
  return ApiClient(dio);
});

final dioInstanceProvider = Provider<Dio>((ref) {
  // This will be overridden in main.dart after initialization
  return Dio(); 
});

final aiDioInstanceProvider = Provider<Dio>((ref) {
  // This will be overridden in main.dart after initialization
  return Dio();
});
