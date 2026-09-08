import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/models/result.dart';

class AskDripService {
  final ApiClient _mainClient;
  final ApiClient _aiClient;

  AskDripService(this._mainClient, this._aiClient);

  Future<Result<dynamic>> getConversations() async {
    AppLogger.d('[AskDripService] [getConversations] Fetching...');
    return await _mainClient.get('/api/v1/askdrip/conversations');
  }

  Future<Result<dynamic>> getMessages(String conversationId) async {
    AppLogger.d('[AskDripService] [getMessages] ID: $conversationId');
    return await _mainClient.get('/api/v1/askdrip/conversations/$conversationId/messages');
  }

  Future<Result<dynamic>> createConversation(String title) async {
    AppLogger.i('[AskDripService] [createConversation] Title: $title');
    return await _mainClient.post(
      '/api/v1/askdrip/conversations',
      data: {'title': title},
    );
  }

  Future<Result<dynamic>> deleteConversation(String id) async {
    AppLogger.w('[AskDripService] [deleteConversation] ID: $id');
    return await _mainClient.delete('/api/v1/askdrip/conversations/$id');
  }

  Future<Result<dynamic>> sendPrompt({
    required String userId,
    required String prompt,
    String? conversationId,
    required String mode,
  }) async {
    AppLogger.i(
      '[AskDripService] [sendPrompt] \n'
      'User: $userId\n'
      'Mode: $mode\n'
      'ConvID: $conversationId\n'
      'Prompt: $prompt',
    );

    final result = await _aiClient.post(
      '/api/v1/$mode',
      data: {
        'userId': userId,
        'prompt': prompt,
        'conversationId':? conversationId,
      },
    );

    if (result is Success) {
      AppLogger.d('[AskDripService] [sendPrompt] Success: ${result.data}');
    } else {
      final f = result as Failure;
      AppLogger.e(
        '[AskDripService] [sendPrompt] Error: ${f.message}\n'
        'Endpoint: ${f.endpoint}\n'
        'Status: ${f.statusCode}',
        error: f.exception,
        stackTrace: f.stackTrace,
      );
    }

    return result;
  }
}

final askDripServiceProvider = Provider<AskDripService>((ref) {
  final mainClient = ref.watch(apiClientProvider);
  final aiClient = ref.watch(aiApiClientProvider);
  return AskDripService(mainClient, aiClient);
});
