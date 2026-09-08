import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/services/app_initializer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/app_logo.dart';

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
    try {
      await AppInitializer.initialize();
      // Add a reasonable timeout for session check
      await ref.read(authProvider.notifier).checkSession().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          // If it times out, we force unauthenticated status to move forward
          // In a real app, you might want to show a retry button or offline message
        },
      );
    } catch (e, stack) {
      AppLogger.e('[SplashScreen] [initialize] Critical failure during startup', error: e, stackTrace: stack);
    } finally {
      // Fallback: If for any reason the router doesn't move us, 
      // check the status and move manually as a secondary trigger
      if (mounted) {
        final auth = ref.read(authProvider);
        if (auth.status == AuthStatus.authenticated) {
          context.go('/home');
        } else if (auth.status == AuthStatus.unauthenticated) {
          context.go('/login');
        }
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
    final bottomInset = MediaQuery.paddingOf(context).bottom;

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

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: bottomInset + 42,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppLoader(),
                      const SizedBox(height: 18),
                      Text(
                        "Initializing...",
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
