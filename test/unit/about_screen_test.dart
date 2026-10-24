import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dripzoid_v2/features/auth/presentation/screens/about_screen.dart';
import 'package:dripzoid_v2/shared/widgets/app_logo.dart';
import 'package:dripzoid_v2/shared/widgets/product_attribution.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createSubject({ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? ThemeData.light(),
      home: const AboutScreen(),
    );
  }

  group('AboutScreen Confirmed Brand Identity & Content Tests', () {
    testWidgets('renders Hero section with AppLogo, DRIPZOID, tagline, and verified description', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.byType(AppLogo), findsOneWidget);
      expect(find.text('DRIPZOID'), findsOneWidget);
      expect(find.text('Wear The Confidence'), findsOneWidget);
      expect(
        find.textContaining('Minimal, premium clothing designed to help you express your individuality with confidence'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Thoughtfully designed for everyday style, with premium fabrics and a focus on fit and feel'),
        findsOneWidget,
      );
      expect(find.text('Shop Now'), findsOneWidget);
      expect(find.text('Explore Collections'), findsOneWidget);
    });

    testWidgets('renders confirmed Brand Pillars (FOUNDED: 2025, SHIPPING: Across India, QUALITY: Premium Fabrics)', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Founded 2025
      expect(find.text('FOUNDED'), findsOneWidget);
      expect(find.text('2025'), findsOneWidget);
      expect(find.text('Established in India'), findsOneWidget);
      expect(find.text('2020'), findsNothing);

      // Shipping Across India (Never worldwide)
      expect(find.text('SHIPPING'), findsOneWidget);
      expect(find.text('Across India'), findsOneWidget);
      expect(find.text('Fast delivery nationwide'), findsOneWidget);
      expect(find.textContaining('worldwide'), findsNothing);
      expect(find.textContaining('Worldwide'), findsNothing);

      // Quality Premium Fabrics
      expect(find.text('QUALITY'), findsOneWidget);
      expect(find.text('Premium Fabrics'), findsOneWidget);
      expect(find.text('Focus on fit and feel'), findsOneWidget);
    });

    testWidgets('unverified community and creator claims are completely absent', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('COMMUNITY'), findsNothing);
      expect(find.text('Design Collabs'), findsNothing);
      expect(find.text('Creators & drop culture'), findsNothing);
    });

    testWidgets('renders dynamic app version and legal footer', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('© 2026 Dripzoid. All rights reserved.'), findsOneWidget);
      expect(find.textContaining('Version'), findsOneWidget);
    });

    testWidgets('renders ProductAttribution without long organization subtitle', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final attributionFinder = find.byType(ProductAttribution);
      expect(attributionFinder, findsOneWidget);
      expect(find.text('A Product of'), findsOneWidget);
      expect(
        find.text('SAI Labs — Sainadh Advanced Intelligence Labs'),
        findsNothing,
      );
    });
  });

  group('AboutScreen Deduplication Verification', () {
    testWidgets('Privacy Policy and phone details are not duplicated in About screen', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Privacy Policy must no longer exist in AboutScreen
      expect(find.text('Privacy Policy'), findsNothing);
      expect(
        find.text('https://dripzoid-frontend.onrender.com/privacy-policy'),
        findsNothing,
      );

      // Support contact details must not exist in AboutScreen
      expect(find.text('+91 94940 38163'), findsNothing);
      expect(find.text('Help & Support'), findsNothing);
      expect(find.text('Help & FAQ'), findsNothing);
      expect(find.text('Contact Details'), findsNothing);
      expect(find.text('Terms & Conditions'), findsNothing);
    });
  });

  group('AboutScreen Theme Adaptability & Layout Safety', () {
    testWidgets('renders cleanly in Light Theme without overflow', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createSubject(theme: ThemeData.light()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders cleanly in Dark Theme without overflow', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createSubject(theme: ThemeData.dark()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders cleanly on 320x568 compact screen without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('DRIPZOID'), findsOneWidget);
      expect(find.text('Wear The Confidence'), findsOneWidget);
      expect(find.text('Across India'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
