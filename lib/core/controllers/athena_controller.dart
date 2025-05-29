// 🎮 NEURONVAULT - ATHENA CONTROLLER - PHASE 3.4
// AI Autonomy State Management Layer with Riverpod integration
// Neural luxury reactive state management for world's first AI autonomy

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../services/athena_intelligence_service.dart';

/// 🎯 Athena UI State for reactive interface
enum AthenaUIState {
  disabled,      // Athena is turned off
  idle,         // Enabled but not active
  analyzing,    // Currently analyzing prompt
  recommending, // Generating recommendations
  ready,        // Recommendations ready for review/apply
  applying,     // Applying recommendations
  error,        // Error state
}

/// 🎛️ Athena Controller State combining service state with UI state
class AthenaControllerState {
  final AthenaUIState uiState;
  final AthenaState serviceState;
  final String? errorMessage;
  final bool autoApplyEnabled;
  final double autoApplyThreshold;
  final List<String> recentPromptCategories;
  final Map<String, int> categoryUsageStats;

  const AthenaControllerState({
    required this.uiState,
    required this.serviceState,
    this.errorMessage,
    required this.autoApplyEnabled,
    required this.autoApplyThreshold,
    required this.recentPromptCategories,
    required this.categoryUsageStats,
  });

  AthenaControllerState.initial()
      : uiState = AthenaUIState.disabled,
        serviceState = AthenaState.initial(), // Removed const
        errorMessage = null,
        autoApplyEnabled = false,
        autoApplyThreshold = 0.8,
        recentPromptCategories = const [],
        categoryUsageStats = const {};
  AthenaControllerState copyWith({
    AthenaUIState? uiState,
    AthenaState? serviceState,
    String? errorMessage,
    bool? autoApplyEnabled,
    double? autoApplyThreshold,
    List<String>? recentPromptCategories,
    Map<String, int>? categoryUsageStats,
  }) {
    return AthenaControllerState(
      uiState: uiState ?? this.uiState,
      serviceState: serviceState ?? this.serviceState,
      errorMessage: errorMessage,
      autoApplyEnabled: autoApplyEnabled ?? this.autoApplyEnabled,
      autoApplyThreshold: autoApplyThreshold ?? this.autoApplyThreshold,
      recentPromptCategories: recentPromptCategories ?? this.recentPromptCategories,
      categoryUsageStats: categoryUsageStats ?? this.categoryUsageStats,
    );
  }

  // Computed properties for UI
  bool get isEnabled => serviceState.isEnabled;
  bool get isAnalyzing => uiState == AthenaUIState.analyzing || uiState == AthenaUIState.recommending;
  bool get hasRecommendation => serviceState.currentRecommendation != null;
  bool get hasError => uiState == AthenaUIState.error;
  bool get canApplyRecommendation => hasRecommendation && uiState == AthenaUIState.ready;

  AthenaRecommendation? get currentRecommendation => serviceState.currentRecommendation;
  List<AthenaDecision> get recentDecisions => serviceState.decisionHistory.take(10).toList();

  double get averageConfidence {
    if (serviceState.decisionHistory.isEmpty) return 0.0;
    final confidences = serviceState.decisionHistory.map((d) => d.confidenceScore);
    return confidences.reduce((a, b) => a + b) / confidences.length;
  }
}

/// 🧠 ATHENA CONTROLLER - AI AUTONOMY STATE MANAGEMENT
class AthenaController extends StateNotifier<AthenaControllerState> {
  final AthenaIntelligenceService _athenaService;
  final Logger _logger;

  // 📡 Stream subscriptions for reactive updates
  StreamSubscription<AthenaState>? _stateSubscription;
  StreamSubscription<AthenaRecommendation>? _recommendationSubscription;
  StreamSubscription<AthenaDecision>? _decisionSubscription;

  // 📊 Local tracking for UI enhancements
  final Map<String, int> _categoryUsage = {};
  final List<String> _recentCategories = [];

  AthenaController(
      this._athenaService,
      this._logger,
      ) : super(AthenaControllerState.initial()) {
    _initializeController();
  }

  /// 🚀 Initialize controller and set up reactive streams
  void _initializeController() {
    _logger.i('🎮 Initializing Athena Controller...');

    // Subscribe to service state changes
    _stateSubscription = _athenaService.stateStream.listen(
      _handleServiceStateChange,
      onError: _handleStreamError,
    );

    // Subscribe to recommendation updates
    _recommendationSubscription = _athenaService.recommendationStream.listen(
      _handleRecommendationUpdate,
      onError: _handleStreamError,
    );

    // Subscribe to decision updates
    _decisionSubscription = _athenaService.decisionStream.listen(
      _handleDecisionUpdate,
      onError: _handleStreamError,
    );

    // Initialize with current service state
    _updateStateFromService(_athenaService.state);

    _logger.i('✅ Athena Controller initialized successfully');
  }

  /// 🔄 Handle service state changes
  void _handleServiceStateChange(AthenaState serviceState) {
    _logger.d('🔄 Service state changed: enabled=${serviceState.isEnabled}, analyzing=${serviceState.isAnalyzing}');
    _updateStateFromService(serviceState);
  }

  /// 📥 Handle new recommendations
  void _handleRecommendationUpdate(AthenaRecommendation recommendation) {
    _logger.d('📥 New recommendation received for ${recommendation.analysis.primaryCategory.name} prompt');

    // Track category usage
    final category = recommendation.analysis.primaryCategory.name;
    _categoryUsage[category] = (_categoryUsage[category] ?? 0) + 1;

    // Update recent categories
    _recentCategories.add(category);
    if (_recentCategories.length > 20) {
      _recentCategories.removeAt(0);
    }

    // Update UI state
    AthenaUIState newUIState;
    if (recommendation.autoApplyRecommended && state.autoApplyEnabled) {
      newUIState = AthenaUIState.applying;
      // Auto-apply will be handled separately
    } else {
      newUIState = AthenaUIState.ready;
    }

    state = state.copyWith(
      uiState: newUIState,
      serviceState: _athenaService.state,
      errorMessage: null,
      recentPromptCategories: List.from(_recentCategories),
      categoryUsageStats: Map.from(_categoryUsage),
    );

    // Auto-apply if enabled and confident
    if (recommendation.autoApplyRecommended && state.autoApplyEnabled) {
      _autoApplyRecommendation(recommendation);
    }
  }

  /// 📊 Handle decision updates
  void _handleDecisionUpdate(AthenaDecision decision) {
    _logger.d('📊 New decision: ${decision.type.name} (confidence: ${decision.confidenceScore.toStringAsFixed(2)})');

    // Update state with latest service state
    state = state.copyWith(
      serviceState: _athenaService.state,
    );
  }

  /// ❌ Handle stream errors
  void _handleStreamError(dynamic error) {
    _logger.e('❌ Athena stream error: $error');

    state = state.copyWith(
      uiState: AthenaUIState.error,
      errorMessage: error.toString(),
    );
  }

  /// 🔄 Update state from service state
  void _updateStateFromService(AthenaState serviceState) {
    AthenaUIState newUIState;

    if (!serviceState.isEnabled) {
      newUIState = AthenaUIState.disabled;
    } else if (serviceState.isAnalyzing) {
      newUIState = AthenaUIState.analyzing;
    } else if (serviceState.currentRecommendation != null) {
      newUIState = AthenaUIState.ready;
    } else {
      newUIState = AthenaUIState.idle;
    }

    state = state.copyWith(
      uiState: newUIState,
      serviceState: serviceState,
      errorMessage: null, // Clear error on successful update
    );
  }

  // 🎯 PUBLIC CONTROLLER METHODS

  /// 🔄 Enable/disable Athena Intelligence
  Future<void> toggleAthenaEnabled() async {
    try {
      final newEnabled = !state.isEnabled;
      _logger.i('🎛️ ${newEnabled ? "Enabling" : "Disabling"} Athena Intelligence...');

      await _athenaService.setEnabled(newEnabled);

      // Update UI state immediately for responsiveness
      state = state.copyWith(
        uiState: newEnabled ? AthenaUIState.idle : AthenaUIState.disabled,
      );

      _logger.i('✅ Athena Intelligence ${newEnabled ? "enabled" : "disabled"}');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to toggle Athena enabled state', error: e, stackTrace: stackTrace);

      state = state.copyWith(
        uiState: AthenaUIState.error,
        errorMessage: 'Failed to toggle Athena: $e',
      );
    }
  }

  /// 🧠 Request AI recommendations for prompt
  Future<void> analyzePrompt(
      String prompt, {
        List<String>? currentModels,
        String? currentStrategy,
        Map<String, double>? currentWeights,
      }) async {
    if (!state.isEnabled) {
      _logger.w('⚠️ Cannot analyze prompt: Athena is disabled');
      return;
    }

    try {
      _logger.i('🧠 Starting prompt analysis...');

      // Update UI to analyzing state
      state = state.copyWith(
        uiState: AthenaUIState.analyzing,
        errorMessage: null,
      );

      // Request recommendations from service

      // State will be updated by recommendation stream
      _logger.i('✅ Prompt analysis completed');

    } catch (e, stackTrace) {
      _logger.e('❌ Prompt analysis failed', error: e, stackTrace: stackTrace);

      state = state.copyWith(
        uiState: AthenaUIState.error,
        errorMessage: 'Analysis failed: $e',
      );
    }
  }

  /// 🎯 Apply current recommendation
  Future<void> applyRecommendation() async {
    final recommendation = state.currentRecommendation;
    if (recommendation == null) {
      _logger.w('⚠️ No recommendation to apply');
      return;
    }

    try {
      _logger.i('🎯 Applying Athena recommendation...');

      // Update UI to applying state
      state = state.copyWith(
        uiState: AthenaUIState.applying,
        errorMessage: null,
      );

      // Apply recommendation through service
      await _athenaService.applyRecommendation(recommendation);

      // Update UI to idle after successful application
      state = state.copyWith(
        uiState: AthenaUIState.idle,
        serviceState: _athenaService.state,
      );

      _logger.i('✅ Recommendation applied successfully');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to apply recommendation', error: e, stackTrace: stackTrace);

      state = state.copyWith(
        uiState: AthenaUIState.error,
        errorMessage: 'Failed to apply: $e',
      );
    }
  }

  /// 🤖 Auto-apply recommendation if confidence is high enough
  Future<void> _autoApplyRecommendation(AthenaRecommendation recommendation) async {
    if (recommendation.overallConfidence < state.autoApplyThreshold) {
      _logger.d('📊 Auto-apply skipped: confidence ${recommendation.overallConfidence.toStringAsFixed(2)} < threshold ${state.autoApplyThreshold}');
      return;
    }

    try {
      _logger.i('🤖 Auto-applying high-confidence recommendation...');

      await _athenaService.applyRecommendation(recommendation);

      // Update state to idle after auto-apply
      state = state.copyWith(
        uiState: AthenaUIState.idle,
        serviceState: _athenaService.state,
      );

      _logger.i('✅ Auto-apply completed successfully');

    } catch (e, stackTrace) {
      _logger.e('❌ Auto-apply failed', error: e, stackTrace: stackTrace);

      // Don't set error state for auto-apply failures - just log
      state = state.copyWith(
        uiState: AthenaUIState.ready, // Fall back to manual apply
      );
    }
  }

  /// ⚙️ Configure auto-apply settings
  void configureAutoApply({
    bool? enabled,
    double? threshold,
  }) {
    _logger.d('⚙️ Configuring auto-apply: enabled=$enabled, threshold=$threshold');

    state = state.copyWith(
      autoApplyEnabled: enabled ?? state.autoApplyEnabled,
      autoApplyThreshold: threshold ?? state.autoApplyThreshold,
    );
  }

  /// 🗑️ Clear recommendation and reset to idle
  void clearRecommendation() {
    _logger.d('🗑️ Clearing current recommendation');

    state = state.copyWith(
      uiState: state.isEnabled ? AthenaUIState.idle : AthenaUIState.disabled,
    );
  }

  /// 🔄 Retry after error
  void retryFromError() {
    _logger.d('🔄 Retrying from error state');

    state = state.copyWith(
      uiState: state.isEnabled ? AthenaUIState.idle : AthenaUIState.disabled,
      errorMessage: null,
    );
  }

  /// 🧹 Clear decision history
  Future<void> clearHistory() async {
    try {
      _logger.i('🧹 Clearing Athena history...');

      _athenaService.clearHistory();

      // Clear local tracking
      _categoryUsage.clear();
      _recentCategories.clear();

      state = state.copyWith(
        serviceState: _athenaService.state,
        recentPromptCategories: [],
        categoryUsageStats: {},
      );

      _logger.i('✅ Athena history cleared');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to clear history', error: e, stackTrace: stackTrace);
    }
  }

  // 📊 ANALYTICS & INSIGHTS METHODS

  /// Get comprehensive Athena statistics
  Map<String, dynamic> getAthenaAnalytics() {
    final serviceStats = _athenaService.getAthenaStatistics();

    return {
      ...serviceStats,
      'ui_state': state.uiState.name,
      'auto_apply_enabled': state.autoApplyEnabled,
      'auto_apply_threshold': state.autoApplyThreshold,
      'category_usage': Map<String, int>.from(state.categoryUsageStats),
      'recent_categories': List<String>.from(state.recentPromptCategories),
      'average_confidence': state.averageConfidence,
      'has_current_recommendation': state.hasRecommendation,
      'error_message': state.errorMessage,
    };
  }

  /// Get usage insights for UI display
  Map<String, dynamic> getUsageInsights() {
    final totalUsage = state.categoryUsageStats.values.fold(0, (a, b) => a + b);

    if (totalUsage == 0) {
      return {
        'total_prompts': 0,
        'most_used_category': 'none',
        'category_distribution': <String, double>{},
        'efficiency_score': 0.0,
      };
    }

    // Find most used category
    final mostUsedEntry = state.categoryUsageStats.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    // Calculate category distribution
    final distribution = state.categoryUsageStats.map(
          (category, count) => MapEntry(category, count / totalUsage),
    );

    // Calculate efficiency score based on average confidence
    final efficiencyScore = (state.averageConfidence * 100).clamp(0.0, 100.0);

    return {
      'total_prompts': totalUsage,
      'most_used_category': mostUsedEntry.key,
      'category_distribution': distribution,
      'efficiency_score': efficiencyScore,
      'recent_trend': _getRecentTrend(),
    };
  }

  /// Get recent usage trend
  String _getRecentTrend() {
    if (state.recentPromptCategories.length < 5) return 'insufficient_data';

    final recent = state.recentPromptCategories.skip(state.recentPromptCategories.length - 5).toList();
    final categories = recent.toSet();

    if (categories.length == 1) return 'focused';
    if (categories.length >= 4) return 'diverse';
    return 'balanced';
  }

  @override
  void dispose() {
    _logger.d('🧹 Disposing Athena Controller...');

    _stateSubscription?.cancel();
    _recommendationSubscription?.cancel();
    _decisionSubscription?.cancel();

    super.dispose();
  }
}