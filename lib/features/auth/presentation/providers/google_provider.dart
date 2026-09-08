import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/config_provider.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/services/google_auth_service.dart';

final googleAuthProvider = Provider<GoogleAuthService>((ref) {
  final dio = ref.watch(dioInstanceProvider);
  final config = ref.watch(configProvider);
  return GoogleAuthService(dio, config);
});
