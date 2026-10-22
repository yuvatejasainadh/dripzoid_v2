import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dripzoid_v2/core/models/result.dart';
import 'package:dripzoid_v2/core/network/token_storage.dart';
import 'package:dripzoid_v2/core/router/app_router.dart';
import 'package:dripzoid_v2/core/theme/app_theme.dart';
import 'package:dripzoid_v2/features/auth/data/models/login_response.dart';
import 'package:dripzoid_v2/features/auth/data/models/user_model.dart';
import 'package:dripzoid_v2/features/auth/data/repositories/auth_repository.dart';
import 'package:dripzoid_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:dripzoid_v2/features/cart/data/models/cart_item_model.dart';
import 'package:dripzoid_v2/features/cart/data/repositories/cart_repository.dart';
import 'package:dripzoid_v2/features/cart/presentation/providers/cart_notifier.dart';
import 'package:dripzoid_v2/features/products/data/models/product_model.dart';
import 'package:dripzoid_v2/features/products/data/models/review_model.dart';
import 'package:dripzoid_v2/features/products/data/models/question_model.dart';
import 'package:dripzoid_v2/features/products/data/models/review_eligibility_model.dart';
import 'package:dripzoid_v2/features/products/data/repositories/product_repository.dart';
import 'package:dripzoid_v2/features/products/presentation/providers/product_providers.dart';
import 'package:dripzoid_v2/shared/widgets/category_card.dart';
import 'package:dripzoid_v2/shared/widgets/primary_button.dart';

class FakeTokenStorage implements TokenStorage {
  String? storedToken;
  FakeTokenStorage([this.storedToken]);
  @override
  Future<void> saveToken(String token) async => storedToken = token;
  @override
  Future<String?> getToken() async => storedToken;
  @override
  Future<void> clearToken() async => storedToken = null;
}

class FakeAuthRepository implements AuthRepository {
  Result<UserModel>? currentUserResult;
  @override
  Future<Result<UserModel>> getCurrentUser() async =>
      currentUserResult ?? const Failure('No user', statusCode: 401);
  @override
  Future<Result<LoginResponse>> login({required String email, required String password}) async =>
      Success(LoginResponse(
        success: true,
        message: 'Success',
        sessionId: 'token',
        user: UserModel(id: '1', email: email, name: 'User'),
      ));
  @override
  Future<Result<void>> logout() async => const Success(null);
  @override
  Future<Result<bool>> checkEmail(String email) async => const Success(true);
  @override
  Future<Result<void>> register(Map<String, dynamic> body) async => const Success(null);
  @override
  Future<Result<void>> resetPassword({required String email, required String password}) async => const Success(null);
  @override
  Future<Result<void>> sendOTP(String email) async => const Success(null);
  @override
  Future<Result<void>> verifyOTP(String email, String otp) async => const Success(null);
}

class FakeProductRepository implements ProductRepository {
  final ProductModel product;
  FakeProductRepository(this.product);

  @override
  Future<Result<ProductModel>> getProductById(String id) async => Success(product);
  @override
  Future<Result<List<ProductModel>>> getRelatedProducts(String id) async => const Success([]);
  @override
  Future<Result<List<ReviewModel>>> getProductReviews(String id) async => const Success([]);
  @override
  Future<Result<List<QuestionModel>>> getProductQuestions(String id) async => const Success([]);
  @override
  Future<Result<ReviewEligibilityModel>> verifyPurchase(String id) async =>
      Success(ReviewEligibilityModel.empty());
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCartRepository implements CartRepository {
  List<CartItemModel> items = [];

  @override
  Future<Result<List<CartItemModel>>> getCart() async => Success(List.from(items));
  @override
  Future<Result<void>> addToCart({
    required String productId,
    required int quantity,
    String? selectedSize,
    String? selectedColor,
  }) async {
    items.add(CartItemModel(
      id: 'cart_${productId}_${DateTime.now().millisecondsSinceEpoch}',
      productId: productId,
      name: 'Test Product',
      price: 999.0,
      quantity: quantity,
      selectedSize: selectedSize,
      selectedColor: selectedColor,
    ));
    return const Success<void>(null);
  }
  @override
  Future<Result<void>> updateCartItem({required String cartId, required int quantity}) async =>
      const Success<void>(null);
  @override
  Future<Result<void>> deleteCartItem(String cartId) async => const Success<void>(null);
  @override
  Future<Result<void>> clearCart() async => const Success<void>(null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testProduct = ProductModel(
    id: 'prod_123',
    name: 'Oversized Vintage Acid Wash Tee',
    slug: 'oversized-vintage-acid-wash-tee',
    price: 999.0,
    originalPrice: 1499.0,
    rating: 4.5,
    stock: 10,
    description: 'High quality cotton tee with drop shoulders and premium wash.',
    colors: ['Vintage Black'],
    sizes: ['M'],
    category: 'Men',
    subcategory: 'T-Shirts',
    images: [],
  );

  group('CategoryCard & Category Section Tests (Task 2)', () {
    testWidgets('1. CategoryCard renders Icons.man for Men and Icons.woman for Women', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Row(
              children: [
                CategoryCard(label: 'men', onTap: () {}),
                CategoryCard(label: 'women', onTap: () {}),
                CategoryCard(label: 'kids', onTap: () {}),
                CategoryCard(label: 'shoes', onTap: () {}),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      // Find icons
      expect(find.byIcon(Icons.man), findsOneWidget);
      expect(find.byIcon(Icons.woman), findsOneWidget);
      expect(find.byIcon(Icons.child_care), findsOneWidget);
      expect(find.byIcon(Icons.roller_skating_outlined), findsOneWidget);

      // Verify formatted labels
      expect(find.text('Men'), findsOneWidget);
      expect(find.text('Women'), findsOneWidget);
      expect(find.text('Kids'), findsOneWidget);
      expect(find.text('Shoes'), findsOneWidget);
    });

    testWidgets('2. CategoryCard sizing and centering conforms to 80x80 circular tile with icon size 38', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: CategoryCard(label: 'Men'),
          ),
        ),
      );
      await tester.pump();

      // Check circular container sizing
      final containerFinder = find.byWidgetPredicate(
        (w) => w is Container && w.constraints?.maxWidth == 80 && w.constraints?.maxHeight == 80,
      );
      expect(containerFinder, findsOneWidget);

      // Check icon size
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.man));
      expect(iconWidget.size, equals(38.0));
    });

    testWidgets('3. CategoryCard provides accessibility Semantics with button and label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: CategoryCard(label: 'Men', onTap: () {}),
          ),
        ),
      );
      await tester.pump();

      final semanticsFinder = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Men category' && w.properties.button == true,
      );
      expect(semanticsFinder, findsOneWidget);
    });

    testWidgets('4. CategoryCard responds to tap callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: CategoryCard(
              label: 'Women',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(CategoryCard));
      expect(tapped, isTrue);
    });

    testWidgets('5. Contrast and color theme: uses onSurface in both Light and Dark themes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Theme(
                  data: AppTheme.darkTheme,
                  child: const CategoryCard(key: ValueKey('dark_men'), label: 'Men'),
                ),
                Theme(
                  data: AppTheme.lightTheme,
                  child: const CategoryCard(key: ValueKey('light_men'), label: 'Men'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      final darkIconFinder = find.descendant(
        of: find.byKey(const ValueKey('dark_men')),
        matching: find.byType(Icon),
      );
      final lightIconFinder = find.descendant(
        of: find.byKey(const ValueKey('light_men')),
        matching: find.byType(Icon),
      );

      final darkIcon = tester.widget<Icon>(darkIconFinder);
      expect(darkIcon.color, equals(AppTheme.darkTheme.colorScheme.onSurface));

      final lightIcon = tester.widget<Icon>(lightIconFinder);
      expect(lightIcon.color, equals(AppTheme.lightTheme.colorScheme.onSurface));
    });
  });

  group('Cart Navigation Crash Fix Tests (Task 1)', () {
    void configureTestViewport(WidgetTester tester) {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) return;
        originalOnError?.call(details);
      };
      addTearDown(() {
        FlutterError.onError = originalOnError;
      });

      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets('1. Product Details navigates to Cart via go(/cart) without keyReservation assertion', (tester) async {
      configureTestViewport(tester);

      final fakeStorage = FakeTokenStorage('auth_token');
      final fakeAuth = FakeAuthRepository();
      fakeAuth.currentUserResult = Success(UserModel(id: '1', email: 'test@example.com', name: 'User'));
      final fakeProductRepo = FakeProductRepository(testProduct);
      final fakeCartRepo = FakeCartRepository();

      // Seed cart item so isInCart is true
      fakeCartRepo.items.add(CartItemModel(
        id: 'cart_1',
        productId: 'prod_123',
        name: testProduct.name,
        price: testProduct.price,
        quantity: 1,
        selectedSize: 'M',
        selectedColor: 'Vintage Black',
      ));

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(fakeStorage),
          authRepositoryProvider.overrideWithValue(fakeAuth),
          productRepositoryProvider.overrideWithValue(fakeProductRepo),
          cartRepositoryProvider.overrideWithValue(fakeCartRepo),
        ],
      );
      addTearDown(container.dispose);

      // Authenticate via checkSession
      await container.read(authProvider.notifier).checkSession();
      await container.read(cartProvider.notifier).fetchCart();

      final router = container.read(appRouterProvider);

      dynamic uncaughtAssertion;
      final prevHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('keyReservation') ||
            details.exceptionAsString().contains('Navigator')) {
          uncaughtAssertion = details;
        }
      };
      addTearDown(() {
        FlutterError.onError = prevHandler;
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.darkTheme,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to product details
      router.go('/product/prod_123');
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, equals('/product/prod_123'));

      // Find "Go to Cart" button in ProductPurchaseBar
      final goToCartFinder = find.widgetWithText(PrimaryButton, 'Go to Cart');
      expect(goToCartFinder, findsOneWidget);

      // Tap Go to Cart
      await tester.tap(goToCartFinder);
      await tester.pumpAndSettle();

      // Verify NO keyReservation assertion was thrown!
      expect(uncaughtAssertion, isNull);

      // Verify navigated to Cart
      expect(router.routeInformationProvider.value.uri.path, equals('/cart'));

      // Verify cart content is rendered
      expect(find.text(testProduct.name), findsOneWidget);
    });

    testWidgets('2. Repeated rapid taps on Go to Cart do not crash or throw duplicate navigation errors', (tester) async {
      configureTestViewport(tester);

      final fakeStorage = FakeTokenStorage('auth_token');
      final fakeAuth = FakeAuthRepository();
      fakeAuth.currentUserResult = Success(UserModel(id: '1', email: 'test@example.com', name: 'User'));
      final fakeProductRepo = FakeProductRepository(testProduct);
      final fakeCartRepo = FakeCartRepository();

      fakeCartRepo.items.add(CartItemModel(
        id: 'cart_1',
        productId: 'prod_123',
        name: testProduct.name,
        price: testProduct.price,
        quantity: 1,
        selectedSize: 'M',
        selectedColor: 'Vintage Black',
      ));

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(fakeStorage),
          authRepositoryProvider.overrideWithValue(fakeAuth),
          productRepositoryProvider.overrideWithValue(fakeProductRepo),
          cartRepositoryProvider.overrideWithValue(fakeCartRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authProvider.notifier).checkSession();
      await container.read(cartProvider.notifier).fetchCart();

      final router = container.read(appRouterProvider);

      dynamic caughtException;
      final prevHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        caughtException = details;
      };
      addTearDown(() {
        FlutterError.onError = prevHandler;
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.darkTheme,
          ),
        ),
      );
      await tester.pumpAndSettle();

      router.go('/product/prod_123');
      await tester.pumpAndSettle();

      final goToCartFinder = find.widgetWithText(PrimaryButton, 'Go to Cart');
      expect(goToCartFinder, findsOneWidget);

      // Rapid successive taps
      await tester.tap(goToCartFinder);
      await tester.tap(goToCartFinder);
      await tester.tap(goToCartFinder);
      await tester.pumpAndSettle();

      expect(caughtException, isNull);
      expect(router.routeInformationProvider.value.uri.path, equals('/cart'));
    });
  });
}
