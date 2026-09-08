import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/result.dart';
import '../../../products/data/models/product_model.dart';
import 'home_notifier.dart';

class SearchState {
  final String query;
  final List<ProductModel> results;
  final bool isLoading;
  final String? errorMessage;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  SearchState copyWith({
    String? query,
    List<ProductModel>? results,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(() {
  return SearchNotifier();
});

class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounceTimer;

  @override
  SearchState build() {
    ref.onDispose(() => _debounceTimer?.cancel());
    return const SearchState();
  }

  void onQueryChanged(String query) {
    state = state.copyWith(query: query);

    _debounceTimer?.cancel();

    if (query.trim().length < 3) {
      state = state.copyWith(results: [], isLoading: false, errorMessage: null);
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await ref.read(homeRepositoryProvider).searchProducts(query);

    // If query has changed since request started, ignore results
    if (state.query != query) return;

    state = switch (result) {
      Success(data: final data) => state.copyWith(
          results: data,
          isLoading: false,
        ),
      Failure(message: final msg) => state.copyWith(
          errorMessage: msg,
          isLoading: false,
        ),
    };
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    state = const SearchState();
  }
}
