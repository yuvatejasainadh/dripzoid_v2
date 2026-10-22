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
  final Set<String> _pendingCartItemIds = {};

  @override
  CartState build() {
    return const CartState();
  }

  CartRepository get _repository => ref.read(cartRepositoryProvider);

  Future<void> fetchCart() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.getCart();

    state = switch (result) {
      Success(data: final List<CartItemModel> items) =>
        state.copyWith(items: items, isLoading: false, errorMessage: null),
      Failure(message: final String msg) =>
        state.copyWith(errorMessage: msg, isLoading: false),
    };
  }

  Future<bool> addToCart({
    required String productId,
    int quantity = 1,
    String? size,
    String? color,
  }) async {
    if (quantity <= 0) return false;

    final opKey = 'add-$productId-$size-$color';
    if (_pendingCartItemIds.contains(opKey)) return false;
    _pendingCartItemIds.add(opKey);

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
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
    } finally {
      _pendingCartItemIds.remove(opKey);
    }
  }

  Future<void> updateQuantity(String cartId, int quantity) async {
    if (quantity < 1) {
      await removeFromCart(cartId);
      return;
    }

    if (_pendingCartItemIds.contains(cartId)) return;
    _pendingCartItemIds.add(cartId);

    final previousItems = state.items;
    final itemIndex = state.items.indexWhere((it) => it.id == cartId);

    int boundedQuantity = quantity;
    if (itemIndex != -1) {
      final targetItem = state.items[itemIndex];
      final maxStock = (targetItem.stock != null && targetItem.stock! > 0) ? targetItem.stock! : 99;
      boundedQuantity = quantity > maxStock ? maxStock : quantity;

      // Optimistic local state update for instant UI responsiveness
      final updatedItems = List<CartItemModel>.from(state.items);
      updatedItems[itemIndex] = targetItem.copyWith(quantity: boundedQuantity);
      state = state.copyWith(items: updatedItems, errorMessage: null);
    }

    try {
      final result = await _repository.updateCartItem(cartId: cartId, quantity: boundedQuantity);
      if (result is Success) {
        await fetchCart();
      } else {
        // Rollback on failure if item was in state
        if (itemIndex != -1) {
          state = state.copyWith(
            items: previousItems,
            errorMessage: (result as Failure).message,
          );
        } else {
          state = state.copyWith(errorMessage: (result as Failure).message);
        }
      }
    } catch (e) {
      if (itemIndex != -1) {
        state = state.copyWith(
          items: previousItems,
          errorMessage: 'Failed to update item quantity',
        );
      } else {
        state = state.copyWith(errorMessage: 'Failed to update item quantity');
      }
    } finally {
      _pendingCartItemIds.remove(cartId);
    }
  }

  Future<void> removeFromCart(String cartId) async {
    if (_pendingCartItemIds.contains(cartId)) return;
    _pendingCartItemIds.add(cartId);

    final previousItems = state.items;
    final itemIndex = state.items.indexWhere((it) => it.id == cartId);
    if (itemIndex != -1) {
      final updatedItems = state.items.where((it) => it.id != cartId).toList();
      state = state.copyWith(items: updatedItems, errorMessage: null);
    }

    try {
      final result = await _repository.deleteCartItem(cartId);
      if (result is Success) {
        await fetchCart();
      } else {
        if (itemIndex != -1) {
          state = state.copyWith(
            items: previousItems,
            errorMessage: (result as Failure).message,
          );
        } else {
          state = state.copyWith(errorMessage: (result as Failure).message);
        }
      }
    } catch (e) {
      if (itemIndex != -1) {
        state = state.copyWith(
          items: previousItems,
          errorMessage: 'Failed to remove item from cart',
        );
      } else {
        state = state.copyWith(errorMessage: 'Failed to remove item from cart');
      }
    } finally {
      _pendingCartItemIds.remove(cartId);
    }
  }

  Future<void> clearCart() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.clearCart();
    state = switch (result) {
      Success() => state.copyWith(items: [], isLoading: false, errorMessage: null),
      Failure(message: final msg) => state.copyWith(isLoading: false, errorMessage: msg),
    };
  }

  void reset() {
    _pendingCartItemIds.clear();
    state = const CartState();
  }
}
