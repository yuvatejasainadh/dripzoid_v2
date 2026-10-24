import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app.dart';
import 'core/config/app_config.dart';
import 'core/config/config_provider.dart';
import 'core/logging/app_logger.dart';
import 'core/logging/provider_observer.dart';
import 'core/network/dio_provider.dart';
import 'core/network/network_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Flutter framework error handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLogger.e(
      '[FlutterError] ${details.exceptionAsString()}',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  // Asynchronous platform dispatcher error handling
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.e(
      '[PlatformDispatcherError] $error',
      error: error,
      stackTrace: stack,
    );
    return true;
  };

  final config = AppConfig.current;
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
