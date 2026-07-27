import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app.dart';
import 'core/network/dio_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DioClient.initialize();

  runApp(
    const ProviderScope(
      child: DripzoidApp(),
    ),
  );
}