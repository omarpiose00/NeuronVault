// lib/services/streaming_service.dart - Advanced Streaming Client
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

enum StreamingState {
  idle,
  connecting,
  connected,
  streaming,
  completed,
  error,
  disconnected
}

enum StreamingType {
  serverSentEvents,
  webSocket,
  socketIO
}

class StreamingEvent {
  final String type;
  final String conversationId;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  StreamingEvent({
    required this.type,
    required this.conversationId,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory StreamingEvent.fromJson(Map<String, dynamic> json) {
    return StreamingEvent(
      type: json['type'] ?? 'unknown',
      conversationId: json['conversationId'] ?? '',
      data: json['data'] ?? {},
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'])
          : DateTime.now(),
    );
  }

  @override
  String toString() => 'StreamingEvent(type: $type, conversationId: $conversationId)';
}

class ModelProgress {
  final String model;
  final String status;
  final double progress;
  final List<String> chunks;
  final bool completed;
  final String? error;
  final Map<String, dynamic> metrics;

  ModelProgress({
    required this.model,
    required this.status,
    required this.progress,
    required this.chunks,
    required this.completed,
    this.error,
    this.metrics = const {},
  });

  factory ModelProgress.fromJson(Map<String, dynamic> json) {
    return ModelProgress(
      model: json['model'] ?? '',
      status: json['status'] ?? 'unknown',
      progress: (json['progress'] ?? 0.0).toDouble(),
      chunks: List<String>.from(json['chunks'] ?? []),
      completed: json['completed'] ?? false,
      error: json['error'],
      metrics: Map<String, dynamic>.from(json['metrics'] ?? {}),
    );
  }

  ModelProgress copyWith({
    String? status,
    double? progress,
    List<String>? chunks,
    bool? completed,
    String? error,
    Map<String, dynamic>? metrics,
  }) {
    return ModelProgress(
      model: model,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      chunks: chunks ?? this.chunks,
      completed: completed ?? this.completed,
      error: error ?? this.error,
      metrics: metrics ?? this.metrics,
    );
  }
}

class StreamingSession {
  final String conversationId;
  final DateTime startTime;
  final StreamingType type;
  final Map<String, ModelProgress> modelProgress;
  final List<StreamingEvent> events;
  final String strategy;
  final double totalProgress;

  StreamingSession({
    required this.conversationId,
    required this.startTime,
    required this.type,
    required this.modelProgress,
    required this.events,
    required this.strategy,
    required this.totalProgress,
  });

  Duration get duration => DateTime.now().difference(startTime);

  List<String> get activeModels => modelProgress.keys.toList();

  bool get isCompleted => modelProgress.values.every((p) => p.completed);

  String get synthesizedResponse {
    final synthesisEvents = events.where((e) => e.type == 'synthesis_chunk').toList();
    return synthesisEvents.map((e) => e.data['chunk'] ?? '').join('');
  }
}

class StreamingService extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:4000';

  // State management
  StreamingState _state = StreamingState.idle;
  StreamingSession? _currentSession;
  String? _error;

  // Connections
  WebSocketChannel? _webSocketChannel;
  StreamSubscription? _sseSubscription;

  // Controllers
  final StreamController<StreamingEvent> _eventController =
  StreamController<StreamingEvent>.broadcast();
  final StreamController<String> _messageController =
  StreamController<String>.broadcast();

  // Configuration
  Duration connectionTimeout = const Duration(seconds: 10);
  Duration heartbeatInterval = const Duration(seconds: 15);
  int maxReconnectAttempts = 3;
  int _reconnectAttempts = 0;

  // Getters
  StreamingState get state => _state;
  StreamingSession? get currentSession => _currentSession;
  String? get error => _error;
  Stream<StreamingEvent> get eventStream => _eventController.stream;
  Stream<String> get messageStream => _messageController.stream;

  bool get isConnected => _state == StreamingState.connected || _state == StreamingState.streaming;
  bool get isStreaming => _state == StreamingState.streaming;

  // Start streaming session with Server-Sent Events
  Future<bool> startSSEStreaming({
    required String conversationId,
    required String prompt,
    required Map<String, bool> modelConfig,
    Map<String, double>? customWeights,
    String mode = 'chat',
  }) async {
    return await _startStreaming(
      conversationId: conversationId,
      prompt: prompt,
      modelConfig: modelConfig,
      customWeights: customWeights,
      mode: mode,
      type: StreamingType.serverSentEvents,
    );
  }

  // Start streaming session with WebSocket
  Future<bool> startWebSocketStreaming({
    required String conversationId,
    required String prompt,
    required Map<String, bool> modelConfig,
    Map<String, double>? customWeights,
    String mode = 'chat',
  }) async {
    return await _startStreaming(
      conversationId: conversationId,
      prompt: prompt,
      modelConfig: modelConfig,
      customWeights: customWeights,
      mode: mode,
      type: StreamingType.webSocket,
    );
  }

  // Universal streaming method
  Future<bool> _startStreaming({
    required String conversationId,
    required String prompt,
    required Map<String, bool> modelConfig,
    Map<String, double>? customWeights,
    required String mode,
    required StreamingType type,
  }) async {
    if (isConnected) {
      await stopStreaming();
    }

    _setState(StreamingState.connecting);
    _error = null;
    _reconnectAttempts = 0;

    // Initialize session
    _currentSession = StreamingSession(
      conversationId: conversationId,
      startTime: DateTime.now(),
      type: type,
      modelProgress: {},
      events: [],
      strategy: 'adaptive', // Will be updated by backend
      totalProgress: 0.0,
    );

    try {
      bool success = false;

      switch (type) {
        case StreamingType.serverSentEvents:
          success = await _connectSSE(conversationId, prompt, modelConfig, customWeights, mode);
          break;
        case StreamingType.webSocket:
          success = await _connectWebSocket(conversationId, prompt, modelConfig, customWeights, mode);
          break;
        case StreamingType.socketIO:
        // Future implementation
          success = false;
          break;
      }

      if (success) {
        _setState(StreamingState.connected);
        debugPrint('🔄 Streaming session started: $conversationId ($type)');
        return true;
      } else {
        _setState(StreamingState.error);
        return false;
      }
    } catch (e) {
      _setError('Failed to start streaming: $e');
      return false;
    }
  }

  // Server-Sent Events connection
  Future<bool> _connectSSE(String conversationId, String prompt,
      Map<String, bool> modelConfig, Map<String, double>? customWeights, String mode) async {
    try {
      final url = Uri.parse('$baseUrl/api/stream/sse/$conversationId');

      final request = http.Request('POST', url);
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
        'Cache-Control': 'no-cache',
      });

      request.body = jsonEncode({
        'prompt': prompt,
        'modelConfig': modelConfig,
        'customWeights': customWeights,
        'mode': mode,
      });

      final streamedResponse = await request.send().timeout(connectionTimeout);

      if (streamedResponse.statusCode != 200) {
        throw Exception('SSE connection failed: ${streamedResponse.statusCode}');
      }

      // Listen to SSE stream
      _sseSubscription = streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        _handleSSEData,
        onError: _handleStreamError,
        onDone: () {
          debugPrint('📡 SSE stream completed');
          _setState(StreamingState.completed);
        },
      );

      return true;
    } catch (e) {
      debugPrint('❌ SSE connection error: $e');
      return false;
    }
  }

  // WebSocket connection
  Future<bool> _connectWebSocket(String conversationId, String prompt,
      Map<String, bool> modelConfig, Map<String, double>? customWeights, String mode) async {
    try {
      final wsUrl = Uri.parse('ws://localhost:4000/ws/stream');

      _webSocketChannel = WebSocketChannel.connect(wsUrl);

      await _webSocketChannel!.ready.timeout(connectionTimeout);

      // Send initial message
      _webSocketChannel!.sink.add(jsonEncode({
        'type': 'start_stream',
        'conversationId': conversationId,
        'prompt': prompt,
        'modelConfig': modelConfig,
        'customWeights': customWeights,
        'mode': mode,
      }));

      // Listen to WebSocket messages
      _webSocketChannel!.stream.listen(
            (data) => _handleWebSocketData(data.toString()),
        onError: _handleStreamError,
        onDone: () {
          debugPrint('🔌 WebSocket stream completed');
          _setState(StreamingState.completed);
        },
      );

      // Setup heartbeat
      _startHeartbeat();

      return true;
    } catch (e) {
      debugPrint('❌ WebSocket connection error: $e');
      return false;
    }
  }

  // Handle SSE data
  void _handleSSEData(String line) {
    if (line.startsWith('data: ')) {
      final data = line.substring(6);
      if (data.trim().isEmpty) return;

      try {
        final json = jsonDecode(data);
        final event = StreamingEvent.fromJson(json);
        _processStreamingEvent(event);
      } catch (e) {
        debugPrint('⚠️ Failed to parse SSE data: $e');
      }
    }
  }

  // Handle WebSocket data
  void _handleWebSocketData(String data) {
    try {
      final json = jsonDecode(data);
      final event = StreamingEvent.fromJson(json);
      _processStreamingEvent(event);
    } catch (e) {
      debugPrint('⚠️ Failed to parse WebSocket data: $e');
    }
  }

  // Process streaming events
  void _processStreamingEvent(StreamingEvent event) {
    if (_currentSession == null) return;

    // Add event to session
    _currentSession!.events.add(event);
    _eventController.add(event);

    switch (event.type) {
      case 'stream_started':
        _setState(StreamingState.streaming);
        debugPrint('🚀 Streaming started with models: ${event.data['models']}');
        break;

      case 'strategy_selected':
        final strategy = event.data['strategy'] ?? 'unknown';
        debugPrint('🎯 Strategy selected: $strategy');
        break;

      case 'model_stream_started':
        final model = event.data['model'];
        if (model != null) {
          _updateModelProgress(model, ModelProgress(
            model: model,
            status: 'streaming',
            progress: 0.0,
            chunks: [],
            completed: false,
          ));
        }
        break;

      case 'model_chunk':
        final model = event.data['model'];
        final chunk = event.data['chunk'];
        final progress = (event.data['progress'] ?? 0.0).toDouble();
        final metrics = event.data['metrics'] ?? {};

        if (model != null && chunk != null) {
          _appendModelChunk(model, chunk, progress, metrics);
          _messageController.add('[$model] $chunk');
        }
        break;

      case 'synthesis_started':
        debugPrint('🔄 Synthesis started');
        break;

      case 'synthesis_chunk':
        final chunk = event.data['chunk'];
        final progress = (event.data['progress'] ?? 0.0).toDouble();

        if (chunk != null) {
          _messageController.add('[SYNTHESIS] $chunk');
        }
        break;

      case 'synthesis_completed':
        final finalResponse = event.data['finalResponse'];
        debugPrint('✅ Synthesis completed');
        if (finalResponse != null) {
          _messageController.add('[FINAL] $finalResponse');
        }
        break;

      case 'stream_completed':
        _setState(StreamingState.completed);
        debugPrint('🏁 Stream completed in ${_currentSession!.duration.inMilliseconds}ms');
        break;

      case 'stream_error':
      case 'synthesis_error':
      case 'model_streaming_error':
        _setError(event.data['error'] ?? 'Unknown streaming error');
        break;

      case 'heartbeat':
      // Keep connection alive
        break;

      default:
        debugPrint('📨 Unknown event type: ${event.type}');
    }

    notifyListeners();
  }

  // Update model progress
  void _updateModelProgress(String model, ModelProgress progress) {
    if (_currentSession != null) {
      _currentSession!.modelProgress[model] = progress;

      // Calculate total progress
      final progresses = _currentSession!.modelProgress.values.map((p) => p.progress);
      if (progresses.isNotEmpty) {
        final totalProgress = progresses.reduce((a, b) => a + b) / progresses.length;
        _currentSession = StreamingSession(
          conversationId: _currentSession!.conversationId,
          startTime: _currentSession!.startTime,
          type: _currentSession!.type,
          modelProgress: _currentSession!.modelProgress,
          events: _currentSession!.events,
          strategy: _currentSession!.strategy,
          totalProgress: totalProgress,
        );
      }
    }
  }

  // Append chunk to model progress
  void _appendModelChunk(String model, String chunk, double progress, Map<String, dynamic> metrics) {
    if (_currentSession?.modelProgress[model] != null) {
      final currentProgress = _currentSession!.modelProgress[model]!;
      final updatedChunks = [...currentProgress.chunks, chunk];

      _updateModelProgress(model, currentProgress.copyWith(
        progress: progress,
        chunks: updatedChunks,
        metrics: metrics,
        completed: progress >= 1.0,
      ));
    }
  }

  // WebSocket heartbeat
  void _startHeartbeat() {
    Timer.periodic(heartbeatInterval, (timer) {
      if (_webSocketChannel == null || _state != StreamingState.streaming) {
        timer.cancel();
        return;
      }

      try {
        _webSocketChannel!.sink.add(jsonEncode({
          'type': 'ping',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }));
      } catch (e) {
        debugPrint('💔 Heartbeat failed: $e');
        timer.cancel();
        _handleStreamError(e);
      }
    });
  }

  // Handle streaming errors
  void _handleStreamError(dynamic error) {
    debugPrint('🔥 Streaming error: $error');

    if (_reconnectAttempts < maxReconnectAttempts && _currentSession != null) {
      _reconnectAttempts++;
      debugPrint('🔄 Reconnection attempt $_reconnectAttempts/$maxReconnectAttempts');

      Timer(Duration(seconds: _reconnectAttempts * 2), () {
        // Retry connection logic would go here
        _setError('Connection lost. Retry $_reconnectAttempts/$maxReconnectAttempts');
      });
    } else {
      _setError('Streaming failed: $error');
    }
  }

  // Stop streaming
  Future<void> stopStreaming() async {
    if (_state == StreamingState.idle) return;

    debugPrint('🛑 Stopping streaming session');

    // Close connections
    await _sseSubscription?.cancel();
    _sseSubscription = null;

    if (_webSocketChannel != null) {
      await _webSocketChannel!.sink.close(status.normalClosure);
      _webSocketChannel = null;
    }

    _setState(StreamingState.idle);
    _currentSession = null;
    _error = null;
    _reconnectAttempts = 0;
  }

  // Get streaming statistics
  Map<String, dynamic> getStreamingStats() {
    if (_currentSession == null) return {};

    return {
      'conversationId': _currentSession!.conversationId,
      'duration': _currentSession!.duration.inMilliseconds,
      'totalProgress': _currentSession!.totalProgress,
      'activeModels': _currentSession!.activeModels.length,
      'eventsReceived': _currentSession!.events.length,
      'strategy': _currentSession!.strategy,
      'isCompleted': _currentSession!.isCompleted,
      'modelProgress': _currentSession!.modelProgress.map(
            (key, value) => MapEntry(key, {
          'status': value.status,
          'progress': value.progress,
          'chunks': value.chunks.length,
          'completed': value.completed,
          'metrics': value.metrics,
        }),
      ),
    };
  }

  // State management helpers
  void _setState(StreamingState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void _setError(String errorMessage) {
    _error = errorMessage;
    _setState(StreamingState.error);
    debugPrint('🔥 Streaming error: $errorMessage');
  }

  @override
  void dispose() {
    stopStreaming();
    _eventController.close();
    _messageController.close();
    super.dispose();
  }
}