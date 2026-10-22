import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dripzoid_v2/core/network/token_storage.dart';
import 'package:dripzoid_v2/features/auth/presentation/screens/about_screen.dart';
import 'package:dripzoid_v2/features/splash/presentation/screens/splash_screen.dart';
import 'package:dripzoid_v2/shared/widgets/product_attribution.dart';

class TestTokenStorage implements TokenStorage {
  @override
  Future<void> saveToken(String token) async {}

  @override
  Future<String?> getToken() async => null;

  @override
  Future<void> clearToken() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProductAttribution Widget Tests', () {
    testWidgets('renders "A Product of" text and SAI Labs dark logo asset', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProductAttribution(),
          ),
        ),
      );
      await tester.pump();

      // Verify "A Product of" text
      expect(find.text('A Product of'), findsOneWidget);

      // Verify Image widget with specified asset
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinder);
      expect(imageWidget.image, isA<AssetImage>());
      final assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, equals('assets/logos/sailabs_logo-dark.png'));

      // Verify aspect ratio preservation
      expect(imageWidget.fit, equals(BoxFit.contain));
    });

    testWidgets('renders correctly in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: ProductAttribution(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('A Product of'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('renders correctly in light mode with contrast container', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: ProductAttribution(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('A Product of'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('AboutScreen Attribution Placement Tests', () {
    testWidgets('AboutScreen includes ProductAttribution', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ProductAttribution), findsOneWidget);
      expect(find.text('A Product of'), findsOneWidget);
      expect(find.text('About Dripzoid'), findsOneWidget);
      expect(find.text('Dripzoid'), findsOneWidget);
    });
  });

  group('SplashScreen Attribution Placement Tests', () {
    testWidgets('SplashScreen displays ProductAttribution, Dripzoid logo, and branding', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(TestTokenStorage()),
          ],
          child: const MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );

      // Advance initial frame and animation
      await tester.pump(const Duration(milliseconds: 100));

      // Verify Dripzoid branding remains intact
      expect(find.text('DRIPZOID'), findsOneWidget);
      expect(find.text('Wear The Confidence'), findsOneWidget);
      expect(find.text('Initializing...'), findsOneWidget);

      // Verify SAI Labs ProductAttribution is present
      expect(find.byType(ProductAttribution), findsOneWidget);
      expect(find.text('A Product of'), findsOneWidget);

      // Verify the image inside ProductAttribution
      final imageFinder = find.descendant(
        of: find.byType(ProductAttribution),
        matching: find.byType(Image),
      );
      expect(imageFinder, findsOneWidget);
      final imageWidget = tester.widget<Image>(imageFinder);
      expect((imageWidget.image as AssetImage).assetName, equals('assets/logos/sailabs_logo-dark.png'));

      // Advance beyond the 1200ms AppInitializer timer without pumpAndSettle (since AppLoader repeats indefinitely)
      await tester.pump(const Duration(milliseconds: 1500));
    });

    testWidgets('SplashScreen renders cleanly on small screen without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568); // iPhone SE size
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(TestTokenStorage()),
          ],
          child: const MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ProductAttribution), findsOneWidget);
      expect(find.text('DRIPZOID'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pump(const Duration(milliseconds: 1500));
    });
  });
}
