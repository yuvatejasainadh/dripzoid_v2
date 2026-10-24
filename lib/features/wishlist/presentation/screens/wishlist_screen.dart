import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/layout_utils.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
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
    final columns = LayoutUtils.getGridColumnCount(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
      ),
      body: ResponsiveContainer(
        child: state.isLoading && state.items.isEmpty
            ? _buildLoadingGrid(columns)
            : state.errorMessage != null && state.items.isEmpty
                ? _buildErrorState(context, state.errorMessage!)
                : state.items.isEmpty
                    ? _buildEmptyState(context)
                    : RefreshIndicator(
                        onRefresh: () => ref.read(wishlistProvider.notifier).fetchWishlist(),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            childAspectRatio: LayoutUtils.getProductGridRatio(context),
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                          ),
                          itemCount: state.items.length,
                          itemBuilder: (context, index) {
                            final item = state.items[index];
                            final product = ProductModel(
                              id: item.productId,
                              name: item.name ?? 'Product',
                              slug: '',
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
                      ),
      ),
    );
  }

  Widget _buildLoadingGrid(int columns) {
    return ProductGridSkeleton(
      columns: columns,
      itemCount: columns * 2,
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            const Text(
              'Failed to load wishlist',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(wishlistProvider.notifier).fetchWishlist(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
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
      ),
    );
  }
}
