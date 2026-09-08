import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app.dart';
import 'core/config/app_config.dart';
import 'core/config/config_provider.dart';
import 'core/network/dio_provider.dart';
import 'core/network/network_initializer.dart';

import 'core/logging/provider_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.production;
  final dio = await NetworkInitializer.initialize(config);
  final aiDio = await NetworkInitializer.initializeAi(config);

  runApp(
    ProviderScope(
      observers: [AppProviderObserver()],
      overrides: [
        dioInstanceProvider.overrideWithValue(dio),
        aiDioInstanceProvider.overrideWithValue(aiDio),
        configProvider.overrideWithValue(config),
      ],
      child: const DripzoidApp(),
    ),
  );
}
