import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/logging/app_logger.dart';

class GoogleAuthService {
  final Dio _dio;
  final AppConfig _config;
  
  GoogleAuthService(this._dio, this._config);

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _initialized = false;

  Future<void> _initialize() async {
    if (_initialized) return;
    await _googleSignIn.initialize(
      serverClientId: _config.googleWebClientId,
    );
    _initialized = true;
  }

  Future<Map<String, dynamic>?> signIn() async {
    await _initialize();

    try {
      AppLogger.d('[GoogleAuth] Starting Google authentication');
      
      if (!_googleSignIn.supportsAuthenticate()) {
        throw Exception("Google Sign-In is not supported on this platform.");
      }

      final GoogleSignInAccount account = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );
      
      AppLogger.d('[GoogleAuth] Google account selected: ${account.email}');

      final auth = account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        AppLogger.e('[GoogleAuth] Google ID Token is null');
        throw Exception("Google ID Token is null");
      }

      AppLogger.d('[GoogleAuth] ID Token obtained, calling mobile backend endpoint');

      final result = await _dio.post(
        ApiEndpoints.googleMobileLogin,
        data: {
          "idToken": idToken,
        },
      );

      if (result.statusCode == 200 || result.statusCode == 201) {
        AppLogger.d('[GoogleAuth] Backend authentication successful');
        return result.data as Map<String, dynamic>;
      }
      
      AppLogger.e('[GoogleAuth] Backend authentication failed with status: ${result.statusCode}');
      throw Exception("Backend authentication failed with status: ${result.statusCode}");
    } catch (e) {
      if (e is GoogleSignInException) {
        if (e.code == GoogleSignInExceptionCode.canceled) {
          AppLogger.d('[GoogleAuth] User cancelled sign-in');
          return null;
        }
        AppLogger.e('[GoogleAuth] GoogleSignInException: ${e.code} - ${e.description}');
        throw Exception("Google Sign-In failed: ${e.description ?? e.code.name}");
      }
      if (e is DioException) {
        final responseData = e.response?.data;
        String msg = "Backend authentication failed";
        if (responseData is Map) {
          msg = responseData['error']?.toString() ?? responseData['message']?.toString() ?? msg;
        } else if (e.message != null) {
          msg = e.message!;
        }
        AppLogger.e('[GoogleAuth] DioException during backend auth: $msg');
        throw Exception(msg);
      }
      AppLogger.e('[GoogleAuth] Unexpected Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      AppLogger.d('[GoogleAuth] Signed out from Google');
    } catch (e) {
      AppLogger.w('[GoogleAuth] SignOut exception: $e');
    }
  }
}
