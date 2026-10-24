import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dripzoid_v2/core/models/result.dart';
import 'package:dripzoid_v2/core/network/api_exception.dart';
import 'package:dripzoid_v2/core/network/app_interceptor.dart';
import 'package:dripzoid_v2/core/network/network_info.dart';
import 'package:dripzoid_v2/core/network/token_storage.dart';
import 'package:dripzoid_v2/core/ui/dialogs/app_error_dialog.dart';
import 'package:dripzoid_v2/features/auth/data/models/login_response.dart';
import 'package:dripzoid_v2/features/auth/data/models/user_model.dart';
import 'package:dripzoid_v2/features/auth/data/repositories/auth_repository.dart';
import 'package:dripzoid_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:dripzoid_v2/features/auth/presentation/screens/login_screen.dart';
import 'package:dripzoid_v2/shared/widgets/primary_button.dart';

// ---------------------------------------------------------------------------
// Test Doubles
// ---------------------------------------------------------------------------

class FakeConnectivity implements Connectivity {
  List<ConnectivityResult> connectivityResults;
  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  FakeConnectivity(this.connectivityResults);

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return connectivityResults;
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  void emit(List<ConnectivityResult> results) {
    connectivityResults = results;
    _controller.add(results);
  }
}

class FakeTokenStorage implements TokenStorage {
  String? token;
  FakeTokenStorage([this.token]);

  @override
  Future<void> clearToken() async => token = null;

  @override
  Future<String?> getToken() async => token;

  @override
  Future<void> saveToken(String t) async => token = t;
}

class MockErrorInterceptorHandler extends ErrorInterceptorHandler {
  DioException? rejectedError;

  @override
  void reject(DioException error, [bool isHandlerExecution = false]) {
    rejectedError = error;
  }
}

class MockAuthRepository implements AuthRepository {
  Result<LoginResponse>? loginResult;
  int loginCallCount = 0;
  Completer<Result<LoginResponse>>? pendingLoginCompleter;

  @override
  Future<Result<LoginResponse>> login({
    required String email,
    required String password,
  }) async {
    loginCallCount++;
    if (pendingLoginCompleter != null) {
      return pendingLoginCompleter!.future;
    }
    return loginResult ??
        const Failure('Invalid email or password', statusCode: 401);
  }

  @override
  Future<Result<UserModel>> getCurrentUser() async {
    return const Failure('No session', statusCode: 401);
  }

  @override
  Future<Result<bool>> checkEmail(String email) async => const Success(false);

  @override
  Future<Result<Map<String, dynamic>>> register(Map<String, dynamic> data) async =>
      const Success({});

  @override
  Future<Result<void>> sendOTP(String email) async => const Success(null);

  @override
  Future<Result<void>> verifyOTP(String email, String otp) async =>
      const Success(null);

  @override
  Future<Result<void>> resetPassword({
    required String email,
    required String password,
  }) async => const Success(null);

  @override
  Future<Result<void>> logout() async => const Success(null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    AppErrorDialog.resetForTesting();
  });

  // =========================================================================
  // 1. AppInterceptor & Error Classification Tests
  // =========================================================================
  group('AppInterceptor & Error Classification Tests', () {
    late AppInterceptor interceptor;

    setUp(() {
      interceptor = AppInterceptor();
    });

    DioException createDioException({
      required DioExceptionType type,
      int? statusCode,
      dynamic data,
      String? message,
    }) {
      return DioException(
        requestOptions: RequestOptions(path: '/api/test'),
        type: type,
        response: statusCode != null
            ? Response(
                requestOptions: RequestOptions(path: '/api/test'),
                statusCode: statusCode,
                data: data,
              )
            : null,
        message: message,
      );
    }

    ApiException getRejectedApiException(DioException err) {
      final handler = MockErrorInterceptorHandler();
      interceptor.onError(err, handler);
      expect(handler.rejectedError, isNotNull);
      expect(handler.rejectedError!.error, isA<ApiException>());
      return handler.rejectedError!.error as ApiException;
    }

    test('1. connectionError maps to networkUnavailable with connection message', () {
      final err = createDioException(type: DioExceptionType.connectionError);
      final apiException = getRejectedApiException(err);
      expect(apiException.type, equals(ApiErrorType.networkUnavailable));
      expect(apiException.message, contains("We couldn't connect to Dripzoid"));
    });

    test('2. connectionTimeout / sendTimeout / receiveTimeout map to timeout', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        final err = createDioException(type: type);
        final apiException = getRejectedApiException(err);
        expect(apiException.type, equals(ApiErrorType.timeout));
        expect(apiException.message, contains('The request took too long'));
      }
    });

    test('3. HTTP 401 & 403 map to authentication error', () {
      for (final code in [401, 403]) {
        final err = createDioException(
          type: DioExceptionType.badResponse,
          statusCode: code,
          data: {'message': 'Invalid credentials'},
        );
        final apiException = getRejectedApiException(err);
        expect(apiException.type, equals(ApiErrorType.authentication));
        expect(apiException.message, equals('Invalid credentials'));
      }
    });

    test('4. HTTP 422 & 400 map to validation error', () {
      for (final code in [400, 422]) {
        final err = createDioException(
          type: DioExceptionType.badResponse,
          statusCode: code,
          data: {'message': 'Field email is invalid'},
        );
        final apiException = getRejectedApiException(err);
        expect(apiException.type, equals(ApiErrorType.validation));
        expect(apiException.message, equals('Field email is invalid'));
      }
    });

    test('5. HTTP 429 maps to rateLimit', () {
      final err = createDioException(
        type: DioExceptionType.badResponse,
        statusCode: 429,
        data: {'message': 'Too many requests'},
      );
      final apiException = getRejectedApiException(err);
      expect(apiException.type, equals(ApiErrorType.rateLimit));
      expect(apiException.message, contains('Too many requests'));
    });

    test('6. HTTP 500 with CORS message maps to corsOrBlocked', () {
      final err = createDioException(
        type: DioExceptionType.badResponse,
        statusCode: 500,
        data: {'success': false, 'message': 'Origin https://dripzoidv2.vercel.app not allowed by CORS'},
      );
      final apiException = getRejectedApiException(err);
      expect(apiException.type, equals(ApiErrorType.corsOrBlocked));
      expect(apiException.message, contains("We couldn't connect to Dripzoid"));
    });

    test('7. Standard HTTP 500 & 503 map to serverError', () {
      for (final code in [500, 503]) {
        final err = createDioException(
          type: DioExceptionType.badResponse,
          statusCode: code,
          data: {'message': 'Internal Server Error'},
        );
        final apiException = getRejectedApiException(err);
        expect(apiException.type, equals(ApiErrorType.serverError));
        expect(apiException.message, equals('Internal Server Error'));
      }
    });
  });

  // =========================================================================
  // 2. NetworkInfo & Connectivity Tests
  // =========================================================================
  group('NetworkInfo Connectivity Tests', () {
    test('reports offline when ConnectivityResult.none is present', () async {
      final fake = FakeConnectivity([ConnectivityResult.none]);
      final info = NetworkInfo(fake);
      expect(await info.isConnected, isFalse);
    });

    test('reports online when active connection (wifi / mobile / ethernet) is present', () async {
      for (final conn in [
        [ConnectivityResult.wifi],
        [ConnectivityResult.mobile],
        [ConnectivityResult.ethernet],
      ]) {
        final fake = FakeConnectivity(conn);
        final info = NetworkInfo(fake);
        expect(await info.isConnected, isTrue);
      }
    });
  });

  // =========================================================================
  // 3. AppErrorDialog Presentation, Responsive Layout & Deduplication Tests
  // =========================================================================
  group('AppErrorDialog UI & Deduplication Tests', () {
    Widget buildTestApp(Widget child) {
      return MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(body: Center(child: child)),
      );
    }

    testWidgets('shows correct title, message, and icon for connection error', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                AppErrorDialog.showForError(
                  context,
                  error: const Failure('Connection failed', errorType: ApiErrorType.networkUnavailable),
                  onRetry: () {},
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Connection Problem'), findsOneWidget);
      expect(find.text("We couldn't connect to Dripzoid. Check your connection and try again."), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Dismiss'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);

      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();
      expect(find.text('Connection Problem'), findsNothing);
    });

    testWidgets('retry callback is triggered when tapping Retry', (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                AppErrorDialog.showForError(
                  context,
                  error: const Failure('Timed out', errorType: ApiErrorType.timeout),
                  onRetry: () => retried = true,
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Request Timed Out'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(retried, isTrue);
      expect(find.text('Request Timed Out'), findsNothing);
    });

    testWidgets('deduplication prevents opening duplicate dialogs', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                AppErrorDialog.show(
                  context,
                  title: 'Duplicate Test',
                  message: 'First dialog',
                );
                AppErrorDialog.show(
                  context,
                  title: 'Duplicate Test 2',
                  message: 'Second dialog should be ignored',
                );
              },
              child: const Text('Show Twice'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Twice'));
      await tester.pumpAndSettle();

      expect(find.text('Duplicate Test'), findsOneWidget);
      expect(find.text('Duplicate Test 2'), findsNothing);

      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();
    });

    testWidgets('renders cleanly on 320px mobile viewport without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                AppErrorDialog.showForError(
                  context,
                  error: const Failure('Server down', errorType: ApiErrorType.serverError),
                  onRetry: () {},
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Service Temporarily Unavailable'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();
    });

    testWidgets('renders cleanly on 844x390 mobile landscape without overflow', (tester) async {
      tester.view.physicalSize = const Size(844, 390);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                AppErrorDialog.showForError(
                  context,
                  error: const Failure('Error', errorType: ApiErrorType.networkUnavailable),
                  onRetry: () {},
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Connection Problem'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();
    });

    testWidgets('renders cleanly on 1440x900 desktop viewport centered', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                AppErrorDialog.showForError(
                  context,
                  error: const Failure('Auth', errorType: ApiErrorType.authentication),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Authentication Error'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();
    });
  });

  // =========================================================================
  // 4. Login Loading State & Recovery Tests
  // =========================================================================
  group('Login Loading State & Non-Stuck Button Tests', () {
    late MockAuthRepository mockAuthRepo;
    late FakeTokenStorage fakeTokenStorage;

    setUp(() {
      mockAuthRepo = MockAuthRepository();
      fakeTokenStorage = FakeTokenStorage();
    });

    Widget createLoginTestWidget() {
      return ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepo),
          tokenStorageProvider.overrideWithValue(fakeTokenStorage),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      );
    }

    testWidgets('Login button resets loading state and shows AppErrorDialog after failure', (tester) async {
      mockAuthRepo.loginResult = const Failure(
        "We couldn't connect to Dripzoid. Check your connection and try again.",
        errorType: ApiErrorType.networkUnavailable,
      );

      await tester.pumpWidget(createLoginTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'user@test.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.pumpAndSettle();

      // Tap Login button (PrimaryButton internally uses FilledButton)
      await tester.tap(find.widgetWithText(FilledButton, 'Login').first);
      await tester.pump(); // Start async login

      // Verify that after resolution, dialog appears and button is NOT loading
      await tester.pumpAndSettle();

      // Centered dialog is displayed
      expect(find.text('Connection Problem'), findsOneWidget);
      expect(find.text("We couldn't connect to Dripzoid. Check your connection and try again."), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();

      // Button is enabled and displays "Login", not loading spinner
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Duplicate submit is prevented while login is already in progress', (tester) async {
      final completer = Completer<Result<LoginResponse>>();
      mockAuthRepo.pendingLoginCompleter = completer;

      await tester.pumpWidget(createLoginTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'user@test.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.pumpAndSettle();

      // First tap
      await tester.tap(find.widgetWithText(FilledButton, 'Login').first);
      await tester.pump();

      // While loading, tap second time
      await tester.tap(find.byType(PrimaryButton).first);
      await tester.pump();

      // Login repository was called only ONCE
      expect(mockAuthRepo.loginCallCount, equals(1));

      // Resolve login
      completer.complete(const Failure('Failed', errorType: ApiErrorType.authentication));
      await tester.pumpAndSettle();

      // Dismiss error
      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();

      // Button is restored
      expect(find.text('Login'), findsOneWidget);
    });
  });
}
