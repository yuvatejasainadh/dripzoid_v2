import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dripzoid_v2/features/navigation/presentation/providers/header_notifier.dart';
import 'package:dripzoid_v2/shared/widgets/app_header.dart';
import 'package:dripzoid_v2/shared/widgets/header_search_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildSubject({
    double width = 360,
    double height = 640,
    double textScale = 1.0,
    EdgeInsets viewInsets = EdgeInsets.zero,
  }) {
    return ProviderScope(
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, height),
            textScaler: TextScaler.linear(textScale),
            viewInsets: viewInsets,
          ),
          child: Consumer(
            builder: (context, ref, child) {
              final headerState = ref.watch(headerProvider);
              return Scaffold(
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(headerState.isSearchVisible ? 134 : 64),
                  child: const AppHeader(),
                ),
                body: const Center(child: Text('Content')),
              );
            },
          ),
        ),
      ),
    );
  }

  void configureViewport(
    WidgetTester tester, {
    double width = 360,
    double height = 640,
  }) {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetViewInsets();
    });
  }

  group('Search Bar Transition Overflow Regression Suite', () {
    testWidgets('1. Opening search bar: transitions smoothly without RenderFlex overflow', (tester) async {
      configureViewport(tester, width: 375, height: 812);
      await tester.pumpWidget(buildSubject(width: 375, height: 812));
      await tester.pumpAndSettle();

      final searchButton = find.byTooltip('Search');
      expect(searchButton, findsOneWidget);

      await tester.tap(searchButton);

      // Verify each intermediate frame during the 300ms expansion animation
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 30));
        expect(tester.takeException(), isNull);
      }

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(HeaderSearchBar), findsOneWidget);
    });

    testWidgets('2. Closing search bar: collapses cleanly without bottom RenderFlex overflow', (tester) async {
      configureViewport(tester, width: 375, height: 812);
      await tester.pumpWidget(buildSubject(width: 375, height: 812));
      await tester.pumpAndSettle();

      // Open search bar first
      final searchButton = find.byTooltip('Search');
      await tester.tap(searchButton);
      await tester.pumpAndSettle();
      expect(find.byType(HeaderSearchBar), findsOneWidget);

      // Tap to close
      await tester.tap(searchButton);

      // Verify each intermediate frame during the 300ms collapsing animation
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 30));
        expect(tester.takeException(), isNull);
      }

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(HeaderSearchBar), findsNothing);
    });

    testWidgets('3. Rapid open/close toggles do not crash, leak exceptions, or cause layout locks', (tester) async {
      configureViewport(tester, width: 375, height: 812);
      await tester.pumpWidget(buildSubject(width: 375, height: 812));
      await tester.pumpAndSettle();

      final searchButton = find.byTooltip('Search');

      for (int cycle = 0; cycle < 6; cycle++) {
        await tester.tap(searchButton);
        await tester.pump(const Duration(milliseconds: 40));
        expect(tester.takeException(), isNull);

        await tester.tap(searchButton);
        await tester.pump(const Duration(milliseconds: 40));
        expect(tester.takeException(), isNull);
      }

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('4. Compact 320px viewport: handles input, clear, and submit without overflow', (tester) async {
      configureViewport(tester, width: 320, height: 568);
      await tester.pumpWidget(buildSubject(width: 320, height: 568));
      await tester.pumpAndSettle();

      // Open
      await tester.tap(find.byTooltip('Search'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 30));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();

      // Type
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, 'oversized tees');
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Submit
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Clear via inner suffix button
      final clearIcon = find.descendant(of: textField, matching: find.byIcon(Icons.close_rounded));
      expect(clearIcon, findsOneWidget);
      await tester.tap(clearIcon);
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Close
      await tester.tap(find.byTooltip('Search'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 30));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('5. Standard phone viewport (390x844) transitions without layout shifts or exceptions', (tester) async {
      configureViewport(tester, width: 390, height: 844);
      await tester.pumpWidget(buildSubject(width: 390, height: 844));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Search'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 30));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Search'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 30));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('6. Wide/tablet viewport (900x1200) maintains clean constraints and alignment', (tester) async {
      configureViewport(tester, width: 900, height: 1200);
      await tester.pumpWidget(buildSubject(width: 900, height: 1200));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final searchBar = find.byType(HeaderSearchBar);
      expect(searchBar, findsOneWidget);

      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('7. High text scaling (1.5x) does not cause vertical or horizontal RenderFlex overflow', (tester) async {
      configureViewport(tester, width: 360, height: 640);
      await tester.pumpWidget(buildSubject(width: 360, height: 640, textScale: 1.5));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Search'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 30));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('Search'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 30));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('8. Keyboard visibility (viewInsets 300) does not cause header layout overflow', (tester) async {
      configureViewport(tester, width: 375, height: 812);
      await tester.pumpWidget(buildSubject(
        width: 375,
        height: 812,
        viewInsets: const EdgeInsets.only(bottom: 300),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Search'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 30));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('Search'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 30));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
