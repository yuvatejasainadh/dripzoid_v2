import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/primary_button.dart';
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          if (state.items.isNotEmpty)
            IconButton(
              onPressed: () => ref.read(cartProvider.notifier).clearCart(),
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear Cart',
            ),
        ],
      ),
      body: state.isLoading && state.items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.items.isEmpty
              ? _buildEmptyState(context)
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.items.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          return CartItemTile(
                            item: item,
                            onQuantityChanged: (q) =>
                                ref.read(cartProvider.notifier).updateQuantity(item.id, q),
                            onRemove: () =>
                                ref.read(cartProvider.notifier).removeFromCart(item.id),
                          );
                        },
                      ),
                    ),
                    _buildSummary(context, state),
                  ],
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
                size: 80, color: theme.colorScheme.outline),
            const SizedBox(height: 20),
            const Text('Your cart is empty',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Looks like you haven\'t added anything yet.',
                style: TextStyle(color: theme.colorScheme.secondary)),
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
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total (${state.totalItems} items)', style: theme.textTheme.bodyMedium),
              Text(
                '₹${state.subtotal.round()}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            onPressed: () => context.push('/checkout', extra: state.items),
            text: 'Proceed to Checkout',
          ),
        ],
      ),
    );
  }
}
