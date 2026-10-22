import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dripzoid_v2/core/models/result.dart';
import 'package:dripzoid_v2/core/network/token_storage.dart';
import 'package:dripzoid_v2/core/router/app_router.dart';
import 'package:dripzoid_v2/features/auth/data/models/login_response.dart';
import 'package:dripzoid_v2/features/auth/data/models/user_model.dart';
import 'package:dripzoid_v2/features/auth/data/repositories/auth_repository.dart';
import 'package:dripzoid_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:dripzoid_v2/features/cart/data/models/cart_item_model.dart';

class FakeTokenStorage implements TokenStorage {
  String? storedToken;
  FakeTokenStorage([this.storedToken]);
  @override
  Future<void> saveToken(String token) async => storedToken = token;
  @override
  Future<String?> getToken() async => storedToken;
  @override
  Future<void> clearToken() async => storedToken = null;
}

class FakeAuthRepository implements AuthRepository {
  Result<UserModel>? currentUserResult;
  @override
  Future<Result<UserModel>> getCurrentUser() async =>
      currentUserResult ?? const Failure('No user', statusCode: 401);
  @override
  Future<Result<LoginResponse>> login({required String email, required String password}) async =>
      Success(LoginResponse(
        success: true,
        message: 'Success',
        sessionId: 'token',
        user: UserModel(id: '1', email: email, name: 'User'),
      ));
  @override
  Future<Result<void>> logout() async => const Success(null);
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
  group('GoRouter Argument Safety & Route Redirect Tests (DRZ-003)', () {
    late FakeTokenStorage fakeTokenStorage;
    late FakeAuthRepository fakeAuthRepository;

    setUp(() {
      fakeTokenStorage = FakeTokenStorage();
      fakeAuthRepository = FakeAuthRepository();
    });

    void configureTestViewport(WidgetTester tester) {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) return;
        originalOnError?.call(details);
      };
      addTearDown(() {
        FlutterError.onError = originalOnError;
      });

      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets('Unauthenticated user is redirected from protected routes to /login', (tester) async {
      configureTestViewport(tester);

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(fakeTokenStorage),
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      container.read(authProvider.notifier).setUnauthenticated();
      final router = container.read(appRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Initial unauthenticated redirect
      expect(router.routeInformationProvider.value.uri.path, equals('/login'));

      // Attempt navigating to protected routes
      router.go('/home');
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, equals('/login'));

      router.go('/checkout');
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, equals('/login'));

      router.go('/order-success');
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, equals('/login'));
    });

    testWidgets('/checkout redirects to /cart when extra is null, wrong type, or empty', (tester) async {
      configureTestViewport(tester);

      fakeTokenStorage.storedToken = 'valid_token';
      fakeAuthRepository.currentUserResult = Success(
        UserModel(id: 'u1', email: 'user@test.com', name: 'Tester'),
      );

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(fakeTokenStorage),
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authProvider.notifier).checkSession();
      final router = container.read(appRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Navigate to /checkout with null extra -> safely redirects to /cart
      router.go('/checkout');
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, equals('/cart'));

      // 2. Navigate to /checkout with invalid string extra -> safely redirects to /cart
      router.go('/checkout', extra: 'not-a-list');
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, equals('/cart'));

      // 3. Navigate to /checkout with empty list -> safely redirects to /cart
      router.go('/checkout', extra: <CartItemModel>[]);
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, equals('/cart'));
    });

    testWidgets('/order-success redirects to /profile/orders when extra is not OrderModel', (tester) async {
      configureTestViewport(tester);

      fakeTokenStorage.storedToken = 'valid_token';
      fakeAuthRepository.currentUserResult = Success(
        UserModel(id: 'u1', email: 'user@test.com', name: 'Tester'),
      );

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(fakeTokenStorage),
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authProvider.notifier).checkSession();
      final router = container.read(appRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Navigate with null extra
      router.go('/order-success');
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, equals('/profile/orders'));

      // 2. Navigate with invalid string extra
      router.go('/order-success', extra: 'order_123');
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, equals('/profile/orders'));
    });

    testWidgets('/register-otp redirects to /register-email when email is missing or empty', (tester) async {
      configureTestViewport(tester);

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(fakeTokenStorage),
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      container.read(authProvider.notifier).setUnauthenticated();
      final router = container.read(appRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Null extra
      router.go('/register-otp');
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, equals('/register-email'));

      // 2. Empty string extra
      router.go('/register-otp', extra: '   ');
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, equals('/register-email'));

      // 3. Non-string extra
      router.go('/register-otp', extra: 12345);
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, equals('/register-email'));
    });

    testWidgets('/register-details redirects to /register-email when email is missing or empty', (tester) async {
      configureTestViewport(tester);

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(fakeTokenStorage),
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      container.read(authProvider.notifier).setUnauthenticated();
      final router = container.read(appRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Null extra
      router.go('/register-details');
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, equals('/register-email'));

      // 2. Empty string extra
      router.go('/register-details', extra: '');
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, equals('/register-email'));
    });

    testWidgets('/forgot-otp redirects to /forgot-password when email is missing or empty', (tester) async {
      configureTestViewport(tester);

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(fakeTokenStorage),
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      container.read(authProvider.notifier).setUnauthenticated();
      final router = container.read(appRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Null extra
      router.go('/forgot-otp');
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, equals('/forgot-password'));

      // 2. Empty string extra
      router.go('/forgot-otp', extra: '  ');
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, equals('/forgot-password'));
    });

    testWidgets('/reset-password redirects to /forgot-password when email is missing or empty', (tester) async {
      configureTestViewport(tester);

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(fakeTokenStorage),
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      container.read(authProvider.notifier).setUnauthenticated();
      final router = container.read(appRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Null extra
      router.go('/reset-password');
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, equals('/forgot-password'));

      // 2. Empty string extra
      router.go('/reset-password', extra: '');
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, equals('/forgot-password'));

      // 3. Wrong type extra
      router.go('/reset-password', extra: ['email@test.com']);
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, equals('/forgot-password'));
    });

    testWidgets('/product/:id redirects to /home when id is empty or whitespace', (tester) async {
      configureTestViewport(tester);

      fakeTokenStorage.storedToken = 'valid_token';
      fakeAuthRepository.currentUserResult = Success(
        UserModel(id: 'u1', email: 'user@test.com', name: 'Tester'),
      );

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(fakeTokenStorage),
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authProvider.notifier).checkSession();
      final router = container.read(appRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      router.go('/product/%20');
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, equals('/home'));
    });
  });
}
