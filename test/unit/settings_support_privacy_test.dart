import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dripzoid_v2/features/auth/presentation/screens/profile_screen.dart';
import 'package:dripzoid_v2/features/auth/presentation/screens/privacy_policy_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createSubject() {
    return const ProviderScope(
      child: MaterialApp(
        home: ProfileScreen(),
      ),
    );
  }

  group('Settings Screen Support & Privacy Centralization Tests', () {
    testWidgets('renders Support & Privacy section with Help & Support and Privacy Policy', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Verify Section Header
      expect(find.text('Support & Privacy'), findsOneWidget);

      // Verify Help & Support menu item
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.byIcon(Icons.help_outline), findsOneWidget);

      // Verify Privacy Policy menu item
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.byIcon(Icons.privacy_tip_outlined), findsOneWidget);

      // Verify Terms & Conditions dead button is removed
      expect(find.text('Terms & Conditions'), findsNothing);
    });

    testWidgets('tapping Help & Support opens bottom sheet with direct contact, copyable address, and FAQs', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final helpTile = find.text('Help & Support');
      await tester.scrollUntilVisible(helpTile, 200);
      await tester.pumpAndSettle();

      await tester.tap(helpTile);
      await tester.pumpAndSettle();

      // Verify Modal Sheet Header and Contact
      expect(find.text('Customer Care Support'), findsOneWidget);
      expect(find.text('+91 94940 38163'), findsOneWidget);
      expect(find.text('Call Support'), findsOneWidget);

      // Verify Registered Address and Copy Action
      expect(find.text('Registered Address'), findsOneWidget);
      expect(
        find.textContaining('Near Cattle Market,\nPithapuram, Andhra Pradesh'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.copy_outlined), findsOneWidget);

      // Scroll to FAQs inside the sheet using the sheet's Scrollable
      final faqFinder = find.text('Frequently Asked Questions');
      await tester.scrollUntilVisible(
        faqFinder,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();

      expect(faqFinder, findsOneWidget);
      expect(find.text('How do I track my order?'), findsOneWidget);
      expect(find.text('What payment methods do you accept?'), findsOneWidget);
      expect(find.text('How do I care for my Dripzoid garments?'), findsOneWidget);
      expect(find.text('Where do you deliver?'), findsOneWidget);
      expect(find.textContaining('We ship across India'), findsOneWidget);

      // Verify unverified claims are absent
      expect(find.text('Are your drops limited edition?'), findsNothing);
    });

    testWidgets('About Dripzoid remains accessible under App Info section', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final aboutTile = find.text('About Dripzoid');
      await tester.scrollUntilVisible(aboutTile, 200);
      await tester.pumpAndSettle();

      expect(find.text('App Info'), findsOneWidget);
      expect(aboutTile, findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('tapping Privacy Policy navigates natively to PrivacyPolicyScreen with back navigation', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final router = GoRouter(
        initialLocation: '/profile',
        routes: [
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'privacy-policy',
                builder: (context, state) => const PrivacyPolicyScreen(),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final privacyTile = find.text('Privacy Policy');
      await tester.scrollUntilVisible(privacyTile, 200);
      await tester.pumpAndSettle();

      await tester.tap(privacyTile);
      await tester.pumpAndSettle();

      // Verify native PrivacyPolicyScreen is displayed
      expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
      expect(find.text('DRIPZOID PRIVACY POLICY'), findsOneWidget);
      expect(find.text('Last updated: 22 October 2026'), findsOneWidget);

      // Test back navigation
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(PrivacyPolicyScreen), findsNothing);
      expect(find.byType(ProfileScreen), findsOneWidget);
    });
  });
}
