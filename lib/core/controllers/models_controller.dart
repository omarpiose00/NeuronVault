// 🤖 NEURONVAULT - AI MODELS CONTROLLER
// Enterprise-grade AI models management and health monitoring
// Part of PHASE 2.5 - QUANTUM STATE MANAGEMENT

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../state/state_models.dart';
import '../services/config_service.dart';
import '../services/ai_service.dart';
import '../services/analytics_service.dart';

// 🤖 MODELS CONTROLLER PROVIDER
final modelsControllerProvider = 
    StateNotifierProvider<ModelsController, ModelsState>((ref) {
  return ModelsController(
    configService: ref.watch(configServiceProvider),
    aiService: ref.watch(aiServiceProvider),
    analyticsService: ref.watch(analyticsServiceProvider),
    logger: ref.watch(loggerProvider),
  );
});

// 🧠 AI MODELS STATE CONTROLLER
class ModelsController extends StateNotifier<ModelsState> {
  final ConfigService _configService;
  final AIService _aiService;
  final AnalyticsService _analyticsService;
  final Logger _logger;
  
  Timer? _healthCheckTimer;
  static const Duration _healthCheckInterval = Duration(minutes: 5);

  ModelsController({
    required ConfigService configService,
    required AIService aiService,
    required AnalyticsService analyticsService,
    required Logger logger,
  }) : _configService = configService,
       _aiService = aiService,
       _analyticsService = analyticsService,
       _logger = logger,
       super(const ModelsState()) {
    _initializeModels();
    _startHealthMonitoring();
  }

  // 🚀 INITIALIZATION
  Future<void> _initializeModels() async {
    try {
      _logger.i('🤖 Initializing Models Controller...');
      
      // Load saved configurations
      final savedModels = await _configService.getModelsConfig();
      if (savedModels != null) {
        state = savedModels;
        _logger.i('✅ Models loaded from config: ${state.availableModels.length} models');
      } else {
        await _setDefaultModels();
      }
      
      // Initial health check
      await performHealthCheck();
      
      _analyticsService.trackEvent('models_initialized', {
        'model_count': state.availableModels.length,
        'active_count': state.activeModels.values.where((active) => active).length,
      });
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to initialize models', error: e, stackTrace: stackTrace);
      await _setDefaultModels();
    }
  }

  // 🔧 MODEL CONFIGURATION
  Future<void> configureModel(AIModel model, ModelConfig config) async {
    try {
      _logger.i('🔧 Configuring model: $model');
      
      // Validate configuration
      await _validateModelConfig(config);
      
      final newModels = Map<AIModel, ModelConfig>.from(state.availableModels);
      newModels[model] = config;
      
      state = state.copyWith(availableModels: newModels);
      await _configService.saveModelsConfig(state);
      
      // Test the configured model
      await _testModelConnection(model, config);
      
      _analyticsService.trackEvent('model_configured', {
        'model': model.name,
        'enabled': config.enabled,
        'weight': config.weight,
      });
      
      _logger.i('✅ Model configured successfully: $model');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to configure model $model', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // 🔑 API KEY MANAGEMENT
  Future<void> setApiKey(AIModel model, String apiKey) async {
    if (apiKey.trim().isEmpty) {
      throw ArgumentError('API key cannot be empty');
    }
    
    try {
      final currentConfig = state.availableModels[model];
      if (currentConfig == null) {
        throw StateError('Model $model not found in configuration');
      }
      
      final updatedConfig = currentConfig.copyWith(apiKey: apiKey);
      await configureModel(model, updatedConfig);
      
      _logger.d('🔑 API key updated for model: $model');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to set API key for $model', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // ⚡ MODEL ACTIVATION
  Future<void> toggleModel(AIModel model, bool enabled) async {
    try {
      _logger.d('⚡ Toggling model $model: $enabled');
      
      final newActiveModels = Map<AIModel, bool>.from(state.activeModels);
      newActiveModels[model] = enabled;
      
      // Update model config
      final currentConfig = state.availableModels[model];
      if (currentConfig != null) {
        final updatedConfig = currentConfig.copyWith(enabled: enabled);
        final newModels = Map<AIModel, ModelConfig>.from(state.availableModels);
        newModels[model] = updatedConfig;
        
        state = state.copyWith(
          availableModels: newModels,
          activeModels: newActiveModels,
        );
      } else {
        state = state.copyWith(activeModels: newActiveModels);
      }
      
      await _configService.saveModelsConfig(state);
      
      if (enabled) {
        await _testModelConnection(model, state.availableModels[model]!);
      }
      
      _analyticsService.trackEvent('model_toggled', {
        'model': model.name,
        'enabled': enabled,
        'active_count': state.activeModels.values.where((active) => active).length,
      });
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to toggle model $model', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // 💰 BUDGET MANAGEMENT
  Future<void> setBudgetLimit(double limit) async {
    if (limit <= 0) {
      throw ArgumentError('Budget limit must be positive');
    }
    
    state = state.copyWith(budgetLimit: limit);
    await _configService.saveModelsConfig(state);
    
    _logger.d('💰 Budget limit set to: \$${limit.toStringAsFixed(2)}');
    
    _analyticsService.trackEvent('budget_limit_changed', {
      'limit': limit,
      'current_usage': state.totalBudgetUsed,
    });
  }

  void addBudgetUsage(double cost) {
    final newTotal = state.totalBudgetUsed + cost;
    state = state.copyWith(totalBudgetUsed: newTotal);
    
    _logger.d('💳 Budget usage: +\$${cost.toStringAsFixed(4)} = \$${newTotal.toStringAsFixed(4)}');
    
    if (state.isOverBudget) {
      _logger.w('⚠️ Budget exceeded! ${state.budgetPercentage.toStringAsFixed(1)}%');
      _analyticsService.trackEvent('budget_exceeded', {
        'usage': newTotal,
        'limit': state.budgetLimit,
        'percentage': state.budgetPercentage,
      });
    }
  }

  Future<void> resetBudget() async {
    state = state.copyWith(totalBudgetUsed: 0.0);
    await _configService.saveModelsConfig(state);
    
    _logger.i('🔄 Budget usage reset');
    _analyticsService.trackEvent('budget_reset', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // 🩺 HEALTH MONITORING
  Future<void> performHealthCheck() async {
    if (state.isCheckingHealth) return;
    
    try {
      _logger.d('🩺 Performing health check...');
      
      state = state.copyWith(
        isCheckingHealth: true,
        lastHealthCheck: DateTime.now(),
      );
      
      final newHealth = <AIModel, ModelHealth>{};
      
      for (final entry in state.availableModels.entries) {
        final model = entry.key;
        final config = entry.value;
        
        if (!config.enabled) {
          newHealth[model] = const ModelHealth(
            status: HealthStatus.unknown,
            lastCheck: null,
          );
          continue;
        }
        
        try {
          final health = await _checkModelHealth(model, config);
          newHealth[model] = health;
          
        } catch (e) {
          _logger.w('⚠️ Health check failed for $model: $e');
          newHealth[model] = ModelHealth(
            status: HealthStatus.unhealthy,
            lastError: e.toString(),
            lastCheck: DateTime.now(),
          );
        }
      }
      
      state = state.copyWith(
        modelHealth: newHealth,
        isCheckingHealth: false,
      );
      
      final healthyCount = state.healthyModelCount;
      final totalCount = newHealth.length;
      
      _logger.i('✅ Health check completed: $healthyCount/$totalCount healthy');
      
      _analyticsService.trackEvent('health_check_completed', {
        'healthy_count': healthyCount,
        'total_count': totalCount,
        'unhealthy_models': newHealth.entries
            .where((e) => e.value.status == HealthStatus.unhealthy)
            .map((e) => e.key.name)
            .toList(),
      });
      
    } catch (e, stackTrace) {
      _logger.e('❌ Health check failed', error: e, stackTrace: stackTrace);
      state = state.copyWith(isCheckingHealth: false);
    }
  }

  void _startHealthMonitoring() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(_healthCheckInterval, (_) {
      performHealthCheck();
    });
    
    _logger.d('💓 Health monitoring started (${_healthCheckInterval.inMinutes}min interval)');
  }

  Future<ModelHealth> _checkModelHealth(AIModel model, ModelConfig config) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final isHealthy = await _aiService.testConnection(model, config);
      stopwatch.stop();
      
      final currentHealth = state.modelHealth[model];
      final totalRequests = (currentHealth?.totalRequests ?? 0) + 1;
      final failedRequests = isHealthy 
          ? (currentHealth?.failedRequests ?? 0)
          : (currentHealth?.failedRequests ?? 0) + 1;
      
      final successRate = totalRequests > 0 
          ? (totalRequests - failedRequests) / totalRequests 
          : 0.0;
      
      return ModelHealth(
        status: isHealthy ? HealthStatus.healthy : HealthStatus.unhealthy,
        responseTime: stopwatch.elapsedMilliseconds,
        successRate: successRate,
        totalRequests: totalRequests,
        failedRequests: failedRequests,
        lastCheck: DateTime.now(),
        lastError: isHealthy ? null : 'Connection test failed',
      );
      
    } catch (e) {
      stopwatch.stop();
      
      final currentHealth = state.modelHealth[model];
      final totalRequests = (currentHealth?.totalRequests ?? 0) + 1;
      final failedRequests = (currentHealth?.failedRequests ?? 0) + 1;
      
      return ModelHealth(
        status: HealthStatus.unhealthy,
        responseTime: stopwatch.elapsedMilliseconds,
        successRate: totalRequests > 0 ? (totalRequests - failedRequests) / totalRequests : 0.0,
        totalRequests: totalRequests,
        failedRequests: failedRequests,
        lastCheck: DateTime.now(),
        lastError: e.toString(),
      );
    }
  }

  // 🧪 VALIDATION & TESTING
  Future<void> _validateModelConfig(ModelConfig config) async {
    if (config.name.trim().isEmpty) {
      throw ArgumentError('Model name cannot be empty');
    }
    
    if (config.apiKey.trim().isEmpty) {
      throw ArgumentError('API key cannot be empty');
    }
    
    if (config.weight < 0.0 || config.weight > 1.0) {
      throw ArgumentError('Weight must be between 0.0 and 1.0');
    }
    
    if (config.maxTokens <= 0) {
      throw ArgumentError('Max tokens must be positive');
    }
    
    if (config.temperature < 0.0 || config.temperature > 2.0) {
      throw ArgumentError('Temperature must be between 0.0 and 2.0');
    }
  }

  Future<void> _testModelConnection(AIModel model, ModelConfig config) async {
    try {
      _logger.d('🧪 Testing connection for $model...');
      
      final isConnected = await _aiService.testConnection(model, config);
      
      if (!isConnected) {
        throw Exception('Connection test failed');
      }
      
      _logger.i('✅ Connection test passed for $model');
      
    } catch (e) {
      _logger.w('⚠️ Connection test failed for $model: $e');
      // Don't rethrow - allow configuration to proceed
    }
  }

  // 🎯 DEFAULT CONFIGURATION
  Future<void> _setDefaultModels() async {
    final defaultState = ModelsState(
      availableModels: {
        AIModel.claude: const ModelConfig(
          name: 'Claude Sonnet',
          apiKey: '',
          baseUrl: 'https://api.anthropic.com',
          enabled: false,
          weight: 0.3,
          costPerToken: 0.000003,
          maxTokens: 4000,
          temperature: 0.7,
        ),
        AIModel.gpt: const ModelConfig(
          name: 'GPT-4o',
          apiKey: '',
          baseUrl: 'https://api.openai.com',
          enabled: false,
          weight: 0.3,
          costPerToken: 0.00001,
          maxTokens: 4000,
          temperature: 0.7,
        ),
        AIModel.deepseek: const ModelConfig(
          name: 'DeepSeek Chat',
          apiKey: '',
          baseUrl: 'https://api.deepseek.com',
          enabled: false,
          weight: 0.2,
          costPerToken: 0.000001,
          maxTokens: 4000,
          temperature: 0.7,
        ),
        AIModel.gemini: const ModelConfig(
          name: 'Gemini Pro',
          apiKey: '',
          baseUrl: 'https://generativelanguage.googleapis.com',
          enabled: false,
          weight: 0.2,
          costPerToken: 0.000002,
          maxTokens: 4000,
          temperature: 0.7,
        ),
      },
      activeModels: {
        AIModel.claude: false,
        AIModel.gpt: false,
        AIModel.deepseek: false,
        AIModel.gemini: false,
      },
      budgetLimit: 100.0,
      totalBudgetUsed: 0.0,
    );
    
    state = defaultState;
    await _configService.saveModelsConfig(state);
    
    _logger.i('🎯 Default models configuration applied');
  }

  // 🔄 RESET & CLEANUP
  Future<void> resetToDefaults() async {
    _logger.i('🔄 Resetting models to defaults...');
    await _setDefaultModels();
    
    _analyticsService.trackEvent('models_reset', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  void dispose() {
    _healthCheckTimer?.cancel();
    _logger.d('🧹 Models Controller disposed');
    super.dispose();
  }
}

// 🎯 COMPUTED PROVIDERS FOR MODELS
final availableModelsProvider = Provider<Map<AIModel, ModelConfig>>((ref) {
  return ref.watch(modelsControllerProvider).availableModels;
});

final activeModelsProvider = Provider<Map<AIModel, bool>>((ref) {
  return ref.watch(modelsControllerProvider).activeModels;
});

final modelHealthProvider = Provider<Map<AIModel, ModelHealth>>((ref) {
  return ref.watch(modelsControllerProvider).modelHealth;
});

final budgetUsageProvider = Provider<double>((ref) {
  return ref.watch(modelsControllerProvider).budgetPercentage;
});

final isOverBudgetProvider = Provider<bool>((ref) {
  return ref.watch(modelsControllerProvider).isOverBudget;
});

final healthyModelsCountProvider = Provider<int>((ref) {
  return ref.watch(modelsControllerProvider).healthyModelCount;
});

final isHealthCheckingProvider = Provider<bool>((ref) {
  return ref.watch(modelsControllerProvider).isCheckingHealth;
});