import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/result.dart';
import '../../../products/data/models/product_model.dart';
import 'home_notifier.dart';

class SearchState {
  static const int minQueryLength = 3;

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

  bool get isQueryTooShort =>
      query.trim().isNotEmpty && query.trim().length < minQueryLength;

  bool get hasValidQuery => query.trim().length >= minQueryLength;

  SearchState copyWith({
    String? query,
    List<ProductModel>? results,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(() {
  return SearchNotifier();
});

class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounceTimer;
  int _searchRequestId = 0;

  @override
  SearchState build() {
    ref.onDispose(() => _debounceTimer?.cancel());
    return const SearchState();
  }

  void onQueryChanged(String query) {
    state = state.copyWith(query: query);

    _debounceTimer?.cancel();

    final trimmed = query.trim();
    if (trimmed.length < SearchState.minQueryLength) {
      _searchRequestId++;
      state = state.copyWith(
        results: const [],
        isLoading: false,
        clearError: true,
      );
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch(trimmed);
    });
  }

  void submitQuery(String query) {
    _debounceTimer?.cancel();
    final trimmed = query.trim();
    state = state.copyWith(query: query);

    if (trimmed.length < SearchState.minQueryLength) {
      _searchRequestId++;
      state = state.copyWith(
        results: const [],
        isLoading: false,
        clearError: true,
      );
      return;
    }

    _performSearch(trimmed);
  }

  Future<void> _performSearch(String query) async {
    final currentRequestId = ++_searchRequestId;
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(homeRepositoryProvider).searchProducts(query);

    // If a newer request was dispatched or query changed, discard stale result
    if (currentRequestId != _searchRequestId || state.query.trim() != query) {
      return;
    }

    state = switch (result) {
      Success(data: final data) => state.copyWith(
          results: data,
          isLoading: false,
          clearError: true,
        ),
      Failure(message: final msg) => state.copyWith(
          errorMessage: msg,
          isLoading: false,
        ),
    };
  }

  void retrySearch() {
    final currentQuery = state.query.trim();
    if (currentQuery.length >= SearchState.minQueryLength) {
      _performSearch(currentQuery);
    }
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    _searchRequestId++;
    state = const SearchState();
  }
}
