import 'package:flutter_test/flutter_test.dart';
import 'package:dripzoid_v2/core/config/app_config.dart';
import 'package:dripzoid_v2/core/network/api_endpoints.dart';

void main() {
  group('AppConfig & Domain Centralization Tests', () {
    test('Commerce Base URL is set to confirmed production domain', () {
      expect(AppConfig.production.baseUrl, equals('https://drz.yuvatejasainadh.me'));
      expect(AppConfig.dev.baseUrl, equals('https://drz.yuvatejasainadh.me'));
      expect(AppConfig.staging.baseUrl, equals('https://drz.yuvatejasainadh.me'));
    });

    test('AskDrip AI Base URL is set to confirmed Render backend', () {
      expect(AppConfig.production.aiBaseUrl, equals('https://askdrip-backend.onrender.com'));
      expect(AppConfig.dev.aiBaseUrl, equals('https://askdrip-backend.onrender.com'));
    });

    test('ApiEndpoints constants align with centralized domain', () {
      expect(ApiEndpoints.baseUrl, equals('https://drz.yuvatejasainadh.me'));
      expect(ApiEndpoints.searchProducts, equals('/api/products/search'));
      expect(ApiEndpoints.products, equals('/api/products'));
    });

    test('Razorpay key defaults to empty when not provided via dart-define', () {
      expect(AppConfig.dev.razorpayKey, isEmpty);
      expect(AppConfig.staging.razorpayKey, isEmpty);
      expect(AppConfig.production.razorpayKey, isEmpty);
    });
  });
}
