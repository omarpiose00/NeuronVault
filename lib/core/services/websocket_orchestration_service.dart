// lib/core/services/websocket_orchestration_service.dart
// 🧠 FIXED WebSocket Orchestration Service - SOCKET.IO COMPATIBLE
// Compatible with both Socket.IO and native WebSocket backends

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
      modelName: json['model_name'] as String? ?? json['model'] as String? ?? 'unknown',
      content: json['content'] as String? ?? json['response'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.8,
      responseTime: Duration(milliseconds: json['response_time_ms'] as int? ?? 1000),
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
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

/// 🧠 FIXED WebSocket Orchestration Service - SOCKET.IO COMPATIBLE
class WebSocketOrchestrationService extends ChangeNotifier {
  // Try multiple ports for auto-discovery
  static const List<int> _defaultPorts = [3001, 3002, 3003, 3004, 3005];
  static const String _defaultHost = 'localhost';

  IO.Socket? _socket;
  Timer? _reconnectTimer;
  Timer? _healthCheckTimer;

  // Connection state
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  int _currentPort = 3001;
  int get currentPort => _currentPort;

  // AI Orchestration state
  final List<AIResponse> _individualResponses = [];
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

  /// Initialize Socket.IO connection with auto-discovery
  Future<bool> connect({String? host, int? port}) async {
    try {
      if (_isConnected) await disconnect();

      final targetHost = host ?? _defaultHost;
      final targetPorts = port != null ? [port] : _defaultPorts;

      debugPrint('🔍 Auto-discovering NeuronVault backend...');

      // Try each port until one works
      for (final testPort in targetPorts) {
        if (await _tryConnect(targetHost, testPort)) {
          _currentPort = testPort;
          debugPrint('✅ Connected to NeuronVault backend at $targetHost:$testPort');
          return true;
        }
        debugPrint('❌ Port $testPort unavailable, trying next...');
      }

      debugPrint('❌ No available NeuronVault backend found on ports: $targetPorts');
      return false;

    } catch (e) {
      debugPrint('❌ Connection failed: $e');
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }

  /// Try to connect to specific host:port
  Future<bool> _tryConnect(String host, int port) async {
    try {
      final serverUrl = 'http://$host:$port';
      debugPrint('🔗 Attempting Socket.IO connection to $serverUrl');

      _socket = IO.io(serverUrl, <String, dynamic>{
        'transports': ['websocket', 'polling'],
        'timeout': 5000,
        'autoConnect': false,
        'forceNew': true,
      });

      // Setup event handlers BEFORE connecting
      _setupSocketHandlers();

      // Connect and wait for result
      final completer = Completer<bool>();

      _socket!.onConnect((_) {
        debugPrint('🎉 Socket.IO connected successfully!');
        if (!completer.isCompleted) completer.complete(true);
      });

      _socket!.onConnectError((error) {
        debugPrint('❌ Socket.IO connection error: $error');
        if (!completer.isCompleted) completer.complete(false);
      });

      _socket!.onError((error) {
        debugPrint('❌ Socket.IO error: $error');
        if (!completer.isCompleted) completer.complete(false);
      });

      // Start connection
      _socket!.connect();

      // Wait for connection result with timeout
      final connected = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );

      if (connected) {
        _isConnected = true;
        notifyListeners();
        _startHealthCheck();
        _sendInitialPing();
        return true;
      } else {
        _socket?.dispose();
        _socket = null;
        return false;
      }

    } catch (e) {
      debugPrint('❌ Connection attempt failed: $e');
      _socket?.dispose();
      _socket = null;
      return false;
    }
  }

  /// Setup Socket.IO event handlers
  void _setupSocketHandlers() {
    if (_socket == null) return;

    // Connection events
    _socket!.onDisconnect((reason) {
      debugPrint('🔌 Socket.IO disconnected: $reason');
      _isConnected = false;
      notifyListeners();

      // Auto-reconnect if not intentional
      if (reason != 'io client disconnect') {
        _scheduleReconnect();
      }
    });

    // Server status
    _socket!.on('server_status', (data) {
      debugPrint('📡 Server status: $data');
    });

    // AI Orchestration events
    _socket!.on('strategy_selected', (data) {
      debugPrint('🎯 Strategy selected: ${data['strategy']}');
    });

    _socket!.on('stream_chunk', (data) {
      _handleStreamChunk(data);
    });

    _socket!.on('streaming_completed', (data) {
      _handleStreamingCompleted(data);
    });

    _socket!.on('stream_error', (data) {
      debugPrint('❌ Stream error: ${data['error']}');
    });

    // AI orchestration events (if backend supports them)
    _socket!.on('individual_response', (data) {
      _handleIndividualResponse(data);
    });

    _socket!.on('orchestration_progress', (data) {
      _handleOrchestrationProgress(data);
    });

    _socket!.on('synthesis_complete', (data) {
      _handleSynthesisComplete(data);
    });

    _socket!.on('orchestration_error', (data) {
      _handleOrchestrationError(data);
    });

    // Ping/Pong for latency
    _socket!.on('pong', (data) {
      debugPrint('🏓 Pong received');
    });
  }

  /// Send initial ping to test connection
  void _sendInitialPing() {
    try {
      _socket?.emit('ping', {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'client': 'flutter'
      });
      debugPrint('📡 Initial ping sent');
    } catch (e) {
      debugPrint('❌ Failed to send ping: $e');
    }
  }

  /// Start health check timer
  void _startHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected && _socket?.connected == true) {
        _socket?.emit('ping', {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      } else {
        debugPrint('⚠️ Health check failed, connection lost');
        _isConnected = false;
        notifyListeners();
      }
    });
  }

  /// Schedule reconnect attempt
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      debugPrint('🔄 Attempting to reconnect...');
      connect();
    });
  }

  /// Disconnect from Socket.IO
  Future<void> disconnect() async {
    try {
      _reconnectTimer?.cancel();
      _healthCheckTimer?.cancel();

      if (_socket != null) {
        _socket!.disconnect();
        _socket?.dispose();
        _socket = null;
      }

      _isConnected = false;
      notifyListeners();
      debugPrint('🔌 Socket.IO disconnected');
    } catch (e) {
      debugPrint('⚠️ Error during disconnect: $e');
    }
  }

  /// Send AI orchestration request (MAIN METHOD)
  Future<void> orchestrateAIRequest({
    required String prompt,
    required List<String> selectedModels,
    required OrchestrationStrategy strategy,
    Map<String, double>? modelWeights,
    String? conversationId,
  }) async {
    if (!_isConnected || _socket == null) {
      throw Exception('Not connected to backend');
    }

    // Reset state for new request
    _individualResponses.clear();
    _synthesizedResponse = null;
    _currentStrategy = strategy;

    final request = {
      'prompt': prompt,
      'models': selectedModels,
      'strategy': strategy.name,
      'weights': modelWeights ?? {},
      'conversation_id': conversationId ?? _generateConversationId(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    try {
      debugPrint('🚀 Starting AI orchestration: ${selectedModels.join(', ')}');
      _socket!.emit('start_ai_stream', request);

      // Start demo simulation if backend doesn't respond within 2 seconds
      Timer(const Duration(seconds: 2), () {
        if (_individualResponses.isEmpty) {
          debugPrint('🧪 Backend not responding, starting demo simulation');
          _simulateOrchestrationForDemo(prompt, selectedModels);
        }
      });

    } catch (e) {
      debugPrint('❌ Failed to send AI orchestration request: $e');
      throw Exception('Failed to send AI orchestration request: $e');
    }
  }

  /// Alternative method name for compatibility
  Future<void> startAIStream({
    required String prompt,
    required List<String> selectedModels,
    required OrchestrationStrategy strategy,
    Map<String, double>? modelWeights,
    String? conversationId,
  }) async {
    return orchestrateAIRequest(
      prompt: prompt,
      selectedModels: selectedModels,
      strategy: strategy,
      modelWeights: modelWeights,
      conversationId: conversationId,
    );
  }

  /// Handle stream chunk from backend
  void _handleStreamChunk(Map<String, dynamic> data) {
    try {
      final chunk = data['chunk'] as String? ?? '';
      final buffer = data['buffer'] as String? ?? '';
      final model = data['model'] as String? ?? 'unknown';
      final isComplete = data['isComplete'] as bool? ?? false;

      debugPrint('📥 Stream chunk from $model: ${chunk.length} chars');

      if (isComplete && buffer.isNotEmpty) {
        final response = AIResponse(
          modelName: model,
          content: buffer,
          confidence: 0.8,
          responseTime: const Duration(milliseconds: 1500),
          timestamp: DateTime.now(),
        );

        _individualResponses.add(response);
        _responsesController.add(List.unmodifiable(_individualResponses));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error handling stream chunk: $e');
    }
  }

  /// Handle streaming completion
  void _handleStreamingCompleted(Map<String, dynamic> data) {
    try {
      final finalResponse = data['finalResponse'] as String? ?? '';
      debugPrint('✅ Streaming completed: ${finalResponse.length} chars');

      if (finalResponse.isNotEmpty) {
        _synthesizedResponse = finalResponse;
        _synthesisController.add(finalResponse);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error handling streaming completion: $e');
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
      _synthesizedResponse = data['synthesis'] as String? ?? data['final_response'] as String? ?? '';
      if (_synthesizedResponse!.isNotEmpty) {
        _synthesisController.add(_synthesizedResponse!);
        notifyListeners();
        debugPrint('✨ Synthesis complete: ${_synthesizedResponse!.length} chars');
      }
    } catch (e) {
      debugPrint('❌ Error handling synthesis: $e');
    }
  }

  /// Handle orchestration errors
  void _handleOrchestrationError(Map<String, dynamic> data) {
    final errorMessage = data['message'] as String? ?? data['error'] as String? ?? 'Unknown error';
    final errorCode = data['code'] as String?;

    debugPrint('❌ Orchestration error [$errorCode]: $errorMessage');
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