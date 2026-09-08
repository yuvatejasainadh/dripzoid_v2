import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/layout_utils.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../../products/data/models/product_model.dart';
import '../providers/wishlist_notifier.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(wishlistProvider.notifier).fetchWishlist());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
      ),
      body: state.isLoading && state.items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.items.isEmpty
              ? _buildEmptyState(context)
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: LayoutUtils.getProductGridRatio(context),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    // Map WishlistItem to ProductModel for ProductCard
                    final product = ProductModel(
                      id: item.productId,
                      name: item.name ?? 'Product',
                      slug: '', // slug not in wishlist item but id is enough for details
                      price: item.price,
                      images: item.images,
                    );
                    
                    return ProductCard(
                      product: product,
                      isWishlisted: true,
                      heroSuffix: 'wishlist',
                      onWishlistToggle: () =>
                          ref.read(wishlistProvider.notifier).toggleWishlist(item.productId),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline, size: 80, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 20),
          const Text('Your wishlist is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Save items you like to see them here.', style: TextStyle(color: theme.colorScheme.secondary)),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: FilledButton(
              onPressed: () => context.go('/shop'),
              child: const Text('Explore Products'),
            ),
          ),
        ],
      ),
    );
  }
}
