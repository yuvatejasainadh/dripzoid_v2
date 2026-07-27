import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_email_screen.dart';
import '../../features/auth/screens/register_otp_screen.dart';
import '../../features/auth/screens/register_details_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/forgot_otp_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/auth/screens/session_loader_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: '/session-loader',
      builder: (context, state) => const SessionLoaderScreen(),
    ),

    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),

    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: '/register-email',
      builder: (context, state) => const RegisterEmailScreen(),
    ),

    GoRoute(
      path: '/register-otp',
      builder: (context, state) => const RegisterOtpScreen(),
    ),

    GoRoute(
      path: '/register-details',
      builder: (context, state) => const RegisterDetailsScreen(),
    ),

    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    GoRoute(
      path: '/forgot-otp',
      builder: (context, state) => const ForgotOtpScreen(),
    ),

    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
  ],
);