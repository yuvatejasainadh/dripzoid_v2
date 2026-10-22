import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dripzoid_v2/core/models/result.dart';
import 'package:dripzoid_v2/features/askdrip/data/models/conversation_model.dart';
import 'package:dripzoid_v2/features/askdrip/data/models/message_model.dart';
import 'package:dripzoid_v2/features/askdrip/data/repositories/askdrip_repository.dart';
import 'package:dripzoid_v2/features/askdrip/presentation/providers/askdrip_notifier.dart';
import 'package:dripzoid_v2/features/askdrip/presentation/screens/askdrip_chat_screen.dart';
import 'package:dripzoid_v2/features/auth/data/models/user_model.dart';
import 'package:dripzoid_v2/features/auth/presentation/providers/auth_provider.dart';

class FakeAskDripRepository implements AskDripRepository {
  int createConversationCalls = 0;
  int sendPromptCalls = 0;
  int getMessagesCalls = 0;
  int getConversationsCalls = 0;

  List<String?> sentConversationIds = [];
  Duration? sendDelay;
  Result<MessageModel>? mockSendPromptResult;
  Result<ConversationModel>? mockCreateResult;

  @override
  Future<Result<List<ConversationModel>>> getConversations() async {
    getConversationsCalls++;
    return const Success<List<ConversationModel>>([]);
  }

  @override
  Future<Result<List<MessageModel>>> getMessages(String conversationId) async {
    getMessagesCalls++;
    return const Success<List<MessageModel>>([]);
  }

  @override
  Future<Result<ConversationModel>> createConversation(String title) async {
    createConversationCalls++;
    return mockCreateResult ??
        Success(ConversationModel(
          id: 'conv-$createConversationCalls',
          title: title,
          updatedAt: DateTime.now(),
        ));
  }

  @override
  Future<Result<void>> deleteConversation(String id) async {
    return const Success(null);
  }

  @override
  Future<Result<MessageModel>> sendPrompt({
    required String userId,
    required String prompt,
    String? conversationId,
    required String mode,
  }) async {
    sendPromptCalls++;
    sentConversationIds.add(conversationId);

    if (sendDelay != null) {
      await Future.delayed(sendDelay!);
    }

    if (mockSendPromptResult != null) {
      return mockSendPromptResult!;
    }

    return Success(MessageModel(
      id: 'ai-msg-$sendPromptCalls',
      conversationId: conversationId ?? 'unknown',
      role: 'assistant',
      content: 'AI Response to: $prompt',
      createdAt: DateTime.now(),
    ));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AskDrip Conversation Continuity & Deduplication (Workstream A)', () {
    late FakeAskDripRepository fakeRepository;
    late ProviderContainer container;

    setUp(() {
      fakeRepository = FakeAskDripRepository();
      container = ProviderContainer(
        overrides: [
          askDripRepositoryProvider.overrideWithValue(fakeRepository),
          authProvider.overrideWith(() => FakeAuthNotifier()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Fresh chat starts empty when conversationId is null', () {
      final initialMessages = container.read(askDripNotifierProvider(null));
      expect(initialMessages.value, isEmpty);
      expect(initialMessages.isLoading, false);
      expect(initialMessages.hasError, false);
    });

    test('Multiple messages in fresh chat reuse resolved conversation ID without creating duplicate conversations', () async {
      final notifier = container.read(askDripNotifierProvider(null).notifier);

      // Message 1: Triggers conversation creation and initial prompt
      await notifier.sendMessage('Hello, can you help me style an outfit?');

      expect(fakeRepository.createConversationCalls, 1);
      expect(fakeRepository.sendPromptCalls, 1);
      expect(fakeRepository.sentConversationIds.last, 'conv-1');
      expect(notifier.conversationId, 'conv-1');

      var messages = container.read(askDripNotifierProvider(null)).value ?? [];
      expect(messages.length, 2);
      expect(messages[0].role, 'user');
      expect(messages[0].content, 'Hello, can you help me style an outfit?');
      expect(messages[1].role, 'assistant');
      expect(messages[1].content, 'AI Response to: Hello, can you help me style an outfit?');

      // Message 2: MUST continue the existing conversation and NOT create a new one!
      await notifier.sendMessage('I need something vintage.');

      expect(fakeRepository.createConversationCalls, 1,
          reason: 'createConversation must NOT be called again for subsequent messages in the same chat');
      expect(fakeRepository.sendPromptCalls, 2);
      expect(fakeRepository.sentConversationIds.last, 'conv-1',
          reason: 'Subsequent message must use the previously resolved conversation ID');
      expect(notifier.conversationId, 'conv-1');

      messages = container.read(askDripNotifierProvider(null)).value ?? [];
      expect(messages.length, 4);
      expect(messages[2].role, 'user');
      expect(messages[2].content, 'I need something vintage.');
      expect(messages[3].role, 'assistant');

      // Message 3: Continues existing conversation
      await notifier.sendMessage('What color sneakers work best?');

      expect(fakeRepository.createConversationCalls, 1);
      expect(fakeRepository.sendPromptCalls, 3);
      expect(fakeRepository.sentConversationIds.last, 'conv-1');
      expect(container.read(askDripNotifierProvider(null)).value?.length, 6);
    });

    test('Concurrent message requests in flight are discarded by the loading guard', () async {
      fakeRepository.sendDelay = const Duration(milliseconds: 60);

      final notifier = container.read(askDripNotifierProvider(null).notifier);

      // Launch first message (which stays in flight for 60ms)
      final future1 = notifier.sendMessage('First prompt');
      // Fire second message immediately while first is in-flight
      final future2 = notifier.sendMessage('Duplicate prompt while loading');

      await Future.wait([future1, future2]);

      // Only the first message should have been processed
      expect(fakeRepository.sendPromptCalls, 1);
      expect(fakeRepository.createConversationCalls, 1);
    });

    test('Network/AI errors do not destroy previous chat history (copyWithPrevious)', () async {
      final notifier = container.read(askDripNotifierProvider(null).notifier);

      // First message succeeds
      await notifier.sendMessage('Valid message');
      expect(container.read(askDripNotifierProvider(null)).value?.length, 2);

      // Second message encounters a backend AI error
      fakeRepository.mockSendPromptResult = const Failure(
        'Inference service timeout',
        statusCode: 504,
        endpoint: '/api/v1/chat',
      );

      await notifier.sendMessage('Failing message');

      final state = container.read(askDripNotifierProvider(null));
      expect(state.hasError, true);
      expect(state.hasValue, true,
          reason: 'state.hasValue must remain true so chat bubbles do not vanish on error');
      // Messages contain valid user1, ai1, and optimistic user2
      expect(state.value?.length, 3);
      expect(state.value?.last.content, 'Failing message');

      // Dismiss error banner using clearError
      notifier.clearError();
      final clearedState = container.read(askDripNotifierProvider(null));
      expect(clearedState.hasError, false);
      expect(clearedState.value?.length, 3);
    });

    test('resetFreshChat cleanly resets conversation id and message list for next chat', () async {
      final notifier = container.read(askDripNotifierProvider(null).notifier);

      await notifier.sendMessage('Conversation 1 initial message');
      expect(fakeRepository.createConversationCalls, 1);
      expect(notifier.conversationId, 'conv-1');
      expect(container.read(askDripNotifierProvider(null)).value?.length, 2);

      // User presses "New Chat"
      notifier.resetFreshChat();

      expect(notifier.conversationId, isNull);
      expect(container.read(askDripNotifierProvider(null)).value, isEmpty);

      // Next message starts a new conversation
      await notifier.sendMessage('Conversation 2 initial message');
      expect(fakeRepository.createConversationCalls, 2);
      expect(notifier.conversationId, 'conv-2');
      expect(fakeRepository.sentConversationIds.last, 'conv-2');
    });

    test('activeConversationIdProvider integration with New Chat reset', () {
      container.read(activeConversationIdProvider.notifier).state = 'conv-existing';
      expect(container.read(activeConversationIdProvider), 'conv-existing');

      // Trigger New Chat logic
      container.read(activeConversationIdProvider.notifier).state = null;
      container.read(askDripNotifierProvider(null).notifier).resetFreshChat();

      expect(container.read(activeConversationIdProvider), isNull);
      expect(container.read(askDripNotifierProvider(null)).value, isEmpty);
      expect(container.read(askDripNotifierProvider(null).notifier).conversationId, isNull);
    });
  });
}

class FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() {
    return const AuthState(
      status: AuthStatus.authenticated,
      user: UserModel(
        id: 'user-unit-1',
        name: 'Unit Tester',
        email: 'tester@dripzoid.com',
      ),
    );
  }
}
