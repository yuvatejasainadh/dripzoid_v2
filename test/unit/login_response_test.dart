import 'package:flutter_test/flutter_test.dart';
import 'package:dripzoid_v2/features/auth/data/models/login_response.dart';

void main() {
  group('LoginResponse JSON Parsing Tests', () {
    test('Parses standard response with top-level user object', () {
      final json = {
        'success': true,
        'message': 'Logged in successfully',
        'sessionId': 'sess_123',
        'user': {
          'id': 'usr_1',
          'email': 'test@dripzoid.com',
          'name': 'Test User',
        },
      };

      final response = LoginResponse.fromJson(json);
      expect(response.success, isTrue);
      expect(response.message, equals('Logged in successfully'));
      expect(response.sessionId, equals('sess_123'));
      expect(response.user.email, equals('test@dripzoid.com'));
      expect(response.user.name, equals('Test User'));
    });

    test('Parses nested data response object safely without throwing TypeError', () {
      final json = {
        'status': 'success',
        'token': 'bearer_token_abc',
        'data': {
          'user': {
            'id': 'usr_2',
            'email': 'nested@dripzoid.com',
            'name': 'Nested User',
          },
        },
      };

      final response = LoginResponse.fromJson(json);
      expect(response.success, isTrue);
      expect(response.sessionId, equals('bearer_token_abc'));
      expect(response.user.email, equals('nested@dripzoid.com'));
    });
  });
}
