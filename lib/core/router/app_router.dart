import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
// ... (rest of imports remain same, but I'll update the whole file as it's cleaner)
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_email_screen.dart';
import '../../features/auth/presentation/screens/register_otp_screen.dart';
import '../../features/auth/presentation/screens/register_details_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/forgot_otp_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/session_loader_screen.dart';
import '../../features/products/presentation/screens/product_details_screen.dart';
import '../../features/products/presentation/screens/shop_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/wishlist/presentation/screens/wishlist_screen.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/checkout/presentation/screens/order_success_screen.dart';
import '../../features/orders/presentation/screens/order_history_screen.dart';
import '../../features/orders/presentation/screens/order_details_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/screens/edit_profile_screen.dart';
import '../../features/auth/presentation/screens/security_screen.dart';
import '../../features/auth/presentation/screens/about_screen.dart';
import '../../features/address/presentation/screens/address_list_screen.dart';
import '../../features/address/presentation/screens/address_form_screen.dart';
import '../../features/address/data/models/address_model.dart';
import '../../features/cart/data/models/cart_item_model.dart';
import '../../features/orders/data/models/order_model.dart';
import '../../features/navigation/presentation/screens/app_shell.dart';
import '../../features/askdrip/presentation/screens/askdrip_chat_screen.dart';

final _rootNavigatorKey = GlobalObjectKey<NavigatorState>('root');
final _homeNavigatorKey = GlobalObjectKey<NavigatorState>('home');
final _wishlistNavigatorKey = GlobalObjectKey<NavigatorState>('wishlist');
final _askDripNavigatorKey = GlobalObjectKey<NavigatorState>('askdrip');
final _cartNavigatorKey = GlobalObjectKey<NavigatorState>('cart');
final _profileNavigatorKey = GlobalObjectKey<NavigatorState>('profile');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final status = authState.status;
      final location = state.uri.path;

      final isAuthRoute = location.startsWith('/login') ||
          location.startsWith('/register') ||
          location.startsWith('/forgot') ||
          location.startsWith('/reset');

      final isProtectedRoute = location.startsWith('/home') ||
          location.startsWith('/cart') ||
          location.startsWith('/wishlist') ||
          location.startsWith('/askdrip') ||
          location.startsWith('/profile') ||
          location.startsWith('/shop') ||
          location.startsWith('/checkout') ||
          location.startsWith('/order-success') ||
          location.startsWith('/product');

      // 1. Handle Initial State - Stay on Splash
      if (status == AuthStatus.initial) {
        return null; 
      }

      // 2. Handle Authenticated Users
      if (status == AuthStatus.authenticated) {
        if (isAuthRoute || location == '/') {
          return '/home';
        }
      }

      // 3. Handle Unauthenticated Users
      if (status == AuthStatus.unauthenticated) {
        if (isProtectedRoute || location == '/') {
          return '/login';
        }
      }

      return null;
    },
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
      name: 'product',
      parentNavigatorKey: _rootNavigatorKey,
      path: '/product/:id',
      redirect: (context, state) {
        final id = state.pathParameters['id'];
        if (id == null || id.trim().isEmpty) {
          return '/home';
        }
        return null;
      },
      pageBuilder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return MaterialPage(
          key: ValueKey('product_${id}_${state.pageKey.value}'),
          child: ProductDetailsScreen(productId: id),
        );
      },
    ),

    // Application Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // Home Branch
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Wishlist Branch
        StatefulShellBranch(
          navigatorKey: _wishlistNavigatorKey,
          routes: [
            GoRoute(
              path: '/wishlist',
              builder: (context, state) => const WishlistScreen(),
            ),
          ],
        ),
        // AskDrip Branch
        StatefulShellBranch(
          navigatorKey: _askDripNavigatorKey,
          routes: [
            GoRoute(
              path: '/askdrip',
              builder: (context, state) => const AskDripChatScreen(),
            ),
          ],
        ),
        // Cart Branch
        StatefulShellBranch(
          navigatorKey: _cartNavigatorKey,
          routes: [
            GoRoute(
              path: '/cart',
              builder: (context, state) => const CartScreen(),
            ),
          ],
        ),
        // Profile Branch
        StatefulShellBranch(
          navigatorKey: _profileNavigatorKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'orders',
                  builder: (context, state) => const OrderHistoryScreen(),
                ),
                GoRoute(
                  path: 'order-details/:id',
                  redirect: (context, state) {
                    final id = state.pathParameters['id'];
                    if (id == null || id.trim().isEmpty) {
                      return '/profile/orders';
                    }
                    return null;
                  },
                  builder: (context, state) {
                    final id = state.pathParameters['id'] ?? '';
                    return OrderDetailsScreen(orderId: id);
                  },
                ),
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => const EditProfileScreen(),
                ),
                GoRoute(
                  path: 'security',
                  builder: (context, state) => const SecurityScreen(),
                ),
                GoRoute(
                  path: 'about',
                  builder: (context, state) => const AboutScreen(),
                ),
                GoRoute(
                  path: 'addresses',
                  builder: (context, state) => const AddressListScreen(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (context, state) => const AddressFormScreen(),
                    ),
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) {
                        final address = state.extra is AddressModel ? state.extra as AddressModel : null;
                        return AddressFormScreen(address: address);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    // Full-screen routes (outside shell if needed, or keeping them simple)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/shop',
      builder: (context, state) {
        final category = state.uri.queryParameters['category'];
        return ShopScreen(category: category);
      },
    ),

    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/checkout',
      redirect: (context, state) {
        final extra = state.extra;
        final isValid = extra is List && extra.isNotEmpty && extra.every((item) => item is CartItemModel);
        if (!isValid) {
          return '/cart';
        }
        return null;
      },
      builder: (context, state) {
        final extra = state.extra;
        final items = (extra is List)
            ? extra.whereType<CartItemModel>().toList()
            : <CartItemModel>[];
        return CheckoutScreen(items: items);
      },
    ),

    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/order-success',
      redirect: (context, state) {
        if (state.extra is! OrderModel) {
          return '/profile/orders';
        }
        return null;
      },
      builder: (context, state) {
        final order = state.extra is OrderModel ? state.extra as OrderModel : null;
        if (order == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return OrderSuccessScreen(order: order);
      },
    ),

    // Auth Routes
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/register-email',
      builder: (context, state) => const RegisterEmailScreen(),
    ),

    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/register-otp',
      redirect: (context, state) {
        final email = state.extra is String && (state.extra as String).trim().isNotEmpty
            ? state.extra as String
            : state.uri.queryParameters['email'];
        if (email == null || email.trim().isEmpty) {
          return '/register-email';
        }
        return null;
      },
      builder: (context, state) {
        final email = state.extra is String && (state.extra as String).trim().isNotEmpty
            ? state.extra as String
            : state.uri.queryParameters['email'] ?? '';
        return RegisterOtpScreen(email: email);
      },
    ),

    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/register-details',
      redirect: (context, state) {
        final email = state.extra is String && (state.extra as String).trim().isNotEmpty
            ? state.extra as String
            : state.uri.queryParameters['email'];
        if (email == null || email.trim().isEmpty) {
          return '/register-email';
        }
        return null;
      },
      builder: (context, state) {
        final email = state.extra is String && (state.extra as String).trim().isNotEmpty
            ? state.extra as String
            : state.uri.queryParameters['email'] ?? '';
        return RegisterDetailsScreen(email: email);
      },
    ),

    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/forgot-otp',
      redirect: (context, state) {
        final email = state.extra is String && (state.extra as String).trim().isNotEmpty
            ? state.extra as String
            : state.uri.queryParameters['email'];
        if (email == null || email.trim().isEmpty) {
          return '/forgot-password';
        }
        return null;
      },
      builder: (context, state) {
        final email = state.extra is String && (state.extra as String).trim().isNotEmpty
            ? state.extra as String
            : state.uri.queryParameters['email'] ?? '';
        return ForgotOtpScreen(email: email);
      },
    ),

    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/reset-password',
      redirect: (context, state) {
        final email = state.extra is String && (state.extra as String).trim().isNotEmpty
            ? state.extra as String
            : state.uri.queryParameters['email'];
        if (email == null || email.trim().isEmpty) {
          return '/forgot-password';
        }
        return null;
      },
      builder: (context, state) {
        final email = state.extra is String && (state.extra as String).trim().isNotEmpty
            ? state.extra as String
            : state.uri.queryParameters['email'] ?? '';
        return ResetPasswordScreen(email: email);
      },
    ),
  ],
);
});

class _AuthListenable extends ChangeNotifier {
  final Ref _ref;
  _AuthListenable(this._ref) {
    _ref.listen(authProvider, (previous, next) {
      if (previous?.status != next.status) {
        notifyListeners();
      }
    });
  }
}
