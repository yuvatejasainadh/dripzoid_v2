import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/result.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import 'product_providers.dart';

class ProductListFilter {
  final String? category;
  final List<String> subcategories;
  final List<String> colors;
  final double minPrice;
  final double maxPrice;
  final String sort;

  const ProductListFilter({
    this.category,
    this.subcategories = const [],
    this.colors = const [],
    this.minPrice = 0,
    this.maxPrice = 100000,
    this.sort = 'newest',
  });

  ProductListFilter copyWith({
    String? category,
    List<String>? subcategories,
    List<String>? colors,
    double? minPrice,
    double? maxPrice,
    String? sort,
  }) {
    return ProductListFilter(
      category: category ?? this.category,
      subcategories: subcategories ?? this.subcategories,
      colors: colors ?? this.colors,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sort: sort ?? this.sort,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      if (category != null) 'category': category,
      if (subcategories.isNotEmpty) 'subcategory': subcategories.join(','),
      if (colors.isNotEmpty) 'colors': colors.join(','),
      'minPrice': minPrice.toInt(),
      'maxPrice': maxPrice.toInt(),
      'sort': _mapSort(sort),
    };
    return params;
  }

  String _mapSort(String s) {
    return switch (s) {
      'low-high' => 'price_asc',
      'high-low' => 'price_desc',
      'newest' => 'newest',
      _ => 'newest',
    };
  }
}

class ProductListState {
  final List<ProductModel> products;
  final bool isLoading;
  final String? errorMessage;
  final ProductListFilter filter;
  final int page;
  final bool hasReachedMax;

  const ProductListState({
    this.products = const [],
    this.isLoading = false,
    this.errorMessage,
    this.filter = const ProductListFilter(),
    this.page = 1,
    this.hasReachedMax = false,
  });

  ProductListState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    String? errorMessage,
    ProductListFilter? filter,
    int? page,
    bool? hasReachedMax,
  }) {
    return ProductListState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      filter: filter ?? this.filter,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

final productListProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  return ProductListNotifier(ref);
});

class ProductListNotifier extends StateNotifier<ProductListState> {
  final Ref _ref;

  ProductListNotifier(this._ref) : super(const ProductListState());

  ProductRepository get _repository => _ref.read(productRepositoryProvider);

  Future<void> loadProducts({bool refresh = false}) async {
    if (state.isLoading || (state.hasReachedMax && !refresh)) return;

    if (refresh) {
      state = state.copyWith(page: 1, products: [], hasReachedMax: false);
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final params = state.filter.toQueryParameters();
    params['page'] = state.page;

    final Result<List<ProductModel>> result = await _repository.getProducts(queryParameters: params);

    state = switch (result) {
      Success(data: final List<ProductModel> newProducts) => state.copyWith(
          products: refresh ? newProducts : [...state.products, ...newProducts],
          isLoading: false,
          page: state.page + 1,
          hasReachedMax: newProducts.isEmpty || newProducts.length < 10, // Assuming 10 is page limit
        ),
      Failure(message: final msg) => state.copyWith(
          isLoading: false,
          errorMessage: msg,
        ),
    };
  }

  void updateFilter(ProductListFilter filter) {
    state = state.copyWith(filter: filter);
    loadProducts(refresh: true);
  }

  void setCategory(String? category) {
    state = state.copyWith(filter: state.filter.copyWith(category: category));
    loadProducts(refresh: true);
  }

  void clearFilters() {
    state = state.copyWith(filter: const ProductListFilter());
    loadProducts(refresh: true);
  }
}
