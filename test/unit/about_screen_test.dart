import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dripzoid_v2/features/auth/presentation/screens/about_screen.dart';
import 'package:dripzoid_v2/shared/widgets/product_attribution.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createSubject({ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? ThemeData.light(),
      home: const AboutScreen(),
    );
  }

  group('AboutScreen Content & Structure Tests', () {
    testWidgets('renders Hero section with branding and actions', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Dripzoid — Wear the Confidence'), findsOneWidget);
      expect(
        find.textContaining('Bold streetwear with a luxury touch'),
        findsOneWidget,
      );
      expect(find.text('Shop Now'), findsOneWidget);
      expect(find.text('Explore Collections'), findsOneWidget);
    });

    testWidgets('renders Brand Highlights cards', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('FOUNDED'), findsOneWidget);
      expect(find.text('2020'), findsOneWidget);
      expect(find.text('PIECES'), findsOneWidget);
      expect(find.text('Premium Fabrics'), findsOneWidget);
      expect(find.text('COMMUNITY'), findsOneWidget);
      expect(find.text('Design Collabs'), findsOneWidget);
    });

    testWidgets('renders Our Story narrative', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Our Story'), findsOneWidget);
      expect(
        find.textContaining('Dripzoid began as a small creative collective'),
        findsOneWidget,
      );
    });

    testWidgets('renders Mission and Vision cards', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Mission'), findsOneWidget);
      expect(find.text('Vision'), findsOneWidget);
      expect(
        find.textContaining('To craft accessible street-luxury that empowers people'),
        findsOneWidget,
      );
    });

    testWidgets('renders Our Values with all four core pillars', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Our Values'), findsOneWidget);
      expect(find.text('Design-First'), findsOneWidget);
      expect(find.text('Quality'), findsOneWidget);
      expect(find.text('Community'), findsOneWidget);
      expect(find.text('Sustainability'), findsWidgets);
    });

    testWidgets('renders Quality & Craftsmanship section and points', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final craftsmanshipFinder = find.text('Quality & Craftsmanship');
      await tester.scrollUntilVisible(craftsmanshipFinder, 200);
      await tester.pumpAndSettle();

      expect(craftsmanshipFinder, findsOneWidget);
      expect(find.text('Premium, pre-shrunk fabrics for consistent fit.'), findsOneWidget);
      expect(find.text('Reinforced seams at stress points.'), findsOneWidget);
      expect(find.text('Blended materials where performance matters.'), findsOneWidget);
    });

    testWidgets('renders Sustainability section and cards', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final sustFinder = find.text('Recycled & organic materials');
      await tester.scrollUntilVisible(sustFinder, 200);
      await tester.pumpAndSettle();

      expect(sustFinder, findsOneWidget);
      expect(find.text('Minimal packaging'), findsOneWidget);
    });

    testWidgets('renders Community & Collaborations section', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final commFinder = find.text('Community & Collaborations');
      await tester.scrollUntilVisible(commFinder, 200);
      await tester.pumpAndSettle();

      expect(commFinder, findsOneWidget);
      expect(find.text('Join the List'), findsOneWidget);
      expect(find.text('See Collabs'), findsOneWidget);
    });

    testWidgets('renders Sizing, Shipping and Careers sections', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final sizingFinder = find.text('Sizing & Fit');
      await tester.scrollUntilVisible(sizingFinder, 200);
      await tester.pumpAndSettle();

      expect(sizingFinder, findsOneWidget);
      expect(find.text('View Size Guide'), findsOneWidget);
      expect(find.text('Shipping & Returns'), findsOneWidget);
      expect(find.text('Shipping Policy'), findsOneWidget);
      expect(find.text('Careers & Wholesale'), findsOneWidget);
      expect(find.text('Work With Us'), findsOneWidget);
    });
  });

  group('Contact Details & Privacy Policy Verification (Phase 2)', () {
    testWidgets('renders exact contact details: name, address, phone, and privacy URL', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final contactFinder = find.text('Contact Details');
      await tester.scrollUntilVisible(contactFinder, 200);
      await tester.pumpAndSettle();

      expect(contactFinder, findsOneWidget);
      expect(find.text('Business Name'), findsOneWidget);
      expect(find.text('Dripzoid'), findsWidgets);

      // Verify exact address lines
      expect(find.text('Registered Address'), findsOneWidget);
      expect(
        find.text('Near Cattle Market,\nPithapuram, Andhra Pradesh\nIndia – 533450'),
        findsOneWidget,
      );

      // Verify exact phone number
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('+91 94940 38163'), findsOneWidget);

      // Verify exact Privacy Policy URL
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(
        find.text('https://dripzoid-frontend.onrender.com/privacy-policy'),
        findsOneWidget,
      );
    });

    testWidgets('removes standalone Terms & Conditions menu item from About section', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Ensure no standalone Terms & Conditions list tile exists in AboutScreen
      expect(find.widgetWithText(ListTile, 'Terms & Conditions'), findsNothing);
      expect(find.text('Terms & Conditions'), findsNothing);
    });
  });

  group('SAI Labs Attribution & Footer Verification (Phase 4)', () {
    testWidgets('renders ProductAttribution and copyright footer', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final attributionFinder = find.byType(ProductAttribution);
      await tester.scrollUntilVisible(attributionFinder, 200);
      await tester.pumpAndSettle();

      expect(attributionFinder, findsOneWidget);
      expect(find.text('A Product of'), findsOneWidget);
      expect(
        find.text('SAI Labs — Sainadh Advanced Intelligence Labs'),
        findsOneWidget,
      );
      expect(find.text('© 2026 Dripzoid. All rights reserved.'), findsOneWidget);
      expect(find.textContaining('Version'), findsOneWidget);
    });
  });

  group('Modals & Interactions', () {
    testWidgets('tapping View Size Guide opens size modal', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final sizeGuideBtn = find.text('View Size Guide');
      await tester.scrollUntilVisible(sizeGuideBtn, 200);
      await tester.pumpAndSettle();

      await tester.tap(sizeGuideBtn);
      await tester.pumpAndSettle();

      expect(find.text('Dripzoid Size Guide'), findsOneWidget);
      expect(find.text('Chest'), findsOneWidget);
      expect(find.text('Length'), findsOneWidget);
      expect(find.text('Shoulder'), findsOneWidget);
    });

    testWidgets('tapping Shipping Policy opens shipping modal', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final shippingBtn = find.text('Shipping Policy');
      await tester.scrollUntilVisible(shippingBtn, 200);
      await tester.pumpAndSettle();

      await tester.tap(shippingBtn);
      await tester.pumpAndSettle();

      expect(find.text('Shipping & Returns Policy'), findsOneWidget);
      expect(find.text('Standard Shipping'), findsOneWidget);
      expect(find.text('14-Day Easy Returns'), findsOneWidget);
    });

    testWidgets('tapping Help & FAQ opens FAQ modal', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final faqTile = find.text('Help & FAQ');
      await tester.scrollUntilVisible(faqTile, 200);
      await tester.pumpAndSettle();

      await tester.tap(faqTile);
      await tester.pumpAndSettle();

      expect(find.text('Frequently Asked Questions'), findsOneWidget);
      expect(find.text('How do I track my order?'), findsOneWidget);
      expect(find.text('What payment methods do you accept?'), findsOneWidget);
    });
  });

  group('Theme Adaptability & Layout Safety', () {
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
  });
}
