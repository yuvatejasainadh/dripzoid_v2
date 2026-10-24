import 'user_model.dart';

class LoginResponse {
  final bool success;
  final String message;
  final String? token;
  final String? sessionId;
  final UserModel user;

  const LoginResponse({
    required this.success,
    required this.message,
    this.token,
    required this.sessionId,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final userData = json["user"] ?? (json["data"] is Map ? (json["data"]["user"] ?? json["data"]) : null) ?? json;
    final token = json["token"]?.toString() ??
        json["accessToken"]?.toString() ??
        (json["data"] is Map ? (json["data"]["token"]?.toString() ?? json["data"]["accessToken"]?.toString()) : null);
    final sessionId = json["sessionId"]?.toString() ??
        (json["data"] is Map ? json["data"]["sessionId"]?.toString() : null) ??
        token;

    return LoginResponse(
      success: json["success"] == true || json["status"] == "success",
      message: json["message"]?.toString() ?? "",
      token: token,
      sessionId: sessionId,
      user: UserModel.fromJson(userData is Map<String, dynamic> ? userData : Map<String, dynamic>.from(userData as Map)),
    );
  }
}
