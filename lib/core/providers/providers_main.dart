// 🎯 NEURONVAULT - ENHANCED CENTRAL PROVIDERS HUB - PHASE 3.4 ATHENA INTEGRATION
// Enterprise-grade provider management with AI Autonomy Intelligence
// PHASE 3.4 COMPLETE: Athena Intelligence Engine + Mini-LLM Analysis + AI Autonomy

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 🔧 EXISTING IMPORTS (unchanged)
import '../state/state_models.dart';
import '../services/config_service.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart';
import '../services/theme_service.dart';
import '../services/websocket_orchestration_service.dart' as ws;
import '../services/spatial_audio_service.dart';
import '../services/achievement_service.dart';

// 🧠 NEW: ATHENA INTELLIGENCE IMPORTS - PHASE 3.4
import '../services/mini_llm_analyzer_service.dart';
import '../services/athena_intelligence_service.dart';
import '../controllers/athena_controller.dart';

// 🧠 EXISTING CONTROLLER EXPORTS (unchanged)
export '../controllers/strategy_controller.dart';
export '../controllers/models_controller.dart';
export '../controllers/chat_controller.dart';
export '../controllers/connection_controller.dart';

// 🔧 EXISTING CORE INFRASTRUCTURE PROVIDERS (unchanged)
final loggerProvider = Provider<Logger>((ref) {
  return Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    level: Level.debug,
  );
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main()');
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
    lOptions: LinuxOptions(),
    wOptions: WindowsOptions(
      useBackwardCompatibility: false,
    ),
    mOptions: MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
  );
});

// 🛠️ EXISTING SERVICE PROVIDERS (unchanged)
final configServiceProvider = Provider<ConfigService>((ref) {
  return ConfigService(
    sharedPreferences: ref.watch(sharedPreferencesProvider),
    secureStorage: ref.watch(secureStorageProvider),
    logger: ref.watch(loggerProvider),
  );
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(
    sharedPreferences: ref.watch(sharedPreferencesProvider),
    secureStorage: ref.watch(secureStorageProvider),
    logger: ref.watch(loggerProvider),
  );
});

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService(
    configService: ref.watch(configServiceProvider),
    logger: ref.watch(loggerProvider),
    storageService: ref.watch(storageServiceProvider),
  );
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(
    storageService: ref.watch(storageServiceProvider),
    logger: ref.watch(loggerProvider),
  );
});

final themeServiceProvider = Provider<ThemeService>((ref) {
  return ThemeService(
    configService: ref.watch(configServiceProvider),
    logger: ref.watch(loggerProvider),
  );
});

final spatialAudioServiceProvider = Provider<SpatialAudioService>((ref) {
  return SpatialAudioService();
});

// 🏆 EXISTING ACHIEVEMENT SERVICE PROVIDERS (unchanged)
final enhancedAchievementServiceProvider = ChangeNotifierProvider<EnhancedAchievementService>((ref) {
  final logger = ref.watch(loggerProvider);
  final sharedPreferences = ref.watch(sharedPreferencesProvider);

  logger.i('🏆 Initializing Enhanced Achievement Service PHASE 3.3...');

  final service = EnhancedAchievementService(
    prefs: sharedPreferences,
    logger: logger,
  );

  logger.i('✅ Enhanced Achievement Service initialized successfully with luxury features');
  return service;
});

final achievementServiceProvider = Provider<EnhancedAchievementService>((ref) {
  return ref.watch(enhancedAchievementServiceProvider);
});

// 🧬 EXISTING WEBSOCKET ORCHESTRATION SERVICE PROVIDER (unchanged)
final webSocketOrchestrationServiceProvider = ChangeNotifierProvider<ws.WebSocketOrchestrationService>((ref) {
  final logger = ref.watch(loggerProvider);

  logger.i('🧬 Initializing WebSocket Orchestration Service...');

  final service = ws.WebSocketOrchestrationService();

  Future.microtask(() async {
    try {
      final connected = await service.connect();
      if (connected) {
        logger.i('✅ WebSocket Orchestration Service connected successfully');
      } else {
        logger.w('⚠️ WebSocket Orchestration Service connection failed - will retry');
      }
    } catch (e) {
      logger.e('❌ Error connecting WebSocket Orchestration Service: $e');
    }
  });

  return service;
});

// 🧠 NEW: ATHENA INTELLIGENCE PROVIDERS - PHASE 3.4 REVOLUTIONARY

/// 🔍 Mini-LLM Analyzer Service Provider
final miniLLMAnalyzerServiceProvider = Provider<MiniLLMAnalyzerService>((ref) {
  final logger = ref.watch(loggerProvider);
  logger.i('🔍 Initializing Mini-LLM Analyzer Service for Athena Intelligence...');

  final service = MiniLLMAnalyzerService(
    configService: ref.watch(configServiceProvider),
    storageService: ref.watch(storageServiceProvider),
    logger: logger,
  );

  logger.i('✅ Mini-LLM Analyzer Service initialized - Fast AI analysis ready');
  return service;
});

/// 🧠 Athena Intelligence Service Provider
final athenaIntelligenceServiceProvider = ChangeNotifierProvider<AthenaIntelligenceService>((ref) {
  final logger = ref.watch(loggerProvider);
  logger.i('🧠 Initializing Athena Intelligence Service - World\'s first AI Autonomy Engine...');

  final service = AthenaIntelligenceService(
    configService: ref.watch(configServiceProvider),
    storageService: ref.watch(storageServiceProvider),
    miniLLMAnalyzer: ref.watch(miniLLMAnalyzerServiceProvider),
    logger: logger,
  );

  logger.i('✅ Athena Intelligence Service initialized - AI Autonomy Engine ready');
  return service;
});

/// 🎯 Athena Controller Provider
final athenaControllerProvider = ChangeNotifierProvider<AthenaController>((ref) {
  final logger = ref.watch(loggerProvider);
  logger.i('🎯 Initializing Athena Controller - AI Autonomy State Management...');

  final controller = AthenaController(
    athenaService: ref.watch(athenaIntelligenceServiceProvider),
    miniLLMService: ref.watch(miniLLMAnalyzerServiceProvider),
    logger: logger,
  );

  logger.i('✅ Athena Controller initialized - AI Autonomy state management ready');
  return controller;
});

// 🧠 ATHENA STATE PROVIDERS

/// Current Athena Recommendation State Provider
final athenaRecommendationStateProvider = Provider<AthenaRecommendationState>((ref) {
  final controller = ref.watch(athenaControllerProvider);
  return controller.state;
});

/// Athena System Status Provider
final athenaSystemStatusProvider = Provider<Map<String, dynamic>>((ref) {
  final controller = ref.watch(athenaControllerProvider);
  return controller.getSystemStatus();
});

/// Current AI Recommendation Provider
final currentAIRecommendationProvider = Provider<AIRecommendationResult?>((ref) {
  final state = ref.watch(athenaRecommendationStateProvider);
  return state.currentRecommendation;
});

/// AI Decision Tree Provider
final aiDecisionTreeProvider = Provider<List<DecisionTreeNode>>((ref) {
  final state = ref.watch(athenaRecommendationStateProvider);
  return state.decisionTree;
});

/// Athena Auto Mode Provider
final athenaAutoModeProvider = Provider<bool>((ref) {
  final state = ref.watch(athenaRecommendationStateProvider);
  return state.isAutoModeEnabled;
});

/// Athena System Confidence Provider
final athenaSystemConfidenceProvider = Provider<double>((ref) {
  final state = ref.watch(athenaRecommendationStateProvider);
  return state.systemConfidence;
});

/// Last Prompt Analysis Provider
final lastPromptAnalysisProvider = Provider<PromptAnalysisResult?>((ref) {
  final state = ref.watch(athenaRecommendationStateProvider);
  return state.currentAnalysis;
});

/// Athena Analytics Provider
final athenaAnalyticsProvider = Provider<Map<String, dynamic>>((ref) {
  final service = ref.watch(athenaIntelligenceServiceProvider);
  return service.getAthenaAnalytics();
});

/// Mini-LLM Analytics Provider
final miniLLMAnalyticsProvider = Provider<Map<String, dynamic>>((ref) {
  final service = ref.watch(miniLLMAnalyzerServiceProvider);
  return service.getAnalyticsData();
});

// 📊 EXISTING ORCHESTRATION STATE PROVIDERS (unchanged)
final currentOrchestrationProvider = StateProvider<String?>((ref) => null);
final isOrchestrationActiveProvider = StateProvider<bool>((ref) => false);

final individualResponsesProvider = StreamProvider<List<ws.AIResponse>>((ref) {
  final orchestrationService = ref.watch(webSocketOrchestrationServiceProvider);
  return orchestrationService.individualResponsesStream;
});

final synthesizedResponseProvider = StreamProvider<String>((ref) {
  final orchestrationService = ref.watch(webSocketOrchestrationServiceProvider);
  return orchestrationService.synthesizedResponseStream;
});

final orchestrationProgressProvider = StreamProvider<ws.OrchestrationProgress>((ref) {
  final orchestrationService = ref.watch(webSocketOrchestrationServiceProvider);
  return orchestrationService.orchestrationProgressStream;
});

// 🧬 EXISTING ORCHESTRATION CONFIGURATION PROVIDERS (unchanged)
final activeModelsProvider = StateProvider<List<String>>((ref) {
  return ['claude', 'gpt', 'deepseek', 'gemini'];
});

final currentStrategyProvider = StateProvider<String>((ref) {
  return OrchestrationStrategy.parallel.name;
});

final availableStrategiesProvider = Provider<List<String>>((ref) {
  return OrchestrationStrategy.values.map((e) => e.name).toList();
});

final modelWeightsProvider = StateProvider<Map<String, double>>((ref) {
  return {
    'claude': 1.0,
    'gpt': 1.0,
    'deepseek': 0.8,
    'gemini': 1.0,
    'mistral': 0.9,
    'llama': 0.7,
    'ollama': 0.8,
  };
});

// 🧠 ENHANCED ORCHESTRATION PROVIDERS WITH ATHENA INTEGRATION

/// Enhanced Model Weights Provider with Athena Recommendations
final enhancedModelWeightsProvider = Provider<Map<String, double>>((ref) {
  final baseWeights = ref.watch(modelWeightsProvider);
  final currentRecommendation = ref.watch(currentAIRecommendationProvider);

  // If Athena has recommendations, use them; otherwise use base weights
  if (currentRecommendation != null && currentRecommendation.recommendedWeights.isNotEmpty) {
    return currentRecommendation.recommendedWeights;
  }

  return baseWeights;
});

/// Smart Model Selection Provider (Athena-enhanced)
final smartModelSelectionProvider = Provider<List<String>>((ref) {
  final activeModels = ref.watch(activeModelsProvider);
  final currentRecommendation = ref.watch(currentAIRecommendationProvider);
  final isAutoMode = ref.watch(athenaAutoModeProvider);

  // If auto mode is enabled and we have Athena recommendations, use them
  if (isAutoMode && currentRecommendation != null && currentRecommendation.recommendedModels.isNotEmpty) {
    return currentRecommendation.recommendedModels;
  }

  return activeModels;
});

/// Smart Strategy Selection Provider (Athena-enhanced)
final smartStrategySelectionProvider = Provider<String>((ref) {
  final currentStrategy = ref.watch(currentStrategyProvider);
  final currentRecommendation = ref.watch(currentAIRecommendationProvider);
  final isAutoMode = ref.watch(athenaAutoModeProvider);

  // If auto mode is enabled and we have Athena strategy recommendation, use it
  if (isAutoMode && currentRecommendation != null && currentRecommendation.recommendedStrategy.isNotEmpty) {
    return currentRecommendation.recommendedStrategy;
  }

  return currentStrategy;
});

// 🏆 EXISTING ACHIEVEMENT SYSTEM PROVIDERS (unchanged)
final achievementTrackerProvider = Provider<EnhancedAchievementService>((ref) {
  return ref.watch(enhancedAchievementServiceProvider);
});

final achievementStateProvider = Provider<AchievementState>((ref) {
  final service = ref.watch(enhancedAchievementServiceProvider);
  return service.state;
});

final achievementStatsProvider = Provider<AchievementStats>((ref) {
  final state = ref.watch(achievementStateProvider);
  return state.stats;
});

final liveAnalyticsProvider = Provider<Map<String, dynamic>>((ref) {
  final service = ref.watch(enhancedAchievementServiceProvider);
  return service.liveAnalytics;
});

final achievementEventHistoryProvider = Provider<List<AchievementEvent>>((ref) {
  final service = ref.watch(enhancedAchievementServiceProvider);
  return service.eventHistory;
});

final sessionStatsProvider = Provider<Map<String, int>>((ref) {
  final service = ref.watch(enhancedAchievementServiceProvider);
  return service.sessionStats;
});

final currentSessionMinutesProvider = Provider<int>((ref) {
  final service = ref.watch(enhancedAchievementServiceProvider);
  return service.currentSessionMinutes;
});

final achievementNotificationStreamProvider = StreamProvider<AchievementNotification>((ref) {
  final service = ref.watch(enhancedAchievementServiceProvider);
  return service.notificationStream;
});

final achievementsByCategoryProvider = Provider.family<List<Achievement>, AchievementCategory>((ref, category) {
  final state = ref.watch(achievementStateProvider);
  return state.achievements.values.where((a) => a.category == category).toList()
    ..sort((a, b) => a.rarity.index.compareTo(b.rarity.index));
});

final achievementProgressProvider = Provider.family<AchievementProgress?, String>((ref, achievementId) {
  final state = ref.watch(achievementStateProvider);
  return state.progress[achievementId];
});

final achievementByIdProvider = Provider.family<Achievement?, String>((ref, achievementId) {
  final state = ref.watch(achievementStateProvider);
  return state.achievements[achievementId];
});

final recentAchievementsProvider = Provider<List<Achievement>>((ref) {
  final state = ref.watch(achievementStateProvider);
  final unlocked = state.achievements.values
      .where((a) => a.isUnlocked && a.unlockedAt != null)
      .toList();

  unlocked.sort((a, b) => b.unlockedAt!.compareTo(a.unlockedAt!));
  return unlocked.take(5).toList();
});

final totalPointsProvider = Provider<int>((ref) {
  final state = ref.watch(achievementStateProvider);
  return state.achievements.values
      .where((a) => a.isUnlocked)
      .fold(0, (sum, a) => sum + _getRarityPoints(a.rarity));
});

final categoryStatsProvider = Provider.family<Map<AchievementRarity, int>, AchievementCategory>((ref, category) {
  final achievements = ref.watch(achievementsByCategoryProvider(category));
  final unlocked = achievements.where((a) => a.isUnlocked);

  return {
    AchievementRarity.common: unlocked.where((a) => a.rarity == AchievementRarity.common).length,
    AchievementRarity.rare: unlocked.where((a) => a.rarity == AchievementRarity.rare).length,
    AchievementRarity.epic: unlocked.where((a) => a.rarity == AchievementRarity.epic).length,
    AchievementRarity.legendary: unlocked.where((a) => a.rarity == AchievementRarity.legendary).length,
  };
});

final overallCompletionProvider = Provider<double>((ref) {
  final state = ref.watch(achievementStateProvider);
  return state.stats.completionPercentage;
});

final unlockedAchievementsProvider = Provider<List<Achievement>>((ref) {
  final state = ref.watch(achievementStateProvider);
  return state.achievements.values.where((a) => a.isUnlocked).toList();
});

final pendingNotificationsProvider = Provider<List<AchievementNotification>>((ref) {
  final state = ref.watch(achievementStateProvider);
  return state.notifications.where((n) => !n.isShown).toList();
});

// 🎯 PHASE 3.4: ENHANCED ANALYTICS PROVIDERS WITH ATHENA INTEGRATION

final sessionPerformanceProvider = Provider<SessionPerformance>((ref) {
  final sessionMinutes = ref.watch(currentSessionMinutesProvider);
  final sessionStats = ref.watch(sessionStatsProvider);
  final liveAnalytics = ref.watch(liveAnalyticsProvider);

  return SessionPerformance(
    sessionDuration: Duration(minutes: sessionMinutes),
    achievementsUnlocked: sessionStats['achievements_unlocked'] ?? 0,
    orchestrationsCompleted: sessionStats['orchestrations'] ?? 0,
    themesChanged: sessionStats['themes_changed'] ?? 0,
    featuresUsed: sessionStats['features_used'] ?? 0,
    performanceMaintained: liveAnalytics['performance_maintained'] ?? false,
    unlockRate: liveAnalytics['unlock_rate']?.toDouble() ?? 0.0,
    favoriteCategory: liveAnalytics['favorite_category'] ?? 'none',
    streakDays: liveAnalytics['streak_days'] ?? 0,
  );
});

/// Enhanced System Status Provider with Athena Integration
final enhancedSystemStatusProvider = Provider<EnhancedSystemStatus>((ref) {
  final orchestrationService = ref.watch(webSocketOrchestrationServiceProvider);
  final isOrchestrationActive = ref.watch(isOrchestrationActiveProvider);
  final activeModels = ref.watch(activeModelsProvider);
  final sessionPerformance = ref.watch(sessionPerformanceProvider);
  final achievementStats = ref.watch(achievementStatsProvider);
  final athenaStatus = ref.watch(athenaSystemStatusProvider);

  return EnhancedSystemStatus(
    connectionStatus: orchestrationService.isConnected
        ? ConnectionStatus.connected
        : ConnectionStatus.disconnected,
    isGenerating: isOrchestrationActive,
    healthyModelCount: orchestrationService.isConnected ? activeModels.length : 0,
    isHealthChecking: false,
    lastUpdate: DateTime.now(),
    sessionPerformance: sessionPerformance,
    achievementStats: achievementStats,
    totalAchievements: achievementStats.totalAchievements,
    unlockedAchievements: achievementStats.unlockedAchievements,
    completionPercentage: achievementStats.completionPercentage,
    // 🧠 NEW: Athena Integration
    athenaSystemState: athenaStatus['system_state'] as String?,
    athenaConfidence: athenaStatus['system_confidence'] as double? ?? 0.0,
    athenaAutoMode: athenaStatus['auto_mode_enabled'] as bool? ?? false,
  );
});

// 📊 EXISTING COMPUTED STATE PROVIDERS (enhanced with Athena)
final appReadyProvider = Provider<bool>((ref) {
  try {
    final configService = ref.watch(configServiceProvider);
    final storageService = ref.watch(storageServiceProvider);
    final aiService = ref.watch(aiServiceProvider);
    final achievementService = ref.watch(enhancedAchievementServiceProvider);
    final athenaService = ref.watch(athenaIntelligenceServiceProvider); // 🧠 NEW
    final athenaController = ref.watch(athenaControllerProvider); // 🧠 NEW

    return achievementService.state.isInitialized &&
        athenaController.state.systemState != AthenaSystemState.initializing;
  } catch (e) {
    return false;
  }
});

final overallHealthProvider = Provider<AppHealth>((ref) {
  final orchestrationService = ref.watch(webSocketOrchestrationServiceProvider);
  final achievementService = ref.watch(enhancedAchievementServiceProvider);
  final athenaController = ref.watch(athenaControllerProvider); // 🧠 NEW

  final orchestrationHealthy = orchestrationService.isConnected;
  final achievementsHealthy = achievementService.state.isInitialized;
  final athenaHealthy = athenaController.state.systemState == AthenaSystemState.ready; // 🧠 NEW

  final healthyCount = [orchestrationHealthy, achievementsHealthy, athenaHealthy].where((h) => h).length;

  switch (healthyCount) {
    case 3:
      return AppHealth.healthy; // All systems operational
    case 2:
      return AppHealth.degraded; // Most systems operational
    case 1:
      return AppHealth.unhealthy; // Few systems operational
    default:
      return AppHealth.critical; // Systems down
  }
});

final systemStatusProvider = Provider<SystemStatus>((ref) {
  final orchestrationService = ref.watch(webSocketOrchestrationServiceProvider);
  final isOrchestrationActive = ref.watch(isOrchestrationActiveProvider);
  final activeModels = ref.watch(activeModelsProvider);

  return SystemStatus(
    connectionStatus: orchestrationService.isConnected
        ? ConnectionStatus.connected
        : ConnectionStatus.disconnected,
    isGenerating: isOrchestrationActive,
    healthyModelCount: orchestrationService.isConnected ? activeModels.length : 0,
    isHealthChecking: false,
    lastUpdate: DateTime.now(),
  );
});

// 🎨 EXISTING THEME & UI PROVIDERS (unchanged)
final currentThemeProvider = StateProvider<AppTheme>((ref) {
  return AppTheme.neural;
});

final isDarkModeProvider = StateProvider<bool>((ref) {
  return true;
});

final adaptiveLayoutProvider = Provider<LayoutBreakpoint>((ref) {
  return LayoutBreakpoint.desktop;
});

// 🌍 EXISTING LOCALIZATION PROVIDERS (unchanged)
final currentLocaleProvider = StateProvider<String>((ref) {
  return 'en_US';
});

final localizationProvider = Provider<Map<String, String>>((ref) {
  final locale = ref.watch(currentLocaleProvider);
  return _getLocalizationForLocale(locale);
});

// 🔄 ENHANCED ASYNC DATA PROVIDERS WITH ATHENA
final initializationProvider = FutureProvider<bool>((ref) async {
  final logger = ref.watch(loggerProvider);

  try {
    logger.i('🚀 Starting application initialization with Athena Intelligence...');
    await Future.delayed(const Duration(milliseconds: 100));

    final configService = ref.read(configServiceProvider);
    final storageService = ref.read(storageServiceProvider);
    final aiService = ref.read(aiServiceProvider);

    logger.i('✅ Core services initialized successfully');

    // Initialize Enhanced Achievement Service
    final achievementService = ref.read(enhancedAchievementServiceProvider);
    await Future.delayed(const Duration(milliseconds: 200));

    if (achievementService.state.isInitialized) {
      logger.i('🏆 Enhanced Achievement System initialized successfully');
    }

    // 🧠 NEW: Initialize Athena Intelligence System
    final athenaController = ref.read(athenaControllerProvider);
    await Future.delayed(const Duration(milliseconds: 300));

    logger.i('🧠 Athena Intelligence System initialized');

    final orchestrationService = ref.read(webSocketOrchestrationServiceProvider);
    await Future.delayed(const Duration(milliseconds: 500));

    if (orchestrationService.isConnected) {
      logger.i('🧬 Orchestration service connected and ready');
    } else {
      logger.i('🧬 Orchestration service will connect in background');
    }

    logger.i('✅ Application initialization completed with PHASE 3.4 Athena Intelligence');
    return true;

  } catch (e, stackTrace) {
    logger.e('❌ Application initialization failed', error: e, stackTrace: stackTrace);
    return true; // Continue anyway
  }
});

final performanceMetricsProvider = StreamProvider<PerformanceMetrics>((ref) {
  return Stream.periodic(const Duration(seconds: 5), (count) {
    final orchestrationService = ref.read(webSocketOrchestrationServiceProvider);
    final sessionPerformance = ref.read(sessionPerformanceProvider);
    final athenaAnalytics = ref.read(athenaAnalyticsProvider); // 🧠 NEW

    return PerformanceMetrics(
      memoryUsage: _getCurrentMemoryUsage(),
      cpuUsage: _getCurrentCpuUsage(),
      renderTime: _getAverageRenderTime(),
      networkLatency: orchestrationService.isConnected ? 50 : 999,
      timestamp: DateTime.now(),
      sessionDuration: sessionPerformance.sessionDuration,
      achievementsPerHour: sessionPerformance.unlockRate,
      performanceMaintained: sessionPerformance.performanceMaintained,
      // 🧠 NEW: Athena Performance Metrics
      athenaDecisionTime: athenaAnalytics['average_decision_time_ms']?.toDouble() ?? 0.0,
      athenaConfidence: ref.read(athenaSystemConfidenceProvider),
      athenaRecommendations: athenaAnalytics['total_recommendations'] as int? ?? 0,
    );
  });
});

// 🔧 EXISTING UTILITY FUNCTIONS (unchanged)
int _getRarityPoints(AchievementRarity rarity) {
  switch (rarity) {
    case AchievementRarity.common:
      return 10;
    case AchievementRarity.rare:
      return 25;
    case AchievementRarity.epic:
      return 50;
    case AchievementRarity.legendary:
      return 100;
  }
}

Map<String, String> _getLocalizationForLocale(String locale) {
  switch (locale) {
    case 'en_US':
      return {
        'app_title': 'NeuronVault',
        'connecting': 'Connecting...',
        'connected': 'Connected',
        'disconnected': 'Disconnected',
        'error': 'Error',
        'orchestrating': 'Orchestrating...',
        'synthesis_complete': 'Synthesis Complete',
        'models_active': 'models active',
        'achievements_unlocked': 'achievements unlocked',
        'session_duration': 'Session Duration',
        'performance_maintained': 'Performance Maintained',
        'streak_days': 'Streak Days',
        // 🧠 NEW: Athena Localization
        'athena_analyzing': 'Athena Analyzing...',
        'ai_recommendation': 'AI Recommendation',
        'auto_mode_enabled': 'Auto Mode Enabled',
        'decision_confidence': 'Decision Confidence',
      };
    case 'it_IT':
      return {
        'app_title': 'NeuronVault',
        'connecting': 'Connettendo...',
        'connected': 'Connesso',
        'disconnected': 'Disconnesso',
        'error': 'Errore',
        'orchestrating': 'Orchestrando...',
        'synthesis_complete': 'Sintesi Completata',
        'models_active': 'modelli attivi',
        'achievements_unlocked': 'achievement sbloccati',
        'session_duration': 'Durata Sessione',
        'performance_maintained': 'Performance Mantenuta',
        'streak_days': 'Giorni Consecutivi',
        // 🧠 NEW: Athena Localization
        'athena_analyzing': 'Athena sta analizzando...',
        'ai_recommendation': 'Raccomandazione AI',
        'auto_mode_enabled': 'Modalità Auto Attiva',
        'decision_confidence': 'Confidenza Decisione',
      };
    default:
      return _getLocalizationForLocale('en_US');
  }
}

double _getCurrentMemoryUsage() => 0.0;
double _getCurrentCpuUsage() => 0.0;
double _getAverageRenderTime() => 16.67;

// 📊 ENHANCED SUPPORTING MODELS WITH ATHENA

enum AppHealth {
  healthy,
  degraded,
  unhealthy,
  critical,
}

enum LayoutBreakpoint {
  mobile,
  tablet,
  desktop,
  ultrawide,
}

class SystemStatus {
  final ConnectionStatus connectionStatus;
  final bool isGenerating;
  final int healthyModelCount;
  final bool isHealthChecking;
  final DateTime? lastUpdate;

  const SystemStatus({
    required this.connectionStatus,
    required this.isGenerating,
    required this.healthyModelCount,
    required this.isHealthChecking,
    required this.lastUpdate,
  });
}

/// Enhanced System Status with Achievement + Athena Integration - PHASE 3.4
class EnhancedSystemStatus extends SystemStatus {
  final SessionPerformance sessionPerformance;
  final AchievementStats achievementStats;
  final int totalAchievements;
  final int unlockedAchievements;
  final double completionPercentage;

  // 🧠 NEW: Athena Integration
  final String? athenaSystemState;
  final double athenaConfidence;
  final bool athenaAutoMode;

  const EnhancedSystemStatus({
    required super.connectionStatus,
    required super.isGenerating,
    required super.healthyModelCount,
    required super.isHealthChecking,
    required super.lastUpdate,
    required this.sessionPerformance,
    required this.achievementStats,
    required this.totalAchievements,
    required this.unlockedAchievements,
    required this.completionPercentage,
    this.athenaSystemState,
    required this.athenaConfidence,
    required this.athenaAutoMode,
  });
}

class SessionPerformance {
  final Duration sessionDuration;
  final int achievementsUnlocked;
  final int orchestrationsCompleted;
  final int themesChanged;
  final int featuresUsed;
  final bool performanceMaintained;
  final double unlockRate;
  final String favoriteCategory;
  final int streakDays;

  const SessionPerformance({
    required this.sessionDuration,
    required this.achievementsUnlocked,
    required this.orchestrationsCompleted,
    required this.themesChanged,
    required this.featuresUsed,
    required this.performanceMaintained,
    required this.unlockRate,
    required this.favoriteCategory,
    required this.streakDays,
  });
}

/// Enhanced Performance Metrics with Athena Integration - PHASE 3.4
class PerformanceMetrics {
  final double memoryUsage;
  final double cpuUsage;
  final double renderTime;
  final int networkLatency;
  final DateTime timestamp;
  final Duration sessionDuration;
  final double achievementsPerHour;
  final bool performanceMaintained;

  // 🧠 NEW: Athena Performance Metrics
  final double athenaDecisionTime;
  final double athenaConfidence;
  final int athenaRecommendations;

  const PerformanceMetrics({
    required this.memoryUsage,
    required this.cpuUsage,
    required this.renderTime,
    required this.networkLatency,
    required this.timestamp,
    required this.sessionDuration,
    required this.achievementsPerHour,
    required this.performanceMaintained,
    required this.athenaDecisionTime,
    required this.athenaConfidence,
    required this.athenaRecommendations,
  });
}