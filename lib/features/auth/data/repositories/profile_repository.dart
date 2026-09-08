import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/result.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(profileServiceProvider));
});

class ProfileRepository {
  final ProfileService _service;

  ProfileRepository(this._service);

  Future<Result<UserModel?>> updateProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    final result = await _service.updateProfile(userId, data);
    if (result is Success<Map<String, dynamic>>) {
      final userData = result.data['user'] ?? result.data['data'];
      
      // If the response contains actual user data, parse it
      if (userData != null && userData is Map && (userData.containsKey('id') || userData.containsKey('email'))) {
        return Success(UserModel.fromJson(userData as Map<String, dynamic>));
      }
      
      // Otherwise return Success with null, indicating the update worked but data is not in response
      return const Success(null);
    }
    final failure = result as Failure;
    return Failure(
      failure.message,
      statusCode: failure.statusCode,
      exception: failure.exception,
    );
  }

  Future<Result<String>> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    final result = await _service.changePassword(currentPassword, newPassword, confirmPassword);
    if (result is Success<Map<String, dynamic>>) {
      return Success(
        result.data['message'] as String? ?? 'Password changed successfully',
      );
    }
    final failure = result as Failure;
    return Failure(
      failure.message,
      statusCode: failure.statusCode,
      exception: failure.exception,
    );
  }

  Future<Result<String>> uploadAvatar(String filePath) async {
    final result = await _service.uploadAvatar(filePath);
    if (result is Success<Map<String, dynamic>>) {
      return Success(result.data['avatarUrl'] as String? ?? '');
    }
    final failure = result as Failure;
    return Failure(
      failure.message,
      statusCode: failure.statusCode,
      exception: failure.exception,
    );
  }

  Future<Result<void>> deleteAvatar() async {
    final result = await _service.deleteAvatar();
    if (result is Success) return const Success(null);
    final failure = result as Failure;
    return Failure(
      failure.message,
      statusCode: failure.statusCode,
      exception: failure.exception,
    );
  }

  Future<Result<void>> deleteAccount() async {
    final result = await _service.deleteAccount();
    if (result is Success) return const Success(null);
    final failure = result as Failure;
    return Failure(
      failure.message,
      statusCode: failure.statusCode,
      exception: failure.exception,
    );
  }
}
