import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/services/app_initializer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/product_attribution.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  bool _hasError = false;
  String _errorMessage = '';
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scale = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    if (_isInitializing) return;
    setState(() {
      _isInitializing = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      await AppInitializer.initialize();
      // 10-second timeout for initial session check
      await ref.read(authProvider.notifier).checkSession().timeout(
        const Duration(seconds: 10),
      );
    } on TimeoutException {
      AppLogger.w('[SplashScreen] Session verification timed out');
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _hasError = true;
          _errorMessage = 'Connection timed out. Please check your network.';
        });
      }
      return;
    } catch (e, stack) {
      AppLogger.e('[SplashScreen] [initialize] Critical failure during startup', error: e, stackTrace: stack);
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _hasError = true;
          _errorMessage = 'Unable to connect to server. Please try again.';
        });
      }
      return;
    } finally {
      if (mounted && !_hasError) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Stack(
              children: [
                Center(
                  child: Transform.translate(
                    offset: const Offset(0, -30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppLogo(size: 190),

                        Transform.translate(
                          offset: const Offset(0, -55),
                          child: Column(
                            children: [
                              Text(
                                "DRIPZOID",
                                style: textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 6,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Wear The Confidence",
                                style: textTheme.bodyMedium?.copyWith(
                                  letterSpacing: .5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                _buildBottomSection(context, textTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, TextTheme textTheme) {
    final theme = Theme.of(context);

    if (_hasError) {
      return Positioned(
        left: 24,
        right: 24,
        bottom: 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: _initialize,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Retry'),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).setUnauthenticated();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Continue to Login'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const ProductAttribution(),
          ],
        ),
      );
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLoader(),
          const SizedBox(height: 14),
          Text(
            "Initializing...",
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          const ProductAttribution(),
        ],
      ),
    );
  }
}
