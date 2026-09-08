import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/models/result.dart';
import '../../../../core/network/dio_provider.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(ref.watch(apiClientProvider));
});

class ProfileService {
  final ApiClient _client;

  ProfileService(this._client);

  Future<Result<Map<String, dynamic>>> updateProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    return await _client.put("${ApiEndpoints.updateProfile}/$userId", data: data);
  }

  Future<Result<Map<String, dynamic>>> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    return await _client.post(
      ApiEndpoints.changePassword,
      data: {
        'current': currentPassword,
        'newpw': newPassword,
        'confirm': confirmPassword,
      },
    );
  }

  Future<Result<Map<String, dynamic>>> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(filePath),
    });
    return await _client.post(ApiEndpoints.uploadProfileImage, data: formData);
  }

  Future<Result<Map<String, dynamic>>> deleteAvatar() async {
    return await _client.delete(ApiEndpoints.deleteProfileImage);
  }

  Future<Result<Map<String, dynamic>>> deleteAccount() async {
    return await _client.delete(ApiEndpoints.deleteAccount);
  }
}
