// lib/core/controllers/athena_controller.dart
// 🧠 NEURONVAULT - ATHENA CONTROLLER - PHASE 3.4 REVOLUTIONARY
// AI Autonomy State Management - Riverpod 2.x Controller Pattern
// Manages Athena Intelligence System state and interactions

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../services/athena_intelligence_service.dart';
import '../services/mini_llm_analyzer_service.dart';
import '../state/state_models.dart';

/// 🧠 ATHENA SYSTEM STATE
enum AthenaSystemState {
  initializing,
  ready,
  analyzing,
  recommending,
  learning,
  error,
  disabled,
}

/// 🎯 ATHENA RECOMMENDATION STATE
class AthenaRecommendationState {
  final bool isActive;
  final AthenaSystemState systemState;
  final AIRecommendationResult? currentRecommendation;
  final PromptAnalysisResult? currentAnalysis;
  final bool isAutoModeEnabled;
  final double systemConfidence;
  final List<DecisionTreeNode> decisionTree;
  final String? errorMessage;
  final DateTime? lastRecommendationTime;
  final Map<String, dynamic> systemMetrics;

  const AthenaRecommendationState({
    this.isActive = false,
    this.systemState = AthenaSystemState.initializing,
    this.currentRecommendation,
    this.currentAnalysis,
    this.isAutoModeEnabled = false,
    this.systemConfidence = 0.0,
    this.decisionTree = const [],
    this.errorMessage,
    this.lastRecommendationTime,
    this.systemMetrics = const {},
  });

  AthenaRecommendationState copyWith({
    bool? isActive,
    AthenaSystemState? systemState,
    AIRecommendationResult? currentRecommendation,
    PromptAnalysisResult? currentAnalysis,
    bool? isAutoModeEnabled,
    double? systemConfidence,
    List<DecisionTreeNode>? decisionTree,
    String? errorMessage,
    DateTime? lastRecommendationTime,
    Map<String, dynamic>? systemMetrics,
  }) {
    return AthenaRecommendationState(
      isActive: isActive ?? this.isActive,
      systemState: systemState ?? this.systemState,
      currentRecommendation: currentRecommendation ?? this.currentRecommendation,
      currentAnalysis: currentAnalysis ?? this.currentAnalysis,
      isAutoModeEnabled: isAutoModeEnabled ?? this.isAutoModeEnabled,
      systemConfidence: systemConfidence ?? this.systemConfidence,
      decisionTree: decisionTree ?? this.decisionTree,
      errorMessage: errorMessage ?? this.errorMessage,
      lastRecommendationTime: lastRecommendationTime ?? this.lastRecommendationTime,
      systemMetrics: systemMetrics ?? this.systemMetrics,
    );
  }

  Map<String, dynamic> toJson() => {
    'is_active': isActive,
    'system_state': systemState.name,
    'current_recommendation': currentRecommendation?.toJson(),
    'current_analysis': currentAnalysis?.toJson(),
    'is_auto_mode_enabled': isAutoModeEnabled,
    'system_confidence': systemConfidence,
    'decision_tree': decisionTree.map((node) => node.toJson()).toList(),
    'error_message': errorMessage,
    'last_recommendation_time': lastRecommendationTime?.toIso8601String(),
    'system_metrics': systemMetrics,
  };
}

/// 🧠 ATHENA CONTROLLER - AI AUTONOMY STATE MANAGER
class AthenaController extends ChangeNotifier {
  final AthenaIntelligenceService _athenaService;
  final MiniLLMAnalyzerService _miniLLMService;
  final Logger _logger;

  // State
  AthenaRecommendationState _state = const AthenaRecommendationState();

  // Subscriptions
  StreamSubscription<AIRecommendationResult>? _recommendationSubscription;
  Timer? _metricsUpdateTimer;

  // Configuration
  static const Duration _metricsUpdateInterval = Duration(seconds: 30);
  static const Duration _recommendationTimeout = Duration(seconds: 10);

  // Getters
  AthenaRecommendationState get state => _state;
  bool get isActive => _state.isActive;
  bool get isAutoModeEnabled => _state.isAutoModeEnabled;
  AIRecommendationResult? get currentRecommendation => _state.currentRecommendation;
  List<DecisionTreeNode> get decisionTree => _state.decisionTree;
  double get systemConfidence => _state.systemConfidence;

  AthenaController({
    required AthenaIntelligenceService athenaService,
    required MiniLLMAnalyzerService miniLLMService,
    required Logger logger,
  })  : _athenaService = athenaService,
        _miniLLMService = miniLLMService,
        _logger = logger {
    _initializeController();
    _logger.i('🧠 AthenaController initialized - AI Autonomy state management ready');
  }

  /// 🚀 INITIALIZATION
  Future<void> _initializeController() async {
    try {
      _updateState(_state.copyWith(systemState: AthenaSystemState.initializing));

      // Listen to Athena service changes
      _athenaService.addListener(_onAthenaServiceUpdate);

      // Start metrics update timer
      _startMetricsTimer();

      // System ready
      _updateState(_state.copyWith(
        systemState: AthenaSystemState.ready,
        isAutoModeEnabled: _athenaService.isAutoModeEnabled,
      ));

      _logger.i('✅ AthenaController initialization completed');

    } catch (e) {
      _logger.e('❌ AthenaController initialization failed: $e');
      _updateState(_state.copyWith(
        systemState: AthenaSystemState.error,
        errorMessage: 'Initialization failed: $e',
      ));
    }
  }

  /// 🎯 CORE RECOMMENDATION METHOD
  Future<AIRecommendationResult?> requestRecommendation(
      String prompt, {
        required List<String> availableModels,
        List<String>? currentActiveModels,
        String? currentStrategy,
        Map<String, double>? currentWeights,
        Map<String, dynamic>? context,
      }) async {
    if (_state.systemState == AthenaSystemState.analyzing ||
        _state.systemState == AthenaSystemState.recommending) {
      _logger.w('⚠️ Recommendation already in progress, ignoring new request');
      return null;
    }

    try {
      _logger.d('🧠 Requesting AI recommendation for prompt: "${_truncatePrompt(prompt)}"');

      // Update state to analyzing
      _updateState(_state.copyWith(
        systemState: AthenaSystemState.analyzing,
        errorMessage: null,
      ));

      // Generate recommendation with timeout
      final recommendation = await _athenaService.generateAIRecommendation(
        prompt,
        availableModels: availableModels,
        currentActiveModels: currentActiveModels,
        currentStrategy: currentStrategy,
        currentWeights: currentWeights,
        context: context,
      ).timeout(_recommendationTimeout);

      // Update state with recommendation
      _updateState(_state.copyWith(
        systemState: AthenaSystemState.ready,
        currentRecommendation: recommendation,
        systemConfidence: recommendation.overallConfidence,
        decisionTree: recommendation.decisionTree,
        lastRecommendationTime: DateTime.now(),
      ));

      _logger.i('🎯 AI recommendation completed with ${(recommendation.overallConfidence * 100).round()}% confidence');

      // Check if should auto-apply
      if (_athenaService.shouldAutoApply(recommendation)) {
        _logger.i('🤖 Auto-applying recommendation (confidence: ${(recommendation.overallConfidence * 100).round()}%)');
        await _recordAutoApplication(recommendation);
      }

      return recommendation;

    } catch (e) {
      _logger.e('❌ AI recommendation failed: $e');
      _updateState(_state.copyWith(
        systemState: AthenaSystemState.error,
        errorMessage: 'Recommendation failed: $e',
      ));
      return null;
    }
  }

  /// 🔍 PROMPT ANALYSIS METHOD
  Future<PromptAnalysisResult?> analyzePrompt(
      String prompt, {
        List<String>? availableModels,
        Map<String, dynamic>? context,
      }) async {
    try {
      _logger.d('🔍 Analyzing prompt: "${_truncatePrompt(prompt)}"');

      _updateState(_state.copyWith(systemState: AthenaSystemState.analyzing));

      final analysis = await _miniLLMService.analyzePrompt(
        prompt,
        availableModels: availableModels,
        context: context,
      );

      _updateState(_state.copyWith(
        systemState: AthenaSystemState.ready,
        currentAnalysis: analysis,
      ));

      _logger.d('✅ Prompt analysis completed: ${analysis.promptType} (${(analysis.complexity * 100).round()}% complexity)');

      return analysis;

    } catch (e) {
      _logger.e('❌ Prompt analysis failed: $e');
      _updateState(_state.copyWith(
        systemState: AthenaSystemState.error,
        errorMessage: 'Analysis failed: $e',
      ));
      return null;
    }
  }

  /// 🎛️ AUTO MODE CONTROL
  Future<void> toggleAutoMode() async {
    try {
      final newAutoMode = !_state.isAutoModeEnabled;
      await _athenaService.setAutoMode(newAutoMode);

      _updateState(_state.copyWith(isAutoModeEnabled: newAutoMode));

      _logger.i('🎛️ Auto mode ${newAutoMode ? 'enabled' : 'disabled'}');

    } catch (e) {
      _logger.e('❌ Failed to toggle auto mode: $e');
    }
  }

  /// 👤 USER INTERACTION METHODS

  Future<void> recordUserOverride(
      AIRecommendationResult originalRecommendation,
      List<String> userSelectedModels,
      String userSelectedStrategy,
      ) async {
    try {
      _athenaService.recordUserOverride();

      _logger.d('👤 User override recorded: ${userSelectedModels.join(', ')} with $userSelectedStrategy');

      // This is a learning opportunity - record the user preference
      // Note: We might want to implement user preference learning in the future

    } catch (e) {
      _logger.e('❌ Failed to record user override: $e');
    }
  }

  Future<void> recordOrchestrationOutcome({
    required String prompt,
    required List<String> usedModels,
    required String usedStrategy,
    required double qualityScore,
    Map<String, dynamic>? context,
  }) async {
    try {
      _updateState(_state.copyWith(systemState: AthenaSystemState.learning));

      await _athenaService.recordOrchestrationOutcome(
        prompt: prompt,
        usedModels: usedModels,
        usedStrategy: usedStrategy,
        qualityScore: qualityScore,
        context: context,
      );

      _updateState(_state.copyWith(systemState: AthenaSystemState.ready));

      _logger.d('📚 Orchestration outcome recorded for learning');

    } catch (e) {
      _logger.e('❌ Failed to record orchestration outcome: $e');
      _updateState(_state.copyWith(systemState: AthenaSystemState.ready));
    }
  }

  /// 🤖 AUTO-APPLICATION TRACKING
  Future<void> _recordAutoApplication(AIRecommendationResult recommendation) async {
    try {
      _athenaService.recordAutoApplication();

      // You might want to emit an event or callback here for the UI to apply the recommendation
      // For now, we just log it
      _logger.i('🤖 Auto-application recorded for models: ${recommendation.recommendedModels.join(', ')}');

    } catch (e) {
      _logger.e('❌ Failed to record auto-application: $e');
    }
  }

  /// 📊 METRICS AND ANALYTICS

  void _startMetricsTimer() {
    _metricsUpdateTimer?.cancel();
    _metricsUpdateTimer = Timer.periodic(_metricsUpdateInterval, (_) => _updateSystemMetrics());
  }

  void _updateSystemMetrics() {
    try {
      final athenaAnalytics = _athenaService.getAthenaAnalytics();
      final miniLLMAnalytics = _miniLLMService.getAnalyticsData();

      final combinedMetrics = {
        'athena': athenaAnalytics,
        'mini_llm': miniLLMAnalytics,
        'controller': {
          'state': _state.systemState.name,
          'last_update': DateTime.now().toIso8601String(),
          'uptime_seconds': DateTime.now().difference(_initTime).inSeconds,
        },
      };

      _updateState(_state.copyWith(systemMetrics: combinedMetrics));

    } catch (e) {
      _logger.w('⚠️ Failed to update system metrics: $e');
    }
  }

  late final DateTime _initTime = DateTime.now();

  Map<String, dynamic> getSystemStatus() {
    return {
      'system_state': _state.systemState.name,
      'is_active': _state.isActive,
      'auto_mode_enabled': _state.isAutoModeEnabled,
      'system_confidence': _state.systemConfidence,
      'has_current_recommendation': _state.currentRecommendation != null,
      'has_current_analysis': _state.currentAnalysis != null,
      'decision_tree_nodes': _state.decisionTree.length,
      'error_message': _state.errorMessage,
      'last_recommendation_time': _state.lastRecommendationTime?.toIso8601String(),
      'uptime_seconds': DateTime.now().difference(_initTime).inSeconds,
    };
  }

  /// 🎯 SYSTEM CONTROL METHODS

  Future<void> activateSystem() async {
    try {
      _updateState(_state.copyWith(
        isActive: true,
        systemState: AthenaSystemState.ready,
        errorMessage: null,
      ));

      _logger.i('🚀 Athena Intelligence System activated');

    } catch (e) {
      _logger.e('❌ Failed to activate Athena system: $e');
    }
  }

  Future<void> deactivateSystem() async {
    try {
      _updateState(_state.copyWith(
        isActive: false,
        systemState: AthenaSystemState.disabled,
      ));

      _logger.i('⏸️ Athena Intelligence System deactivated');

    } catch (e) {
      _logger.e('❌ Failed to deactivate Athena system: $e');
    }
  }

  Future<void> resetSystem() async {
    try {
      _updateState(const AthenaRecommendationState(
        systemState: AthenaSystemState.ready,
        isActive: true,
      ));

      _logger.i('🔄 Athena Intelligence System reset');

    } catch (e) {
      _logger.e('❌ Failed to reset Athena system: $e');
    }
  }

  /// 🔧 UTILITY METHODS

  void _updateState(AthenaRecommendationState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void _onAthenaServiceUpdate() {
    // Handle updates from the Athena service
    try {
      _updateState(_state.copyWith(
        isAutoModeEnabled: _athenaService.isAutoModeEnabled,
        currentRecommendation: _athenaService.lastRecommendation,
      ));
    } catch (e) {
      _logger.w('⚠️ Error handling Athena service update: $e');
    }
  }

  String _truncatePrompt(String prompt, {int maxLength = 50}) {
    return prompt.length > maxLength ? '${prompt.substring(0, maxLength)}...' : prompt;
  }

  /// 🧠 ADVANCED FEATURES

  /// Get decision explanation for transparency
  String getDecisionExplanation() {
    if (_state.currentRecommendation == null) {
      return 'No current recommendation available.';
    }

    final recommendation = _state.currentRecommendation!;
    final explanation = StringBuffer();

    explanation.writeln('🧠 AI Decision Analysis:');
    explanation.writeln('');
    explanation.writeln('📊 Confidence: ${(recommendation.overallConfidence * 100).round()}%');
    explanation.writeln('⏱️ Decision Time: ${recommendation.decisionTime.inMilliseconds}ms');
    explanation.writeln('');
    explanation.writeln('🎯 Recommendations:');
    explanation.writeln('• Models: ${recommendation.recommendedModels.join(', ')}');
    explanation.writeln('• Strategy: ${recommendation.recommendedStrategy}');
    explanation.writeln('');
    explanation.writeln('🧬 Reasoning:');
    explanation.writeln(recommendation.decisionReasoning);

    if (_state.decisionTree.isNotEmpty) {
      explanation.writeln('');
      explanation.writeln('🌳 Decision Tree:');
      for (final node in _state.decisionTree) {
        explanation.writeln('• ${node.question} → ${node.answer} (${(node.confidence * 100).round()}%)');
      }
    }

    return explanation.toString();
  }

  /// Export system state for debugging
  Map<String, dynamic> exportSystemState() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'state': _state.toJson(),
      'system_status': getSystemStatus(),
      'system_metrics': _state.systemMetrics,
    };
  }

  /// 🧹 CLEANUP

  @override
  Future<void> dispose() async {
    try {
      _metricsUpdateTimer?.cancel();
      _recommendationSubscription?.cancel();
      _athenaService.removeListener(_onAthenaServiceUpdate);

      _logger.i('✅ AthenaController disposed successfully');
    } catch (e) {
      _logger.e('❌ Error disposing AthenaController: $e');
    }

    super.dispose();
  }
}