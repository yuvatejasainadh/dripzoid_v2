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
  @override
  FutureOr<List<MessageModel>> build(String? arg) {
    if (arg == null) {
      AppLogger.d('[AskDripNotifier] No conversation ID, starting fresh');
      return [];
    }
    return loadMessages(arg);
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
    String? currentId = arg;
    final repository = ref.read(askDripRepositoryProvider);
    AppLogger.i('[AskDripNotifier] [sendMessage] Starting flow for prompt: $prompt');

    try {
      // 1. If conversationId is null, automatically create a new conversation first
      if (currentId == null) {
        AppLogger.d('[AskDripNotifier] [sendMessage] Creating new conversation...');
        final convResult = await repository.createConversation(prompt);
        switch (convResult) {
          case Success(data: final data):
            currentId = data.id;
            AppLogger.i('[AskDripNotifier] [sendMessage] New conversation: $currentId');
            // Refresh conversations list to include the new one
            ref.read(conversationsNotifierProvider.notifier).loadConversations();
          case Failure(message: final m, endpoint: final ep, statusCode: final sc):
            final errorMsg = kDebugMode ? 'Failed to create chat: $m\nEndpoint: $ep\nCode: $sc' : 'Unable to start chat. Please try again.';
            AppLogger.e('[AskDripNotifier] [sendMessage] Chat creation failed: $m');
            state = AsyncValue.error(errorMsg, StackTrace.current);
            return;
        }
      }

      // 2. Optimistically add the user message to the list
      final userMessage = MessageModel(
        id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
        conversationId: currentId,
        role: 'user',
        content: prompt,
        createdAt: DateTime.now(),
      );

      final previousMessages = state.valueOrNull ?? [];
      state = AsyncValue.data([...previousMessages, userMessage]);
      AppLogger.d('[AskDripNotifier] [sendMessage] User message added optimistically');

      // Set to loading while keeping the data (including the new user message)
      state = const AsyncLoading<List<MessageModel>>().copyWithPrevious(state);

      // 3. Call the repository's sendPrompt
      final userId = ref.read(authProvider).user?.id;
      if (userId == null) {
        AppLogger.w('[AskDripNotifier] [sendMessage] User ID missing');
        state = AsyncValue.error('User not authenticated. Please log in.', StackTrace.current);
        return;
      }

      AppLogger.d('[AskDripNotifier] [sendMessage] Calling AI engine...');
      final result = await repository.sendPrompt(
        userId: userId,
        prompt: prompt,
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
          state = AsyncValue.error(errorMsg, st ?? StackTrace.current);
      }
    } catch (e, stack) {
      AppLogger.f('[AskDripNotifier] [sendMessage] Critical crash', error: e, stackTrace: stack);
      state = AsyncValue.error(kDebugMode ? 'Crash: ${e.toString()}' : 'Something went wrong.', stack);
    }
  }
}

final askDripNotifierProvider =
    AsyncNotifierProviderFamily<AskDripNotifier, List<MessageModel>, String?>(
  AskDripNotifier.new,
);
