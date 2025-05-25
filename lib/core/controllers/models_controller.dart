// 🤖 NEURONVAULT - MODELS CONTROLLER
// Enterprise-grade AI models management with health monitoring
// Part of PHASE 2.5 - QUANTUM STATE MANAGEMENT

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../state/state_models.dart';
import '../services/config_service.dart';
import '../services/ai_service.dart';
import '../services/analytics_service.dart';
import '../providers/providers_main.dart';

// 🤖 MODELS CONTROLLER
class ModelsController extends Notifier<ModelsState> {
  late final ConfigService _configService;
  late final AIService _aiService;
  late final AnalyticsService _analyticsService;
  late final Logger _logger;

  @override
  ModelsState build() {
    // Initialize services
    _configService = ref.read(configServiceProvider);
    _aiService = ref.read(aiServiceProvider);
    _analyticsService = ref.read(analyticsServiceProvider);
    _logger = ref.read(loggerProvider);

    // Load initial state
    _loadModelsConfig();
    _initializeDefaultModels();

    return const ModelsState();
  }

  // 🔄 LOAD CONFIGURATION
  Future<void> _loadModelsConfig() async {
    try {
      _logger.d('🔄 Loading models configuration...');

      final savedModels = await _configService.getModelsConfig();
      if (savedModels != null) {
        state = savedModels;
        _logger.i('✅ Models configuration loaded: ${savedModels.availableModels.length} models');
      } else {
        _logger.d('ℹ️ No saved models found, using defaults');
      }

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to load models config', error: e, stackTrace: stackTrace);
    }
  }

  // 🚀 INITIALIZE DEFAULT MODELS
  void _initializeDefaultModels() {
    if (state.availableModels.isNotEmpty) return;

    final defaultModels = <AIModel, ModelConfig>{
      AIModel.claude: const ModelConfig(
        name: 'Claude',
        baseUrl: 'https://api.anthropic.com',
        maxTokens: 4000,
        temperature: 0.7,
      ),
      AIModel.gpt: const ModelConfig(
        name: 'GPT',
        baseUrl: 'https://api.openai.com',
        maxTokens: 4000,
        temperature: 0.7,
      ),
      AIModel.deepseek: const ModelConfig(
        name: 'DeepSeek',
        baseUrl: 'https://api.deepseek.com',
        maxTokens: 4000,
        temperature: 0.7,
      ),
      AIModel.gemini: const ModelConfig(
        name: 'Gemini',
        baseUrl: 'https://generativelanguage.googleapis.com',
        maxTokens: 4000,
        temperature: 0.7,
      ),
    };

    final defaultHealth = <AIModel, ModelHealth>{
      for (final model in defaultModels.keys)
        model: const ModelHealth(status: HealthStatus.unknown),
    };

    state = state.copyWith(
      availableModels: defaultModels,
      modelHealth: defaultHealth,
      activeModels: {},
    );

    _logger.i('🚀 Default models initialized: ${defaultModels.length} models');
  }

  // 🔧 CONFIGURE MODEL
  Future<void> configureModel(AIModel model, ModelConfig config) async {
    try {
      _logger.d('🔧 Configuring model: ${model.displayName}');

      final updatedModels = Map<AIModel, ModelConfig>.from(state.availableModels);
      updatedModels[model] = config;

      state = state.copyWith(availableModels: updatedModels);

      await _configService.saveModelsConfig(state);

      _analyticsService.trackEvent('model_configured', properties: {
        'model': model.name,
        'has_api_key': config.apiKey.isNotEmpty,
        'enabled': config.enabled,
      });

      _logger.i('✅ Model configured: ${model.displayName}');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to configure model', error: e, stackTrace: stackTrace);
    }
  }

  // ✅ ACTIVATE MODEL
  Future<void> activateModel(AIModel model) async {
    try {
      _logger.d('✅ Activating model: ${model.displayName}');

      final config = state.availableModels[model];
      if (config == null) {
        _logger.e('❌ Cannot activate unconfigured model: ${model.displayName}');
        return;
      }

      if (config.apiKey.isEmpty) {
        _logger.w('⚠️ Model has no API key: ${model.displayName}');
      }

      final updatedActiveModels = Map<AIModel, bool>.from(state.activeModels);
      updatedActiveModels[model] = true;

      state = state.copyWith(activeModels: updatedActiveModels);

      await _configService.saveModelsConfig(state);

      // Test connection
      _testModelConnection(model);

      _analyticsService.trackEvent('model_activated', properties: {
        'model': model.name,
      });

      _logger.i('✅ Model activated: ${model.displayName}');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to activate model', error: e, stackTrace: stackTrace);
    }
  }

  // ❌ DEACTIVATE MODEL
  Future<void> deactivateModel(AIModel model) async {
    try {
      _logger.d('❌ Deactivating model: ${model.displayName}');

      final updatedActiveModels = Map<AIModel, bool>.from(state.activeModels);
      updatedActiveModels[model] = false;

      state = state.copyWith(activeModels: updatedActiveModels);

      await _configService.saveModelsConfig(state);

      _analyticsService.trackEvent('model_deactivated', properties: {
        'model': model.name,
      });

      _logger.i('❌ Model deactivated: ${model.displayName}');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to deactivate model', error: e, stackTrace: stackTrace);
    }
  }

  // 🧪 TEST MODEL CONNECTION
  Future<void> _testModelConnection(AIModel model) async {
    try {
      final config = state.availableModels[model];
      if (config == null) return;

      final isHealthy = await _aiService.testConnection(model, config);

      final updatedHealth = Map<AIModel, ModelHealth>.from(state.modelHealth);
      updatedHealth[model] = ModelHealth(
        status: isHealthy ? HealthStatus.healthy : HealthStatus.unhealthy,
        lastCheck: DateTime.now(),
        responseTime: 0,
      );

      state = state.copyWith(modelHealth: updatedHealth);

      _logger.d('🧪 Model connection test: ${model.displayName} - ${isHealthy ? 'Healthy' : 'Unhealthy'}');

    } catch (e) {
      _logger.w('⚠️ Model connection test failed: ${model.displayName} - $e');

      final updatedHealth = Map<AIModel, ModelHealth>.from(state.modelHealth);
      updatedHealth[model] = ModelHealth(
        status: HealthStatus.unhealthy,
        lastCheck: DateTime.now(),
        lastError: e.toString(),
      );

      state = state.copyWith(modelHealth: updatedHealth);
    }
  }

  // 💰 UPDATE BUDGET USAGE
  void updateBudgetUsage(double amount) {
    if (amount <= 0) return;

    final newTotal = state.totalBudgetUsed + amount;
    state = state.copyWith(totalBudgetUsed: newTotal);

    _logger.d('💰 Budget usage updated: \$${newTotal.toStringAsFixed(3)}');

    if (state.isOverBudget) {
      _logger.w('⚠️ Budget limit exceeded!');
      _analyticsService.trackEvent('budget_limit_exceeded', properties: {
        'total_used': newTotal,
        'budget_limit': state.budgetLimit,
      });
    }
  }

  // 💳 SET BUDGET LIMIT
  Future<void> setBudgetLimit(double limit) async {
    try {
      final clampedLimit = limit.clamp(0.0, 10000.0); // Max $10,000

      state = state.copyWith(budgetLimit: clampedLimit);

      await _configService.saveModelsConfig(state);

      _logger.d('💳 Budget limit set: \$${clampedLimit.toStringAsFixed(2)}');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to set budget limit', error: e, stackTrace: stackTrace);
    }
  }

  // 🩺 PERFORM HEALTH CHECK
  Future<void> performHealthCheck() async {
    if (state.isCheckingHealth) return;

    try {
      state = state.copyWith(isCheckingHealth: true);

      _logger.i('🩺 Performing health check for all models...');

      for (final model in state.availableModels.keys) {
        if (state.activeModels[model] == true) {
          await _testModelConnection(model);
        }
      }

      state = state.copyWith(
        isCheckingHealth: false,
        lastHealthCheck: DateTime.now(),
      );

      final healthyCount = state.healthyModelCount;
      _logger.i('🩺 Health check completed: $healthyCount/${state.availableModels.length} models healthy');

      _analyticsService.trackEvent('health_check_completed', properties: {
        'healthy_models': healthyCount,
        'total_models': state.availableModels.length,
      });

    } catch (e, stackTrace) {
      _logger.e('❌ Health check failed', error: e, stackTrace: stackTrace);
      state = state.copyWith(isCheckingHealth: false);
    }
  }

  // 📊 GET MODEL STATISTICS
  Map<String, dynamic> getModelStatistics(AIModel model) {
    final config = state.availableModels[model];
    final health = state.modelHealth[model];
    final isActive = state.activeModels[model] ?? false;

    return {
      'model': model.name,
      'display_name': model.displayName,
      'is_active': isActive,
      'is_configured': config != null,
      'has_api_key': config?.apiKey.isNotEmpty ?? false,
      'health_status': health?.status.name ?? 'unknown',
      'last_check': health?.lastCheck?.toIso8601String(),
      'response_time': health?.responseTime ?? 0,
      'success_rate': health?.successRate ?? 0.0,
      'weight': config?.weight ?? 0.0,
      'max_tokens': config?.maxTokens ?? 0,
      'temperature': config?.temperature ?? 0.0,
    };
  }

  // 📈 GET ALL STATISTICS
  Map<String, dynamic> getAllStatistics() {
    return {
      'total_models': state.availableModels.length,
      'active_models': state.activeModels.values.where((active) => active).length,
      'healthy_models': state.healthyModelCount,
      'budget_used': state.totalBudgetUsed,
      'budget_limit': state.budgetLimit,
      'budget_percentage': state.budgetPercentage,
      'is_over_budget': state.isOverBudget,
      'last_health_check': state.lastHealthCheck?.toIso8601String(),
      'models': {
        for (final model in AIModel.values)
          model.name: getModelStatistics(model),
      },
    };
  }

  // 🔄 RESET BUDGET
  Future<void> resetBudget() async {
    try {
      state = state.copyWith(totalBudgetUsed: 0.0);

      await _configService.saveModelsConfig(state);

      _analyticsService.trackEvent('budget_reset');

      _logger.i('🔄 Budget usage reset');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to reset budget', error: e, stackTrace: stackTrace);
    }
  }
}

// 🤖 MODELS CONTROLLER PROVIDER
final modelsControllerProvider = NotifierProvider<ModelsController, ModelsState>(
      () => ModelsController(),
);

// 📊 COMPUTED PROVIDERS
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
  return ref.watch(modelsControllerProvider).totalBudgetUsed;
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

final modelsStatisticsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.read(modelsControllerProvider.notifier).getAllStatistics();
});