import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dripzoid_v2/core/models/result.dart';
import 'package:dripzoid_v2/core/network/token_storage.dart';
import 'package:dripzoid_v2/features/auth/data/models/login_response.dart';
import 'package:dripzoid_v2/features/auth/data/models/user_model.dart';
import 'package:dripzoid_v2/features/auth/data/repositories/auth_repository.dart';
import 'package:dripzoid_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:dripzoid_v2/features/cart/presentation/providers/cart_notifier.dart';

class FakeTokenStorage implements TokenStorage {
  String? storedToken;

  FakeTokenStorage([this.storedToken]);

  @override
  Future<void> saveToken(String token) async {
    storedToken = token;
  }

  @override
  Future<String?> getToken() async {
    return storedToken;
  }

  @override
  Future<void> clearToken() async {
    storedToken = null;
  }
}

class FakeAuthRepository implements AuthRepository {
  Result<UserModel>? currentUserResult;
  Result<LoginResponse>? loginResult;
  Result<void>? logoutResult;
  int getCurrentUserCallCount = 0;
  Duration? delay;

  @override
  Future<Result<UserModel>> getCurrentUser() async {
    getCurrentUserCallCount++;
    if (delay != null) {
      await Future.delayed(delay!);
    }
    return currentUserResult ??
        Failure('No user', statusCode: 401);
  }

  @override
  Future<Result<LoginResponse>> login({
    required String email,
    required String password,
  }) async {
    return loginResult ??
        Success(LoginResponse(
          success: true,
          message: 'Success',
          sessionId: 'jwt_token',
          user: UserModel(id: '1', email: email, name: 'Test User'),
        ));
  }

  @override
  Future<Result<void>> logout() async {
    return logoutResult ?? const Success<void>(null);
  }

  @override
  Future<Result<bool>> checkEmail(String email) async => const Success(true);

  @override
  Future<Result<void>> register(Map<String, dynamic> body) async => const Success(null);

  @override
  Future<Result<void>> resetPassword({required String email, required String password}) async => const Success(null);

  @override
  Future<Result<void>> sendOTP(String email) async => const Success(null);

  @override
  Future<Result<void>> verifyOTP(String email, String otp) async => const Success(null);
}

void main() {
  group('AuthNotifier Session Initialization & State Transitions', () {
    late FakeTokenStorage fakeTokenStorage;
    late FakeAuthRepository fakeAuthRepository;
    late ProviderContainer container;

    setUp(() {
      fakeTokenStorage = FakeTokenStorage();
      fakeAuthRepository = FakeAuthRepository();

      container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(fakeTokenStorage),
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial status is AuthStatus.initial and not loading', () {
      final state = container.read(authProvider);
      expect(state.status, equals(AuthStatus.initial));
      expect(state.isLoading, isFalse);
      expect(state.user, isNull);
    });

    test('Missing stored token transitions to AuthStatus.unauthenticated', () async {
      fakeTokenStorage.storedToken = null;

      await container.read(authProvider.notifier).checkSession();

      final state = container.read(authProvider);
      expect(state.status, equals(AuthStatus.unauthenticated));
      expect(state.isLoading, isFalse);
      expect(state.user, isNull);
      expect(fakeAuthRepository.getCurrentUserCallCount, equals(0));
    });

    test('Valid token with successful server response restores authenticated user', () async {
      fakeTokenStorage.storedToken = 'valid_jwt_token';
      fakeAuthRepository.currentUserResult = Success(
        UserModel(id: 'u123', email: 'user@dripzoid.com', name: 'Drip User'),
      );

      await container.read(authProvider.notifier).checkSession();

      final state = container.read(authProvider);
      expect(state.status, equals(AuthStatus.authenticated));
      expect(state.isLoading, isFalse);
      expect(state.user, isNotNull);
      expect(state.user!.email, equals('user@dripzoid.com'));
      expect(fakeAuthRepository.getCurrentUserCallCount, equals(1));
    });

    test('401 Unauthorized clears stored token and marks unauthenticated', () async {
      fakeTokenStorage.storedToken = 'expired_jwt_token';
      fakeAuthRepository.currentUserResult = Failure('Token expired', statusCode: 401);

      await container.read(authProvider.notifier).checkSession();

      final state = container.read(authProvider);
      expect(state.status, equals(AuthStatus.unauthenticated));
      expect(state.isLoading, isFalse);
      expect(fakeTokenStorage.storedToken, isNull);
    });

    test('403 Forbidden clears stored token and marks unauthenticated', () async {
      fakeTokenStorage.storedToken = 'forbidden_jwt_token';
      fakeAuthRepository.currentUserResult = Failure('Forbidden', statusCode: 403);

      await container.read(authProvider.notifier).checkSession();

      final state = container.read(authProvider);
      expect(state.status, equals(AuthStatus.unauthenticated));
      expect(state.isLoading, isFalse);
      expect(fakeTokenStorage.storedToken, isNull);
    });

    test('Network error does not wipe stored token but sets unauthenticated with message', () async {
      fakeTokenStorage.storedToken = 'valid_token_offline';
      fakeAuthRepository.currentUserResult = Failure('Connection timeout', statusCode: 504);

      await container.read(authProvider.notifier).checkSession();

      final state = container.read(authProvider);
      expect(state.status, equals(AuthStatus.unauthenticated));
      expect(state.isLoading, isFalse);
      // Token should NOT be wiped on temporary network failure
      expect(fakeTokenStorage.storedToken, equals('valid_token_offline'));
      expect(state.errorMessage, equals('Connection timeout'));
    });

    test('Late checkSession response does not overwrite subsequent login', () async {
      fakeTokenStorage.storedToken = 'old_token';
      fakeAuthRepository.delay = const Duration(milliseconds: 100);
      fakeAuthRepository.currentUserResult = Failure('Slow failure', statusCode: 401);

      // 1. Trigger slow checkSession in background
      final checkFuture = container.read(authProvider.notifier).checkSession();

      // 2. User immediately performs successful login
      await container.read(authProvider.notifier).login(
            email: 'newuser@dripzoid.com',
            password: 'Password123!',
          );

      expect(container.read(authProvider).status, equals(AuthStatus.authenticated));
      expect(container.read(authProvider).user!.email, equals('newuser@dripzoid.com'));

      // 3. Wait for the slow checkSession to finish
      await checkFuture;

      // 4. Verify login state was NOT overwritten by the slow checkSession
      final finalState = container.read(authProvider);
      expect(finalState.status, equals(AuthStatus.authenticated));
      expect(finalState.user!.email, equals('newuser@dripzoid.com'));
    });

    test('Logout clears user, clears stored token, and resets cart', () async {
      // Setup authenticated state with user and token
      fakeTokenStorage.storedToken = 'active_token';
      fakeAuthRepository.currentUserResult = Success(
        UserModel(id: 'u1', email: 'test@dripzoid.com', name: 'Test'),
      );
      await container.read(authProvider.notifier).checkSession();
      expect(container.read(authProvider).status, equals(AuthStatus.authenticated));

      // Trigger logout
      await container.read(authProvider.notifier).logout();

      final state = container.read(authProvider);
      expect(state.status, equals(AuthStatus.unauthenticated));
      expect(state.user, isNull);
      expect(fakeTokenStorage.storedToken, isNull);

      final cartState = container.read(cartProvider);
      expect(cartState.items, isEmpty);
    });

    test('setUnauthenticated forces unauthenticated status and resets loading', () {
      container.read(authProvider.notifier).setUnauthenticated(
            errorMessage: 'User cancelled or offline',
          );

      final state = container.read(authProvider);
      expect(state.status, equals(AuthStatus.unauthenticated));
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, equals('User cancelled or offline'));
    });
  });
}
