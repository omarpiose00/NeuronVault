// 🎛️ NEURONVAULT - AI STRATEGY CONTROLLER
// Enterprise-grade state management for AI orchestration strategies
// Part of PHASE 2.5 - QUANTUM STATE MANAGEMENT

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../state/state_models.dart';
import '../services/config_service.dart';
import '../services/analytics_service.dart';

// 🎯 STRATEGY CONTROLLER PROVIDER
final strategyControllerProvider = 
    StateNotifierProvider<StrategyController, StrategyState>((ref) {
  return StrategyController(
    configService: ref.watch(configServiceProvider),
    analyticsService: ref.watch(analyticsServiceProvider),
    logger: ref.watch(loggerProvider),
  );
});

// 🧠 AI STRATEGY STATE CONTROLLER
class StrategyController extends StateNotifier<StrategyState> {
  final ConfigService _configService;
  final AnalyticsService _analyticsService;
  final Logger _logger;

  StrategyController({
    required ConfigService configService,
    required AnalyticsService analyticsService,
    required Logger logger,
  }) : _configService = configService,
       _analyticsService = analyticsService,
       _logger = logger,
       super(const StrategyState()) {
    _initializeStrategy();
  }

  // 🚀 INITIALIZATION
  Future<void> _initializeStrategy() async {
    try {
      _logger.i('🎛️ Initializing Strategy Controller...');
      
      final savedStrategy = await _configService.getStrategy();
      if (savedStrategy != null) {
        state = savedStrategy;
        _logger.i('✅ Strategy loaded from config: ${state.activeStrategy}');
      } else {
        await _setDefaultStrategy();
      }
      
      _analyticsService.trackEvent('strategy_initialized', {
        'strategy': state.activeStrategy.name,
        'model_count': state.activeModelCount,
      });
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to initialize strategy', error: e, stackTrace: stackTrace);
      await _setDefaultStrategy();
    }
  }

  // 🎯 STRATEGY MANAGEMENT
  Future<void> setStrategy(AIStrategy strategy) async {
    if (state.isProcessing) {
      _logger.w('⚠️ Cannot change strategy while processing');
      return;
    }

    try {
      _logger.i('🔄 Changing strategy: ${state.activeStrategy} → $strategy');
      
      state = state.copyWith(
        activeStrategy: strategy,
        isProcessing: true,
      );

      // Apply strategy-specific optimizations
      await _applyStrategyOptimizations(strategy);
      
      // Save configuration
      await _configService.saveStrategy(state);
      
      state = state.copyWith(isProcessing: false);
      
      _analyticsService.trackEvent('strategy_changed', {
        'old_strategy': state.activeStrategy.name,
        'new_strategy': strategy.name,
        'model_count': state.activeModelCount,
      });
      
      _logger.i('✅ Strategy changed successfully to: $strategy');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to change strategy', error: e, stackTrace: stackTrace);
      state = state.copyWith(isProcessing: false);
      rethrow;
    }
  }

  // ⚖️ MODEL WEIGHT MANAGEMENT
  Future<void> setModelWeight(AIModel model, double weight) async {
    if (weight < 0.0 || weight > 1.0) {
      throw ArgumentError('Weight must be between 0.0 and 1.0');
    }

    try {
      _logger.d('⚖️ Setting weight for $model: $weight');
      
      final newWeights = Map<AIModel, double>.from(state.modelWeights);
      
      if (weight == 0.0) {
        newWeights.remove(model);
      } else {
        newWeights[model] = weight;
      }
      
      state = state.copyWith(modelWeights: newWeights);
      await _configService.saveStrategy(state);
      
      _analyticsService.trackEvent('model_weight_changed', {
        'model': model.name,
        'weight': weight,
        'active_models': state.activeModelCount,
      });
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to set model weight', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // 🎛️ BATCH MODEL CONFIGURATION
  Future<void> setModelWeights(Map<AIModel, double> weights) async {
    try {
      _logger.i('🎛️ Setting batch model weights: ${weights.length} models');
      
      // Validate all weights
      for (final entry in weights.entries) {
        if (entry.value < 0.0 || entry.value > 1.0) {
          throw ArgumentError('Weight for ${entry.key} must be between 0.0 and 1.0');
        }
      }
      
      // Remove zero weights
      final cleanWeights = Map<AIModel, double>.fromEntries(
        weights.entries.where((e) => e.value > 0.0)
      );
      
      state = state.copyWith(modelWeights: cleanWeights);
      await _configService.saveStrategy(state);
      
      _analyticsService.trackEvent('batch_weights_changed', {
        'model_count': cleanWeights.length,
        'total_weight': state.totalWeight,
      });
      
      _logger.i('✅ Batch weights set successfully');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to set batch weights', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // 🔧 STRATEGY PARAMETERS
  Future<void> setConfidenceThreshold(double threshold) async {
    if (threshold < 0.0 || threshold > 1.0) {
      throw ArgumentError('Confidence threshold must be between 0.0 and 1.0');
    }

    state = state.copyWith(confidenceThreshold: threshold);
    await _configService.saveStrategy(state);
    
    _logger.d('🎯 Confidence threshold set to: $threshold');
  }

  Future<void> setMaxConcurrentRequests(int maxRequests) async {
    if (maxRequests < 1 || maxRequests > 20) {
      throw ArgumentError('Max concurrent requests must be between 1 and 20');
    }

    state = state.copyWith(maxConcurrentRequests: maxRequests);
    await _configService.saveStrategy(state);
    
    _logger.d('🚀 Max concurrent requests set to: $maxRequests');
  }

  Future<void> setTimeout(int seconds) async {
    if (seconds < 5 || seconds > 300) {
      throw ArgumentError('Timeout must be between 5 and 300 seconds');
    }

    state = state.copyWith(timeoutSeconds: seconds);
    await _configService.saveStrategy(state);
    
    _logger.d('⏱️ Timeout set to: ${seconds}s');
  }

  // 🔍 FILTERS MANAGEMENT
  Future<void> addFilter(String filter) async {
    if (state.activeFilters.contains(filter)) return;
    
    final newFilters = [...state.activeFilters, filter];
    state = state.copyWith(activeFilters: newFilters);
    await _configService.saveStrategy(state);
    
    _logger.d('🔍 Filter added: $filter');
  }

  Future<void> removeFilter(String filter) async {
    final newFilters = state.activeFilters.where((f) => f != filter).toList();
    state = state.copyWith(activeFilters: newFilters);
    await _configService.saveStrategy(state);
    
    _logger.d('🗑️ Filter removed: $filter');
  }

  // 🎯 STRATEGY OPTIMIZATIONS
  Future<void> _applyStrategyOptimizations(AIStrategy strategy) async {
    switch (strategy) {
      case AIStrategy.parallel:
        await _optimizeForParallel();
        break;
      case AIStrategy.consensus:
        await _optimizeForConsensus();
        break;
      case AIStrategy.adaptive:
        await _optimizeForAdaptive();
        break;
      case AIStrategy.sequential:
        await _optimizeForSequential();
        break;
      case AIStrategy.weighted:
        await _optimizeForWeighted();
        break;
    }
  }

  Future<void> _optimizeForParallel() async {
    state = state.copyWith(
      maxConcurrentRequests: 5,
      confidenceThreshold: 0.7,
      timeoutSeconds: 30,
    );
    _logger.d('🚀 Optimized for parallel strategy');
  }

  Future<void> _optimizeForConsensus() async {
    state = state.copyWith(
      maxConcurrentRequests: 3,
      confidenceThreshold: 0.8,
      timeoutSeconds: 45,
    );
    _logger.d('🤝 Optimized for consensus strategy');
  }

  Future<void> _optimizeForAdaptive() async {
    state = state.copyWith(
      maxConcurrentRequests: 4,
      confidenceThreshold: 0.75,
      timeoutSeconds: 40,
    );
    _logger.d('🧠 Optimized for adaptive strategy');
  }

  Future<void> _optimizeForSequential() async {
    state = state.copyWith(
      maxConcurrentRequests: 1,
      confidenceThreshold: 0.6,
      timeoutSeconds: 20,
    );
    _logger.d('📝 Optimized for sequential strategy');
  }

  Future<void> _optimizeForWeighted() async {
    state = state.copyWith(
      maxConcurrentRequests: 3,
      confidenceThreshold: 0.7,
      timeoutSeconds: 35,
    );
    _logger.d('⚖️ Optimized for weighted strategy');
  }

  // 🎯 DEFAULT CONFIGURATION
  Future<void> _setDefaultStrategy() async {
    const defaultState = StrategyState(
      activeStrategy: AIStrategy.parallel,
      modelWeights: {
        AIModel.claude: 0.3,
        AIModel.gpt: 0.3,
        AIModel.deepseek: 0.2,
        AIModel.gemini: 0.2,
      },
      confidenceThreshold: 0.7,
      maxConcurrentRequests: 4,
      timeoutSeconds: 30,
    );
    
    state = defaultState;
    await _configService.saveStrategy(state);
    
    _logger.i('🎯 Default strategy configuration applied');
  }

  // 🔄 RESET & CLEANUP
  Future<void> resetToDefaults() async {
    _logger.i('🔄 Resetting strategy to defaults...');
    await _setDefaultStrategy();
    
    _analyticsService.trackEvent('strategy_reset', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  void dispose() {
    _logger.d('🧹 Strategy Controller disposed');
    super.dispose();
  }
}

// 🎯 COMPUTED PROVIDERS FOR STRATEGY
final activeStrategyProvider = Provider<AIStrategy>((ref) {
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