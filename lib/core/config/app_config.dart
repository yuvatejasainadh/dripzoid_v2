import 'environment.dart';

class AppConfig {
  final String baseUrl;
  final String aiBaseUrl;
  final String appName;
  final AppEnvironment environment;
  final String razorpayKey;
  final String googleWebClientId;
  final Duration connectionTimeout;

  AppConfig({
    required this.baseUrl,
    required this.aiBaseUrl,
    required this.appName,
    required this.environment,
    required this.razorpayKey,
    required this.googleWebClientId,
    this.connectionTimeout = const Duration(seconds: 30),
  });

  static AppConfig dev = AppConfig(
    baseUrl: "https://drz.yuvatejasainadh.me",
    aiBaseUrl: "https://askdrip-backend.onrender.com",
    appName: "Dripzoid (Dev)",
    environment: AppEnvironment.development,
    razorpayKey: const String.fromEnvironment('RAZORPAY_KEY', defaultValue: ''),
    googleWebClientId: "83358271931-jt696gs2pb1bqssq2fer32n2ou7gjaoi.apps.googleusercontent.com",
  );

  static AppConfig staging = AppConfig(
    baseUrl: "https://drz.yuvatejasainadh.me",
    aiBaseUrl: "https://askdrip-backend.onrender.com",
    appName: "Dripzoid (Staging)",
    environment: AppEnvironment.staging,
    razorpayKey: const String.fromEnvironment('RAZORPAY_KEY', defaultValue: ''),
    googleWebClientId: "83358271931-jt696gs2pb1bqssq2fer32n2ou7gjaoi.apps.googleusercontent.com",
  );

  static AppConfig production = AppConfig(
    baseUrl: "https://drz.yuvatejasainadh.me",
    aiBaseUrl: "https://askdrip-backend.onrender.com",
    appName: "Dripzoid",
    environment: AppEnvironment.production,
    razorpayKey: const String.fromEnvironment('RAZORPAY_KEY', defaultValue: ''),
    googleWebClientId: "83358271931-jt696gs2pb1bqssq2fer32n2ou7gjaoi.apps.googleusercontent.com",
  );
}
