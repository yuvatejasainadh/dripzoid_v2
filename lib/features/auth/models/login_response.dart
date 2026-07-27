
import 'user_model.dart';
class LoginResponse {
  final bool success;
  final String message;
  final String? sessionId;
  final UserModel user;

  const LoginResponse({
    required this.success,
    required this.message,
    required this.sessionId,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      sessionId: json["sessionId"]?.toString(),
      user: UserModel.fromJson(json["user"]),
    );
  }
}