import '../../../../core/logging/app_logger.dart';
import '../../../../core/models/result.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _service;

  AuthRepository(this._service);

  Future<Result<LoginResponse>> login({
    required String email,
    required String password,
  }) async {
    AppLogger.i('[AuthRepository] [login] Attempting login for: $email');
    final result = await _service.login(
      LoginRequest(
        email: email,
        password: password,
      ),
    );

    return switch (result) {
      Success(data: final data) => () {
          final response = LoginResponse.fromJson(data);
          AppLogger.i('[AuthRepository] [login] Login successful for: ${response.user.email}');
          return Success<LoginResponse>(response);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.e('[AuthRepository] [login] Login failed: $m', error: e);
          return Failure<LoginResponse>(m, statusCode: s, exception: e);
        }(),
    };
  }

  Future<Result<bool>> checkEmail(String email) async {
    AppLogger.d('[AuthRepository] [checkEmail] Checking: $email');
    final result = await _service.checkEmail(email);

    return switch (result) {
      Success(data: final data) => () {
          final exists = data["exists"] == true;
          AppLogger.d('[AuthRepository] [checkEmail] Result: $exists');
          return Success<bool>(exists);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.e('[AuthRepository] [checkEmail] Failed: $m', error: e);
          return Failure<bool>(m, statusCode: s, exception: e);
        }(),
    };
  }

  Future<Result<UserModel>> getCurrentUser() async {
    AppLogger.d('[AuthRepository] [getCurrentUser] Fetching session...');
    final result = await _service.getCurrentUser();

    return switch (result) {
      Success(data: final data) => () {
          final user = UserModel.fromJson(data["user"]);
          AppLogger.i('[AuthRepository] [getCurrentUser] Session restored for: ${user.email}');
          return Success<UserModel>(user);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.w('[AuthRepository] [getCurrentUser] Session restore failed: $m');
          return Failure<UserModel>(m, statusCode: s, exception: e);
        }(),
    };
  }

  Future<Result<void>> register(Map<String, dynamic> body) async {
    AppLogger.i('[AuthRepository] [register] Attempting registration for: ${body['email']}');
    final result = await _service.register(body);

    return switch (result) {
      Success() => () {
          AppLogger.i('[AuthRepository] [register] Registration successful');
          return const Success<void>(null);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.e('[AuthRepository] [register] Registration failed: $m', error: e);
          return Failure<void>(m, statusCode: s, exception: e);
        }(),
    };
  }

  Future<Result<void>> resetPassword({
    required String email,
    required String password,
  }) async {
    AppLogger.i('[AuthRepository] [resetPassword] Resetting for: $email');
    final result = await _service.resetPassword(
      email: email,
      password: password,
    );

    return switch (result) {
      Success() => () {
          AppLogger.i('[AuthRepository] [resetPassword] Reset successful');
          return const Success<void>(null);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.e('[AuthRepository] [resetPassword] Reset failed: $m', error: e);
          return Failure<void>(m, statusCode: s, exception: e);
        }(),
    };
  }

  Future<Result<void>> logout() async {
    AppLogger.i('[AuthRepository] [logout] Attempting logout...');
    final result = await _service.logout();

    return switch (result) {
      Success() => () {
          AppLogger.i('[AuthRepository] [logout] Logout successful');
          return const Success<void>(null);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e) => () {
          AppLogger.e('[AuthRepository] [logout] Logout failed: $m', error: e);
          return Failure<void>(m, statusCode: s, exception: e);
        }(),
    };
  }

  Future<Result<void>> sendOTP(String email) async {
    AppLogger.i('[AuthRepository] [sendOTP] Sending to: $email');
    final result = await _service.sendOTP(email);
    return switch (result) {
      Success() => const Success(null),
      Failure(message: final m, statusCode: final s, exception: final e) =>
        Failure(m, statusCode: s, exception: e),
    };
  }

  Future<Result<void>> verifyOTP(String email, String otp) async {
    AppLogger.i('[AuthRepository] [verifyOTP] Verifying for: $email');
    final result = await _service.verifyOTP(email, otp);
    return switch (result) {
      Success() => const Success(null),
      Failure(message: final m, statusCode: final s, exception: final e) =>
        Failure(m, statusCode: s, exception: e),
    };
  }
}
