import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/models/result.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/auth_service.dart';
import '../../../../core/network/token_storage.dart';
import '../../../cart/presentation/providers/cart_notifier.dart';
import '../../../wishlist/presentation/providers/wishlist_notifier.dart';
import 'google_provider.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(apiClientProvider);
  return AuthService(client);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final service = ref.watch(authServiceProvider);
  return AuthRepository(service);
});

enum AuthStatus {
  authenticated,
  unauthenticated,
  initial,
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    bool clearError = false,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<AuthState> {
  int _sessionCheckCounter = 0;

  @override
  AuthState build() {
    return const AuthState();
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  void updateUser(UserModel user) {
    state = state.copyWith(user: user);
  }

  void setUnauthenticated({String? errorMessage}) {
    _sessionCheckCounter++;
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      errorMessage: errorMessage,
      isLoading: false,
    );
  }

  Future<void> checkSession() async {
    final currentCheck = ++_sessionCheckCounter;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final token = await ref.read(tokenStorageProvider).getToken();
      if (token == null) {
        if (currentCheck != _sessionCheckCounter) return;
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          isLoading: false,
        );
        return;
      }

      final result = await _repository.getCurrentUser();
      if (currentCheck != _sessionCheckCounter) return;

      state = switch (result) {
        Success(data: final user) => () {
            ref.read(cartProvider.notifier).fetchCart();
            return state.copyWith(
              status: AuthStatus.authenticated,
              user: user,
              isLoading: false,
            );
          }(),
        Failure(statusCode: final code, message: final msg) => () {
            if (code == 401 || code == 403) {
              ref.read(tokenStorageProvider).clearToken();
            }
            return state.copyWith(
              status: AuthStatus.unauthenticated,
              errorMessage: msg,
              isLoading: false,
            );
          }(),
      };
    } catch (_) {
      if (currentCheck != _sessionCheckCounter) return;
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Session validation failed',
        isLoading: false,
      );
    } finally {
      if (currentCheck == _sessionCheckCounter) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _sessionCheckCounter++;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _repository.login(
        email: email,
        password: password,
      );

      return switch (result) {
        Success(data: final response) => () {
            ref.read(cartProvider.notifier).fetchCart();
            state = state.copyWith(
              status: AuthStatus.authenticated,
              user: response.user,
              isLoading: false,
            );
            return true;
          }(),
        Failure(message: final msg) => () {
            state = state.copyWith(
              status: AuthStatus.unauthenticated,
              errorMessage: msg,
              isLoading: false,
            );
            return false;
          }(),
      };
    } catch (e) {
      final cleanError = e.toString().replaceAll(RegExp(r'^Exception:\s*'), '');
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: cleanError,
        isLoading: false,
      );
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> logout() async {
    _sessionCheckCounter++;
    state = state.copyWith(isLoading: true);
    try {
      await _repository.logout();
      await ref.read(googleAuthProvider).signOut();
      await ref.read(tokenStorageProvider).clearToken();
    } catch (_) {
      await ref.read(tokenStorageProvider).clearToken();
    } finally {
      ref.read(cartProvider.notifier).reset();
      ref.read(wishlistProvider.notifier).reset();
      state = const AuthState(status: AuthStatus.unauthenticated, isLoading: false);
    }
  }

  Future<bool> googleLogin() async {
    _sessionCheckCounter++;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await ref.read(googleAuthProvider).signIn();

      if (response == null) {
        state = state.copyWith(isLoading: false);
        return false; // User cancelled
      }

      final rawUser = response['user'] ?? (response['data'] is Map ? (response['data']['user'] ?? response['data']) : null) ?? response;
      final user = UserModel.fromJson(rawUser is Map<String, dynamic> ? rawUser : Map<String, dynamic>.from(rawUser as Map));
      ref.read(cartProvider.notifier).fetchCart();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
      );
      return true;
    } catch (e) {
      final cleanError = e.toString().replaceAll(RegExp(r'^Exception:\s*'), '');
      state = state.copyWith(
        isLoading: false,
        errorMessage: cleanError,
      );
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.register(data);

      if (result is Success) {
        await checkSession();
        return state.status == AuthStatus.authenticated;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: (result as Failure).message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll(RegExp(r'^Exception:\s*'), ''),
      );
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> checkEmail(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.checkEmail(email);
      state = state.copyWith(isLoading: false);
      if (result is Success<bool>) return result.data;
      if (result is Failure<bool>) state = state.copyWith(errorMessage: result.message);
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> sendOTP(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.sendOTP(email);
      state = state.copyWith(isLoading: false);
      if (result is Failure<void>) state = state.copyWith(errorMessage: result.message);
      return result is Success;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> verifyOTP(String email, String otp) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.verifyOTP(email, otp);
      state = state.copyWith(isLoading: false);
      if (result is Failure<void>) state = state.copyWith(errorMessage: result.message);
      return result is Success;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> resetPassword({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.resetPassword(email: email, password: password);
      state = state.copyWith(isLoading: false);
      if (result is Failure<void>) state = state.copyWith(errorMessage: result.message);
      return result is Success;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
