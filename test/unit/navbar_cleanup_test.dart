import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dripzoid_v2/shared/widgets/app_header.dart';
import 'package:dripzoid_v2/shared/widgets/app_logo.dart';
import 'package:dripzoid_v2/features/products/presentation/screens/shop_screen.dart';
import 'package:dripzoid_v2/features/products/data/models/product_model.dart';
import 'package:dripzoid_v2/features/products/data/repositories/product_repository.dart';
import 'package:dripzoid_v2/features/products/presentation/providers/product_providers.dart';
import 'package:dripzoid_v2/core/models/result.dart';

class FakeProductRepository implements ProductRepository {
  @override
  Future<Result<List<ProductModel>>> getProducts({Map<String, dynamic>? queryParameters}) async {
    return const Success<List<ProductModel>>([]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Navbar Cleanup Tests', () {
    testWidgets('AppHeader does not display DRIPZOID text or Wear The Confidence tagline', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AppHeader(),
            ),
          ),
        ),
      );
      await tester.pump();

      // Branding text must not exist
      expect(find.text('DRIPZOID'), findsNothing);
      expect(find.text('Wear The Confidence'), findsNothing);

      // Logo and action icons must be preserved
      expect(find.byType(AppLogo), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    });
  });

  group('Product Listing Screen Tests', () {
    testWidgets('ShopScreen does not have secondary category navbar (Men / Women / Shop)', (tester) async {
      final fakeRepo = FakeProductRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: ShopScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure no secondary category navigation tabs/chips with Men / Women
      expect(find.text('Men'), findsNothing);
      expect(find.text('Women'), findsNothing);

      // Filter action icon in AppBar is present
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });
  });
}
