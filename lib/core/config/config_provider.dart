import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_config.dart';

final configProvider = Provider<AppConfig>((ref) {
  // In a real app, this could be determined by build flavors
  return AppConfig.production;
});
