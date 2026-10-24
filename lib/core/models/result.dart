import 'package:equatable/equatable.dart';
import '../network/api_exception.dart';

sealed class Result<T> extends Equatable {
  const Result();

  @override
  List<Object?> get props => [];
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  List<Object?> get props => [data];
}

class Failure<T> extends Result<T> {
  final String message;
  final int? statusCode;
  final ApiErrorType errorType;
  final dynamic exception;
  final StackTrace? stackTrace;
  final String? endpoint;

  const Failure(
    this.message, {
    this.statusCode,
    this.errorType = ApiErrorType.unknown,
    this.exception,
    this.stackTrace,
    this.endpoint,
  });

  @override
  List<Object?> get props => [message, statusCode, errorType, exception, stackTrace, endpoint];
}
