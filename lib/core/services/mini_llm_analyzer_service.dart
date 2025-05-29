// lib/core/services/mini_llm_analyzer_service.dart
// 🧠 NEURONVAULT - MINI-LLM ANALYZER SERVICE - PHASE 3.4 REVOLUTIONARY
// AI Autonomy Intelligence Engine - Fast prompt analysis with Claude Haiku
// Part of ATHENA INTELLIGENCE SYSTEM - World's first AI that selects AI

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

import '../state/state_models.dart';
import 'config_service.dart';
import 'storage_service.dart';

/// 🧠 PROMPT ANALYSIS RESULT
class PromptAnalysisResult {
  final String promptType;
  final double complexity;
  final List<String> recommendedModels;
  final Map<String, double> modelConfidenceScores;
  final String reasoningExplanation;
  final Duration analysisTime;
  final Map<String, dynamic> metadata;

  const PromptAnalysisResult({
    required this.promptType,
    required this.complexity,
    required this.recommendedModels,
    required this.modelConfidenceScores,
    required this.reasoningExplanation,
    required this.analysisTime,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'prompt_type': promptType,
    'complexity': complexity,
    'recommended_models': recommendedModels,
    'model_confidence_scores': modelConfidenceScores,
    'reasoning_explanation': reasoningExplanation,
    'analysis_time_ms': analysisTime.inMilliseconds,
    'metadata': metadata,
  };

  factory PromptAnalysisResult.fromJson(Map<String, dynamic> json) {
    return PromptAnalysisResult(
      promptType: json['prompt_type'] as String,
      complexity: (json['complexity'] as num).toDouble(),
      recommendedModels: List<String>.from(json['recommended_models'] as List),
      modelConfidenceScores: Map<String, double>.from(
          (json['model_confidence_scores'] as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, (v as num).toDouble()))
      ),
      reasoningExplanation: json['reasoning_explanation'] as String,
      analysisTime: Duration(milliseconds: json['analysis_time_ms'] as int),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
    );
  }
}

/// 🎯 PROMPT CLASSIFICATION TYPES
enum PromptType {
  creative,           // Creative writing, storytelling, artistic
  analytical,         // Data analysis, reasoning, logic
  technical,          // Programming, technical documentation
  conversational,     // Chat, Q&A, general discussion
  mathematical,       // Math problems, calculations
  research,           // Information gathering, summarization
  instructional,      // How-to, explanations, tutorials
  complex,            // Multi-faceted, requires multiple AI perspectives
}

/// 🔧 MODEL SPECIALIZATION PROFILES
class ModelSpecialization {
  static const Map<String, Map<PromptType, double>> profiles = {
    'claude': {
      PromptType.analytical: 0.95,
      PromptType.technical: 0.90,
      PromptType.research: 0.90,
      PromptType.instructional: 0.85,
      PromptType.conversational: 0.80,
      PromptType.creative: 0.75,
      PromptType.mathematical: 0.70,
      PromptType.complex: 0.90,
    },
    'gpt': {
      PromptType.conversational: 0.95,
      PromptType.creative: 0.90,
      PromptType.instructional: 0.85,
      PromptType.technical: 0.80,
      PromptType.analytical: 0.80,
      PromptType.research: 0.75,
      PromptType.mathematical: 0.75,
      PromptType.complex: 0.85,
    },
    'deepseek': {
      PromptType.technical: 0.95,
      PromptType.mathematical: 0.90,
      PromptType.analytical: 0.85,
      PromptType.research: 0.80,
      PromptType.instructional: 0.75,
      PromptType.conversational: 0.70,
      PromptType.creative: 0.65,
      PromptType.complex: 0.80,
    },
    'gemini': {
      PromptType.creative: 0.85,
      PromptType.conversational: 0.85,
      PromptType.research: 0.80,
      PromptType.analytical: 0.80,
      PromptType.instructional: 0.75,
      PromptType.technical: 0.75,
      PromptType.mathematical: 0.70,
      PromptType.complex: 0.80,
    },
    'mistral': {
      PromptType.analytical: 0.80,
      PromptType.technical: 0.75,
      PromptType.research: 0.75,
      PromptType.conversational: 0.75,
      PromptType.instructional: 0.70,
      PromptType.creative: 0.70,
      PromptType.mathematical: 0.65,
      PromptType.complex: 0.75,
    },
    'llama': {
      PromptType.conversational: 0.80,
      PromptType.creative: 0.75,
      PromptType.analytical: 0.70,
      PromptType.technical: 0.70,
      PromptType.research: 0.70,
      PromptType.instructional: 0.65,
      PromptType.mathematical: 0.60,
      PromptType.complex: 0.70,
    },
    'ollama': {
      PromptType.conversational: 0.75,
      PromptType.creative: 0.70,
      PromptType.analytical: 0.65,
      PromptType.technical: 0.65,
      PromptType.research: 0.65,
      PromptType.instructional: 0.60,
      PromptType.mathematical: 0.55,
      PromptType.complex: 0.65,
    },
  };

  static double getConfidence(String modelName, PromptType promptType) {
    return profiles[modelName.toLowerCase()]?[promptType] ?? 0.5;
  }
}

/// 🧠 MINI-LLM ANALYZER SERVICE - AI AUTONOMY FOUNDATION
class MiniLLMAnalyzerService {
  final ConfigService _configService;
  final StorageService _storageService;
  final Logger _logger;

  late final Dio _dio;
  final Map<String, int> _analysisCount = {};
  final Map<String, List<Duration>> _responseTimes = {};
  final Map<String, int> _cacheHits = {};

  // 🧠 Claude Haiku specific configuration
  static const String _claudeHaikuModel = 'claude-3-haiku-20240307';
  static const String _claudeApiVersion = '2023-06-01';
  static const int _maxAnalysisTokens = 150; // Keep analysis concise and fast
  static const Duration _analysisTimeout = Duration(milliseconds: 2000); // 2s max

  // 📈 Performance tracking
  final List<Duration> _recentAnalysisTimes = [];
  int _totalAnalyses = 0;
  int _cacheHitCount = 0;
  int _failureCount = 0;

  MiniLLMAnalyzerService({
    required ConfigService configService,
    required StorageService storageService,
    required Logger logger,
  })  : _configService = configService,
        _storageService = storageService,
        _logger = logger {
    _initializeHttpClient();
    _logger.i('🧠 MiniLLMAnalyzerService initialized - Athena Intelligence Engine ready');
  }

  /// 🔧 HTTP CLIENT INITIALIZATION
  void _initializeHttpClient() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: _analysisTimeout,
      sendTimeout: const Duration(seconds: 5),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'NeuronVault-Athena/3.4.0',
      },
    ));

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (obj) => _logger.d('🔗 Mini-LLM HTTP: $obj'),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          _logger.e('❌ Mini-LLM HTTP Error: ${error.message}');
          _failureCount++;
          handler.next(error);
        },
      ),
    );

    _logger.d('🔧 Mini-LLM HTTP client initialized with Claude Haiku integration');
  }

  /// 🧠 MAIN ANALYSIS METHOD - FAST PROMPT ANALYSIS
  Future<PromptAnalysisResult> analyzePrompt(
      String prompt, {
        List<String>? availableModels,
        bool useCache = true,
        Map<String, dynamic>? context,
      }) async {
    final stopwatch = Stopwatch()..start();

    try {
      _logger.d('🧠 Starting prompt analysis: "${prompt.length > 50 ? '${prompt.substring(0, 50)}...' : prompt}"');
      _totalAnalyses++;

      // 📊 Cache check for performance
      if (useCache) {
        final cachedResult = await _getCachedAnalysis(prompt);
        if (cachedResult != null) {
          _cacheHitCount++;
          _logger.d('💨 Cache hit for prompt analysis (${stopwatch.elapsedMilliseconds}ms)');
          return cachedResult;
        }
      }

      // 🎯 Fast heuristic analysis (local, instant)
      final heuristicResult = _performHeuristicAnalysis(prompt, availableModels ?? []);

      // 🧠 Enhanced analysis with Claude Haiku (if available and configured)
      PromptAnalysisResult finalResult;
      if (_isClaudeHaikuConfigured()) {
        try {
          final claudeEnhancedResult = await _performClaudeHaikuAnalysis(
            prompt,
            heuristicResult,
            availableModels ?? [],
            context,
          );
          finalResult = claudeEnhancedResult;
          _logger.d('✨ Claude Haiku enhanced analysis completed');
        } catch (e) {
          _logger.w('⚠️ Claude Haiku analysis failed, using heuristic: $e');
          finalResult = heuristicResult;
        }
      } else {
        finalResult = heuristicResult;
        _logger.d('💡 Using heuristic analysis (Claude Haiku not configured)');
      }

      stopwatch.stop();
      final analysisTime = stopwatch.elapsed;

      // 📊 Performance tracking
      _recentAnalysisTimes.add(analysisTime);
      if (_recentAnalysisTimes.length > 100) {
        _recentAnalysisTimes.removeAt(0);
      }

      // 💾 Cache result for future use
      if (useCache) {
        await _cacheAnalysisResult(prompt, finalResult);
      }

      _logger.i('🎯 Prompt analysis completed in ${analysisTime.inMilliseconds}ms');
      _logger.d('📊 Recommended models: ${finalResult.recommendedModels.join(', ')}');

      return PromptAnalysisResult(
        promptType: finalResult.promptType,
        complexity: finalResult.complexity,
        recommendedModels: finalResult.recommendedModels,
        modelConfidenceScores: finalResult.modelConfidenceScores,
        reasoningExplanation: finalResult.reasoningExplanation,
        analysisTime: analysisTime,
        metadata: {
          ...finalResult.metadata,
          'analysis_method': _isClaudeHaikuConfigured() ? 'claude_haiku_enhanced' : 'heuristic_only',
          'cache_used': false,
          'total_analyses': _totalAnalyses,
          'cache_hit_rate': _cacheHitCount / _totalAnalyses,
        },
      );

    } catch (e, stackTrace) {
      stopwatch.stop();
      _failureCount++;
      _logger.e('❌ Prompt analysis failed after ${stopwatch.elapsedMilliseconds}ms',
          error: e, stackTrace: stackTrace);

      // Return fallback analysis
      return _getFallbackAnalysis(prompt, availableModels ?? [], stopwatch.elapsed);
    }
  }

  /// 🎯 FAST HEURISTIC ANALYSIS (Local, <50ms)
  PromptAnalysisResult _performHeuristicAnalysis(String prompt, List<String> availableModels) {
    final promptLower = prompt.toLowerCase();
    final words = prompt.split(RegExp(r'\s+'));

    // 🔍 Keyword-based classification
    PromptType detectedType = PromptType.conversational; // Default
    double complexity = 0.5; // Default complexity

    // 🎨 Creative indicators
    if (_containsKeywords(promptLower, ['write', 'create', 'story', 'poem', 'creative', 'imagine', 'fiction'])) {
      detectedType = PromptType.creative;
      complexity = 0.6;
    }
    // 🔧 Technical indicators
    else if (_containsKeywords(promptLower, ['code', 'program', 'debug', 'api', 'function', 'algorithm', 'technical', 'implement'])) {
      detectedType = PromptType.technical;
      complexity = 0.8;
    }
    // 📊 Analytical indicators
    else if (_containsKeywords(promptLower, ['analyze', 'compare', 'evaluate', 'assess', 'reasoning', 'logic', 'data'])) {
      detectedType = PromptType.analytical;
      complexity = 0.7;
    }
    // 🔢 Mathematical indicators
    else if (_containsKeywords(promptLower, ['calculate', 'solve', 'equation', 'math', 'formula', 'number'])) {
      detectedType = PromptType.mathematical;
      complexity = 0.7;
    }
    // 📚 Research indicators
    else if (_containsKeywords(promptLower, ['research', 'find', 'information', 'summarize', 'explain', 'what is'])) {
      detectedType = PromptType.research;
      complexity = 0.6;
    }
    // 📖 Instructional indicators
    else if (_containsKeywords(promptLower, ['how to', 'step by step', 'guide', 'tutorial', 'instructions', 'teach'])) {
      detectedType = PromptType.instructional;
      complexity = 0.5;
    }

    // 📈 Complexity adjustment based on prompt characteristics
    if (words.length > 100) complexity += 0.2;
    if (prompt.contains('?') && prompt.split('?').length > 3) complexity += 0.1;
    if (_containsKeywords(promptLower, ['complex', 'detailed', 'comprehensive', 'thorough', 'advanced'])) {
      complexity += 0.2;
      if (complexity > 0.8) detectedType = PromptType.complex;
    }

    complexity = complexity.clamp(0.0, 1.0);

    // 🎯 Generate model recommendations based on specializations
    final modelScores = <String, double>{};
    final availableModelSet = Set<String>.from(availableModels.map((m) => m.toLowerCase()));

    for (final modelName in availableModelSet) {
      if (ModelSpecialization.profiles.containsKey(modelName)) {
        modelScores[modelName] = ModelSpecialization.getConfidence(modelName, detectedType);
      }
    }

    // 📊 Sort models by confidence score
    final sortedModels = modelScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final recommendedModels = sortedModels
        .where((entry) => entry.value >= 0.7) // Only recommend high-confidence models
        .map((entry) => entry.key)
        .take(3) // Top 3 recommendations
        .toList();

    // 📝 Generate reasoning explanation
    final reasoning = _generateHeuristicReasoning(detectedType, complexity, recommendedModels, modelScores);

    return PromptAnalysisResult(
      promptType: detectedType.name,
      complexity: complexity,
      recommendedModels: recommendedModels,
      modelConfidenceScores: modelScores,
      reasoningExplanation: reasoning,
      analysisTime: const Duration(milliseconds: 25), // Heuristic is very fast
      metadata: {
        'word_count': words.length,
        'analysis_method': 'heuristic',
        'detected_keywords': _getDetectedKeywords(promptLower),
      },
    );
  }

  /// 🧠 CLAUDE HAIKU ENHANCED ANALYSIS
  Future<PromptAnalysisResult> _performClaudeHaikuAnalysis(
      String prompt,
      PromptAnalysisResult heuristicResult,
      List<String> availableModels,
      Map<String, dynamic>? context,
      ) async {
    final claudeConfig = _configService.getModelConfig(AIModel.claude);

    if (claudeConfig == null || claudeConfig.apiKey.isEmpty) {
      throw Exception('Claude configuration not available');
    }

    final analysisPrompt = _buildClaudeAnalysisPrompt(prompt, heuristicResult, availableModels, context);

    final response = await _dio.post(
      '${claudeConfig.baseUrl}/v1/messages',
      options: Options(
        headers: {
          'x-api-key': claudeConfig.apiKey,
          'anthropic-version': _claudeApiVersion,
        },
      ),
      data: {
        'model': _claudeHaikuModel,
        'max_tokens': _maxAnalysisTokens,
        'temperature': 0.1, // Low temperature for consistent analysis
        'messages': [
          {
            'role': 'user',
            'content': analysisPrompt,
          }
        ],
      },
    );

    final claudeAnalysis = response.data['content'][0]['text'] as String;
    return _parseClaudeAnalysis(claudeAnalysis, heuristicResult, availableModels);
  }

  /// 📝 BUILD CLAUDE ANALYSIS PROMPT
  String _buildClaudeAnalysisPrompt(
      String prompt,
      PromptAnalysisResult heuristicResult,
      List<String> availableModels,
      Map<String, dynamic>? context,
      ) {
    return '''Analyze this prompt for AI model selection. Respond in JSON format only.

PROMPT TO ANALYZE: "$prompt"

AVAILABLE MODELS: ${availableModels.join(', ')}

HEURISTIC ANALYSIS: 
- Type: ${heuristicResult.promptType}
- Complexity: ${heuristicResult.complexity}
- Recommendations: ${heuristicResult.recommendedModels.join(', ')}

Provide JSON with:
{
  "prompt_type": "creative|analytical|technical|conversational|mathematical|research|instructional|complex",
  "complexity": 0.0-1.0,
  "recommended_models": ["model1", "model2", "model3"],
  "confidence_scores": {"model1": 0.95, "model2": 0.85},
  "reasoning": "Brief explanation of recommendations"
}

Focus on accuracy over verbosity. Consider model specializations:
- Claude: analytical, technical, research
- GPT: conversational, creative, general
- DeepSeek: technical, mathematical  
- Gemini: creative, research
- Others: balanced capabilities''';
  }

  /// 🔍 PARSE CLAUDE ANALYSIS RESPONSE
  PromptAnalysisResult _parseClaudeAnalysis(
      String claudeResponse,
      PromptAnalysisResult heuristicFallback,
      List<String> availableModels,
      ) {
    try {
      // Extract JSON from Claude's response
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(claudeResponse);
      if (jsonMatch == null) {
        throw Exception('No JSON found in Claude response');
      }

      final jsonData = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;

      final promptType = jsonData['prompt_type'] as String? ?? heuristicFallback.promptType;
      final complexity = (jsonData['complexity'] as num?)?.toDouble() ?? heuristicFallback.complexity;
      final recommendedModels = List<String>.from(jsonData['recommended_models'] as List? ?? heuristicFallback.recommendedModels);
      final confidenceScores = Map<String, double>.from(
          (jsonData['confidence_scores'] as Map<String, dynamic>? ?? heuristicFallback.modelConfidenceScores)
              .map((k, v) => MapEntry(k, (v as num).toDouble()))
      );
      final reasoning = jsonData['reasoning'] as String? ?? heuristicFallback.reasoningExplanation;

      return PromptAnalysisResult(
        promptType: promptType,
        complexity: complexity.clamp(0.0, 1.0),
        recommendedModels: recommendedModels.take(3).toList(),
        modelConfidenceScores: confidenceScores,
        reasoningExplanation: reasoning,
        analysisTime: const Duration(milliseconds: 1500), // Claude Haiku typical response time
        metadata: {
          'analysis_method': 'claude_haiku_enhanced',
          'claude_response_length': claudeResponse.length,
          'heuristic_agreement': _calculateAgreement(heuristicFallback, promptType, recommendedModels),
        },
      );

    } catch (e) {
      _logger.w('⚠️ Failed to parse Claude analysis, using heuristic fallback: $e');
      return heuristicFallback;
    }
  }

  /// 📊 UTILITY METHODS

  bool _containsKeywords(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  List<String> _getDetectedKeywords(String text) {
    final allKeywords = [
      'write', 'create', 'story', 'poem', 'creative', 'imagine', 'fiction',
      'code', 'program', 'debug', 'api', 'function', 'algorithm', 'technical',
      'analyze', 'compare', 'evaluate', 'assess', 'reasoning', 'logic', 'data',
      'calculate', 'solve', 'equation', 'math', 'formula', 'number',
      'research', 'find', 'information', 'summarize', 'explain',
      'how to', 'step by step', 'guide', 'tutorial', 'instructions',
    ];

    return allKeywords.where((keyword) => text.contains(keyword)).toList();
  }

  String _generateHeuristicReasoning(
      PromptType type,
      double complexity,
      List<String> recommendedModels,
      Map<String, double> scores,
      ) {
    final complexityDesc = complexity > 0.8 ? 'high' : complexity > 0.6 ? 'medium' : 'low';

    return 'Detected ${type.name} prompt with $complexityDesc complexity. '
        'Recommended ${recommendedModels.length} models based on specialization scores: '
        '${recommendedModels.map((m) => '$m (${(scores[m] ?? 0).toStringAsFixed(2)})').join(', ')}.';
  }

  double _calculateAgreement(
      PromptAnalysisResult heuristic,
      String claudeType,
      List<String> claudeModels,
      ) {
    double agreement = 0.0;

    // Type agreement
    if (heuristic.promptType == claudeType) agreement += 0.5;

    // Model agreement
    final heuristicSet = Set<String>.from(heuristic.recommendedModels);
    final claudeSet = Set<String>.from(claudeModels);
    final intersection = heuristicSet.intersection(claudeSet);
    agreement += (intersection.length / heuristicSet.union(claudeSet).length) * 0.5;

    return agreement.clamp(0.0, 1.0);
  }

  bool _isClaudeHaikuConfigured() {
    final config = _configService.getModelConfig(AIModel.claude);
    return config != null && config.apiKey.isNotEmpty;
  }

  /// 💾 CACHING METHODS

  Future<PromptAnalysisResult?> _getCachedAnalysis(String prompt) async {
    try {
      final cacheKey = 'prompt_analysis_${prompt.hashCode}';
      final cachedJson = await _storageService.getString(cacheKey);

      if (cachedJson != null) {
        final result = PromptAnalysisResult.fromJson(jsonDecode(cachedJson));
        // Cache valid for 1 hour
        if (DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(
          result.metadata['cached_at'] as int? ?? 0,
        )).inHours < 1) {
          return result;
        }
      }
    } catch (e) {
      _logger.w('⚠️ Cache retrieval failed: $e');
    }
    return null;
  }

  Future<void> _cacheAnalysisResult(String prompt, PromptAnalysisResult result) async {
    try {
      final cacheKey = 'prompt_analysis_${prompt.hashCode}';
      final resultWithTimestamp = PromptAnalysisResult(
        promptType: result.promptType,
        complexity: result.complexity,
        recommendedModels: result.recommendedModels,
        modelConfidenceScores: result.modelConfidenceScores,
        reasoningExplanation: result.reasoningExplanation,
        analysisTime: result.analysisTime,
        metadata: {
          ...result.metadata,
          'cached_at': DateTime.now().millisecondsSinceEpoch,
        },
      );

      await _storageService.setString(cacheKey, jsonEncode(resultWithTimestamp.toJson()));
    } catch (e) {
      _logger.w('⚠️ Cache storage failed: $e');
    }
  }

  /// 🛡️ FALLBACK ANALYSIS
  PromptAnalysisResult _getFallbackAnalysis(String prompt, List<String> availableModels, Duration elapsed) {
    return PromptAnalysisResult(
      promptType: 'conversational',
      complexity: 0.5,
      recommendedModels: availableModels.take(2).toList(),
      modelConfidenceScores: {
        for (final model in availableModels.take(3)) model: 0.6
      },
      reasoningExplanation: 'Fallback analysis due to service error. Using conservative recommendations.',
      analysisTime: elapsed,
      metadata: {
        'analysis_method': 'fallback',
        'error_recovery': true,
        'failure_count': _failureCount,
      },
    );
  }

  /// 📊 ANALYTICS & PERFORMANCE

  Map<String, dynamic> getAnalyticsData() {
    final avgResponseTime = _recentAnalysisTimes.isNotEmpty
        ? _recentAnalysisTimes.fold<int>(0, (sum, time) => sum + time.inMilliseconds) / _recentAnalysisTimes.length
        : 0.0;

    return {
      'total_analyses': _totalAnalyses,
      'cache_hit_rate': _totalAnalyses > 0 ? _cacheHitCount / _totalAnalyses : 0.0,
      'failure_rate': _totalAnalyses > 0 ? _failureCount / _totalAnalyses : 0.0,
      'average_response_time_ms': avgResponseTime,
      'min_response_time_ms': _recentAnalysisTimes.isNotEmpty
          ? _recentAnalysisTimes.map((t) => t.inMilliseconds).reduce((a, b) => a < b ? a : b)
          : 0,
      'max_response_time_ms': _recentAnalysisTimes.isNotEmpty
          ? _recentAnalysisTimes.map((t) => t.inMilliseconds).reduce((a, b) => a > b ? a : b)
          : 0,
      'claude_haiku_configured': _isClaudeHaikuConfigured(),
      'recent_analyses_count': _recentAnalysisTimes.length,
    };
  }

  void resetAnalytics() {
    _recentAnalysisTimes.clear();
    _totalAnalyses = 0;
    _cacheHitCount = 0;
    _failureCount = 0;
    _logger.i('📊 MiniLLMAnalyzerService analytics reset');
  }

  /// 🧹 CLEANUP
  Future<void> dispose() async {
    _logger.d('🧹 Disposing MiniLLMAnalyzerService...');

    try {
      _dio.close();
      _recentAnalysisTimes.clear();
      _analysisCount.clear();
      _responseTimes.clear();
      _cacheHits.clear();

      _logger.i('✅ MiniLLMAnalyzerService disposed successfully');
    } catch (e) {
      _logger.e('❌ Error disposing MiniLLMAnalyzerService: $e');
    }
  }
}