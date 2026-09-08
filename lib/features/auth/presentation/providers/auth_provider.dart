import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/models/result.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/auth_service.dart';
import '../../../../core/network/token_storage.dart';
import '../../../cart/presentation/providers/cart_notifier.dart';
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
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  void updateUser(UserModel user) {
    state = state.copyWith(user: user);
  }

  Future<void> checkSession() async {
    state = state.copyWith(isLoading: true);
    
    final token = await ref.read(tokenStorageProvider).getToken();
    if (token == null) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
      );
      return;
    }

    final result = await _repository.getCurrentUser();
    
    state = switch (result) {
      Success(data: final user) => () {
          ref.read(cartProvider.notifier).fetchCart();
          return state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            isLoading: false,
          );
        }(),
      Failure() => state.copyWith(
          status: AuthStatus.unauthenticated,
          isLoading: false,
        ),
    };
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

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
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    await _repository.logout();
    await ref.read(googleAuthProvider).signOut();
    await ref.read(tokenStorageProvider).clearToken();

    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<bool> googleLogin() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await ref.read(googleAuthProvider).signIn();

      if (response == null) {
        state = state.copyWith(isLoading: false);
        return false; // User cancelled
      }

      final user = UserModel.fromJson(response['user']);
      ref.read(cartProvider.notifier).fetchCart();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.register(data);

    if (result is Success) {
      // Backend automatically logs in upon registration by setting cookies
      // We check session to update state
      await checkSession();
      return state.status == AuthStatus.authenticated;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: (result as Failure).message,
      );
      return false;
    }
  }

  Future<bool> checkEmail(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.checkEmail(email);
    state = state.copyWith(isLoading: false);
    if (result is Success<bool>) return result.data;
    if (result is Failure<bool>) state = state.copyWith(errorMessage: result.message);
    return false;
  }

  Future<bool> sendOTP(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.sendOTP(email);
    state = state.copyWith(isLoading: false);
    if (result is Failure<void>) state = state.copyWith(errorMessage: result.message);
    return result is Success;
  }

  Future<bool> verifyOTP(String email, String otp) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.verifyOTP(email, otp);
    state = state.copyWith(isLoading: false);
    if (result is Failure<void>) state = state.copyWith(errorMessage: result.message);
    return result is Success;
  }

  Future<bool> resetPassword({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.resetPassword(email: email, password: password);
    state = state.copyWith(isLoading: false);
    if (result is Failure<void>) state = state.copyWith(errorMessage: result.message);
    return result is Success;
  }
}
