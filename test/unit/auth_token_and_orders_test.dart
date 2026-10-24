import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dripzoid_v2/core/models/result.dart';
import 'package:dripzoid_v2/core/network/auth_interceptor.dart';
import 'package:dripzoid_v2/core/network/token_storage.dart';
import 'package:dripzoid_v2/features/auth/data/models/login_response.dart';
import 'package:dripzoid_v2/features/auth/data/models/user_model.dart';
import 'package:dripzoid_v2/features/auth/data/repositories/auth_repository.dart';
import 'package:dripzoid_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:dripzoid_v2/features/checkout/presentation/providers/checkout_notifier.dart';
import 'package:dripzoid_v2/features/orders/data/models/order_model.dart';
import 'package:dripzoid_v2/features/orders/data/repositories/order_repository.dart';
import 'package:dripzoid_v2/features/orders/presentation/providers/order_history_notifier.dart';

// ---------------------------------------------------------------------------
// Test Doubles
// ---------------------------------------------------------------------------

class FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _data[key] = value;
    } else {
      _data.remove(key);
    }
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data[key];
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.clear();
  }

  @override
  Future<bool> containsKey({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data.containsKey(key);
  }

  @override
  Future<Map<String, String>> readAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return Map<String, String>.from(_data);
  }
}

class MockAuthRepository implements AuthRepository {
  Result<LoginResponse>? loginResult;
  Result<UserModel>? currentUserResult;
  int getCurrentUserCallCount = 0;
  int loginCallCount = 0;

  @override
  Future<Result<LoginResponse>> login({required String email, required String password}) async {
    loginCallCount++;
    return loginResult ??
        Success(LoginResponse(
          success: true,
          message: 'Success',
          token: 'test_jwt_token',
          sessionId: 'sess_1',
          user: UserModel(id: 'u1', email: email, name: 'User', phone: '9999999999'),
        ));
  }

  @override
  Future<Result<UserModel>> getCurrentUser() async {
    getCurrentUserCallCount++;
    return currentUserResult ??
        const Success(UserModel(id: 'u1', email: 'test@dripzoid.com', name: 'User', phone: '9999999999'));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockOrderRepository implements OrderRepository {
  Result<List<OrderModel>>? getUserOrdersResult;
  Result<OrderModel>? getOrderDetailsResult;
  int getUserOrdersCallCount = 0;
  int getOrderDetailsCallCount = 0;

  @override
  Future<Result<List<OrderModel>>> getUserOrders() async {
    getUserOrdersCallCount++;
    return getUserOrdersResult ?? const Success([]);
  }

  @override
  Future<Result<OrderModel>> getOrderDetails(String id) async {
    getOrderDetailsCallCount++;
    return getOrderDetailsResult ??
        Failure('Not found', statusCode: 404);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockRequestInterceptorHandler extends RequestInterceptorHandler {
  RequestOptions? passedOptions;

  @override
  void next(RequestOptions options) {
    passedOptions = options;
  }
}

class MockResponseInterceptorHandler extends ResponseInterceptorHandler {
  Response? passedResponse;

  @override
  void next(Response response) {
    passedResponse = response;
  }
}

class MockErrorInterceptorHandler extends ErrorInterceptorHandler {
  DioException? passedError;

  @override
  void next(DioException err) {
    passedError = err;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    TokenStorage.clearCacheForTesting();
  });

  tearDown(() {
    TokenStorage.clearCacheForTesting();
  });

  group('TokenStorage Cache & Persistence Tests', () {
    test('1. saveToken caches in-memory and persists to storage', () async {
      final fakeStorage = FakeSecureStorage();
      final tokenStorage = TokenStorage(fakeStorage);

      await tokenStorage.saveToken('jwt_token_123');
      expect(await fakeStorage.read(key: 'auth_token'), equals('jwt_token_123'));
      expect(await tokenStorage.getToken(), equals('jwt_token_123'));
    });

    test('2. Multiple TokenStorage instances share synchronized in-memory cache', () async {
      final fakeStorage = FakeSecureStorage();
      final tokenStorage1 = TokenStorage(fakeStorage);
      final tokenStorage2 = TokenStorage(fakeStorage);

      await tokenStorage1.saveToken('shared_jwt_abc');
      expect(await tokenStorage2.getToken(), equals('shared_jwt_abc'));

      await tokenStorage2.clearToken();
      expect(await tokenStorage1.getToken(), isNull);
    });

    test('3. clearToken purges both cache and storage', () async {
      final fakeStorage = FakeSecureStorage();
      final tokenStorage = TokenStorage(fakeStorage);

      await tokenStorage.saveToken('token_to_purge');
      expect(await tokenStorage.getToken(), equals('token_to_purge'));

      await tokenStorage.clearToken();
      expect(await tokenStorage.getToken(), isNull);
      expect(await fakeStorage.read(key: 'auth_token'), isNull);
    });
  });

  group('AuthInterceptor Header & Token Extraction Tests', () {
    test('4. onRequest attaches Bearer header when token exists', () async {
      final fakeStorage = FakeSecureStorage();
      final tokenStorage = TokenStorage(fakeStorage);
      await tokenStorage.saveToken('jwt_valid_bearer');

      final interceptor = AuthInterceptor(tokenStorage);
      final options = RequestOptions(path: '/api/user/orders');
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(options.headers['Authorization'], equals('Bearer jwt_valid_bearer'));
      expect(options.extra['withCredentials'], isTrue);
    });

    test('5. onRequest leaves Authorization absent when no token is stored (public endpoint safe)', () async {
      final fakeStorage = FakeSecureStorage();
      final tokenStorage = TokenStorage(fakeStorage);

      final interceptor = AuthInterceptor(tokenStorage);
      final options = RequestOptions(path: '/api/products');
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(options.headers['Authorization'], isNull);
      expect(options.extra['withCredentials'], isTrue);
    });

    test('6. onResponse extracts token from JSON response body and saves it', () async {
      final fakeStorage = FakeSecureStorage();
      final tokenStorage = TokenStorage(fakeStorage);
      final interceptor = AuthInterceptor(tokenStorage);

      final response = Response(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        statusCode: 200,
        data: {
          'success': true,
          'token': 'extracted_body_jwt',
          'sessionId': 'sess_99',
          'user': {'id': 'u1', 'email': 'user@dripzoid.com', 'name': 'User'},
        },
      );
      final handler = MockResponseInterceptorHandler();

      interceptor.onResponse(response, handler);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(await tokenStorage.getToken(), equals('extracted_body_jwt'));
    });

    test('7. onError on 401 Unauthorized clears token from storage', () async {
      final fakeStorage = FakeSecureStorage();
      final tokenStorage = TokenStorage(fakeStorage);
      await tokenStorage.saveToken('expired_token');

      final interceptor = AuthInterceptor(tokenStorage);
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/user/orders'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/user/orders'),
          statusCode: 401,
        ),
      );
      final handler = MockErrorInterceptorHandler();

      interceptor.onError(err, handler);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(await tokenStorage.getToken(), isNull);
    });
  });

  group('LoginResponse Parsing & Auth Propagation Tests', () {
    test('8. LoginResponse parses token field accurately', () {
      final json = {
        'success': true,
        'message': 'Login successful',
        'token': 'jwt_backend_token_123',
        'sessionId': 'sess_1',
        'user': {'id': 'u1', 'email': 'test@dripzoid.com', 'name': 'User'},
      };

      final response = LoginResponse.fromJson(json);
      expect(response.token, equals('jwt_backend_token_123'));
      expect(response.sessionId, equals('sess_1'));
      expect(response.user.email, equals('test@dripzoid.com'));
    });

    test('9. LoginResponse falls back to accessToken if present', () {
      final json = {
        'success': true,
        'accessToken': 'jwt_access_token_456',
        'user': {'id': 'u2', 'email': 'user2@dripzoid.com', 'name': 'User 2'},
      };

      final response = LoginResponse.fromJson(json);
      expect(response.token, equals('jwt_access_token_456'));
    });

    test('10. AuthNotifier.login persists token and sets authenticated state', () async {
      final fakeStorage = FakeSecureStorage();
      final tokenStorage = TokenStorage(fakeStorage);
      final mockAuthRepo = MockAuthRepository();

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(tokenStorage),
          authRepositoryProvider.overrideWithValue(mockAuthRepo),
        ],
      );
      addTearDown(container.dispose);

      mockAuthRepo.loginResult = Success(LoginResponse(
        success: true,
        message: 'Success',
        token: 'persisted_jwt_789',
        sessionId: 'sess_10',
        user: const UserModel(id: 'u1', email: 'user@dripzoid.com', name: 'User', phone: '9999999999'),
      ));

      final success = await container.read(authProvider.notifier).login(
        email: 'user@dripzoid.com',
        password: 'Password123!',
      );

      expect(success, isTrue);
      expect(await tokenStorage.getToken(), equals('persisted_jwt_789'));
      expect(container.read(authProvider).status, equals(AuthStatus.authenticated));
    });

    test('11. AuthNotifier.logout clears token and authenticated state', () async {
      final fakeStorage = FakeSecureStorage();
      final tokenStorage = TokenStorage(fakeStorage);
      await tokenStorage.saveToken('token_before_logout');

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(tokenStorage),
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authProvider.notifier).logout();

      expect(await tokenStorage.getToken(), isNull);
      expect(container.read(authProvider).status, equals(AuthStatus.unauthenticated));
    });
  });

  group('OrderHistoryNotifier Authentication & Protection Tests', () {
    setUp(() async {
      await TokenStorage(FakeSecureStorage()).clearToken();
    });

    test('12. fetchOrders blocks unauthenticated request and sets auth error without doomed network call', () async {
      final fakeStorage = FakeSecureStorage();
      final tokenStorage = TokenStorage(fakeStorage);
      await tokenStorage.clearToken();
      final mockOrderRepo = MockOrderRepository();
      final mockAuthRepo = MockAuthRepository();

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(tokenStorage),
          orderRepositoryProvider.overrideWithValue(mockOrderRepo),
          authRepositoryProvider.overrideWithValue(mockAuthRepo),
        ],
      );
      addTearDown(container.dispose);

      // Force unauthenticated state
      container.read(authProvider.notifier).setUnauthenticated();

      await container.read(orderHistoryProvider.notifier).fetchOrders();

      final state = container.read(orderHistoryProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, equals('Please sign in to view your orders'));
      // No network request was sent to /api/user/orders
      expect(mockOrderRepo.getUserOrdersCallCount, equals(0));
    });

    test('13. fetchOrders awaits session check when state is initial before fetching orders', () async {
      final fakeStorage = FakeSecureStorage();
      final tokenStorage = TokenStorage(fakeStorage);
      await tokenStorage.saveToken('jwt_valid_session');

      final mockOrderRepo = MockOrderRepository();
      final mockAuthRepo = MockAuthRepository();

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(tokenStorage),
          orderRepositoryProvider.overrideWithValue(mockOrderRepo),
          authRepositoryProvider.overrideWithValue(mockAuthRepo),
        ],
      );
      addTearDown(container.dispose);

      // AuthState is initial
      expect(container.read(authProvider).status, equals(AuthStatus.initial));

      await container.read(orderHistoryProvider.notifier).fetchOrders();

      // Session check was awaited and succeeded
      expect(mockAuthRepo.getCurrentUserCallCount, equals(1));
      // Orders were fetched with authenticated client
      expect(mockOrderRepo.getUserOrdersCallCount, equals(1));
      expect(container.read(orderHistoryProvider).isLoading, isFalse);
    });
  });
}
