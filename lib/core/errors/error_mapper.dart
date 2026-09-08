import 'package:dio/dio.dart';
import '../network/api_exception.dart';

class UserFeedback {
  final String title;
  final String message;

  UserFeedback({required this.title, required this.message});
}

class ErrorMapper {
  ErrorMapper._();

  static UserFeedback map(dynamic error) {
    String title = 'Something went wrong';
    String message = 'We couldn\'t complete your request. Please try again.';

    if (error is ApiException) {
      message = error.message;
      
      if (error.statusCode == 401) {
        title = 'Session Expired';
        message = 'Your session has expired. Please sign in again.';
      } else if (error.statusCode == 403) {
        title = 'Access Denied';
      } else if (error.statusCode == 404) {
        title = 'Not Found';
      } else if (error.statusCode! >= 500) {
        title = 'Server Error';
        message = 'We\'re having trouble processing your request. Please try again later.';
      }
    } else if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          title = 'Connection Timeout';
          message = 'The server is taking too long to respond. Please check your connection.';
        case DioExceptionType.connectionError:
          title = 'No Internet';
          message = 'Please check your internet connection and try again.';
        default:
          if (error.response?.statusCode == 401) {
            title = 'Session Expired';
            message = 'Your session has expired. Please sign in again.';
          }
      }
    }

    return UserFeedback(title: title, message: message);
  }
}
