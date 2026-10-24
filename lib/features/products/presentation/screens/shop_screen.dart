import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/layout_utils.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../providers/product_list_notifier.dart';

class ShopScreen extends ConsumerStatefulWidget {
  final String? category;
  const ShopScreen({super.key, this.category});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.category != null) {
        ref.read(productListProvider.notifier).setCategory(widget.category);
      } else {
        ref.read(productListProvider.notifier).loadProducts();
      }
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(productListProvider.notifier).loadProducts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productListProvider);
    final columns = LayoutUtils.getGridColumnCount(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          IconButton(
            onPressed: () => _showFilterBottomSheet(context),
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(productListProvider.notifier).loadProducts(refresh: true),
        child: ResponsiveContainer(
          child: state.products.isEmpty && state.isLoading
              ? _buildLoadingGrid(columns)
              : state.products.isEmpty
                  ? const Center(child: Text('No products found'))
                  : GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        childAspectRatio: LayoutUtils.getProductGridRatio(context),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      itemCount: state.products.length + (state.hasReachedMax ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index >= state.products.length) {
                          return const ProductCardSkeleton();
                        }
                        return ProductCard(product: state.products[index]);
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

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: LayoutUtils.maxFormWidth),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const FilterBottomSheet(),
    );
  }
}

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late ProductListFilter _tempFilter;

  @override
  void initState() {
    super.initState();
    _tempFilter = ref.read(productListProvider).filter;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  ref.read(productListProvider.notifier).clearFilters();
                  Navigator.pop(context);
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: [
              _SortChip(
                label: 'Newest',
                value: 'newest',
                selectedValue: _tempFilter.sort,
                onSelected: (v) => setState(() => _tempFilter = _tempFilter.copyWith(sort: v)),
              ),
              _SortChip(
                label: 'Price: Low to High',
                value: 'low-high',
                selectedValue: _tempFilter.sort,
                onSelected: (v) => setState(() => _tempFilter = _tempFilter.copyWith(sort: v)),
              ),
              _SortChip(
                label: 'Price: High to Low',
                value: 'high-low',
                selectedValue: _tempFilter.sort,
                onSelected: (v) => setState(() => _tempFilter = _tempFilter.copyWith(sort: v)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              onPressed: () {
                ref.read(productListProvider.notifier).updateFilter(_tempFilter);
                Navigator.pop(context);
              },
              text: 'Apply Filters',
            ),
          ),
        ],
      ),
    ),
  );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final String value;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  const _SortChip({
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isSelected = value == selectedValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onSelected(value),
      showCheckmark: false,
      selectedColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
