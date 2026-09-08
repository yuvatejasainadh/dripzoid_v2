import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/models/result.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/askdrip_service.dart';

class AskDripRepository {
  final AskDripService _service;

  AskDripRepository(this._service);

  Future<Result<List<ConversationModel>>> getConversations() async {
    AppLogger.d('[AskDripRepository] [getConversations] Fetching history...');
    final result = await _service.getConversations();
    return switch (result) {
      Success(data: final data) => () {
          final list = ((data is Map ? data['conversations'] : data) as List)
              .map((e) => ConversationModel.fromJson(e))
              .toList();
          AppLogger.d('[AskDripRepository] [getConversations] Found ${list.length} chats');
          return Success(list);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e, stackTrace: final st, endpoint: final ep) => () {
          AppLogger.e('[AskDripRepository] [getConversations] Failed: $m', error: e, stackTrace: st);
          return Failure<List<ConversationModel>>(m, statusCode: s, exception: e, stackTrace: st, endpoint: ep);
        }(),
    };
  }

  Future<Result<List<MessageModel>>> getMessages(String conversationId) async {
    AppLogger.d('[AskDripRepository] [getMessages] ID: $conversationId');
    final result = await _service.getMessages(conversationId);
    return switch (result) {
      Success(data: final data) => () {
          final list = ((data is Map ? data['messages'] : data) as List)
              .map((e) => MessageModel.fromJson(e))
              .toList();
          AppLogger.d('[AskDripRepository] [getMessages] Loaded ${list.length} messages');
          return Success(list);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e, stackTrace: final st, endpoint: final ep) => () {
          AppLogger.e('[AskDripRepository] [getMessages] Failed: $m', error: e, stackTrace: st);
          return Failure<List<MessageModel>>(m, statusCode: s, exception: e, stackTrace: st, endpoint: ep);
        }(),
    };
  }

  Future<Result<ConversationModel>> createConversation(String title) async {
    AppLogger.i('[AskDripRepository] [createConversation] Title: $title');
    final result = await _service.createConversation(title);
    return switch (result) {
      Success(data: final data) => () {
          final conv = ConversationModel.fromJson(data is Map ? (data['conversation'] ?? data) : data);
          AppLogger.i('[AskDripRepository] [createConversation] Created ID: ${conv.id}');
          return Success(conv);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e, stackTrace: final st, endpoint: final ep) => () {
          AppLogger.e('[AskDripRepository] [createConversation] Failed: $m', error: e, stackTrace: st);
          return Failure<ConversationModel>(m, statusCode: s, exception: e, stackTrace: st, endpoint: ep);
        }(),
    };
  }

  Future<Result<void>> deleteConversation(String id) async {
    AppLogger.w('[AskDripRepository] [deleteConversation] Deleting ID: $id');
    final result = await _service.deleteConversation(id);
    return switch (result) {
      Success() => () {
          AppLogger.i('[AskDripRepository] [deleteConversation] Deleted successfully');
          return const Success(null);
        }(),
      Failure(message: final m, statusCode: final s, exception: final e, stackTrace: final st, endpoint: final ep) => () {
          AppLogger.e('[AskDripRepository] [deleteConversation] Failed: $m', error: e, stackTrace: st);
          return Failure<void>(m, statusCode: s, exception: e, stackTrace: st, endpoint: ep);
        }(),
    };
  }

  Future<Result<MessageModel>> sendPrompt({
    required String userId,
    required String prompt,
    String? conversationId,
    required String mode,
  }) async {
    AppLogger.i('[AskDripRepository] [sendPrompt] Mode: $mode, ID: $conversationId');
    final result = await _service.sendPrompt(
      userId: userId,
      prompt: prompt,
      conversationId: conversationId,
      mode: mode,
    );
    return switch (result) {
      Success(data: final data) => () {
          try {
            AppLogger.d('[AskDripRepository] [sendPrompt] RAW DATA: $data');
            
            // Handle nested structure from success_response
            Map<String, dynamic>? messageData;
            
            if (data is Map) {
              final nestedData = data['data'];
              if (nestedData is Map) {
                // Try to find DB message, fallback to the data object itself (which has 'response')
                messageData = nestedData['message'] ?? nestedData;
              } else {
                messageData = data['message'];
              }
            }

            if (messageData == null || (messageData['content'] == null && messageData['response'] == null)) {
              AppLogger.e('[AskDripRepository] [sendPrompt] Invalid message format. Missing content/response in: $data');
              return Failure<MessageModel>(
                'AI response missing valid message content',
                statusCode: 400,
                endpoint: '/api/v1/$mode',
              );
            }
            
            // Self-Healing Mapping:
            // If backend didn't return the structured DB message, synthesize one
            final Map<String, dynamic> rawMsg = Map<String, dynamic>.from(messageData);
            
            final processedMsg = {
              'id': rawMsg['id'] ?? 'temp-assistant-${DateTime.now().millisecondsSinceEpoch}',
              'conversationId': rawMsg['conversationId'] ?? conversationId ?? '',
              'role': rawMsg['role'] ?? 'assistant',
              'content': rawMsg['content'] ?? rawMsg['response'] ?? '',
              'products': rawMsg['products'] ?? [],
              'createdAt': rawMsg['createdAt'] ?? DateTime.now().toIso8601String(),
            };
            
            final model = MessageModel.fromJson(processedMsg);
            AppLogger.i('[AskDripRepository] [sendPrompt] Success: ${model.id}');
            return Success<MessageModel>(model);
          } catch (e, stack) {
            AppLogger.f('[AskDripRepository] [sendPrompt] Parse error', error: e, stackTrace: stack);
            return Failure<MessageModel>(
              'Failed to parse AI message: ${e.toString()}',
              statusCode: 400,
              endpoint: '/api/v1/$mode',
              stackTrace: stack,
            );
          }
        }(),
            Failure(message: final m, statusCode: final s, exception: final e, stackTrace: final st, endpoint: final ep) =>
              Failure<MessageModel>(m, statusCode: s, exception: e, stackTrace: st, endpoint: ep),
    };
  }
}

final askDripRepositoryProvider = Provider<AskDripRepository>((ref) {
  final service = ref.watch(askDripServiceProvider);
  return AskDripRepository(service);
});
