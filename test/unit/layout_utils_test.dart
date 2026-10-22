import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dripzoid_v2/core/utils/layout_utils.dart';

void main() {
  group('LayoutUtils & Responsive Layout Tests', () {
    testWidgets('Detects mobile viewport (<600px)', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(LayoutUtils.isMobile(context), isTrue);
              expect(LayoutUtils.isTablet(context), isFalse);
              expect(LayoutUtils.isDesktop(context), isFalse);
              expect(LayoutUtils.getGridColumnCount(context), equals(2));
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('Detects tablet viewport (600px - 899px)', (tester) async {
      tester.view.physicalSize = const Size(768 * 2, 1024 * 2);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(LayoutUtils.isMobile(context), isFalse);
              expect(LayoutUtils.isTablet(context), isTrue);
              expect(LayoutUtils.isDesktop(context), isFalse);
              expect(LayoutUtils.getGridColumnCount(context), equals(3));
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('Detects desktop viewport (>=900px)', (tester) async {
      tester.view.physicalSize = const Size(1280 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(LayoutUtils.isMobile(context), isFalse);
              expect(LayoutUtils.isTablet(context), isFalse);
              expect(LayoutUtils.isDesktop(context), isTrue);
              expect(LayoutUtils.getGridColumnCount(context), equals(5));
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });
}
