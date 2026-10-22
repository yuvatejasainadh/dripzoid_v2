import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dripzoid_v2/core/network/token_storage.dart';
import 'package:dripzoid_v2/features/splash/presentation/screens/splash_screen.dart';
import 'package:dripzoid_v2/shared/widgets/product_card.dart';
import 'package:dripzoid_v2/shared/widgets/product_attribution.dart';
import 'package:dripzoid_v2/features/products/data/models/product_model.dart';
import 'package:dripzoid_v2/features/cart/data/models/cart_item_model.dart';
import 'package:dripzoid_v2/features/cart/presentation/widgets/cart_item_tile.dart';
import 'package:dripzoid_v2/features/orders/presentation/widgets/order_summary_widget.dart';
import 'package:dripzoid_v2/features/orders/presentation/widgets/tracking_timeline_widget.dart';
import 'package:dripzoid_v2/features/orders/presentation/widgets/order_item_tile.dart';
import 'package:dripzoid_v2/features/orders/presentation/widgets/order_history_card.dart';
import 'package:dripzoid_v2/features/orders/data/models/shipment_model.dart';
import 'package:dripzoid_v2/features/orders/data/models/order_model.dart';
import 'package:dripzoid_v2/shared/widgets/primary_button.dart';
import 'package:dripzoid_v2/shared/widgets/google_sign_in_button.dart';
import 'package:dripzoid_v2/features/products/presentation/widgets/product_purchase_bar.dart';
import 'package:dripzoid_v2/core/ui/widgets/premium_dialog_widget.dart';
import 'package:dripzoid_v2/features/products/presentation/screens/shop_screen.dart';
import 'package:dripzoid_v2/features/auth/presentation/widgets/otp_verification_widget.dart';
import 'package:dripzoid_v2/features/checkout/presentation/screens/order_success_screen.dart';

class MockTokenStorage implements TokenStorage {
  @override
  Future<void> saveToken(String token) async {}
  @override
  Future<String?> getToken() async => null;
  @override
  Future<void> clearToken() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<List<String>> checkOverflow({
    required WidgetTester tester,
    required Widget widget,
    required Size size,
    double textScale = 1.0,
    EdgeInsets insets = EdgeInsets.zero,
    Duration settleDuration = const Duration(milliseconds: 100),
  }) async {
    final List<String> errors = [];
    final oldHandler = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final msg = details.toString();
      if (msg.contains('overflowed') || msg.contains('RenderFlex')) {
        errors.add(msg);
      }
    };

    tester.view.physicalSize = Size(size.width * 2, size.height * 2);
    tester.view.devicePixelRatio = 2.0;

    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(MockTokenStorage()),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: size,
                textScaler: TextScaler.linear(textScale),
                viewInsets: insets,
              ),
              child: Scaffold(body: widget),
            ),
          ),
        ),
      );
      await tester.pump(settleDuration);
    } finally {
      FlutterError.onError = oldHandler;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }

    return errors;
  }

  group('CartItemTile Overflow Audit', () {
    testWidgets('CartItemTile on 320px width compact screen with high price', (tester) async {
      final item = CartItemModel(
        id: 'cart_1',
        productId: 'prod_1',
        name: 'Oversized Vintage Washed Graphic T-Shirt',
        price: 24999.0,
        quantity: 12,
        stock: 50,
        selectedColor: 'Washed Charcoal Black',
        selectedSize: 'XXL',
        images: ['https://example.com/img.jpg'],
      );

      final errors = await checkOverflow(
        tester: tester,
        widget: CartItemTile(
          item: item,
          onQuantityChanged: (_) {},
          onRemove: () {},
        ),
        size: const Size(320, 568),
      );

      expect(errors, isEmpty, reason: 'CartItemTile should not overflow horizontally on 320px screens');
    });
  });

  group('TrackingTimelineWidget Overflow Audit', () {
    testWidgets('TrackingTimelineWidget with long location name', (tester) async {
      final activity = TrackingActivityModel(
        status: 'in transit',
        location: 'Hub Logistics Sorting Facility, Sector 62, Greater Noida, Uttar Pradesh 201301',
        timestamp: DateTime.now(),
      );

      final errors = await checkOverflow(
        tester: tester,
        widget: TrackingTimelineWidget(activities: [activity]),
        size: const Size(320, 568),
      );

      expect(errors, isEmpty, reason: 'TrackingTimelineWidget should not overflow with long location text');
    });
  });

  group('OrderItemTile Overflow Audit', () {
    testWidgets('OrderItemTile with long color and size names', (tester) async {
      final item = OrderItemModel(
        id: 'p1',
        productName: 'Limited Edition Oversized Heavyweight Cotton Hoodie',
        quantity: 2,
        unitPrice: 3499.0,
        price: 6998.0,
        options: {
          'color': 'Vintage Washed Charcoal Heather',
          'size': 'Extra Large (XL)',
        },
      );

      final errors = await checkOverflow(
        tester: tester,
        widget: OrderItemTile(item: item),
        size: const Size(320, 568),
      );

      expect(errors, isEmpty, reason: 'OrderItemTile option chips should wrap and not overflow');
    });
  });

  group('PrimaryButton & PurchaseBar Overflow Audit', () {
    testWidgets('PrimaryButton on narrow constrained width with long text', (tester) async {
      final errors = await checkOverflow(
        tester: tester,
        widget: Center(
          child: SizedBox(
            width: 140,
            child: PrimaryButton(
              text: 'Buy Now With 1-Click',
              onPressed: () {},
            ),
          ),
        ),
        size: const Size(320, 568),
        textScale: 1.3,
      );

      expect(errors, isEmpty, reason: 'PrimaryButton text should scale and ellipsis gracefully');
    });

    testWidgets('ProductPurchaseBar on 320px width with textScale 1.3', (tester) async {
      final errors = await checkOverflow(
        tester: tester,
        widget: ProductPurchaseBar(
          isAvailable: true,
          isInCart: false,
          isLoading: false,
          onAddToCart: () {},
          onBuyNow: () {},
        ),
        size: const Size(320, 568),
        textScale: 1.3,
      );

      expect(errors, isEmpty, reason: 'ProductPurchaseBar buttons should fit on compact screens');
    });
  });

  group('OrderHistoryCard Overflow Audit', () {
    testWidgets('OrderHistoryCard on 320px width with shipped status', (tester) async {
      final order = OrderModel(
        id: 'ord_123',
        orderNumber: 'ORD-998877665544',
        status: 'shipped',
        totalAmount: 149999.0,
        items: [
          const OrderItemModel(
            id: 'p1',
            productName: 'Heavyweight Luxury Hoodie',
            quantity: 1,
            unitPrice: 149999.0,
          ),
        ],
      );

      final errors = await checkOverflow(
        tester: tester,
        widget: OrderHistoryCard(
          order: order,
          onTap: () {},
          onTrackTap: () {},
        ),
        size: const Size(320, 568),
        textScale: 1.2,
      );

      expect(errors, isEmpty, reason: 'OrderHistoryCard should fit amount and actions on 320px');
    });
  });

  group('OrderSummaryWidget Overflow Audit', () {
    testWidgets('OrderSummaryWidget on 320px width with large numbers', (tester) async {
      final errors = await checkOverflow(
        tester: tester,
        widget: const OrderSummaryWidget(
          total: 1250,
          active: 450,
          cancelled: 120,
        ),
        size: const Size(320, 568),
        textScale: 1.3,
      );

      expect(errors, isEmpty, reason: 'OrderSummaryWidget should not overflow with large stats');
    });
  });

  group('GoogleSignInButton Overflow Audit', () {
    testWidgets('GoogleSignInButton in constrained container on 320px width with text scale', (tester) async {
      final errors = await checkOverflow(
        tester: tester,
        widget: Center(
          child: SizedBox(
            width: 216,
            child: GoogleSignInButton(
              onPressed: () {},
            ),
          ),
        ),
        size: const Size(320, 568),
        textScale: 1.3,
      );

      expect(errors, isEmpty, reason: 'GoogleSignInButton should scale text down without overflowing');
    });
  });

  group('ProductCard Horizontal Mode Overflow Audit', () {
    testWidgets('ProductCard horizontal mode on 360 width with textScale 1.4', (tester) async {
      const product = ProductModel(
        id: 'p_horiz',
        name: 'Essential Oversized Streetwear Graphic Drop Shoulder Hoodie',
        slug: 'hoodie',
        category: 'Apparel',
        subcategory: 'Streetwear Collection 2026',
        price: 4999.0,
        originalPrice: 8999.0,
        images: ['https://example.com/h.jpg'],
      );

      final errors = await checkOverflow(
        tester: tester,
        widget: Center(
          child: SizedBox(
            width: 340,
            child: ProductCard(
              product: product,
              mode: ProductCardMode.horizontal,
            ),
          ),
        ),
        size: const Size(360, 800),
        textScale: 1.4,
      );

      expect(errors, isEmpty, reason: 'ProductCard horizontal mode should not overflow with high text scaling');
    });
  });

  group('FilterBottomSheet Overflow Audit', () {
    testWidgets('FilterBottomSheet on landscape mobile (height 360)', (tester) async {
      final errors = await checkOverflow(
        tester: tester,
        widget: const FilterBottomSheet(),
        size: const Size(640, 360),
      );

      expect(errors, isEmpty, reason: 'FilterBottomSheet should be scrollable and not overflow vertically');
    });
  });

  group('PremiumDialogWidget Overflow Audit', () {
    testWidgets('PremiumDialogWidget on landscape phone (height 340) with two actions', (tester) async {
      final errors = await checkOverflow(
        tester: tester,
        widget: const PremiumDialogWidget(
          title: 'Confirm Cancellation',
          message: 'Are you sure you want to cancel this order? Once cancelled, promotional coupons cannot be restored and the refund will be credited to original source.',
          type: PremiumAlertType.confirmation,
          primaryActionText: 'Yes, Cancel Order',
          secondaryActionText: 'Keep My Order',
        ),
        size: const Size(640, 340),
      );

      expect(errors, isEmpty, reason: 'PremiumDialogWidget should scroll content without vertical overflow');
    });
  });

  group('OtpVerificationWidget & OrderSuccessScreen Audit', () {
    testWidgets('OtpVerificationWidget with keyboard inset bottom: 300', (tester) async {
      final errors = await checkOverflow(
        tester: tester,
        widget: OtpVerificationWidget(
          email: 'testuser@example.com',
          onVerify: (_) async => true,
          onResend: () async {},
        ),
        size: const Size(320, 568),
        insets: const EdgeInsets.only(bottom: 300),
      );

      expect(errors, isEmpty, reason: 'OtpVerificationWidget should scroll cleanly when keyboard opens');
    });

    testWidgets('OrderSuccessScreen on compact short screen', (tester) async {
      final order = OrderModel(
        id: 'ord_success_1',
        orderNumber: 'ORD-SUCCESS-1234',
        status: 'placed',
        totalAmount: 2999.0,
        items: const [],
      );

      final errors = await checkOverflow(
        tester: tester,
        widget: OrderSuccessScreen(order: order),
        size: const Size(320, 500),
      );

      expect(errors, isEmpty, reason: 'OrderSuccessScreen should scroll cleanly without overflow');
    });
  });

  group('ProductAttribution Audit', () {
    testWidgets('ProductAttribution on 320px compact screen with text scale 1.4', (tester) async {
      final errors = await checkOverflow(
        tester: tester,
        widget: const ProductAttribution(),
        size: const Size(320, 568),
        textScale: 1.4,
      );

      expect(errors, isEmpty, reason: 'ProductAttribution should render cleanly without overflow');
    });
  });

  group('SplashScreen Timer & Layout Audit', () {
    testWidgets('SplashScreen layout on 320px width with textScale 1.3', (tester) async {
      final errors = await checkOverflow(
        tester: tester,
        widget: const SplashScreen(),
        size: const Size(320, 568),
        textScale: 1.3,
        settleDuration: const Duration(seconds: 12),
      );

      expect(errors, isEmpty, reason: 'SplashScreen should layout without overflow');
    });
  });
}
