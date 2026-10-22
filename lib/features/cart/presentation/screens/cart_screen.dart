import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/layout_utils.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../data/models/cart_item_model.dart';
import '../providers/cart_notifier.dart';
import '../widgets/cart_item_tile.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(cartProvider.notifier).fetchCart());
  }

  Future<void> _confirmRemoveItem(BuildContext context, CartItemModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove from Cart'),
        content: Text('Remove "${item.name ?? 'this item'}" from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ref.read(cartProvider.notifier).removeFromCart(item.id);
    }
  }

  Future<void> _confirmClearCart(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ref.read(cartProvider.notifier).clearCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CartState>(cartProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage &&
          next.items.isNotEmpty) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final state = ref.watch(cartProvider);
    final isDesktop = LayoutUtils.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          if (state.items.isNotEmpty)
            IconButton(
              onPressed: () => _confirmClearCart(context),
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear Cart',
            ),
        ],
      ),
      body: ResponsiveContainer(
        child: state.isLoading && state.items.isEmpty
            ? const CartScreenSkeleton()
            : state.errorMessage != null && state.items.isEmpty
                ? _buildErrorState(context, state.errorMessage!)
                : state.items.isEmpty
                    ? _buildEmptyState(context)
                    : isDesktop
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: RefreshIndicator(
                                    onRefresh: () => ref.read(cartProvider.notifier).fetchCart(),
                                    child: ListView.separated(
                                      itemCount: state.items.length,
                                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                                      itemBuilder: (context, index) {
                                        final item = state.items[index];
                                        return CartItemTile(
                                          item: item,
                                          onTap: item.productId.isNotEmpty
                                              ? () => context.push('/product/${item.productId}')
                                              : null,
                                          onQuantityChanged: (q) =>
                                              ref.read(cartProvider.notifier).updateQuantity(item.id, q),
                                          onRemove: () => _confirmRemoveItem(context, item),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 32),
                                Expanded(
                                  flex: 5,
                                  child: _buildSummary(context, state),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh: () => ref.read(cartProvider.notifier).fetchCart(),
                                  child: ListView.separated(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: state.items.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                                    itemBuilder: (context, index) {
                                      final item = state.items[index];
                                      return CartItemTile(
                                        item: item,
                                        onTap: item.productId.isNotEmpty
                                            ? () => context.push('/product/${item.productId}')
                                            : null,
                                        onQuantityChanged: (q) =>
                                            ref.read(cartProvider.notifier).updateQuantity(item.id, q),
                                        onRemove: () => _confirmRemoveItem(context, item),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              _buildSummary(context, state),
                            ],
                          ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 72, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 20),
            Text(
              'Unable to load cart',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: () => ref.read(cartProvider.notifier).fetchCart(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 80, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 20),
            Text(
              'Your cart is empty',
              style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 10),
            Text('Looks like you haven\'t added anything yet.',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 30),
            PrimaryButton(
              onPressed: () => context.go('/shop'),
              text: 'Start Shopping',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, CartState state) {
    final theme = Theme.of(context);
    final isDesktop = LayoutUtils.isDesktop(context);

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, isDesktop ? 24 : MediaQuery.of(context).padding.bottom + 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: BorderRadius.vertical(top: const Radius.circular(24), bottom: isDesktop ? const Radius.circular(24) : Radius.zero),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Total (${state.totalItems} items)',
                  style: theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '₹${state.subtotal.round()}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            onPressed: state.isLoading
                ? null
                : () => context.push('/checkout', extra: state.items),
            text: 'Proceed to Checkout',
            loading: state.isLoading,
          ),
        ],
      ),
    );
  }
}
