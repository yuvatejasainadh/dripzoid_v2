import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/conversation_model.dart';
import '../../data/repositories/askdrip_repository.dart';
import '../../../../core/models/result.dart';

class ConversationsNotifier extends AsyncNotifier<List<ConversationModel>> {
  @override
  FutureOr<List<ConversationModel>> build() {
    return loadConversations();
  }

  Future<List<ConversationModel>> loadConversations() async {
    final repository = ref.read(askDripRepositoryProvider);
    final result = await repository.getConversations();

    return switch (result) {
      Success(data: final data) => data,
      Failure(message: final m) => throw Exception(m),
    };
  }

  Future<void> createConversation(String title) async {
    final repository = ref.read(askDripRepositoryProvider);
    final result = await repository.createConversation(title);

    if (result is Success<ConversationModel>) {
      final conversations = state.valueOrNull ?? [];
      state = AsyncValue.data([result.data, ...conversations]);
    }
  }

  Future<void> deleteConversation(String id) async {
    final repository = ref.read(askDripRepositoryProvider);
    final result = await repository.deleteConversation(id);

    if (result is Success) {
      final conversations = state.valueOrNull ?? [];
      state = AsyncValue.data(
        conversations.where((c) => c.id != id).toList(),
      );
    }
  }
}

final conversationsNotifierProvider =
    AsyncNotifierProvider<ConversationsNotifier, List<ConversationModel>>(
  ConversationsNotifier.new,
);
