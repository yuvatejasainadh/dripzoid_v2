import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/logging/app_logger.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories/askdrip_repository.dart';
import '../../../../core/models/result.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'conversations_notifier.dart';

class AskDripNotifier extends FamilyAsyncNotifier<List<MessageModel>, String?> {
  String? _resolvedConversationId;

  String? get conversationId => _resolvedConversationId ?? arg;

  @override
  FutureOr<List<MessageModel>> build(String? arg) {
    _resolvedConversationId = arg;
    if (arg == null) {
      AppLogger.d('[AskDripNotifier] No conversation ID, starting fresh');
      return [];
    }
    return loadMessages(arg);
  }

  void resetFreshChat() {
    _resolvedConversationId = null;
    state = const AsyncValue.data([]);
  }

  void clearError() {
    if (state.hasError && state.hasValue) {
      state = AsyncValue.data(state.value!);
    }
  }

  Future<List<MessageModel>> loadMessages(String id) async {
    AppLogger.d('[AskDripNotifier] [loadMessages] Fetching: $id');
    final repository = ref.read(askDripRepositoryProvider);
    final result = await repository.getMessages(id);

    return switch (result) {
      Success(data: final data) => data,
      Failure(message: final m, endpoint: final ep, statusCode: final sc) => () {
          AppLogger.e('[AskDripNotifier] [loadMessages] Failed: $m ($sc) at $ep');
          throw Exception(m);
        }(),
    };
  }

  Future<void> sendMessage(String prompt, {String mode = 'chat'}) async {
    final trimmedPrompt = prompt.trim();
    if (trimmedPrompt.isEmpty) return;

    if (state.isLoading) {
      AppLogger.w('[AskDripNotifier] [sendMessage] Request already in flight, ignoring duplicate');
      return;
    }

    String? currentId = _resolvedConversationId ?? arg;
    final repository = ref.read(askDripRepositoryProvider);
    AppLogger.i('[AskDripNotifier] [sendMessage] Starting flow for prompt: $trimmedPrompt, currentId: $currentId');

    // 1. Optimistically add the user message and set to loading synchronously
    final userMessage = MessageModel(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: currentId ?? '',
      role: 'user',
      content: trimmedPrompt,
      createdAt: DateTime.now(),
    );

    final previousMessages = state.valueOrNull ?? [];
    state = AsyncValue.data([...previousMessages, userMessage]);
    state = const AsyncLoading<List<MessageModel>>().copyWithPrevious(state);
    AppLogger.d('[AskDripNotifier] [sendMessage] User message added optimistically and loading state set');

    try {
      // 2. If conversationId is null, automatically create a new conversation first
      if (currentId == null) {
        AppLogger.d('[AskDripNotifier] [sendMessage] Creating new conversation...');
        final convResult = await repository.createConversation(trimmedPrompt);
        switch (convResult) {
          case Success(data: final data):
            currentId = data.id;
            _resolvedConversationId = data.id;
            AppLogger.i('[AskDripNotifier] [sendMessage] New conversation: $currentId');
            // Refresh conversations list to include the new one
            ref.read(conversationsNotifierProvider.notifier).loadConversations();
          case Failure(message: final m, endpoint: final ep, statusCode: final sc, stackTrace: final st):
            final errorMsg = kDebugMode ? 'Failed to create chat: $m\nEndpoint: $ep\nCode: $sc' : 'Unable to start chat. Please try again.';
            AppLogger.e('[AskDripNotifier] [sendMessage] Chat creation failed: $m');
            state = AsyncError<List<MessageModel>>(errorMsg, st ?? StackTrace.current).copyWithPrevious(state);
            return;
        }
      }

      // 3. Call the repository's sendPrompt
      final userId = ref.read(authProvider).user?.id;
      if (userId == null) {
        AppLogger.w('[AskDripNotifier] [sendMessage] User ID missing');
        state = AsyncError<List<MessageModel>>('User not authenticated. Please log in.', StackTrace.current).copyWithPrevious(state);
        return;
      }

      AppLogger.d('[AskDripNotifier] [sendMessage] Calling AI engine...');
      final result = await repository.sendPrompt(
        userId: userId,
        prompt: trimmedPrompt,
        conversationId: currentId,
        mode: mode,
      );

      // 4. Replace/add the assistant response
      switch (result) {
        case Success(data: final data):
          AppLogger.i('[AskDripNotifier] [sendMessage] Received AI response: ${data.id}');
          state = AsyncValue.data([...state.valueOrNull ?? [], data]);
        case Failure(message: final m, endpoint: final ep, statusCode: final sc, stackTrace: final st):
          final errorMsg = kDebugMode 
              ? 'AI Error: $m\nEndpoint: $ep\nStatus: $sc' 
              : 'Dripzoid AI is unavailable. Please try again later.';
          AppLogger.e('[AskDripNotifier] [sendMessage] Pipeline failure: $m');
          state = AsyncError<List<MessageModel>>(errorMsg, st ?? StackTrace.current).copyWithPrevious(state);
      }
    } catch (e, stack) {
      AppLogger.f('[AskDripNotifier] [sendMessage] Critical crash', error: e, stackTrace: stack);
      state = AsyncError<List<MessageModel>>(kDebugMode ? 'Crash: ${e.toString()}' : 'Something went wrong.', stack).copyWithPrevious(state);
    }
  }
}

final askDripNotifierProvider =
    AsyncNotifierProviderFamily<AskDripNotifier, List<MessageModel>, String?>(
  AskDripNotifier.new,
);
