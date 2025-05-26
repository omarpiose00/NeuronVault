// 💬 NEURONVAULT - CHAT CONTROLLER
// Enterprise-grade chat management with AI orchestration
// Part of PHASE 2.5 - QUANTUM STATE MANAGEMENT

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../state/state_models.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart';
import '../providers/providers_main.dart';

// 💬 CHAT CONTROLLER
class ChatController extends Notifier<ChatState> {
  late final AIService _aiService;
  late final StorageService _storageService;
  late final AnalyticsService _analyticsService;
  late final Logger _logger;

  final Uuid _uuid = const Uuid();
  StreamSubscription<String>? _currentStreamSubscription;

  @override
  ChatState build() {
    // Initialize services
    _aiService = ref.read(aiServiceProvider);
    _storageService = ref.read(storageServiceProvider);
    _analyticsService = ref.read(analyticsServiceProvider);
    _logger = ref.read(loggerProvider);

    // Load chat history
    _loadChatHistory();

    return const ChatState();
  }

  // 🔄 LOAD CHAT HISTORY
  Future<void> _loadChatHistory() async {
    try {
      _logger.d('🔄 Loading chat history...');

      final messages = await _storageService.getChatHistory();

      state = state.copyWith(
        messages: messages,
        messageCount: messages.length,
        lastMessageTime: messages.isNotEmpty ? messages.last.timestamp : null,
      );

      _logger.i('✅ Chat history loaded: ${messages.length} messages');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to load chat history', error: e, stackTrace: stackTrace);
    }
  }

  // 📝 UPDATE CURRENT INPUT
  void updateCurrentInput(String input) {
    if (state.currentInput == input) return;

    state = state.copyWith(currentInput: input);

    // Start typing indicator
    if (!state.isTyping && input.isNotEmpty) {
      _setTypingState(true);
    } else if (state.isTyping && input.isEmpty) {
      _setTypingState(false);
    }
  }

  // ⌨️ SET TYPING STATE
  void _setTypingState(bool isTyping) {
    state = state.copyWith(isTyping: isTyping);

    if (isTyping) {
      _analyticsService.trackEvent('chat_typing_started');
    }
  }

  // 📤 SEND MESSAGE
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || state.isGenerating) return;

    try {
      final requestId = _uuid.v4();

      // Create user message
      final userMessage = ChatMessage(
        id: _uuid.v4(),
        content: content.trim(),
        type: MessageType.user,
        timestamp: DateTime.now(),
        requestId: requestId,
      );

      // Add user message to state
      final updatedMessages = [...state.messages, userMessage];
      state = state.copyWith(
        messages: updatedMessages,
        currentInput: '',
        isTyping: false,
        isGenerating: true,
        activeRequestId: requestId,
        messageCount: updatedMessages.length,
        lastMessageTime: userMessage.timestamp,
      );

      // Save user message
      await _storageService.saveMessage(userMessage);

      // Track analytics
      _analyticsService.trackChatEvent('message_sent', data: {
        'length': content.length,
        'request_id': requestId,
      });

      // Generate AI response
      await _generateAIResponse(content, requestId);

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to send message', error: e, stackTrace: stackTrace);
      _handleError('Failed to send message: ${e.toString()}');
    }
  }

  // 🤖 GENERATE AI RESPONSE
  Future<void> _generateAIResponse(String prompt, String requestId) async {
    try {
      _logger.d('🤖 Generating AI response for request: $requestId');

      // Create streaming response
      final responseStream = _aiService.streamResponse(prompt, requestId);

      // Create initial assistant message
      final assistantMessage = ChatMessage(
        id: _uuid.v4(),
        content: '',
        type: MessageType.assistant,
        timestamp: DateTime.now(),
        requestId: requestId,
      );

      // Add initial message to state
      final updatedMessages = [...state.messages, assistantMessage];
      state = state.copyWith(messages: updatedMessages);

      // Listen to stream
      _currentStreamSubscription = responseStream.listen(
            (chunk) => _handleStreamChunk(assistantMessage.id, chunk),
        onError: (error) => _handleStreamError(error),
        onDone: () => _handleStreamComplete(requestId),
      );

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to generate AI response', error: e, stackTrace: stackTrace);
      _handleError('Failed to generate response: ${e.toString()}');
    }
  }

  // 📝 HANDLE STREAM CHUNK
  void _handleStreamChunk(String messageId, String chunk) {
    try {
      final messageIndex = state.messages.indexWhere((msg) => msg.id == messageId);
      if (messageIndex == -1) return;

      final currentMessage = state.messages[messageIndex];
      final updatedMessage = currentMessage.copyWith(
        content: currentMessage.content + chunk,
      );

      final updatedMessages = [...state.messages];
      updatedMessages[messageIndex] = updatedMessage;

      state = state.copyWith(messages: updatedMessages);

    } catch (e) {
      _logger.w('⚠️ Failed to handle stream chunk: $e');
    }
  }

  // ❌ HANDLE STREAM ERROR
  void _handleStreamError(dynamic error) {
    _logger.e('❌ Stream error: $error');

    state = state.copyWith(
      isGenerating: false,
      activeRequestId: null,
    );

    _handleError('AI response error: ${error.toString()}');
  }

  // ✅ HANDLE STREAM COMPLETE
  void _handleStreamComplete(String requestId) async {
    try {
      _logger.d('✅ Stream completed for request: $requestId');

      state = state.copyWith(
        isGenerating: false,
        activeRequestId: null,
      );

      // Find and save the completed message
      final completedMessage = state.messages
          .where((msg) => msg.requestId == requestId && msg.type == MessageType.assistant)
          .lastOrNull;

      if (completedMessage != null) {
        await _storageService.saveMessage(completedMessage);

        _analyticsService.trackChatEvent('response_completed', data: {
          'request_id': requestId,
          'response_length': completedMessage.content.length,
        });
      }

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to handle stream completion', error: e, stackTrace: stackTrace);
    }
  }

  // ⏹️ STOP GENERATION
  Future<void> stopGeneration() async {
    if (!state.isGenerating || state.activeRequestId == null) return;

    try {
      _logger.d('⏹️ Stopping generation...');

      await _aiService.stopGeneration(state.activeRequestId!);
      await _currentStreamSubscription?.cancel();

      state = state.copyWith(
        isGenerating: false,
        activeRequestId: null,
      );

      _analyticsService.trackChatEvent('generation_stopped');

      _logger.i('⏹️ Generation stopped');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to stop generation', error: e, stackTrace: stackTrace);
    }
  }

  // ❌ HANDLE ERROR
  void _handleError(String errorMessage) {
    final errorId = _uuid.v4();

    final errorMsg = ChatMessage(
      id: errorId,
      content: errorMessage,
      type: MessageType.error,
      timestamp: DateTime.now(),
      isError: true,
    );

    final updatedMessages = [...state.messages, errorMsg];
    state = state.copyWith(
      messages: updatedMessages,
      isGenerating: false,
      activeRequestId: null,
      messageCount: updatedMessages.length,
    );

    _analyticsService.trackError('chat_error', description: errorMessage);
  }

  // 🗑️ DELETE MESSAGE
  Future<void> deleteMessage(String messageId) async {
    try {
      _logger.d('🗑️ Deleting message: $messageId');

      final updatedMessages = state.messages.where((msg) => msg.id != messageId).toList();

      state = state.copyWith(
        messages: updatedMessages,
        messageCount: updatedMessages.length,
      );

      await _storageService.deleteMessage(messageId);

      _analyticsService.trackChatEvent('message_deleted', data: {
        'message_id': messageId,
      });

      _logger.i('✅ Message deleted');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to delete message', error: e, stackTrace: stackTrace);
    }
  }

  // 🧹 CLEAR CHAT HISTORY
  Future<void> clearChatHistory() async {
    try {
      _logger.i('🧹 Clearing chat history...');

      // Stop any ongoing generation
      if (state.isGenerating) {
        await stopGeneration();
      }

      state = const ChatState();

      await _storageService.clearChatHistory();

      _analyticsService.trackChatEvent('chat_history_cleared', data: {
        'message_count': state.messageCount,
      });

      _logger.i('✅ Chat history cleared');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to clear chat history', error: e, stackTrace: stackTrace);
    }
  }

  // 📤 EXPORT CHAT
  Future<String> exportChat() async {
    try {
      _logger.d('📤 Exporting chat...');

      final exportPath = await _storageService.exportChatHistory();

      _analyticsService.trackChatEvent('chat_exported', data: {
        'message_count': state.messageCount,
        'export_path': exportPath,
      });

      _logger.i('✅ Chat exported to: $exportPath');
      return exportPath;

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to export chat', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // 🔍 SEARCH MESSAGES
  Future<List<ChatMessage>> searchMessages(String query) async {
    try {
      _logger.d('🔍 Searching messages for: "$query"');

      final results = await _storageService.searchMessages(query);

      _analyticsService.trackChatEvent('messages_searched', data: {
        'query': query,
        'results_count': results.length,
      });

      return results;

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to search messages', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // 📊 GET CHAT STATISTICS
  Map<String, dynamic> getChatStatistics() {
    return {
      'total_messages': state.messageCount,
      'user_messages': state.userMessageCount,
      'assistant_messages': state.assistantMessageCount,
      'has_messages': state.hasMessages,
      'is_generating': state.isGenerating,
      'is_typing': state.isTyping,
      'current_input_length': state.currentInput.length,
      'can_send_message': state.canSendMessage,
      'last_message_time': state.lastMessageTime?.toIso8601String(),
    };
  }

  // 🧹 DISPOSE
  void dispose() {
    _currentStreamSubscription?.cancel();
  }
}

// 💬 CHAT CONTROLLER PROVIDER
final chatControllerProvider = NotifierProvider<ChatController, ChatState>(
      () => ChatController(),
);

// 📊 COMPUTED PROVIDERS
final chatMessagesProvider = Provider<List<ChatMessage>>((ref) {
  return ref.watch(chatControllerProvider).messages;
});

final currentInputProvider = Provider<String>((ref) {
  return ref.watch(chatControllerProvider).currentInput;
});

final isGeneratingProvider = Provider<bool>((ref) {
  return ref.watch(chatControllerProvider).isGenerating;
});

final isTypingProvider = Provider<bool>((ref) {
  return ref.watch(chatControllerProvider).isTyping;
});

final canSendMessageProvider = Provider<bool>((ref) {
  return ref.watch(chatControllerProvider).canSendMessage;
});

final messageCountProvider = Provider<int>((ref) {
  return ref.watch(chatControllerProvider).messageCount;
});

final lastMessageTimeProvider = Provider<DateTime?>((ref) {
  return ref.watch(chatControllerProvider).lastMessageTime;
});

final userMessageCountProvider = Provider<int>((ref) {
  return ref.watch(chatControllerProvider).userMessageCount;
});

final assistantMessageCountProvider = Provider<int>((ref) {
  return ref.watch(chatControllerProvider).assistantMessageCount;
});

final chatStatisticsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.read(chatControllerProvider.notifier).getChatStatistics();
});