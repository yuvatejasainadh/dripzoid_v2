import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationState {
  final int currentIndex;
  final int notificationCount;

  const NavigationState({
    this.currentIndex = 0,
    this.notificationCount = 0,
  });

  NavigationState copyWith({
    int? currentIndex,
    int? notificationCount,
  }) {
    return NavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      notificationCount: notificationCount ?? this.notificationCount,
    );
  }
}

class NavigationNotifier extends Notifier<NavigationState> {
  @override
  NavigationState build() {
    return const NavigationState();
  }

  void setIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  void updateNotificationCount(int count) {
    state = state.copyWith(notificationCount: count);
  }
}

final navigationProvider = NotifierProvider<NavigationNotifier, NavigationState>(() {
  return NavigationNotifier();
});
