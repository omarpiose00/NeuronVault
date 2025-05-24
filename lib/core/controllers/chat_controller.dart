// 💬 NEURONVAULT - REAL-TIME CHAT CONTROLLER
// Enterprise-grade chat state management with real-time messaging
// Part of PHASE 2.5 - QUANTUM STATE MANAGEMENT

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../state/state_models.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart';

// 💬 CHAT CONTROLLER PROVIDER
final chatControllerProvider = 
    StateNotifierProvider<ChatController, ChatState>((ref) {
  return ChatController(
    aiService: ref.watch(aiServiceProvider),
    storageService: ref.watch(storageServiceProvider),
    analyticsService: ref.watch(analyticsServiceProvider),
    logger: ref.watch(loggerProvider),
  );
});

// 🧠 REAL-TIME CHAT STATE CONTROLLER
class ChatController extends StateNotifier<ChatState> {
  final AIService _aiService;
  final StorageService _storageService;
  final AnalyticsService _analyticsService;
  final Logger _logger;
  final Uuid _uuid = const Uuid();

  StreamSubscription<String>? _streamSubscription;
  Timer? _typingTimer;
  static const Duration _typingTimeout = Duration(seconds: 2);

  ChatController({
    required AIService aiService,
    required StorageService storageService,
    required AnalyticsService analyticsService,
    required Logger logger,
  }) : _aiService = aiService,
       _storageService = storageService,
       _analyticsService = analyticsService,
       _logger = logger,
       super(const ChatState()) {
    _initializeChat();
  }

  // 🚀 INITIALIZATION
  Future<void> _initializeChat() async {
    try {
      _logger.i('💬 Initializing Chat Controller...');
      
      // Load chat history
      final savedMessages = await _storageService.getChatHistory();
      if (savedMessages.isNotEmpty) {
        state = state.copyWith(
          messages: savedMessages,
          messageCount: savedMessages.length,
          lastMessageTime: savedMessages.last.timestamp,
        );
        _logger.i('✅ Loaded ${savedMessages.length} messages from history');
      }
      
      _analyticsService.trackEvent('chat_initialized', {
        'message_count': state.messageCount,
        'has_history': savedMessages.isNotEmpty,
      });
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to initialize chat', error: e, stackTrace: stackTrace);
    }
  }

  // ✍️ INPUT MANAGEMENT
  void updateInput(String input) {
    if (input == state.currentInput) return;
    
    state = state.copyWith(currentInput: input);
    
    // Handle typing indicator
    _handleTypingIndicator();
    
    _logger.d('✍️ Input updated: ${input.length} chars');
  }

  void clearInput() {
    state = state.copyWith(currentInput: '');
    _stopTypingIndicator();
    _logger.d('🗑️ Input cleared');
  }

  // 📨 MESSAGE SENDING
  Future<void> sendMessage() async {
    if (!state.canSendMessage) {
      _logger.w('⚠️ Cannot send message: ${state.isGenerating ? "generating" : "empty input"}');
      return;
    }

    final messageContent = state.currentInput.trim();
    final requestId = _uuid.v4();
    
    try {
      _logger.i('📨 Sending message: ${messageContent.length} chars');
      
      // Create user message
      final userMessage = ChatMessage(
        id: _uuid.v4(),
        content: messageContent,
        type: MessageType.user,
        timestamp: DateTime.now(),
        requestId: requestId,
      );
      
      // Update state
      state = state.copyWith(
        messages: [...state.messages, userMessage],
        currentInput: '',
        isGenerating: true,
        activeRequestId: requestId,
        messageCount: state.messageCount + 1,
        lastMessageTime: DateTime.now(),
      );
      
      // Save message immediately
      await _storageService.saveMessage(userMessage);
      
      // Process AI response
      await _processAIResponse(messageContent, requestId);
      
      _analyticsService.trackEvent('message_sent', {
        'message_length': messageContent.length,
        'request_id': requestId,
        'total_messages': state.messageCount,
      });
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to send message', error: e, stackTrace: stackTrace);
      await _handleMessageError(e.toString(), requestId);
    }
  }

  // 🤖 AI RESPONSE PROCESSING
  Future<void> _processAIResponse(String userMessage, String requestId) async {
    try {
      _logger.d('🤖 Processing AI response for request: $requestId');
      
      // Start streaming response
      final responseStream = _aiService.streamResponse(userMessage, requestId);
      
      // Create initial assistant message
      final assistantMessage = ChatMessage(
        id: _uuid.v4(),
        content: '',
        type: MessageType.assistant,
        timestamp: DateTime.now(),
        requestId: requestId,
      );
      
      // Add to messages list
      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        messageCount: state.messageCount + 1,
      );
      
      // Listen to stream
      _streamSubscription?.cancel();
      _streamSubscription = responseStream.listen(
        _onStreamData,
        onError: (error) => _onStreamError(error, requestId),
        onDone: () => _onStreamComplete(requestId),
      );
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to process AI response', error: e, stackTrace: stackTrace);
      await _handleMessageError(e.toString(), requestId);
    }
  }

  void _onStreamData(String chunk) {
    if (state.activeRequestId == null) return;
    
    try {
      // Find the assistant message for this request
      final messages = List<ChatMessage>.from(state.messages);
      final messageIndex = messages.lastIndexWhere(
        (msg) => msg.requestId == state.activeRequestId && 
                msg.type == MessageType.assistant
      );
      
      if (messageIndex == -1) return;
      
      // Update message content
      final currentMessage = messages[messageIndex];
      final updatedMessage = currentMessage.copyWith(
        content: currentMessage.content + chunk,
        timestamp: DateTime.now(),
      );
      
      messages[messageIndex] = updatedMessage;
      
      state = state.copyWith(
        messages: messages,
        lastMessageTime: DateTime.now(),
      );
      
      _logger.d('📡 Stream chunk received: ${chunk.length} chars');
      
    } catch (e) {
      _logger.e('❌ Failed to process stream chunk: $e');
    }
  }

  void _onStreamError(dynamic error, String requestId) {
    _logger.e('❌ Stream error for request $requestId: $error');
    _handleMessageError(error.toString(), requestId);
  }

  void _onStreamComplete(String requestId) {
    _logger.i('✅ Stream completed for request: $requestId');
    
    state = state.copyWith(
      isGenerating: false,
      activeRequestId: null,
    );
    
    // Save the completed message
    _saveCompletedMessage(requestId);
    
    _analyticsService.trackEvent('ai_response_completed', {
      'request_id': requestId,
      'response_time': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // 💾 MESSAGE PERSISTENCE
  Future<void> _saveCompletedMessage(String requestId) async {
    try {
      final message = state.messages.lastWhere(
        (msg) => msg.requestId == requestId && msg.type == MessageType.assistant
      );
      
      await _storageService.saveMessage(message);
      _logger.d('💾 Message saved: ${message.id}');
      
    } catch (e) {
      _logger.w('⚠️ Failed to save completed message: $e');
    }
  }

  // ⚠️ ERROR HANDLING
  Future<void> _handleMessageError(String error, String requestId) async {
    _logger.e('⚠️ Handling message error: $error');
    
    final errorMessage = ChatMessage(
      id: _uuid.v4(),
      content: 'Error: $error',
      type: MessageType.error,
      timestamp: DateTime.now(),
      requestId: requestId,
      isError: true,
      metadata: {'error_type': 'ai_response_error'},
    );
    
    state = state.copyWith(
      messages: [...state.messages, errorMessage],
      isGenerating: false,
      activeRequestId: null,
      messageCount: state.messageCount + 1,
    );
    
    await _storageService.saveMessage(errorMessage);
    
    _analyticsService.trackEvent('message_error', {
      'error': error,
      'request_id': requestId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ⌨️ TYPING INDICATORS
  void _handleTypingIndicator() {
    if (!state.isTyping) {
      state = state.copyWith(isTyping: true);
      _logger.d('⌨️ Started typing');
    }
    
    _typingTimer?.cancel();
    _typingTimer = Timer(_typingTimeout, () {
      _stopTypingIndicator();
    });
  }

  void _stopTypingIndicator() {
    if (state.isTyping) {
      state = state.copyWith(isTyping: false);
      _logger.d('⏹️ Stopped typing');
    }
    _typingTimer?.cancel();
  }

  // 🔄 MESSAGE MANAGEMENT
  Future<void> deleteMessage(String messageId) async {
    try {
      _logger.d('🗑️ Deleting message: $messageId');
      
      final updatedMessages = state.messages
          .where((msg) => msg.id != messageId)
          .toList();
      
      state = state.copyWith(
        messages: updatedMessages,
        messageCount: updatedMessages.length,
      );
      
      await _storageService.deleteMessage(messageId);
      
      _analyticsService.trackEvent('message_deleted', {
        'message_id': messageId,
        'remaining_count': state.messageCount,
      });
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to delete message', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> editMessage(String messageId, String newContent) async {
    try {
      _logger.d('✏️ Editing message: $messageId');
      
      final messages = List<ChatMessage>.from(state.messages);
      final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
      
      if (messageIndex == -1) {
        throw StateError('Message not found: $messageId');
      }
      
      final updatedMessage = messages[messageIndex].copyWith(
        content: newContent,
        timestamp: DateTime.now(),
        metadata: {
          ...messages[messageIndex].metadata,
          'edited': true,
          'edit_time': DateTime.now().toIso8601String(),
        },
      );
      
      messages[messageIndex] = updatedMessage;
      
      state = state.copyWith(messages: messages);
      await _storageService.saveMessage(updatedMessage);
      
      _analyticsService.trackEvent('message_edited', {
        'message_id': messageId,
        'new_length': newContent.length,
      });
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to edit message', error: e, stackTrace: stackTrace);
    }
  }

  // 🔄 CHAT MANAGEMENT
  Future<void> clearChat() async {
    try {
      _logger.i('🔄 Clearing chat history...');
      
      // Cancel any active streams
      _streamSubscription?.cancel();
      
      state = const ChatState();
      await _storageService.clearChatHistory();
      
      _analyticsService.trackEvent('chat_cleared', {
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      _logger.i('✅ Chat cleared successfully');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to clear chat', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> exportChat() async {
    try {
      _logger.i('📤 Exporting chat...');
      
      final exportData = await _storageService.exportChatHistory();
      
      _analyticsService.trackEvent('chat_exported', {
        'message_count': state.messageCount,
        'export_size': exportData.length,
      });
      
      return exportData;
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to export chat', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // ⏹️ STOP GENERATION
  Future<void> stopGeneration() async {
    if (!state.isGenerating) return;
    
    try {
      _logger.i('⏹️ Stopping generation...');
      
      // Cancel stream
      _streamSubscription?.cancel();
      
      // Stop AI service generation
      if (state.activeRequestId != null) {
        await _aiService.stopGeneration(state.activeRequestId!);
      }
      
      state = state.copyWith(
        isGenerating: false,
        activeRequestId: null,
      );
      
      _analyticsService.trackEvent('generation_stopped', {
        'request_id': state.activeRequestId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      _logger.i('✅ Generation stopped');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to stop generation', error: e, stackTrace: stackTrace);
    }
  }

  // 🔄 CLEANUP
  @override
  void dispose() {
    _streamSubscription?.cancel();
    _typingTimer?.cancel();
    _logger.d('🧹 Chat Controller disposed');
    super.dispose();
  }
}

// 🎯 COMPUTED PROVIDERS FOR CHAT
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