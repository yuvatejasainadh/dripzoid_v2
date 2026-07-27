class ApiEndpoints {
  ApiEndpoints._();

  // Change this according to your backend
  static const String baseUrl =
      "https://api.dripzoid.com";

  // Authentication
  static const String login = "/api/auth/login";
  static const String register = "/api/auth/register";
  static const String checkEmail = "/api/auth/check-email";
  static const String resetPassword = "/api/auth/reset-password";
  static const String googleLogin = "/api/auth/google";

  // User
  static const String me = "/api/auth/me";
  static const String logout = "/api/auth/logout";
}