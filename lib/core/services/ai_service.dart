// 🤖 NEURONVAULT - AI ORCHESTRATION SERVICE
// Enterprise-grade AI model orchestration and streaming
// Part of PHASE 2.5 - QUANTUM STATE MANAGEMENT

import 'dart:async';
import 'dart:convert';
// import 'dart:io'; // Era commentato o non usato, rimosso per pulizia se non serve
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart'; // Usato per IOWebSocketChannel

import '../state/state_models.dart';
import 'config_service.dart';
import 'storage_service.dart'; // <-- IMPORT NECESSARIO

class AIService {
  final ConfigService _configService;
  final StorageService _storageService; // <-- CAMPO AGGIUNTO
  final Logger _logger;

  late final Dio _dio;
  final Map<String, WebSocketChannel> _streamingChannels = {};
  final Map<String, StreamController<String>> _responseControllers = {};
  final Map<String, Completer<void>> _stopCompleters = {};

  // 📊 Performance tracking
  final Map<AIModel, List<int>> _responseTimes = {};
  final Map<AIModel, int> _requestCounts = {};
  final Map<AIModel, int> _errorCounts = {};

  AIService({
    required ConfigService configService,
    required StorageService storageService, // <-- PARAMETRO RICHIESTO
    required Logger logger,
  })  : _configService = configService,
        _storageService = storageService, // <-- ASSEGNAZIONE AL CAMPO
        _logger = logger {
    _initializeHttpClient();
    _logger.i('AIService initialized. StorageService is: ${_storageService.runtimeType}');
  }

  // 🔧 HTTP CLIENT INITIALIZATION
  void _initializeHttpClient() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 120),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'NeuronVault/2.5.0',
      },
    ));

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (obj) => _logger.d('🌐 HTTP: $obj'),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          _logger.e('❌ HTTP Error: ${error.message}');
          handler.next(error);
        },
      ),
    );

    _logger.d('🔧 HTTP client initialized');
  }

  // 🧪 CONNECTION TESTING
  Future<bool> testConnection(AIModel model, ModelConfig config) async {
    if (config.apiKey.isEmpty) {
      _logger.w('⚠️ No API key configured for $model');
      return false;
    }

    try {
      _logger.d('🧪 Testing connection for $model...');
      final stopwatch = Stopwatch()..start();
      switch (model) {
        case AIModel.claude:
          await _testClaudeConnection(config);
          break;
        case AIModel.gpt:
          await _testOpenAIConnection(config);
          break;
        case AIModel.deepseek:
          await _testDeepSeekConnection(config);
          break;
        case AIModel.gemini:
          await _testGeminiConnection(config);
          break;
        case AIModel.mistral:
          await _testMistralConnection(config);
          break;
        case AIModel.llama:
        case AIModel.ollama:
          await _testLocalConnection(config);
          break;
      }
      stopwatch.stop();
      final responseTime = stopwatch.elapsedMilliseconds;
      _recordResponseTime(model, responseTime);
      _logger.i('✅ Connection test passed for $model (${responseTime}ms)');
      return true;
    } catch (e) {
      _recordError(model);
      _logger.w('❌ Connection test failed for $model: $e');
      return false;
    }
  }

  Future<void> _testClaudeConnection(ModelConfig config) async {
    final response = await _dio.post(
      '${config.baseUrl}/v1/messages',
      options: Options(headers: {'x-api-key': config.apiKey, 'anthropic-version': '2023-06-01'}),
      data: {'model': 'claude-3-haiku-20240307', 'max_tokens': 10, 'messages': [{'role': 'user', 'content': 'test'}]},
    );
    if (response.statusCode != 200) throw Exception('Claude API returned ${response.statusCode}');
  }

  Future<void> _testOpenAIConnection(ModelConfig config) async {
    final response = await _dio.post(
      '${config.baseUrl}/v1/chat/completions',
      options: Options(headers: {'Authorization': 'Bearer ${config.apiKey}'}),
      data: {'model': 'gpt-3.5-turbo', 'max_tokens': 10, 'messages': [{'role': 'user', 'content': 'test'}]},
    );
    if (response.statusCode != 200) throw Exception('OpenAI API returned ${response.statusCode}');
  }

  Future<void> _testDeepSeekConnection(ModelConfig config) async {
    final response = await _dio.post(
      '${config.baseUrl}/v1/chat/completions',
      options: Options(headers: {'Authorization': 'Bearer ${config.apiKey}'}),
      data: {'model': 'deepseek-chat', 'max_tokens': 10, 'messages': [{'role': 'user', 'content': 'test'}]},
    );
    if (response.statusCode != 200) throw Exception('DeepSeek API returned ${response.statusCode}');
  }

  Future<void> _testGeminiConnection(ModelConfig config) async {
    final response = await _dio.post(
      '${config.baseUrl}/v1beta/models/gemini-pro:generateContent',
      options: Options(headers: {'x-goog-api-key': config.apiKey}),
      data: {'contents': [{'parts': [{'text': 'test'}]}], 'generationConfig': {'maxOutputTokens': 10}},
    );
    if (response.statusCode != 200) throw Exception('Gemini API returned ${response.statusCode}');
  }

  Future<void> _testMistralConnection(ModelConfig config) async {
    final response = await _dio.post(
      '${config.baseUrl}/v1/chat/completions',
      options: Options(headers: {'Authorization': 'Bearer ${config.apiKey}'}),
      data: {'model': 'mistral-tiny', 'max_tokens': 10, 'messages': [{'role': 'user', 'content': 'test'}]},
    );
    if (response.statusCode != 200) throw Exception('Mistral API returned ${response.statusCode}');
  }

  Future<void> _testLocalConnection(ModelConfig config) async {
    try {
      final channel = IOWebSocketChannel.connect(Uri.parse('ws://${config.baseUrl}/health'));
      await channel.ready.timeout(const Duration(seconds: 5));
      await channel.sink.close();
    } catch (e) {
      throw Exception('Local model connection failed: $e');
    }
  }

  // 📡 STREAMING RESPONSE
  Stream<String> streamResponse(String prompt, String requestId) {
    _logger.d('📡 Starting streaming response for request: $requestId');
    final controller = StreamController<String>.broadcast();
    _responseControllers[requestId] = controller;
    _stopCompleters[requestId] = Completer<void>();
    _processStreamingRequest(prompt, requestId, controller);
    return controller.stream;
  }

  Future<void> _processStreamingRequest(String prompt, String requestId, StreamController<String> controller) async {
    try {
      final channel = IOWebSocketChannel.connect(Uri.parse('ws://localhost:8080/stream'));
      _streamingChannels[requestId] = channel;
      final request = {'id': requestId, 'prompt': prompt, 'timestamp': DateTime.now().millisecondsSinceEpoch, 'strategy': 'parallel'};
      channel.sink.add(jsonEncode(request));
      await for (final message in channel.stream) {
        if (_stopCompleters[requestId]?.isCompleted == true) break;
        try {
          final data = jsonDecode(message as String) as Map<String, dynamic>;
          switch (data['type']) {
            case 'chunk':
              if (!controller.isClosed) controller.add(data['content'] as String);
              break;
            case 'complete':
              _logger.i('✅ Streaming completed for request: $requestId');
              break;
            case 'error':
              if (!controller.isClosed) controller.addError(Exception(data['error'] as String));
              break;
          }
        } catch (e) {
          _logger.w('⚠️ Failed to parse streaming message: $e. Message: $message');
        }
      }
    } catch (e, stackTrace) {
      _logger.e('❌ Streaming error for request $requestId', error: e, stackTrace: stackTrace);
      if (!controller.isClosed) controller.addError(e);
    } finally {
      await _cleanupStreamingRequest(requestId, controller);
    }
  }

  // ⏹️ STOP GENERATION
  Future<void> stopGeneration(String requestId) async {
    try {
      _logger.d('⏹️ Stopping generation for request: $requestId');
      final completer = _stopCompleters[requestId];
      if (completer != null && !completer.isCompleted) completer.complete();
      final channel = _streamingChannels[requestId];
      if (channel != null) {
        channel.sink.add(jsonEncode({'type': 'stop', 'id': requestId}));
        Timer(const Duration(milliseconds: 500), () => channel.sink.close());
      }
      _logger.i('✅ Generation stopped for request: $requestId');
    } catch (e) {
      _logger.e('❌ Failed to stop generation: $e');
    }
  }

  // 🧹 CLEANUP STREAMING REQUEST
  Future<void> _cleanupStreamingRequest(String requestId, StreamController<String> controller) async {
    try {
      if (!controller.isClosed) await controller.close();
      final channel = _streamingChannels.remove(requestId);
      if (channel != null) await channel.sink.close();
      _responseControllers.remove(requestId);
      _stopCompleters.remove(requestId);
      _logger.d('🧹 Cleaned up streaming request: $requestId');
    } catch (e) {
      _logger.w('⚠️ Cleanup error for request $requestId: $e');
    }
  }

  // 💬 SINGLE REQUEST (NON-STREAMING)
  Future<String> singleRequest(String prompt, AIModel model, ModelConfig config) async {
    try {
      _logger.d('💬 Sending single request to $model...');
      final stopwatch = Stopwatch()..start();
      String response;
      switch (model) {
        case AIModel.claude: response = await _sendClaudeRequest(prompt, config); break;
        case AIModel.gpt: response = await _sendOpenAIRequest(prompt, config); break;
        case AIModel.deepseek: response = await _sendDeepSeekRequest(prompt, config); break;
        case AIModel.gemini: response = await _sendGeminiRequest(prompt, config); break;
        case AIModel.mistral: response = await _sendMistralRequest(prompt, config); break;
        default:
          _logger.w('⚠️ Single request not directly supported for $model via this HTTP method.');
          throw UnsupportedError('Single requests not supported for $model via this method.');
      }
      stopwatch.stop();
      _recordResponseTime(model, stopwatch.elapsedMilliseconds);
      _recordRequest(model);
      _logger.i('✅ Single request completed for $model');
      return response;
    } catch (e, stackTrace) {
      _recordError(model);
      _logger.e('❌ Single request failed for $model', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<String> _sendClaudeRequest(String prompt, ModelConfig config) async {
    final response = await _dio.post(
      '${config.baseUrl}/v1/messages',
      options: Options(headers: {'x-api-key': config.apiKey, 'anthropic-version': '2023-06-01'}),
      data: {'model': 'claude-3-sonnet-20240307', 'max_tokens': config.maxTokens, 'temperature': config.temperature, 'messages': [{'role': 'user', 'content': prompt}]},
    );
    return response.data['content'][0]['text'] as String;
  }

  Future<String> _sendOpenAIRequest(String prompt, ModelConfig config) async {
    final response = await _dio.post(
      '${config.baseUrl}/v1/chat/completions',
      options: Options(headers: {'Authorization': 'Bearer ${config.apiKey}'}),
      data: {'model': 'gpt-4o', 'max_tokens': config.maxTokens, 'temperature': config.temperature, 'messages': [{'role': 'user', 'content': prompt}]},
    );
    return response.data['choices'][0]['message']['content'] as String;
  }

  Future<String> _sendDeepSeekRequest(String prompt, ModelConfig config) async {
    final response = await _dio.post(
      '${config.baseUrl}/v1/chat/completions',
      options: Options(headers: {'Authorization': 'Bearer ${config.apiKey}'}),
      data: {'model': 'deepseek-chat', 'max_tokens': config.maxTokens, 'temperature': config.temperature, 'messages': [{'role': 'user', 'content': prompt}]},
    );
    return response.data['choices'][0]['message']['content'] as String;
  }

  Future<String> _sendGeminiRequest(String prompt, ModelConfig config) async {
    final response = await _dio.post(
      '${config.baseUrl}/v1beta/models/gemini-pro:generateContent',
      options: Options(headers: {'x-goog-api-key': config.apiKey}),
      data: {'contents': [{'parts': [{'text': prompt}]}], 'generationConfig': {'maxOutputTokens': config.maxTokens, 'temperature': config.temperature}},
    );
    return response.data['candidates'][0]['content']['parts'][0]['text'] as String;
  }

  Future<String> _sendMistralRequest(String prompt, ModelConfig config) async {
    final response = await _dio.post(
      '${config.baseUrl}/v1/chat/completions',
      options: Options(headers: {'Authorization': 'Bearer ${config.apiKey}'}),
      data: {'model': 'mistral-medium', 'max_tokens': config.maxTokens, 'temperature': config.temperature, 'messages': [{'role': 'user', 'content': prompt}]},
    );
    return response.data['choices'][0]['message']['content'] as String;
  }

  // 📊 PERFORMANCE TRACKING
  void _recordResponseTime(AIModel model, int milliseconds) {
    _responseTimes.putIfAbsent(model, () => []).add(milliseconds);
    if (_responseTimes[model]!.length > 100) _responseTimes[model]!.removeAt(0);
  }

  void _recordRequest(AIModel model) {
    _requestCounts[model] = (_requestCounts[model] ?? 0) + 1;
  }

  void _recordError(AIModel model) {
    _errorCounts[model] = (_errorCounts[model] ?? 0) + 1;
  }

  // 📈 ANALYTICS
  Map<String, dynamic> getModelStatistics(AIModel model) {
    final responseTimes = _responseTimes[model] ?? [];
    final requestCount = _requestCounts[model] ?? 0;
    final errorCount = _errorCounts[model] ?? 0;
    return {
      'model': model.name,
      'request_count': requestCount,
      'error_count': errorCount,
      'success_rate': requestCount > 0 ? (requestCount - errorCount) / requestCount.toDouble() : 0.0,
      'average_response_time': responseTimes.isNotEmpty ? responseTimes.reduce((a, b) => a + b) / responseTimes.length.toDouble() : 0.0,
      'min_response_time': responseTimes.isNotEmpty ? responseTimes.reduce((a,b) => a < b ? a : b) : 0,
      'max_response_time': responseTimes.isNotEmpty ? responseTimes.reduce((a,b) => a > b ? a : b) : 0,
    };
  }

  Map<String, dynamic> getAllStatistics() {
    final stats = <String, dynamic>{};
    for (final model in AIModel.values) {
      stats[model.name] = getModelStatistics(model);
    }
    return stats;
  }

  // 🔄 RESET STATISTICS
  void resetStatistics([AIModel? model]) {
    if (model != null) {
      _responseTimes.remove(model);
      _requestCounts.remove(model);
      _errorCounts.remove(model);
    } else {
      _responseTimes.clear();
      _requestCounts.clear();
      _errorCounts.clear();
    }
    _logger.i('📊 Statistics reset for ${model?.name ?? 'all models'}');
  }

  // 🧹 CLEANUP
  Future<void> dispose() async {
    _logger.d('🧹 Disposing AI Service...');
    for (final entry in _streamingChannels.entries) {
      try { await entry.value.sink.close(); } catch (e) { _logger.w('⚠️ Error closing channel ${entry.key}: $e'); }
    }
    _streamingChannels.clear();
    for (final entry in _responseControllers.entries) {
      try { if (!entry.value.isClosed) await entry.value.close(); } catch (e) { _logger.w('⚠️ Error closing controller ${entry.key}: $e'); }
    }
    _responseControllers.clear();
    for (final completer in _stopCompleters.values) {
      if (!completer.isCompleted) completer.complete();
    }
    _stopCompleters.clear();
    _dio.close();
    _logger.i('✅ AI Service disposed successfully');
  }
}