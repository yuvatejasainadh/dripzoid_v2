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
    final userData = json["user"] ?? (json["data"] is Map ? (json["data"]["user"] ?? json["data"]) : null) ?? json;
    return LoginResponse(
      success: json["success"] == true || json["status"] == "success",
      message: json["message"]?.toString() ?? "",
      sessionId: json["sessionId"]?.toString() ?? json["token"]?.toString() ?? json["accessToken"]?.toString(),
      user: UserModel.fromJson(userData is Map<String, dynamic> ? userData : Map<String, dynamic>.from(userData as Map)),
    );
  }
}
