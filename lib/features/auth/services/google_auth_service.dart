import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';

class GoogleAuthService {
  GoogleAuthService() {
    _initialize();
  }

  final Dio _dio = DioClient.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _initialized = false;

  Future<void> _initialize() async {
    if (_initialized) return;

    await _googleSignIn.initialize();

    _initialized = true;
  }

  Future<bool> signIn() async {
    await _initialize();

    try {
      if (!_googleSignIn.supportsAuthenticate()) {
        throw Exception(
          "Google Sign-In is not supported on this platform.",
        );
      }

      final GoogleSignInAccount account =
      await _googleSignIn.authenticate(
        scopeHint: const [
          'email',
          'profile',
        ],
      );

      final auth = account.authentication;

      final idToken = auth.idToken;

      if (idToken == null) {
        throw Exception("Google ID Token is null");
      }

      await _dio.post(
        ApiEndpoints.googleLogin,
        data: {
          "idToken": idToken,
        },
      );

      return true;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _initialize();
    await _googleSignIn.signOut();
  }
}