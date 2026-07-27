import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import 'google_provider.dart';

final sessionProvider =
StateNotifierProvider<SessionNotifier, SessionState>(
      (ref) => SessionNotifier(ref),
);

class SessionState {
  final bool initialized;
  final bool authenticated;
  final UserModel? user;

  const SessionState({
    this.initialized = false,
    this.authenticated = false,
    this.user,
  });

  SessionState copyWith({
    bool? initialized,
    bool? authenticated,
    UserModel? user,
  }) {
    return SessionState(
      initialized: initialized ?? this.initialized,
      authenticated: authenticated ?? this.authenticated,
      user: user ?? this.user,
    );
  }
}

class SessionNotifier extends StateNotifier<SessionState> {
  final Ref ref;

  SessionNotifier(this.ref)
      : super(const SessionState());

  Future<void> initialize() async {
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .getCurrentUser();

      state = state.copyWith(
        initialized: true,
        authenticated: true,
        user: user,
      );
    } catch (_) {
      state = state.copyWith(
        initialized: true,
        authenticated: false,
      );
    }
  }

  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
      await ref.read(googleAuthProvider).signOut();
    } catch (_) {}

    state = const SessionState(
      initialized: true,
      authenticated: false,
    );
  }
}