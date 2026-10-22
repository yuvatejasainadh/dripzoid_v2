import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/layout_utils.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../providers/order_history_notifier.dart';
import '../widgets/order_filter_chips.dart';
import '../widgets/order_history_card.dart';
import '../widgets/order_summary_widget.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(orderHistoryProvider.notifier).fetchOrders());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderHistoryProvider);

    return Scaffold(
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 900,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref.read(orderHistoryProvider.notifier).fetchOrders(),
                  child: CustomScrollView(
                    slivers: [
                      if (state.isLoading && state.orders.isEmpty)
                        _buildLoadingState()
                      else if (state.errorMessage != null && state.orders.isEmpty)
                        _buildErrorState(state.errorMessage!)
                      else if (state.orders.isEmpty)
                        _buildEmptyState(context)
                      else ...[
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),
                        SliverToBoxAdapter(
                          child: OrderSummaryWidget(
                            total: state.totalCount,
                            active: state.activeCount,
                            cancelled: state.cancelledCount,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                        SliverToBoxAdapter(
                          child: OrderFilterChips(
                            selectedFilter: state.selectedFilter,
                            onFilterChanged: (filter) =>
                                ref.read(orderHistoryProvider.notifier).setFilter(filter),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final order = state.filteredOrders[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: OrderHistoryCard(
                                    order: order,
                                    onTap: () => context.push('/profile/order-details/${order.id}'),
                                    onTrackTap: () => context.push('/profile/order-details/${order.id}'),
                                  ),
                                );
                              },
                              childCount: state.filteredOrders.length,
                            ),
                          ),
                        ),
                      ],
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'My Orders',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: ShimmerWidget.rectangular(height: 180),
          ),
          childCount: 3,
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final theme = Theme.of(context);
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                'Couldn\'t load your orders',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => ref.read(orderHistoryProvider.notifier).fetchOrders(),
                  child: const Text('Try Again'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
            const SizedBox(height: 24),
            const Text('No orders yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              'Your future Dripzoid looks\nwill appear here.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Start Shopping'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
