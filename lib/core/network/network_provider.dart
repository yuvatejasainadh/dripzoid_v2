import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'network_info.dart';

final networkProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo();
});