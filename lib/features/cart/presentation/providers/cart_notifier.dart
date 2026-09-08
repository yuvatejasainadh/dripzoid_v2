import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/result.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/services/cart_service.dart';

final cartServiceProvider = Provider<CartService>((ref) {
  final client = ref.watch(apiClientProvider);
  return CartService(client);
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final service = ref.watch(cartServiceProvider);
  return CartRepository(service);
});

class CartState {
  final List<CartItemModel> items;
  final bool isLoading;
  final String? errorMessage;

  const CartState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CartState copyWith({
    List<CartItemModel>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  double get subtotal => items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  bool isInCart(String productId, String? size, String? color) {
    return items.any((item) =>
        item.productId == productId &&
        item.selectedSize == size &&
        item.selectedColor == color);
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(() {
  return CartNotifier();
});

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    return const CartState();
  }

  CartRepository get _repository => ref.read(cartRepositoryProvider);

  Future<void> fetchCart() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.getCart();

    state = switch (result) {
      Success(data: final List<CartItemModel> items) => state.copyWith(items: items, isLoading: false),
      Failure(message: final String msg) => state.copyWith(errorMessage: msg, isLoading: false),
    };
  }

  Future<bool> addToCart({
    required String productId,
    int quantity = 1,
    String? size,
    String? color,
  }) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.addToCart(
      productId: productId,
      quantity: quantity,
      selectedSize: size,
      selectedColor: color,
    );

    if (result is Success) {
      await fetchCart();
      return true;
    } else {
      state = state.copyWith(isLoading: false, errorMessage: (result as Failure).message);
      return false;
    }
  }

  Future<void> updateQuantity(String cartId, int quantity) async {
    if (quantity < 1) {
      await removeFromCart(cartId);
      return;
    }

    final result = await _repository.updateCartItem(cartId: cartId, quantity: quantity);
    if (result is Success) {
      await fetchCart();
    }
  }

  Future<void> removeFromCart(String cartId) async {
    final result = await _repository.deleteCartItem(cartId);
    if (result is Success) {
      await fetchCart();
    }
  }

  Future<void> clearCart() async {
    final result = await _repository.clearCart();
    if (result is Success) {
      state = state.copyWith(items: []);
    }
  }
}
