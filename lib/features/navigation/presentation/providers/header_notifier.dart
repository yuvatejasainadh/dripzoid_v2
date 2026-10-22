import 'package:flutter_riverpod/flutter_riverpod.dart';

class HeaderState {
  final bool isSearchVisible;
  final String searchQuery;

  const HeaderState({
    this.isSearchVisible = false,
    this.searchQuery = '',
  });

  HeaderState copyWith({
    bool? isSearchVisible,
    String? searchQuery,
  }) {
    return HeaderState(
      isSearchVisible: isSearchVisible ?? this.isSearchVisible,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class HeaderNotifier extends Notifier<HeaderState> {
  @override
  HeaderState build() {
    return const HeaderState();
  }

  void toggleSearch() {
    if (state.isSearchVisible) {
      clearSearch();
    } else {
      state = state.copyWith(isSearchVisible: true);
    }
  }

  void setSearchVisible(bool visible) {
    state = state.copyWith(isSearchVisible: visible);
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '', isSearchVisible: false);
  }
}

final headerProvider = NotifierProvider<HeaderNotifier, HeaderState>(() {
  return HeaderNotifier();
});
