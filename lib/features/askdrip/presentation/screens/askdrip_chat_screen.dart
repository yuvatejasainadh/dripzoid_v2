import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/layout_utils.dart';
import '../providers/askdrip_notifier.dart';
import '../providers/conversations_notifier.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/ai_product_carousel.dart';
import '../widgets/typing_indicator_bubble.dart';
import '../../data/models/message_model.dart';

final activeConversationIdProvider = StateProvider<String?>((ref) => null);

class AskDripChatScreen extends ConsumerStatefulWidget {
  const AskDripChatScreen({super.key});

  @override
  ConsumerState<AskDripChatScreen> createState() => _AskDripChatScreenState();
}

class _AskDripChatScreenState extends ConsumerState<AskDripChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final activeId = ref.read(activeConversationIdProvider);
    final messagesAsync = ref.read(askDripNotifierProvider(activeId));
    
    if (messagesAsync.isLoading) return;

    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    
    await ref.read(askDripNotifierProvider(activeId).notifier).sendMessage(text);
    
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final activeId = ref.watch(activeConversationIdProvider);
    final messagesAsync = ref.watch(askDripNotifierProvider(activeId));
    final theme = Theme.of(context);

    // Auto-scroll when messages change or loading state changes
    ref.listen(askDripNotifierProvider(activeId), (previous, next) {
      if (next.hasValue || next.isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('AskDrip AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'New Chat',
            onPressed: () {
              ref.read(activeConversationIdProvider.notifier).state = null;
              ref.read(askDripNotifierProvider(null).notifier).resetFreshChat();
            },
          ),
        ],
      ),
      drawer: const _ConversationHistoryDrawer(),
      body: ResponsiveContainer(
        maxWidth: LayoutUtils.maxChatWidth,
        child: Column(
          children: [
            Expanded(
              child: _buildChatContent(messagesAsync),
            ),
            _buildInputArea(theme, messagesAsync.isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildChatContent(AsyncValue<List<MessageModel>> state) {
    if (state.isLoading && !state.hasValue) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError && !state.hasValue) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: ${state.error}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () {
                  final activeId = ref.read(activeConversationIdProvider);
                  ref.invalidate(askDripNotifierProvider(activeId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final messages = state.value ?? [];

    if (messages.isEmpty) {
      return _buildEmptyState();
    }

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length + (state.isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == messages.length) {
              return const TypingIndicatorBubble();
            }
            final msg = messages[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChatBubble(message: msg),
                if (msg.products.isNotEmpty)
                  AiProductCarousel(products: msg.products),
              ],
            );
          },
        ),
        if (state.hasError)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.red.withValues(alpha: 0.9),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.error.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 18),
                    onPressed: () {
                      final activeId = ref.read(activeConversationIdProvider);
                      ref.read(askDripNotifierProvider(activeId).notifier).clearError();
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          const Text(
            'Ask me anything about fashion!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Try: "What matches with a red hoodie?"',
            style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                enabled: !isLoading,
                decoration: InputDecoration(
                  hintText: isLoading ? 'AI is thinking...' : 'Type your message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onSubmitted: (_) => !isLoading ? _sendMessage() : null,
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
              onPressed: isLoading ? null : _sendMessage,
              backgroundColor: isLoading 
                  ? theme.colorScheme.surfaceContainerHighest 
                  : theme.colorScheme.primary,
              foregroundColor: isLoading 
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.3) 
                  : theme.colorScheme.onPrimary,
              elevation: 0,
              child: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationHistoryDrawer extends ConsumerWidget {
  const _ConversationHistoryDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(conversationsNotifierProvider);
    final activeId = ref.watch(activeConversationIdProvider);
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            child: Center(
              child: Text(
                'History',
                style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: historyAsync.when(
              data: (history) => history.isEmpty
                  ? const Center(child: Text('No previous chats'))
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final conv = history[index];
                        final isSelected = conv.id == activeId;
                        return ListTile(
                          selected: isSelected,
                          title: Text(conv.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                            DateFormat('MMM dd, yyyy').format(conv.updatedAt),
                            style: const TextStyle(fontSize: 12),
                          ),
                          leading: const Icon(Icons.chat_bubble_outline_rounded),
                          onTap: () {
                            ref.read(activeConversationIdProvider.notifier).state = conv.id;
                            Navigator.pop(context);
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 20),
                            onPressed: () {
                              ref.read(conversationsNotifierProvider.notifier).deleteConversation(conv.id);
                              if (isSelected) {
                                ref.read(activeConversationIdProvider.notifier).state = null;
                                ref.read(askDripNotifierProvider(null).notifier).resetFreshChat();
                              }
                            },
                          ),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
