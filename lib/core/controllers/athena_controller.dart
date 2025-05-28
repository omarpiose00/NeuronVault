// 🧠 NEURONVAULT - ATHENA INTELLIGENCE CONTROLLER
// PHASE 3.4: Athena Intelligence Engine - State Management & Orchestration
// Revolutionary AI autonomy state management with Riverpod integration

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../state/state_models.dart';
import '../services/athena_intelligence_service.dart';
import '../services/mini_llm_analyzer_service.dart';
import '../services/ai_service.dart';
import '../services/analytics_service.dart';
import '../providers/providers_main.dart';

/// 🎯 ATHENA CONTROLLER STATE
class AthenaControllerState {
  final bool isInitialized;
  final bool isAnalyzing;
  final bool autoApplyEnabled;
  final bool showDecisionTree;
  final AthenaRecommendation? currentRecommendation;
  final PromptAnalysis? currentAnalysis;
  final List<AthenaRecommendation> recentRecommendations;
  final Map<String, double> liveModelScores;
  final String? selectedDecisionNodeId;
  final DateTime? lastAnalysisTime;
  final String? lastError;
  final bool hasNewRecommendation;

  const AthenaControllerState({
    this.isInitialized = false,
    this.isAnalyzing = false,
    this.autoApplyEnabled = false,
    this.showDecisionTree = false,
    this.currentRecommendation,
    this.currentAnalysis,
    this.recentRecommendations = const [],
    this.liveModelScores = const {},
    this.selectedDecisionNodeId,
    this.lastAnalysisTime,
    this.lastError,
    this.hasNewRecommendation = false,
  });

  AthenaControllerState copyWith({
    bool? isInitialized,
    bool? isAnalyzing,
    bool? autoApplyEnabled,
    bool? showDecisionTree,
    AthenaRecommendation? currentRecommendation,
    PromptAnalysis? currentAnalysis,
    List<AthenaRecommendation>? recentRecommendations,
    Map<String, double>? liveModelScores,
    String? selectedDecisionNodeId,
    DateTime? lastAnalysisTime,
    String? lastError,
    bool? hasNewRecommendation,
  }) {
    return AthenaControllerState(
      isInitialized: isInitialized ?? this.isInitialized,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      autoApplyEnabled: autoApplyEnabled ?? this.autoApplyEnabled,
      showDecisionTree: showDecisionTree ?? this.showDecisionTree,
      currentRecommendation: currentRecommendation ?? this.currentRecommendation,
      currentAnalysis: currentAnalysis ?? this.currentAnalysis,
      recentRecommendations: recentRecommendations ?? this.recentRecommendations,
      liveModelScores: liveModelScores ?? this.liveModelScores,
      selectedDecisionNodeId: selectedDecisionNodeId ?? this.selectedDecisionNodeId,
      lastAnalysisTime: lastAnalysisTime ?? this.lastAnalysisTime,
      lastError: lastError ?? this.lastError,
      hasNewRecommendation: hasNewRecommendation ?? this.hasNewRecommendation,
    );
  }
}

/// 🧠 ATHENA INTELLIGENCE CONTROLLER
/// Manages AI autonomy state and orchestrates intelligent decision-making
class AthenaController extends AutoDisposeNotifier<AthenaControllerState> {
  late final AthenaIntelligenceService _athenaService;
  late final MiniLLMAnalyzerService _analyzerService;
  late final AIService _aiService;
  late final AnalyticsService _analyticsService;
  late final Logger _logger;

  // 📊 STREAM SUBSCRIPTIONS
  StreamSubscription<AthenaRecommendation>? _recommendationSubscription;
  StreamSubscription<PromptAnalysis>? _analysisSubscription;

  // ⏰ TIMERS
  Timer? _autoAnalysisTimer;
  Timer? _recommendationExpiryTimer;

  @override
  AthenaControllerState build() {
    // Initialize services
    _logger = ref.read(loggerProvider);
    _analyticsService = ref.read(analyticsServiceProvider);

    // Initialize Athena services
    _analyzerService = ref.read(miniLLMAnalyzerServiceProvider);
    _athenaService = ref.read(athenaIntelligenceServiceProvider);
    _aiService = ref.read(aiServiceProvider);

    // Initialize controller
    _initialize();

    // Setup cleanup
    ref.onDispose(() {
      _dispose();
    });

    return const AthenaControllerState();
  }

  /// 🚀 INITIALIZE ATHENA CONTROLLER
  Future<void> _initialize() async {
    try {
      _logger.i('🧠 Initializing Athena Intelligence Controller...');

      // Wait for services to be ready
      if (!_athenaService.state.isInitialized) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Setup stream subscriptions
      _setupStreamSubscriptions();

      // Listen to orchestration events
      _listenToOrchestrationEvents();

      // Mark as initialized
      state = state.copyWith(
        isInitialized: true,
        lastAnalysisTime: DateTime.now(),
      );

      _logger.i('✅ Athena Intelligence Controller initialized successfully');

      // Track achievement
      _trackAthenaInitializationAchievement();

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to initialize Athena Controller', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isInitialized: false,
        lastError: 'Initialization failed: ${e.toString()}',
      );
    }
  }

  /// 📡 SETUP STREAM SUBSCRIPTIONS
  void _setupStreamSubscriptions() {
    // Listen to recommendation stream
    _recommendationSubscription = _athenaService.recommendationStream.listen(
      _handleRecommendation,
      onError: _handleRecommendationError,
    );

    // Listen to analysis stream
    _analysisSubscription = _athenaService.analysisStream.listen(
      _handleAnalysis,
      onError: _handleAnalysisError,
    );
  }

  /// 👂 LISTEN TO ORCHESTRATION EVENTS
  void _listenToOrchestrationEvents() {
    // Listen to chat input changes for proactive analysis
    ref.listen<String>(currentInputProvider, (previous, next) {
      if (next.isNotEmpty && next.length > 20) {
        _scheduleProactiveAnalysis(next);
      }
    });

    // Listen to orchestration start
    ref.listen<bool>(isOrchestrationActiveProvider, (previous, next) {
      if (next && !state.isAnalyzing) {
        _handleOrchestrationStart();
      } else if (!next && state.isAnalyzing) {
        _handleOrchestrationComplete();
      }
    });

    // Listen to model changes for live scoring updates
    ref.listen<List<String>>(activeModelsProvider, (previous, next) {
      if (state.currentAnalysis != null) {
        _updateLiveModelScores();
      }
    });
  }

  /// 🎯 ANALYZE PROMPT - Main analysis method
  Future<AthenaRecommendation?> analyzePrompt(String prompt) async {
    if (!state.isInitialized || prompt.trim().isEmpty) {
      return null;
    }

    try {
      _logger.d('🧠 Athena analyzing prompt: "${prompt.substring(0, 50)}..."');

      state = state.copyWith(
        isAnalyzing: true,
        lastError: null,
        hasNewRecommendation: false,
      );

      final recommendation = await _athenaService.analyzeAndRecommend(prompt);

      _logger.i('✅ Athena analysis completed successfully');
      return recommendation;

    } catch (e, stackTrace) {
      _logger.e('❌ Athena analysis failed', error: e, stackTrace: stackTrace);

      state = state.copyWith(
        isAnalyzing: false,
        lastError: 'Analysis failed: ${e.toString()}',
      );

      return null;
    }
  }

  /// 🤖 AUTO-APPLY RECOMMENDATIONS
  Future<void> applyRecommendations({bool force = false}) async {
    if (!state.autoApplyEnabled && !force) {
      return;
    }

    final recommendation = state.currentRecommendation;
    if (recommendation == null) {
      _logger.w('⚠️ No recommendation to apply');
      return;
    }

    try {
      _logger.i('🤖 Applying Athena recommendations...');

      // Apply recommended models
      ref.read(activeModelsProvider.notifier).state = recommendation.recommendedModels;

      // Apply recommended strategy
      ref.read(currentStrategyProvider.notifier).state = recommendation.recommendedStrategy;

      // Apply model weights
      ref.read(modelWeightsProvider.notifier).state = recommendation.modelWeights;

      _logger.i('✅ Athena recommendations applied');
      _logger.d('🎯 Models: ${recommendation.recommendedModels.join(', ')}');
      _logger.d('📊 Strategy: ${recommendation.recommendedStrategy}');

      // Track analytics
      _analyticsService.trackEvent('athena_recommendations_applied', data: {
        'models_count': recommendation.recommendedModels.length,
        'strategy': recommendation.recommendedStrategy,
        'confidence': recommendation.overallConfidence,
        'auto_applied': !force,
      });

      // Track achievement
      _trackRecommendationAppliedAchievement();

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to apply recommendations', error: e, stackTrace: stackTrace);
    }
  }

  /// ⚙️ TOGGLE AUTO-APPLY
  void toggleAutoApply() {
    state = state.copyWith(
      autoApplyEnabled: !state.autoApplyEnabled,
    );

    _logger.i('🤖 Auto-apply ${state.autoApplyEnabled ? 'ENABLED' : 'DISABLED'}');

    // Track analytics
    _analyticsService.trackEvent('athena_auto_apply_toggled', data: {
      'enabled': state.autoApplyEnabled,
    });

    // Track achievement
    if (state.autoApplyEnabled) {
      _trackAutoApplyEnabledAchievement();
    }
  }

  /// 🌳 TOGGLE DECISION TREE
  void toggleDecisionTree() {
    state = state.copyWith(
      showDecisionTree: !state.showDecisionTree,
    );

    _logger.d('🌳 Decision tree ${state.showDecisionTree ? 'SHOWN' : 'HIDDEN'}');

    // Track analytics
    _analyticsService.trackEvent('athena_decision_tree_toggled', data: {
      'shown': state.showDecisionTree,
    });
  }

  /// 🎯 SELECT DECISION NODE
  void selectDecisionNode(String nodeId) {
    state = state.copyWith(
      selectedDecisionNodeId: nodeId,
    );

    _logger.d('🎯 Decision node selected: $nodeId');
  }

  /// 📊 UPDATE LIVE MODEL SCORES
  void _updateLiveModelScores() {
    final analysis = state.currentAnalysis;
    if (analysis == null) return;

    final activeModels = ref.read(activeModelsProvider);
    final liveScores = <String, double>{};

    for (final modelName in activeModels) {
      liveScores[modelName] = analysis.modelScores[modelName] ?? 0.5;
    }

    state = state.copyWith(liveModelScores: liveScores);
  }

  /// ⏰ SCHEDULE PROACTIVE ANALYSIS
  void _scheduleProactiveAnalysis(String input) {
    _autoAnalysisTimer?.cancel();

    // Analyze after user stops typing for 2 seconds
    _autoAnalysisTimer = Timer(const Duration(seconds: 2), () {
      if (input.length > 20) {
        analyzePrompt(input);
      }
    });
  }

  /// 📥 HANDLE RECOMMENDATION
  void _handleRecommendation(AthenaRecommendation recommendation) {
    final updatedRecommendations = [
      recommendation,
      ...state.recentRecommendations.take(9) // Keep last 10
    ];

    state = state.copyWith(
      isAnalyzing: false,
      currentRecommendation: recommendation,
      recentRecommendations: updatedRecommendations,
      lastAnalysisTime: DateTime.now(),
      hasNewRecommendation: true,
      lastError: null,
    );

    // Auto-apply if enabled
    if (state.autoApplyEnabled) {
      applyRecommendations();
    }

    // Set expiry timer for recommendation
    _setRecommendationExpiry();

    _logger.i('📥 New Athena recommendation received');
  }

  /// 📊 HANDLE ANALYSIS
  void _handleAnalysis(PromptAnalysis analysis) {
    state = state.copyWith(
      currentAnalysis: analysis,
    );

    _updateLiveModelScores();

    _logger.d('📊 Prompt analysis received: ${analysis.promptType} (${analysis.complexity})');
  }

  /// 🚨 HANDLE ERRORS
  void _handleRecommendationError(dynamic error) {
    _logger.e('❌ Recommendation stream error: $error');

    state = state.copyWith(
      isAnalyzing: false,
      lastError: 'Recommendation error: ${error.toString()}',
    );
  }

  void _handleAnalysisError(dynamic error) {
    _logger.e('❌ Analysis stream error: $error');

    state = state.copyWith(
      isAnalyzing: false,
      lastError: 'Analysis error: ${error.toString()}',
    );
  }

  /// 🎮 ORCHESTRATION EVENT HANDLERS
  void _handleOrchestrationStart() {
    _logger.d('🚀 Orchestration started - Athena monitoring');

    // Track orchestration start
    _analyticsService.trackEvent('athena_orchestration_monitored');
  }

  void _handleOrchestrationComplete() {
    _logger.d('✅ Orchestration completed - Athena analyzing results');

    // TODO: Analyze orchestration results for learning
    _analyzeOrchestrationResults();
  }

  /// 📊 ANALYZE ORCHESTRATION RESULTS
  void _analyzeOrchestrationResults() async {
    try {
      // Get orchestration results
      final individualResponses = await ref.read(individualResponsesProvider.future);
      final synthesizedResponse = await ref.read(synthesizedResponseProvider.future);

      if (individualResponses.isNotEmpty && synthesizedResponse.isNotEmpty) {
        // Calculate quality metrics
        final qualityScore = _calculateQualityScore(individualResponses, synthesizedResponse);

        // Record performance for learning
        final activeModels = ref.read(activeModelsProvider);
        final currentStrategy = ref.read(currentStrategyProvider);

        // TODO: Send results to Athena service for learning
        _logger.d('📊 Orchestration quality score: ${qualityScore.toStringAsFixed(2)}');
      }

    } catch (e) {
      _logger.w('⚠️ Failed to analyze orchestration results: $e');
    }
  }

  /// 📏 CALCULATE QUALITY SCORE
  double _calculateQualityScore(List<dynamic> responses, String synthesis) {
    // Simple quality scoring based on response characteristics
    double score = 0.5; // Base score

    // Response diversity bonus
    if (responses.length > 2) score += 0.1;
    if (responses.length > 3) score += 0.1;

    // Synthesis quality (simple heuristic)
    if (synthesis.length > 100) score += 0.1;
    if (synthesis.length > 500) score += 0.1;

    // Response consistency check
    final avgResponseLength = responses
        .map((r) => (r.content as String).length)
        .reduce((a, b) => a + b) / responses.length;

    if (avgResponseLength > 50) score += 0.1;

    return score.clamp(0.0, 1.0);
  }

  /// ⏰ SET RECOMMENDATION EXPIRY
  void _setRecommendationExpiry() {
    _recommendationExpiryTimer?.cancel();

    // Recommendations expire after 10 minutes
    _recommendationExpiryTimer = Timer(const Duration(minutes: 10), () {
      state = state.copyWith(
        hasNewRecommendation: false,
      );
      _logger.d('⏰ Recommendation expired');
    });
  }

  /// 🏆 ACHIEVEMENT TRACKING
  void _trackAthenaInitializationAchievement() {
    try {
      final tracker = ref.read(achievementTrackerProvider);
      tracker.trackFeatureUsage('athena_initialized');
    } catch (e) {
      _logger.w('⚠️ Achievement tracking error: $e');
    }
  }

  void _trackRecommendationAppliedAchievement() {
    try {
      final tracker = ref.read(achievementTrackerProvider);
      tracker.trackFeatureUsage('athena_recommendation_applied');
    } catch (e) {
      _logger.w('⚠️ Achievement tracking error: $e');
    }
  }

  void _trackAutoApplyEnabledAchievement() {
    try {
      final tracker = ref.read(achievementTrackerProvider);
      tracker.trackFeatureUsage('athena_auto_apply_enabled');
    } catch (e) {
      _logger.w('⚠️ Achievement tracking error: $e');
    }
  }

  /// 📊 GETTERS FOR UI
  bool get isReady => state.isInitialized && !state.isAnalyzing;
  bool get hasRecommendation => state.currentRecommendation != null;
  bool get hasActiveAnalysis => state.currentAnalysis != null;
  bool get canApplyRecommendations => hasRecommendation && isReady;

  String get statusText {
    if (!state.isInitialized) return 'Initializing Athena...';
    if (state.isAnalyzing) return 'Analyzing prompt...';
    if (state.lastError != null) return 'Error occurred';
    if (state.hasNewRecommendation) return 'New recommendation ready';
    if (hasRecommendation) return 'Recommendation available';
    return 'Ready for analysis';
  }

  /// 🧹 CLEANUP
  void _dispose() {
    _logger.d('🧹 Disposing Athena Controller...');

    _recommendationSubscription?.cancel();
    _analysisSubscription?.cancel();
    _autoAnalysisTimer?.cancel();
    _recommendationExpiryTimer?.cancel();

    _logger.d('✅ Athena Controller disposed');
  }
}

/// 🧠 ATHENA CONTROLLER PROVIDER
final athenaControllerProvider = NotifierProvider.autoDispose<AthenaController, AthenaControllerState>(
      () => AthenaController(),
);

/// 📊 COMPUTED PROVIDERS FOR UI
final athenaIsReadyProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(athenaControllerProvider.select((state) => state.isInitialized && !state.isAnalyzing));
});

final athenaCurrentRecommendationProvider = Provider.autoDispose<AthenaRecommendation?>((ref) {
  return ref.watch(athenaControllerProvider.select((state) => state.currentRecommendation));
});

final athenaCurrentAnalysisProvider = Provider.autoDispose<PromptAnalysis?>((ref) {
  return ref.watch(athenaControllerProvider.select((state) => state.currentAnalysis));
});

final athenaLiveModelScoresProvider = Provider.autoDispose<Map<String, double>>((ref) {
  return ref.watch(athenaControllerProvider.select((state) => state.liveModelScores));
});

final athenaAutoApplyEnabledProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(athenaControllerProvider.select((state) => state.autoApplyEnabled));
});

final athenaShowDecisionTreeProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(athenaControllerProvider.select((state) => state.showDecisionTree));
});

final athenaStatusTextProvider = Provider.autoDispose<String>((ref) {
  return ref.read(athenaControllerProvider.notifier).statusText;
});

final athenaHasNewRecommendationProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(athenaControllerProvider.select((state) => state.hasNewRecommendation));
});

final athenaRecentRecommendationsProvider = Provider.autoDispose<List<AthenaRecommendation>>((ref) {
  return ref.watch(athenaControllerProvider.select((state) => state.recentRecommendations));
});

/// 🎯 SPECIALIZED PROVIDERS FOR COMPLEX COMPUTATIONS
final athenaRecommendationConfidenceProvider = Provider.autoDispose<double>((ref) {
  final recommendation = ref.watch(athenaCurrentRecommendationProvider);
  return recommendation?.overallConfidence ?? 0.0;
});

final athenaTopModelProvider = Provider.autoDispose<String?>((ref) {
  final recommendation = ref.watch(athenaCurrentRecommendationProvider);
  if (recommendation?.modelWeights.isEmpty ?? true) return null;

  return recommendation!.modelWeights.entries
      .reduce((a, b) => a.value > b.value ? a : b)
      .key;
});

final athenaAnalysisComplexityProvider = Provider.autoDispose<String>((ref) {
  final analysis = ref.watch(athenaCurrentAnalysisProvider);
  return analysis?.complexity ?? 'unknown';
});

final athenaAnalysisTypeProvider = Provider.autoDispose<String>((ref) {
  final analysis = ref.watch(athenaCurrentAnalysisProvider);
  return analysis?.promptType ?? 'unknown';
});

/// 🧠 REQUIRED SERVICE PROVIDERS (to be added to providers_main.dart)
final miniLLMAnalyzerServiceProvider = Provider<MiniLLMAnalyzerService>((ref) {
  return MiniLLMAnalyzerService(
    aiService: ref.watch(aiServiceProvider),
    configService: ref.watch(configServiceProvider),
    logger: ref.watch(loggerProvider),
  );
});

final athenaIntelligenceServiceProvider = Provider<AthenaIntelligenceService>((ref) {
  return AthenaIntelligenceService(
    analyzerService: ref.watch(miniLLMAnalyzerServiceProvider),
    aiService: ref.watch(aiServiceProvider),
    configService: ref.watch(configServiceProvider),
    storageService: ref.watch(storageServiceProvider),
    analyticsService: ref.watch(analyticsServiceProvider),
    logger: ref.watch(loggerProvider),
  );
});