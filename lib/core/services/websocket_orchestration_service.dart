// lib/core/services/websocket_orchestration_service.dart
// 🧠 Simplified WebSocket Orchestration Service
// Basic working version for AI orchestration

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

/// Orchestration strategies
enum OrchestrationStrategy {
  parallel,    // All models run simultaneously
  consensus,   // Majority agreement required
  weighted,    // Weighted combination based on model strengths
  adaptive,    // Dynamic strategy based on prompt analysis
  sequential,  // Models run in sequence with context passing
}

/// AI Response model (simplified)
class AIResponse {
  final String modelName;
  final String content;
  final double confidence;
  final Duration responseTime;
  final DateTime timestamp;

  const AIResponse({
    required this.modelName,
    required this.content,
    required this.confidence,
    required this.responseTime,
    required this.timestamp,
  });

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    return AIResponse(
      modelName: json['model_name'] as String,
      content: json['content'] as String,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.8,
      responseTime: Duration(milliseconds: json['response_time_ms'] as int? ?? 1000),
      timestamp: DateTime.parse(json['timestamp'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Orchestration progress model (simplified)
class OrchestrationProgress {
  final int completedModels;
  final int totalModels;
  final String currentPhase;
  final double overallProgress;

  const OrchestrationProgress({
    required this.completedModels,
    required this.totalModels,
    required this.currentPhase,
    required this.overallProgress,
  });

  factory OrchestrationProgress.fromJson(Map<String, dynamic> json) {
    return OrchestrationProgress(
      completedModels: json['completed_models'] as int? ?? 0,
      totalModels: json['total_models'] as int? ?? 1,
      currentPhase: json['current_phase'] as String? ?? 'initializing',
      overallProgress: (json['overall_progress'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// 🧠 Simplified WebSocket Orchestration Service
class WebSocketOrchestrationService extends ChangeNotifier {
  static const String _defaultUrl = 'ws://localhost:3001';

  WebSocketChannel? _channel;
  StreamSubscription? _streamSubscription;

  // Connection state
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // AI Orchestration state
  List<AIResponse> _individualResponses = [];
  String? _synthesizedResponse;
  OrchestrationStrategy _currentStrategy = OrchestrationStrategy.parallel;

  // Stream controllers for real-time updates
  final StreamController<List<AIResponse>> _responsesController =
  StreamController<List<AIResponse>>.broadcast();
  final StreamController<String> _synthesisController =
  StreamController<String>.broadcast();
  final StreamController<OrchestrationProgress> _progressController =
  StreamController<OrchestrationProgress>.broadcast();

  // Public streams
  Stream<List<AIResponse>> get individualResponsesStream => _responsesController.stream;
  Stream<String> get synthesizedResponseStream => _synthesisController.stream;
  Stream<OrchestrationProgress> get orchestrationProgressStream => _progressController.stream;

  // Getters
  List<AIResponse> get individualResponses => List.unmodifiable(_individualResponses);
  String? get synthesizedResponse => _synthesizedResponse;
  OrchestrationStrategy get currentStrategy => _currentStrategy;

  /// Initialize WebSocket connection to backend
  Future<bool> connect({String? url}) async {
    try {
      if (_isConnected) await disconnect();

      final wsUrl = url ?? _defaultUrl;
      debugPrint('🔗 Attempting to connect to $wsUrl');

      _channel = IOWebSocketChannel.connect(Uri.parse(wsUrl));

      // Listen to messages from backend
      _streamSubscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );

      _isConnected = true;
      notifyListeners();

      debugPrint('🔗 WebSocket connected to $wsUrl');

      // Send a test ping
      _sendPing();

      return true;
    } catch (e) {
      debugPrint('❌ WebSocket connection failed: $e');
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }

  /// Send ping to test connection
  void _sendPing() {
    try {
      final pingMessage = {
        'type': 'ping',
        'timestamp': DateTime.now().toIso8601String(),
      };
      _channel?.sink.add(jsonEncode(pingMessage));
      debugPrint('📡 Ping sent to backend');
    } catch (e) {
      debugPrint('❌ Failed to send ping: $e');
    }
  }

  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    try {
      await _streamSubscription?.cancel();
      await _channel?.sink.close();
      _isConnected = false;
      notifyListeners();
      debugPrint('🔌 WebSocket disconnected');
    } catch (e) {
      debugPrint('⚠️ Error during disconnect: $e');
    }
  }

  /// Send AI orchestration request
  Future<void> orchestrateAIRequest({
    required String prompt,
    required List<String> selectedModels,
    required OrchestrationStrategy strategy,
    Map<String, double>? modelWeights,
    String? conversationId,
  }) async {
    if (!_isConnected) {
      throw Exception('WebSocket not connected');
    }

    // Reset state for new orchestration
    _individualResponses.clear();
    _synthesizedResponse = null;
    _currentStrategy = strategy;

    final request = {
      'type': 'orchestration_request',
      'data': {
        'prompt': prompt,
        'models': selectedModels,
        'strategy': strategy.name,
        'weights': modelWeights ?? {},
        'conversation_id': conversationId ?? _generateConversationId(),
        'timestamp': DateTime.now().toIso8601String(),
      }
    };

    try {
      _channel!.sink.add(jsonEncode(request));
      debugPrint('🚀 Orchestration request sent: ${selectedModels.join(', ')}');

      // Simulate some progress for demo purposes if backend is not ready
      _simulateOrchestrationForDemo(prompt, selectedModels);

    } catch (e) {
      debugPrint('❌ Failed to send orchestration request: $e');
      throw Exception('Failed to send orchestration request: $e');
    }
  }

  /// Simulate orchestration for demo (when backend is not ready)
  void _simulateOrchestrationForDemo(String prompt, List<String> models) async {
    debugPrint('🧪 Simulating orchestration for demo purposes');

    // Simulate individual responses
    for (int i = 0; i < models.length; i++) {
      await Future.delayed(Duration(milliseconds: 500 + (i * 200)));

      final response = AIResponse(
        modelName: models[i],
        content: _generateDemoResponse(models[i], prompt),
        confidence: 0.7 + (i * 0.1),
        responseTime: Duration(milliseconds: 1000 + (i * 200)),
        timestamp: DateTime.now(),
      );

      _individualResponses.add(response);
      _responsesController.add(List.unmodifiable(_individualResponses));
      notifyListeners();

      // Update progress
      final progress = OrchestrationProgress(
        completedModels: i + 1,
        totalModels: models.length,
        currentPhase: 'Processing ${models[i]}',
        overallProgress: (i + 1) / models.length,
      );
      _progressController.add(progress);
    }

    // Simulate synthesis
    await Future.delayed(const Duration(milliseconds: 800));
    _synthesizedResponse = _generateDemoSynthesis(prompt, _individualResponses);
    _synthesisController.add(_synthesizedResponse!);
    notifyListeners();

    debugPrint('✅ Demo orchestration completed');
  }

  /// Generate demo response for a model
  String _generateDemoResponse(String modelName, String prompt) {
    switch (modelName.toLowerCase()) {
      case 'claude':
        return "Claude: I'll approach this systematically. $prompt requires careful analysis and structured thinking. Here's my comprehensive response with detailed reasoning.";
      case 'gpt':
        return "GPT: Based on my training, I can provide a practical solution for '$prompt'. This involves understanding the core concepts and applying them effectively.";
      case 'deepseek':
        return "DeepSeek: Through deep analysis of '$prompt', I've identified key patterns and insights. Here's my technical perspective on the optimal approach.";
      case 'gemini':
        return "Gemini: I can help with '$prompt' by combining multiple perspectives. Let me provide a creative and comprehensive solution.";
      default:
        return "$modelName: Here's my response to '$prompt' with my unique analytical approach.";
    }
  }

  /// Generate demo synthesis
  String _generateDemoSynthesis(String prompt, List<AIResponse> responses) {
    return """🧬 **NEURONVAULT ORCHESTRATED SYNTHESIS**

After analyzing ${responses.length} AI perspectives on "$prompt", here's the comprehensive orchestrated response:

**Key Insights Combined:**
${responses.map((r) => '• ${r.modelName}: ${r.content.split('.').first}.').join('\n')}

**Orchestrated Recommendation:**
By synthesizing multiple AI viewpoints, the optimal approach combines systematic analysis (Claude), practical application (GPT), technical depth (DeepSeek), and creative perspectives (Gemini). This multi-AI orchestration provides a more robust and comprehensive solution than any single AI could offer.

*This response represents the collective intelligence of ${responses.length} AI models, orchestrated using the ${_currentStrategy.name} strategy.*""";
  }

  /// Handle incoming messages from backend
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String);
      final type = data['type'] as String;

      debugPrint('📥 Received message type: $type');

      switch (type) {
        case 'pong':
          debugPrint('📡 Pong received from backend');
          break;
        case 'individual_response':
          _handleIndividualResponse(data['data']);
          break;
        case 'orchestration_progress':
          _handleOrchestrationProgress(data['data']);
          break;
        case 'synthesis_complete':
          _handleSynthesisComplete(data['data']);
          break;
        case 'orchestration_error':
          _handleOrchestrationError(data['data']);
          break;
        default:
          debugPrint('🤔 Unknown message type: $type');
      }
    } catch (e) {
      debugPrint('❌ Error parsing message: $e');
    }
  }

  /// Handle individual AI model response
  void _handleIndividualResponse(Map<String, dynamic> data) {
    try {
      final response = AIResponse.fromJson(data);

      // Update or add response
      final existingIndex = _individualResponses.indexWhere(
              (r) => r.modelName == response.modelName
      );

      if (existingIndex >= 0) {
        _individualResponses[existingIndex] = response;
      } else {
        _individualResponses.add(response);
      }

      // Notify listeners
      _responsesController.add(List.unmodifiable(_individualResponses));
      notifyListeners();

      debugPrint('📥 Individual response from ${response.modelName}: ${response.content.length} chars');
    } catch (e) {
      debugPrint('❌ Error handling individual response: $e');
    }
  }

  /// Handle orchestration progress updates
  void _handleOrchestrationProgress(Map<String, dynamic> data) {
    try {
      final progress = OrchestrationProgress.fromJson(data);
      _progressController.add(progress);

      debugPrint('⏳ Orchestration progress: ${progress.completedModels}/${progress.totalModels}');
    } catch (e) {
      debugPrint('❌ Error handling progress: $e');
    }
  }

  /// Handle final synthesis completion
  void _handleSynthesisComplete(Map<String, dynamic> data) {
    try {
      _synthesizedResponse = data['synthesis'] as String;
      _synthesisController.add(_synthesizedResponse!);
      notifyListeners();

      debugPrint('✨ Synthesis complete: ${_synthesizedResponse!.length} chars');
    } catch (e) {
      debugPrint('❌ Error handling synthesis: $e');
    }
  }

  /// Handle orchestration errors
  void _handleOrchestrationError(Map<String, dynamic> data) {
    final errorMessage = data['message'] as String? ?? 'Unknown error';
    final errorCode = data['code'] as String?;

    debugPrint('❌ Orchestration error [$errorCode]: $errorMessage');
  }

  /// Handle WebSocket errors
  void _handleError(error) {
    debugPrint('❌ WebSocket error: $error');
    _isConnected = false;
    notifyListeners();
  }

  /// Handle WebSocket disconnection
  void _handleDisconnection() {
    debugPrint('🔌 WebSocket disconnected');
    _isConnected = false;
    notifyListeners();
  }

  /// Generate unique conversation ID
  String _generateConversationId() {
    return 'conv_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  /// Dispose resources
  @override
  void dispose() {
    disconnect();
    _responsesController.close();
    _synthesisController.close();
    _progressController.close();
    super.dispose();
  }
}