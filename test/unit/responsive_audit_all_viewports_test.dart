import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dripzoid_v2/core/network/token_storage.dart';
import 'package:dripzoid_v2/features/splash/presentation/screens/splash_screen.dart';
import 'package:dripzoid_v2/features/home/presentation/widgets/search_results_view.dart';
import 'package:dripzoid_v2/features/home/presentation/providers/search_notifier.dart';
import 'package:dripzoid_v2/features/products/data/models/product_model.dart';
import 'package:dripzoid_v2/features/products/presentation/widgets/product_purchase_bar.dart';
import 'package:dripzoid_v2/shared/widgets/category_card.dart';
import 'package:dripzoid_v2/core/ui/widgets/premium_dialog_widget.dart';
import 'package:dripzoid_v2/features/auth/presentation/widgets/profile_quick_action_card.dart';

class MockTokenStorage implements TokenStorage {
  @override
  Future<void> saveToken(String token) async {}
  @override
  Future<String?> getToken() async => null;
  @override
  Future<void> clearToken() async {}
}

class _StaticSearchNotifier extends SearchNotifier {
  final SearchState _initial;
  _StaticSearchNotifier(this._initial);

  @override
  SearchState build() => _initial;
}

const allViewports = <String, Size>{
  'Small Mobile': Size(320, 640),
  'Standard Mobile': Size(360, 800),
  'Large Mobile': Size(393, 852),
  'Mobile Landscape': Size(844, 390),
  'Tablet Portrait': Size(768, 1024),
  'Tablet Landscape': Size(1024, 768),
  'Laptop': Size(1366, 768),
  'Desktop': Size(1440, 900),
  'Wide Desktop': Size(1920, 1080),
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SplashScreen Viewport Audit', () {
    for (final entry in allViewports.entries) {
      testWidgets('SplashScreen renders cleanly on ${entry.key} (${entry.value.width}x${entry.value.height})', (tester) async {
        final List<String> errors = [];
        final oldHandler = FlutterError.onError;
        FlutterError.onError = (FlutterErrorDetails details) {
          final msg = details.toString();
          if (msg.contains('overflowed') || msg.contains('RenderFlex')) {
            errors.add(msg);
          }
        };

        tester.view.physicalSize = Size(entry.value.width * 2, entry.value.height * 2);
        tester.view.devicePixelRatio = 2.0;

        try {
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                tokenStorageProvider.overrideWithValue(MockTokenStorage()),
              ],
              child: MaterialApp(
                home: MediaQuery(
                  data: MediaQueryData(size: entry.value),
                  child: const SplashScreen(),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(seconds: 2));
        } finally {
          FlutterError.onError = oldHandler;
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        }

        expect(errors, isEmpty, reason: 'No RenderFlex overflow on ${entry.key}');
      });
    }
  });

  group('SearchResultsView Viewport Audit', () {
    testWidgets('SearchResultsView with long query string does not overflow on 320x640', (tester) async {
      final List<String> errors = [];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        final msg = details.toString();
        if (msg.contains('overflowed') || msg.contains('RenderFlex')) {
          errors.add(msg);
        }
      };

      tester.view.physicalSize = const Size(320 * 2, 640 * 2);
      tester.view.devicePixelRatio = 2.0;

      const testState = SearchState(
        query: 'Very long query text searching for oversized vintage oversized streetwear hoodie acid wash',
        results: [
          ProductModel(
            id: '1',
            name: 'Heavyweight Oversized Hoodie',
            slug: 'heavyweight-hoodie',
            price: 2499,
            images: [],
          ),
        ],
      );

      try {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              searchProvider.overrideWith(() => _StaticSearchNotifier(testState)),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: MediaQuery(
                  data: MediaQueryData(size: Size(320, 640)),
                  child: SearchResultsView(),
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
      } finally {
        FlutterError.onError = oldHandler;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }

      expect(errors, isEmpty, reason: 'SearchResultsView must not overflow with long query text on 320px');
    });
  });

  group('ProductPurchaseBar Viewport Audit', () {
    testWidgets('ProductPurchaseBar renders symmetrically and without overflow on 320px', (tester) async {
      final List<String> errors = [];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        final msg = details.toString();
        if (msg.contains('overflowed') || msg.contains('RenderFlex')) {
          errors.add(msg);
        }
      };

      tester.view.physicalSize = const Size(320 * 2, 640 * 2);
      tester.view.devicePixelRatio = 2.0;

      try {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: ProductPurchaseBar(
                isAvailable: true,
                isInCart: false,
                isLoading: false,
                onAddToCart: () {},
                onBuyNow: () {},
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // Also test isInCart = true state
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: ProductPurchaseBar(
                isAvailable: true,
                isInCart: true,
                isLoading: false,
                onAddToCart: () {},
                onBuyNow: () {},
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
      } finally {
        FlutterError.onError = oldHandler;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }

      expect(errors, isEmpty, reason: 'ProductPurchaseBar must not overflow on 320px');
    });
  });

  group('CategoryCard & Dialog Viewport Audit', () {
    testWidgets('CategoryCard with long label on 320px does not overflow', (tester) async {
      final List<String> errors = [];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        final msg = details.toString();
        if (msg.contains('overflowed') || msg.contains('RenderFlex')) {
          errors.add(msg);
        }
      };

      tester.view.physicalSize = const Size(320 * 2, 640 * 2);
      tester.view.devicePixelRatio = 2.0;

      try {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 120,
                width: 100,
                child: CategoryCard(
                  label: 'super-long-streetwear-category-name',
                  onTap: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
      } finally {
        FlutterError.onError = oldHandler;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }

      expect(errors, isEmpty, reason: 'CategoryCard should not overflow with long name');
    });

    testWidgets('PremiumDialogWidget with long action text on 320px does not overflow', (tester) async {
      final List<String> errors = [];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        final msg = details.toString();
        if (msg.contains('overflowed') || msg.contains('RenderFlex')) {
          errors.add(msg);
        }
      };

      tester.view.physicalSize = const Size(320 * 2, 640 * 2);
      tester.view.devicePixelRatio = 2.0;

      try {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: MediaQuery(
                data: MediaQueryData(size: Size(320, 640)),
                child: PremiumDialogWidget(
                  title: 'Confirm Order Cancellation',
                  message: 'Are you sure you want to cancel order #DRIP-984210? This action cannot be reversed.',
                  type: PremiumAlertType.confirmation,
                  primaryActionText: 'Yes, Cancel Order',
                  secondaryActionText: 'Keep My Order',
                  isDestructive: true,
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
      } finally {
        FlutterError.onError = oldHandler;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }

      expect(errors, isEmpty, reason: 'PremiumDialogWidget actions should not overflow on 320px');
    });

    testWidgets('ProfileQuickActionCard on 320px renders cleanly', (tester) async {
      final List<String> errors = [];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        final msg = details.toString();
        if (msg.contains('overflowed') || msg.contains('RenderFlex')) {
          errors.add(msg);
        }
      };

      tester.view.physicalSize = const Size(320 * 2, 640 * 2);
      tester.view.devicePixelRatio = 2.0;

      try {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Row(
                children: [
                  ProfileQuickActionCard(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Orders and Shipments',
                    subtitle: 'Track your deliveries',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
      } finally {
        FlutterError.onError = oldHandler;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }

      expect(errors, isEmpty, reason: 'ProfileQuickActionCard should not overflow');
    });
  });
}
