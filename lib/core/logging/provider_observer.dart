import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_logger.dart';

class AppProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    AppLogger.d(
      '🔄 Provider Update: ${provider.name ?? provider.runtimeType}\n'
      'Old: $previousValue\n'
      'New: $newValue',
    );
  }

  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    AppLogger.d(
      '➕ Provider Added: ${provider.name ?? provider.runtimeType}\n'
      'Value: $value',
    );
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    AppLogger.d(
      '🗑️ Provider Disposed: ${provider.name ?? provider.runtimeType}',
    );
  }
}
