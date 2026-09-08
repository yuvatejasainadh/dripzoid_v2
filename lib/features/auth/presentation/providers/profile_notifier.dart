import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/result.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/profile_repository.dart';
import 'auth_provider.dart';

final profileProvider = AsyncNotifierProvider<ProfileNotifier, void>(() {
  return ProfileNotifier();
});

class ProfileNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    final user = ref.read(authProvider).user;
    if (user == null || user.id == null) {
      state = AsyncError('User not found', StackTrace.current);
      return false;
    }

    final result = await _repository.updateProfile(user.id!, data);
    if (result is Success<UserModel?>) {
      if (result.data != null) {
        ref.read(authProvider.notifier).updateUser(result.data!);
      } else {
        // Response didn't have user data, re-fetch from 'me' endpoint
        await ref.read(authProvider.notifier).checkSession();
      }
      state = const AsyncData(null);
      return true;
    } else {
      final msg = (result as Failure).message;
      state = AsyncError(msg, StackTrace.current);
      return false;
    }
  }

  Future<bool> changePassword(String current, String newPw, String confirm) async {
    state = const AsyncLoading();
    final result = await _repository.changePassword(current, newPw, confirm);
    state = switch (result) {
      Success() => const AsyncData(null),
      Failure(message: final msg) => AsyncError(msg, StackTrace.current),
    };
    return result is Success;
  }

  Future<bool> uploadAvatar(String path) async {
    state = const AsyncLoading();
    final result = await _repository.uploadAvatar(path);
    state = switch (result) {
      Success(data: final avatarUrl) => () {
          final user = ref.read(authProvider).user;
          if (user != null) {
            ref.read(authProvider.notifier).updateUser(user.copyWith(avatar: avatarUrl));
          }
          return const AsyncData(null);
        }(),
      Failure(message: final msg) => AsyncError(msg, StackTrace.current),
    };
    return result is Success;
  }

  Future<bool> deleteAccount() async {
    state = const AsyncLoading();
    final result = await _repository.deleteAccount();
    state = switch (result) {
      Success() => () {
          ref.read(authProvider.notifier).logout();
          return const AsyncData(null);
        }(),
      Failure(message: final msg) => AsyncError(msg, StackTrace.current),
    };
    return result is Success;
  }
}
