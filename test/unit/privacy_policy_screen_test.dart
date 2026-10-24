import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dripzoid_v2/core/theme/app_theme.dart';
import 'package:dripzoid_v2/features/auth/presentation/screens/privacy_policy_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Widget createSubject({ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? AppTheme.lightTheme,
      home: const PrivacyPolicyScreen(),
    );
  }

  void configureViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Finder findTextSpanContaining(String pattern) {
    return find.byWidgetPredicate((widget) {
      if (widget is RichText) {
        return widget.text.toPlainText().contains(pattern);
      }
      return false;
    });
  }

  group('PrivacyPolicyScreen Header & Brand Structure Tests', () {
    testWidgets('renders AppBar with Privacy Policy title and centered alignment', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final appBarFinder = find.byType(AppBar);
      expect(appBarFinder, findsOneWidget);
      expect(find.descendant(of: appBarFinder, matching: find.text('Privacy Policy')), findsOneWidget);

      final appBarWidget = tester.widget<AppBar>(appBarFinder);
      expect(appBarWidget.centerTitle, isTrue);
    });

    testWidgets('renders Hero Header with brand title, update date, and intro summary', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('DRIPZOID PRIVACY POLICY'), findsOneWidget);
      expect(find.text('Last updated: 22 October 2026'), findsOneWidget);
      expect(find.byIcon(Icons.privacy_tip_outlined), findsWidgets);
      expect(
        find.textContaining('We value your trust and are committed to safeguarding your personal data'),
        findsOneWidget,
      );
    });

    testWidgets('renders Official Web Reference card and triggers copy feedback on tap', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Official Web Reference'), findsOneWidget);
      expect(find.text(PrivacyPolicyScreen.webPolicyUrl), findsOneWidget);

      final copyButton = find.widgetWithIcon(IconButton, Icons.copy_outlined).first;
      expect(copyButton, findsOneWidget);

      await tester.tap(copyButton);
      await tester.pump();

      expect(find.text('Privacy Policy URL copied to clipboard'), findsOneWidget);
    });
  });

  group('PrivacyPolicyScreen Section Content & Regulatory Verification', () {
    testWidgets('renders Section 1: Introduction, India-only operations, and DPDP Act compliance', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final s1Finder = find.text('1. Introduction & Operational Scope');
      await tester.scrollUntilVisible(s1Finder, 200);
      await tester.pumpAndSettle();

      expect(s1Finder, findsOneWidget);
      expect(find.textContaining('Indian streetwear apparel brand based in Andhra Pradesh'), findsOneWidget);
      expect(find.textContaining('Digital Personal Data Protection Act, 2023 (DPDP Act)'), findsOneWidget);
      expect(find.textContaining('serves customers exclusively across India'), findsOneWidget);
    });

    testWidgets('renders Section 2: Information We Collect with PCI-DSS disclosure', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final s2Finder = find.text('2. Information We Collect');
      await tester.scrollUntilVisible(s2Finder, 200);
      await tester.pumpAndSettle();

      expect(s2Finder, findsOneWidget);
      expect(find.text('A. Personal Information You Provide:'), findsOneWidget);
      expect(find.text('B. Payment Information (Secure Gateway):'), findsOneWidget);
      expect(find.text('C. Technical & Diagnostic Information:'), findsOneWidget);

      // Verify PCI-DSS payment disclosure
      expect(
        find.textContaining('Dripzoid does not collect, receive, or store full credit/debit card numbers, CVVs, or UPI PINs'),
        findsOneWidget,
      );
    });

    testWidgets('renders Section 3: Operational uses of information', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final s3Finder = find.text('3. How We Use Your Information');
      await tester.scrollUntilVisible(s3Finder, 200);
      await tester.pumpAndSettle();

      expect(s3Finder, findsOneWidget);
      expect(findTextSpanContaining('Order Processing & Delivery:'), findsOneWidget);
      expect(findTextSpanContaining('Security & Fraud Prevention:'), findsOneWidget);
    });

    testWidgets('renders Section 4: Legal Basis under DPDP Act', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final s4Finder = find.text('4. Legal Basis for Processing');
      await tester.scrollUntilVisible(s4Finder, 200);
      await tester.pumpAndSettle();

      expect(s4Finder, findsOneWidget);
      expect(findTextSpanContaining('Performance of Contract:'), findsOneWidget);
      expect(findTextSpanContaining('Statutory Compliance:'), findsOneWidget);
    });

    testWidgets('renders Section 5: Strict non-commercialization disclosure', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final s5Finder = find.text('5. Third-Party Sharing & Disclosure');
      await tester.scrollUntilVisible(s5Finder, 200);
      await tester.pumpAndSettle();

      expect(s5Finder, findsOneWidget);
      expect(
        find.textContaining('Dripzoid never sells, rents, or trades your personal data to any third party'),
        findsOneWidget,
      );
    });

    testWidgets('renders Section 6: Explicitly distinguishes native mobile app from web cookies', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final s6Finder = find.text('6. Cookies & Tracking Technologies');
      await tester.scrollUntilVisible(s6Finder, 200);
      await tester.pumpAndSettle();

      expect(s6Finder, findsOneWidget);
      expect(find.text('Native Mobile Application:'), findsOneWidget);
      expect(
        find.textContaining('The Dripzoid Flutter mobile app does NOT use browser cookies'),
        findsOneWidget,
      );
      expect(
        find.textContaining('SharedPreferences / secure storage'),
        findsOneWidget,
      );
      expect(find.text('Web Storefront:'), findsOneWidget);
    });

    testWidgets('renders Section 7 & 8: Data retention and TLS encryption safeguards', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final s7Finder = find.text('7. Data Retention & Storage');
      await tester.scrollUntilVisible(s7Finder, 200);
      await tester.pumpAndSettle();
      expect(s7Finder, findsOneWidget);
      expect(findTextSpanContaining('typically 5 to 7 years'), findsOneWidget);

      final s8Finder = find.text('8. Security Safeguards');
      await tester.scrollUntilVisible(s8Finder, 200);
      await tester.pumpAndSettle();
      expect(s8Finder, findsOneWidget);
      expect(findTextSpanContaining('Transport Layer Security (TLS 1.2 / TLS 1.3)'), findsOneWidget);
      expect(findTextSpanContaining('Standard Security Qualification:'), findsOneWidget);
    });

    testWidgets('renders Section 9 to 12: User rights, 16y children privacy, transfers, updates', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final s9Finder = find.text('9. Your Rights & Choices');
      await tester.scrollUntilVisible(s9Finder, 200);
      await tester.pumpAndSettle();
      expect(s9Finder, findsOneWidget);
      expect(findTextSpanContaining('Right to Access:'), findsOneWidget);
      expect(findTextSpanContaining('Right to Erasure / Deletion:'), findsOneWidget);

      final s10Finder = find.text("10. Children's Privacy");
      await tester.scrollUntilVisible(s10Finder, 200);
      await tester.pumpAndSettle();
      expect(s10Finder, findsOneWidget);
      expect(find.textContaining('at least 16 years of age'), findsOneWidget);

      final s11Finder = find.text('11. International Data Transfers');
      await tester.scrollUntilVisible(s11Finder, 200);
      await tester.pumpAndSettle();
      expect(s11Finder, findsOneWidget);

      final s12Finder = find.text('12. Policy Updates & Notifications');
      await tester.scrollUntilVisible(s12Finder, 200);
      await tester.pumpAndSettle();
      expect(s12Finder, findsOneWidget);
    });
  });

  group('PrivacyPolicyScreen Contact Details & Closing Commitment Tests', () {
    testWidgets('renders Section 13 with entity name, copyable address, phone, and confirmed contact email', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final s13Finder = find.text('13. Contact & Grievance Redressal');
      await tester.scrollUntilVisible(s13Finder, 200);
      await tester.pumpAndSettle();

      expect(s13Finder, findsOneWidget);
      expect(find.text('Dripzoid'), findsOneWidget);
      expect(
        find.text('Near Cattle Market, Pithapuram, Andhra Pradesh, India – 533450'),
        findsOneWidget,
      );
      expect(find.text('+91 94940 38163'), findsOneWidget);
      expect(find.text('Contact Email'), findsOneWidget);
      expect(find.text('dripzoidapp@gmail.com'), findsOneWidget);
      expect(find.textContaining('within 30 days'), findsOneWidget);

      // Verify unverified old emails are completely absent
      expect(find.text('privacy@dripzoid.com'), findsNothing);
      expect(find.text('support@dripzoid.com'), findsNothing);

      // Verify Copy Address action
      final copyAddressButton = find.widgetWithIcon(IconButton, Icons.copy_outlined).last;
      await tester.tap(copyAddressButton);
      await tester.pump();

      expect(find.text('Address copied to clipboard'), findsOneWidget);

      // Verify Contact Email action button exists and is tappable
      final emailButton = find.widgetWithIcon(IconButton, Icons.email_outlined);
      expect(emailButton, findsOneWidget);
      await tester.tap(emailButton);
      await tester.pump();
    });

    testWidgets('renders Section 14 Closing Banner with Wear The Confidence', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final closingFinder = find.text('WEAR THE CONFIDENCE');
      await tester.scrollUntilVisible(closingFinder, 200);
      await tester.pumpAndSettle();

      expect(closingFinder, findsOneWidget);
      expect(
        find.textContaining('We protect your privacy as passionately as we craft our streetwear'),
        findsOneWidget,
      );
    });

    testWidgets('renders cleanly in dark theme without rendering errors', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject(theme: AppTheme.darkTheme));
      await tester.pumpAndSettle();

      expect(find.text('DRIPZOID PRIVACY POLICY'), findsOneWidget);
      expect(find.text('1. Introduction & Operational Scope'), findsOneWidget);
    });
  });
}
