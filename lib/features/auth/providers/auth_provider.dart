import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_provider.dart';

import '../models/user_model.dart';
import '../repository/auth_repository.dart';
import '../services/auth_service.dart';
import 'auth_state.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.read(authServiceProvider),
    ref.read(networkProvider),
  );
});

final authProvider =
StateNotifierProvider<AuthNotifier, AuthControllerState>(
      (ref) {
    return AuthNotifier(
      ref.read(authRepositoryProvider),
    );
  },
);

class AuthControllerState {
  final AuthStatus status;
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthControllerState({
    required this.status,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthControllerState copyWith({
    AuthStatus? status,
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthControllerState(
      status: status ?? this.status,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthControllerState> {
  final AuthRepository repository;

  AuthNotifier(this.repository)
      : super(
    const AuthControllerState(
      status: AuthStatus.unknown,
    ),
  );

  Future<void> checkSession() async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
      );

      final user = await repository.getCurrentUser();

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
      );

      final response = await repository.login(
        email: email,
        password: password,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        isLoading: false,
        error: e.toString(),
      );

      return false;
    }
  }

  Future<void> logout() async {
    try {
      await repository.logout();
    } catch (e) {
      // Optionally log the error
    }

    state = const AuthControllerState(
      status: AuthStatus.unauthenticated,
    );
  }
}