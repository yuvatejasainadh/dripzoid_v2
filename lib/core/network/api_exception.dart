enum ApiErrorType {
  networkUnavailable,
  serverError,
  authentication,
  validation,
  rateLimit,
  timeout,
  corsOrBlocked,
  unknown,
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiErrorType type;

  ApiException(
    this.message, {
    this.statusCode,
    this.type = ApiErrorType.unknown,
  });

  @override
  String toString() => message;
}
