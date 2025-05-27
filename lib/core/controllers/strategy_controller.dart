// 🎛️ NEURONVAULT - STRATEGY CONTROLLER
// Enterprise-grade AI strategy management with Riverpod
// Part of PHASE 2.5 - QUANTUM STATE MANAGEMENT

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../state/state_models.dart';
import '../services/config_service.dart';
import '../services/analytics_service.dart';
import '../providers/providers_main.dart';

// 🎯 STRATEGY CONTROLLER
class StrategyController extends Notifier<StrategyState> {
  late final ConfigService _configService;
  late final AnalyticsService _analyticsService;
  late final Logger _logger;

  @override
  StrategyState build() {
    // Initialize services
    _configService = ref.read(configServiceProvider);
    _analyticsService = ref.read(analyticsServiceProvider);
    _logger = ref.read(loggerProvider);

    // Load initial state
    _loadStrategyConfig();

    return const StrategyState();
  }

  // 🔄 LOAD CONFIGURATION
  Future<void> _loadStrategyConfig() async {
    try {
      _logger.d('🔄 Loading strategy configuration...');

      final savedStrategy = await _configService.getStrategy();
      if (savedStrategy != null) {
        state = savedStrategy;
        _logger.i('✅ Strategy configuration loaded: ${savedStrategy.activeStrategy.displayName}');
      } else {
        _logger.d('ℹ️ No saved strategy found, using defaults');
      }

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to load strategy config', error: e, stackTrace: stackTrace);
    }
  }

  // 🎛️ SET ACTIVE STRATEGY
  Future<void> setActiveStrategy(OrchestrationStrategy strategy) async {
    if (state.activeStrategy == strategy) return;

    try {
      _logger.i('🎛️ Setting active strategy: ${strategy.displayName}');

      state = state.copyWith(
        activeStrategy: strategy,
        isProcessing: false,
      );

      // Save configuration
      await _configService.saveStrategy(state);

      // Track analytics
      _analyticsService.trackEvent('strategy_changed', properties: {
        'strategy': strategy.name,
        'previous_strategy': state.activeStrategy.name,
      });

      _logger.i('✅ Active strategy set: ${strategy.displayName}');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to set active strategy', error: e, stackTrace: stackTrace);
    }
  }

  // ⚖️ SET MODEL WEIGHTS
  Future<void> setModelWeights(Map<AIModel, double> weights) async {
    try {
      _logger.d('⚖️ Setting model weights...');

      // Normalize weights to sum to 1.0
      final totalWeight = weights.values.fold(0.0, (sum, weight) => sum + weight);
      final normalizedWeights = totalWeight > 0
          ? weights.map((model, weight) => MapEntry(model, weight / totalWeight))
          : weights;

      state = state.copyWith(
        modelWeights: normalizedWeights,
      );

      // Save configuration
      await _configService.saveStrategy(state);

      // Track analytics
      _analyticsService.trackEvent('model_weights_changed', properties: {
        'model_count': weights.length,
        'total_weight': totalWeight,
      });

      _logger.i('✅ Model weights updated: ${weights.length} models');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to set model weights', error: e, stackTrace: stackTrace);
    }
  }

  // 🔄 SET PROCESSING STATE
  void setProcessingState(bool isProcessing) {
    if (state.isProcessing == isProcessing) return;

    state = state.copyWith(isProcessing: isProcessing);

    _logger.d('🔄 Processing state: ${isProcessing ? 'Started' : 'Stopped'}');

    if (isProcessing) {
      _analyticsService.trackEvent('strategy_processing_started');
    } else {
      _analyticsService.trackEvent('strategy_processing_completed');
    }
  }

  // 🎯 SET CONFIDENCE THRESHOLD
  Future<void> setConfidenceThreshold(double threshold) async {
    try {
      final clampedThreshold = threshold.clamp(0.0, 1.0);

      state = state.copyWith(confidenceThreshold: clampedThreshold);

      await _configService.saveStrategy(state);

      _logger.d('🎯 Confidence threshold set: $clampedThreshold');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to set confidence threshold', error: e, stackTrace: stackTrace);
    }
  }

  // ⚡ SET MAX CONCURRENT REQUESTS
  Future<void> setMaxConcurrentRequests(int maxRequests) async {
    try {
      final clampedMax = maxRequests.clamp(1, 20);

      state = state.copyWith(maxConcurrentRequests: clampedMax);

      await _configService.saveStrategy(state);

      _logger.d('⚡ Max concurrent requests set: $clampedMax');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to set max concurrent requests', error: e, stackTrace: stackTrace);
    }
  }

  // ⏱️ SET TIMEOUT
  Future<void> setTimeout(int seconds) async {
    try {
      final clampedTimeout = seconds.clamp(5, 300); // 5 seconds to 5 minutes

      state = state.copyWith(timeoutSeconds: clampedTimeout);

      await _configService.saveStrategy(state);

      _logger.d('⏱️ Timeout set: ${clampedTimeout}s');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to set timeout', error: e, stackTrace: stackTrace);
    }
  }

  // 🔍 ADD FILTER
  Future<void> addFilter(String filter) async {
    try {
      if (state.activeFilters.contains(filter)) return;

      final newFilters = [...state.activeFilters, filter];
      state = state.copyWith(activeFilters: newFilters);

      await _configService.saveStrategy(state);

      _logger.d('🔍 Filter added: $filter');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to add filter', error: e, stackTrace: stackTrace);
    }
  }

  // ❌ REMOVE FILTER
  Future<void> removeFilter(String filter) async {
    try {
      final newFilters = state.activeFilters.where((f) => f != filter).toList();
      state = state.copyWith(activeFilters: newFilters);

      await _configService.saveStrategy(state);

      _logger.d('❌ Filter removed: $filter');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to remove filter', error: e, stackTrace: stackTrace);
    }
  }

  // 🔄 RESET TO DEFAULTS
  Future<void> resetToDefaults() async {
    try {
      _logger.i('🔄 Resetting strategy to defaults...');

      state = const StrategyState();

      await _configService.saveStrategy(state);

      _analyticsService.trackEvent('strategy_reset_to_defaults');

      _logger.i('✅ Strategy reset to defaults');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to reset strategy', error: e, stackTrace: stackTrace);
    }
  }

  // 🎯 GET STRATEGY DESCRIPTION
  String getStrategyDescription(OrchestrationStrategy strategy) {
    switch (strategy) {
      case OrchestrationStrategy.parallel:
        return 'All AI models process simultaneously for fastest response';
      case OrchestrationStrategy.consensus:
        return 'Models collaborate to reach consensus on best answer';
      case OrchestrationStrategy.adaptive:
        return 'Dynamically selects best model based on query type';
      case OrchestrationStrategy.sequential:
        return 'Processes through models sequentially for refined output';
      case OrchestrationStrategy.cascade:
        return 'Cascades through models based on confidence levels';
      case OrchestrationStrategy.weighted:
        return 'Uses weighted voting based on model strengths';
    }
  }

  // 📊 GET STRATEGY METRICS
  Map<String, dynamic> getStrategyMetrics() {
    return {
      'active_strategy': state.activeStrategy.name,
      'model_count': state.modelWeights.length,
      'total_weight': state.totalWeight,
      'is_configured': state.isConfigured,
      'confidence_threshold': state.confidenceThreshold,
      'max_concurrent': state.maxConcurrentRequests,
      'timeout_seconds': state.timeoutSeconds,
      'active_filters': state.activeFilters.length,
    };
  }
}

// 🎯 STRATEGY CONTROLLER PROVIDER
final strategyControllerProvider = NotifierProvider<StrategyController, StrategyState>(
      () => StrategyController(),
);

// 📊 COMPUTED PROVIDERS
final activeStrategyProvider = Provider<OrchestrationStrategy>((ref) {
  return ref.watch(strategyControllerProvider).activeStrategy;
});

final modelWeightsProvider = Provider<Map<AIModel, double>>((ref) {
  return ref.watch(strategyControllerProvider).modelWeights;
});

final isStrategyProcessingProvider = Provider<bool>((ref) {
  return ref.watch(strategyControllerProvider).isProcessing;
});

final strategyConfigurationProvider = Provider<bool>((ref) {
  return ref.watch(strategyControllerProvider).isConfigured;
});

final activeModelCountProvider = Provider<int>((ref) {
  return ref.watch(strategyControllerProvider).activeModelCount;
});

final strategyMetricsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.read(strategyControllerProvider.notifier).getStrategyMetrics();
});