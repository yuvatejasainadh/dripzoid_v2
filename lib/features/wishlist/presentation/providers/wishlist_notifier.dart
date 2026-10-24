import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/result.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/models/wishlist_item_model.dart';
import '../../data/repositories/wishlist_repository.dart';
import '../../data/services/wishlist_service.dart';

final wishlistServiceProvider = Provider<WishlistService>((ref) {
  final client = ref.watch(apiClientProvider);
  return WishlistService(client);
});

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  final service = ref.watch(wishlistServiceProvider);
  return WishlistRepository(service);
});

class WishlistState {
  final List<WishlistItemModel> items;
  final bool isLoading;
  final String? errorMessage;

  const WishlistState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  WishlistState copyWith({
    List<WishlistItemModel>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return WishlistState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  bool isWishlisted(String productId) {
    return items.any((item) => item.productId == productId);
  }
}

final wishlistProvider = NotifierProvider<WishlistNotifier, WishlistState>(() {
  return WishlistNotifier();
});

class WishlistNotifier extends Notifier<WishlistState> {
  final Set<String> _pendingProductIds = {};

  @override
  WishlistState build() {
    return const WishlistState();
  }

  WishlistRepository get _repository => ref.read(wishlistRepositoryProvider);

  void reset() {
    _pendingProductIds.clear();
    state = const WishlistState();
  }

  Future<void> fetchWishlist() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.getWishlist();

    state = switch (result) {
      Success(data: final List<WishlistItemModel> items) =>
        state.copyWith(items: items, isLoading: false, errorMessage: null),
      Failure(message: final String msg) =>
        state.copyWith(errorMessage: msg, isLoading: false),
    };
  }

  Future<void> toggleWishlist(String productId) async {
    if (_pendingProductIds.contains(productId)) return;
    _pendingProductIds.add(productId);

    try {
      final isCurrentlyWishlisted = state.isWishlisted(productId);
      final previousItems = state.items;

      if (isCurrentlyWishlisted) {
        // Optimistic Remove
        state = state.copyWith(
          items: state.items.where((item) => item.productId != productId).toList(),
          errorMessage: null,
        );

        final result = await _repository.removeFromWishlist(productId);
        if (result is Failure) {
          state = state.copyWith(items: previousItems, errorMessage: result.message);
        }
      } else {
        final result = await _repository.addToWishlist(productId);
        if (result is Success) {
          await fetchWishlist();
        } else {
          state = state.copyWith(errorMessage: (result as Failure).message);
        }
      }
    } finally {
      _pendingProductIds.remove(productId);
    }
  }

  Future<void> moveToCart(List<String> productIds) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _repository.moveToCart(productIds);
      if (result is Success) {
        await fetchWishlist();
      } else {
        state = state.copyWith(isLoading: false, errorMessage: (result as Failure).message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
