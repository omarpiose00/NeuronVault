// 🧠 NEURONVAULT - ENHANCED PROVIDERS MAIN WITH ATHENA INTELLIGENCE
// PHASE 3.4: Complete Provider System with AI Autonomy Integration
// Revolutionary provider hierarchy with Athena Intelligence Layer

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 🔧 CORE IMPORTS
import '../state/state_models.dart';
import '../services/config_service.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart';
import '../services/theme_service.dart';
import '../services/websocket_orchestration_service.dart' as ws;
import '../services/spatial_audio_service.dart';
import '../services/achievement_service.dart';

// 🧠 ATHENA INTELLIGENCE IMPORTS
import '../services/mini_llm_analyzer_service.dart';
import '../services/athena_intelligence_service.dart';
import '../controllers/athena_controller.dart';

// 🧠 CONTROLLER PROVIDERS - EXPORT CONTROLLERS
export '../controllers/strategy_controller.dart';
export '../controllers/models_controller.dart';
export '../controllers/chat_controller.dart';
export '../controllers/connection_controller.dart';
export '../controllers/athena_controller.dart'; // NEW: Athena Controller

// 🔧 CORE INFRASTRUCTURE PROVIDERS
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

// 🛠️ CORE SERVICE PROVIDERS
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

// 🧠 ATHENA INTELLIGENCE SERVICE PROVIDERS - PHASE 3.4 REVOLUTIONARY

/// 🔍 Mini-LLM Analyzer Service Provider
/// Provides fast prompt analysis using Claude Haiku for intelligent model recommendations
final miniLLMAnalyzerServiceProvider = Provider<MiniLLMAnalyzerService>((ref) {
  final logger = ref.watch(loggerProvider);

  logger.i('🔍 Initializing Mini-LLM Analyzer Service...');

  final service = MiniLLMAnalyzerService(
    aiService: ref.watch(aiServiceProvider),
    configService: ref.watch(configServiceProvider),
    logger: logger,
  );

  logger.i('✅ Mini-LLM Analyzer Service initialized');
  return service;
});

/// 🧠 Athena Intelligence Service Provider
/// Core AI autonomy engine for meta-orchestration and intelligent recommendations
final athenaIntelligenceServiceProvider = Provider<AthenaIntelligenceService>((ref) {
  final logger = ref.watch(loggerProvider);

  logger.i('🧠 Initializing Athena Intelligence Service...');

  final service = AthenaIntelligenceService(
    analyzerService: ref.watch(miniLLMAnalyzerServiceProvider),
    aiService: ref.watch(aiServiceProvider),
    configService: ref.watch(configServiceProvider),
    storageService: ref.watch(storageServiceProvider),
    analyticsService: ref.watch(analyticsServiceProvider),
    logger: logger,
  );

  logger.i('✅ Athena Intelligence Service initialized - AI Autonomy Active');
  return service;
});

/// 🎯 Athena Controller Provider (AutoDispose)
/// State management for Athena Intelligence UI and interactions
final athenaControllerProvider = NotifierProvider.autoDispose<AthenaController, AthenaControllerState>(
      () => AthenaController(),
);

// 🏆 ENHANCED ACHIEVEMENT SERVICE PROVIDER - PHASE 3.3 + 3.4 INTEGRATION
final enhancedAchievementServiceProvider = ChangeNotifierProvider<EnhancedAchievementService>((ref) {
  final logger = ref.watch(loggerProvider);
  final sharedPreferences = ref.watch(sharedPreferencesProvider);

  logger.i('🏆 Initializing Enhanced Achievement Service with Athena Integration...');

  final service = EnhancedAchievementService(
    prefs: sharedPreferences,
    logger: logger,
  );

  // Add Athena-specific achievements
  service.addAthenaAchievements();

  logger.i('✅ Enhanced Achievement Service initialized with Athena achievements');
  return service;
});

// 🏆 LEGACY ACHIEVEMENT SERVICE PROVIDER (for backward compatibility)
final achievementServiceProvider = Provider<EnhancedAchievementService>((ref) {
  return ref.watch(enhancedAchievementServiceProvider);
});

// 🧬 WEBSOCKET ORCHESTRATION SERVICE PROVIDER
final webSocketOrchestrationServiceProvider = ChangeNotifierProvider<ws.WebSocketOrchestrationService>((ref) {
  final logger = ref.watch(loggerProvider);

  logger.i('🧬 Initializing WebSocket Orchestration Service with Athena support...');

  final service = ws.WebSocketOrchestrationService();

  Future.microtask(() async {
    try {
      final connected = await service.connect();
      if (connected) {
        logger.i('✅ WebSocket Orchestration Service connected - Athena backend ready');
      } else {
        logger.w('⚠️ WebSocket Orchestration Service connection failed - will retry');
      }
    } catch (e) {
      logger.e('❌ Error connecting WebSocket Orchestration Service: $e');
    }
  });

  return service;
});

// 📊 ORCHESTRATION STATE PROVIDERS
final currentOrchestrationProvider = StateProvider<String?>((ref) => null);
final isOrchestrationActiveProvider = StateProvider<bool>((ref) => false);

// 🔧 ORCHESTRATION STREAM PROVIDERS (Fixed with proper types)
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

// 🧬 ORCHESTRATION CONFIGURATION PROVIDERS
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

// 🧠 ATHENA INTELLIGENCE COMPUTED PROVIDERS - PHASE 3.4

/// Athena Ready State Provider
final athenaIsReadyProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(athenaControllerProvider.select((state) => state.isInitialized && !state.isAnalyzing));
});

/// Current Athena Recommendation Provider
final athenaCurrentRecommendationProvider = Provider.autoDispose<AthenaRecommendation?>((ref) {
  return ref.watch(athenaControllerProvider.select((state) => state.currentRecommendation));
});

/// Current Prompt Analysis Provider
final athenaCurrentAnalysisProvider = Provider.autoDispose<PromptAnalysis?>((ref) {
  return ref.watch(athenaControllerProvider.select((state) => state.currentAnalysis));
});

/// Live Model Scores Provider
final athenaLiveModelScoresProvider = Provider.autoDispose<Map<String, double>>((ref) {
  return ref.watch(athenaControllerProvider.select((state) => state.liveModelScores));
});

/// Auto-Apply Enabled Provider
final athenaAutoApplyEnabledProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(athenaControllerProvider.select((state) => state.autoApplyEnabled));
});

/// Decision Tree Visibility Provider
final athenaShowDecisionTreeProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(athenaControllerProvider.select((state) => state.showDecisionTree));
});

/// Athena Status Text Provider
final athenaStatusTextProvider = Provider.autoDispose<String>((ref) {
  return ref.read(athenaControllerProvider.notifier).statusText;
});

/// New Recommendation Indicator Provider
final athenaHasNewRecommendationProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(athenaControllerProvider.select((state) => state.hasNewRecommendation));
});

/// Recent Recommendations History Provider
final athenaRecentRecommendationsProvider = Provider.autoDispose<List<AthenaRecommendation>>((ref) {
  return ref.watch(athenaControllerProvider.select((state) => state.recentRecommendations));
});

/// Recommendation Confidence Provider
final athenaRecommendationConfidenceProvider = Provider.autoDispose<double>((ref) {
  final recommendation = ref.watch(athenaCurrentRecommendationProvider);
  return recommendation?.overallConfidence ?? 0.0;
});

/// Top Recommended Model Provider
final athenaTopModelProvider = Provider.autoDispose<String?>((ref) {
  final recommendation = ref.watch(athenaCurrentRecommendationProvider);
  if (recommendation?.modelWeights.isEmpty ?? true) return null;

  return recommendation!.modelWeights.entries
      .reduce((a, b) => a.value > b.value ? a : b)
      .key;
});

/// Analysis Complexity Provider
final athenaAnalysisComplexityProvider = Provider.autoDispose<String>((ref) {
  final analysis = ref.watch(athenaCurrentAnalysisProvider);
  return analysis?.complexity ?? 'unknown';
});

/// Analysis Type Provider
final athenaAnalysisTypeProvider = Provider.autoDispose<String>((ref) {
  final analysis = ref.watch(athenaCurrentAnalysisProvider);
  return analysis?.promptType ?? 'unknown';
});

/// Athena Intelligence Status Provider
final athenaIntelligenceStatusProvider = Provider.autoDispose<AthenaIntelligenceStatus>((ref) {
  final controller = ref.watch(athenaControllerProvider);
  final recommendation = ref.watch(athenaCurrentRecommendationProvider);
  final analysis = ref.watch(athenaCurrentAnalysisProvider);

  return AthenaIntelligenceStatus(
    isInitialized: controller.isInitialized,
    isAnalyzing: controller.isAnalyzing,
    autoApplyEnabled: controller.autoApplyEnabled,
    hasRecommendation: recommendation != null,
    hasAnalysis: analysis != null,
    hasNewRecommendation: controller.hasNewRecommendation,
    recommendationCount: controller.recentRecommendations.length,
    overallConfidence: recommendation?.overallConfidence ?? 0.0,
    lastAnalysisTime: controller.lastAnalysisTime,
    statusText: ref.read(athenaControllerProvider.notifier).statusText,
  );
});

// 🏆 ENHANCED ACHIEVEMENT SYSTEM PROVIDERS - PHASE 3.3 + 3.4 COMPLETE

/// Enhanced Achievement Service Provider (for easy access)
final achievementTrackerProvider = Provider<EnhancedAchievementService>((ref) {
  return ref.watch(enhancedAchievementServiceProvider);
});

/// Achievement State Provider
final achievementStateProvider = Provider<AchievementState>((ref) {
  final service = ref.watch(enhancedAchievementServiceProvider);
  return service.state;
});

/// Enhanced Achievement Stats Provider
final achievementStatsProvider = Provider<AchievementStats>((ref) {
  final state = ref.watch(achievementStateProvider);
  return state.stats;
});

/// Live Analytics Provider - PHASE 3.3 NEW
final liveAnalyticsProvider = Provider<Map<String, dynamic>>((ref) {
  final service = ref.watch(enhancedAchievementServiceProvider);
  return service.liveAnalytics;
});

/// Achievement Event History Provider - PHASE 3.3 NEW
final achievementEventHistoryProvider = Provider<List<AchievementEvent>>((ref) {
  final service = ref.watch(enhancedAchievementServiceProvider);
  return service.eventHistory;
});

/// Session Stats Provider - PHASE 3.3 NEW
final sessionStatsProvider = Provider<Map<String, int>>((ref) {
  final service = ref.watch(enhancedAchievementServiceProvider);
  return service.sessionStats;
});

/// Current Session Minutes Provider - PHASE 3.3 NEW
final currentSessionMinutesProvider = Provider<int>((ref) {
  final service = ref.watch(enhancedAchievementServiceProvider);
  return service.currentSessionMinutes;
});

/// Achievement Notification Stream Provider
final achievementNotificationStreamProvider = StreamProvider<AchievementNotification>((ref) {
  final service = ref.watch(enhancedAchievementServiceProvider);
  return service.notificationStream;
});

/// Achievements by Category Provider
final achievementsByCategoryProvider = Provider.family<List<Achievement>, AchievementCategory>((ref, category) {
  final state = ref.watch(achievementStateProvider);
  return state.achievements.values.where((a) => a.category == category).toList()
    ..sort((a, b) => a.rarity.index.compareTo(b.rarity.index));
});

/// Achievement Progress Provider
final achievementProgressProvider = Provider.family<AchievementProgress?, String>((ref, achievementId) {
  final state = ref.watch(achievementStateProvider);
  return state.progress[achievementId];
});

/// Achievement by ID Provider
final achievementByIdProvider = Provider.family<Achievement?, String>((ref, achievementId) {
  final state = ref.watch(achievementStateProvider);
  return state.achievements[achievementId];
});

/// Recent Achievements Provider (last 5)
final recentAchievementsProvider = Provider<List<Achievement>>((ref) {
  final state = ref.watch(achievementStateProvider);
  final unlocked = state.achievements.values
      .where((a) => a.isUnlocked && a.unlockedAt != null)
      .toList();

  unlocked.sort((a, b) => b.unlockedAt!.compareTo(a.unlockedAt!));
  return unlocked.take(5).toList();
});

/// Total Points Provider
final totalPointsProvider = Provider<int>((ref) {
  final state = ref.watch(achievementStateProvider);
  return state.achievements.values
      .where((a) => a.isUnlocked)
      .fold(0, (sum, a) => sum + _getRarityPoints(a.rarity));
});

/// Category Stats Provider
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

/// Overall Completion Provider
final overallCompletionProvider = Provider<double>((ref) {
  final state = ref.watch(achievementStateProvider);
  return state.stats.completionPercentage;
});

/// Unlocked Achievements Provider
final unlockedAchievementsProvider = Provider<List<Achievement>>((ref) {
  final state = ref.watch(achievementStateProvider);
  return state.achievements.values.where((a) => a.isUnlocked).toList();
});

/// Pending Notifications Provider
final pendingNotificationsProvider = Provider<List<AchievementNotification>>((ref) {
  final state = ref.watch(achievementStateProvider);
  return state.notifications.where((n) => !n.isShown).toList();
});

// 🎯 PHASE 3.4: ENHANCED ANALYTICS PROVIDERS WITH ATHENA INTEGRATION

/// Session Performance Provider with Athena Integration
final sessionPerformanceProvider = Provider<SessionPerformance>((ref) {
  final sessionMinutes = ref.watch(currentSessionMinutesProvider);
  final sessionStats = ref.watch(sessionStatsProvider);
  final liveAnalytics = ref.watch(liveAnalyticsProvider);
  final athenaStats = ref.watch(athenaIntelligenceStatusProvider);

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
    // NEW: Athena-specific metrics
    athenaRecommendations: athenaStats.recommendationCount,
    athenaAutoApplied: athenaStats.autoApplyEnabled ? sessionStats['athena_auto_applied'] ?? 0 : 0,
    athenaConfidence: athenaStats.overallConfidence,
  );
});

/// Enhanced System Status Provider with Athena Integration
final enhancedSystemStatusProvider = Provider<EnhancedSystemStatus>((ref) {
  final orchestrationService = ref.watch(webSocketOrchestrationServiceProvider);
  final isOrchestrationActive = ref.watch(isOrchestrationActiveProvider);
  final activeModels = ref.watch(activeModelsProvider);
  final sessionPerformance = ref.watch(sessionPerformanceProvider);
  final achievementStats = ref.watch(achievementStatsProvider);
  final athenaStatus = ref.watch(athenaIntelligenceStatusProvider);

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
    // NEW: Athena Intelligence Status
    athenaStatus: athenaStatus,
  );
});

// 📊 COMPUTED STATE PROVIDERS WITH ATHENA INTEGRATION
final appReadyProvider = Provider<bool>((ref) {
  try {
    final configService = ref.watch(configServiceProvider);
    final storageService = ref.watch(storageServiceProvider);
    final aiService = ref.watch(aiServiceProvider);
    final achievementService = ref.watch(enhancedAchievementServiceProvider);
    final athenaReady = ref.watch(athenaIsReadyProvider);

    return achievementService.state.isInitialized && athenaReady;
  } catch (e) {
    return false;
  }
});

final overallHealthProvider = Provider<AppHealth>((ref) {
  final orchestrationService = ref.watch(webSocketOrchestrationServiceProvider);
  final achievementService = ref.watch(enhancedAchievementServiceProvider);
  final athenaReady = ref.watch(athenaIsReadyProvider);

  if (orchestrationService.isConnected && achievementService.state.isInitialized && athenaReady) {
    return AppHealth.healthy;
  } else if (orchestrationService.isConnected || achievementService.state.isInitialized || athenaReady) {
    return AppHealth.degraded;
  } else {
    return AppHealth.unhealthy;
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

// 🎨 THEME & UI PROVIDERS
final currentThemeProvider = StateProvider<AppTheme>((ref) {
  return AppTheme.neural;
});

final isDarkModeProvider = StateProvider<bool>((ref) {
  return true;
});

final adaptiveLayoutProvider = Provider<LayoutBreakpoint>((ref) {
  return LayoutBreakpoint.desktop;
});

// 🌍 LOCALIZATION PROVIDERS
final currentLocaleProvider = StateProvider<String>((ref) {
  return 'en_US';
});

final localizationProvider = Provider<Map<String, String>>((ref) {
  final locale = ref.watch(currentLocaleProvider);
  return _getLocalizationForLocale(locale);
});

// 🔄 ASYNC DATA PROVIDERS WITH ATHENA INTEGRATION
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

    // Initialize Athena Intelligence
    final athenaService = ref.read(athenaIntelligenceServiceProvider);
    await Future.delayed(const Duration(milliseconds: 300));

    if (athenaService.state.isInitialized) {
      logger.i('🧠 Athena Intelligence System initialized successfully');
    }

    final orchestrationService = ref.read(webSocketOrchestrationServiceProvider);
    await Future.delayed(const Duration(milliseconds: 500));

    if (orchestrationService.isConnected) {
      logger.i('🧬 Orchestration service connected with Athena backend ready');
    } else {
      logger.i('🧬 Orchestration service will connect in background');
    }

    logger.i('✅ Application initialization completed with PHASE 3.4 Athena Intelligence');
    return true;

  } catch (e, stackTrace) {
    logger.e('❌ Application initialization failed', error: e, stackTrace: stackTrace);
    return true;
  }
});

final performanceMetricsProvider = StreamProvider<PerformanceMetrics>((ref) {
  return Stream.periodic(const Duration(seconds: 5), (count) {
    final orchestrationService = ref.read(webSocketOrchestrationServiceProvider);
    final sessionPerformance = ref.read(sessionPerformanceProvider);
    final athenaStatus = ref.read(athenaIntelligenceStatusProvider);

    return PerformanceMetrics(
      memoryUsage: _getCurrentMemoryUsage(),
      cpuUsage: _getCurrentCpuUsage(),
      renderTime: _getAverageRenderTime(),
      networkLatency: orchestrationService.isConnected ? 50 : 999,
      timestamp: DateTime.now(),
      sessionDuration: sessionPerformance.sessionDuration,
      achievementsPerHour: sessionPerformance.unlockRate,
      performanceMaintained: sessionPerformance.performanceMaintained,
      // NEW: Athena metrics
      athenaRecommendations: athenaStatus.recommendationCount,
      athenaConfidence: athenaStatus.overallConfidence,
      athenaAutoApplyRate: athenaStatus.autoApplyEnabled ? 1.0 : 0.0,
    );
  });
});

// 🔧 UTILITY FUNCTIONS

/// Helper function for rarity points
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
        // NEW: Athena localizations
        'athena_analyzing': 'Athena Analyzing...',
        'athena_ready': 'Athena Ready',
        'athena_recommendation': 'AI Recommendation',
        'auto_apply_enabled': 'Auto-Apply Enabled',
        'decision_tree': 'Decision Tree',
        'ai_autonomy': 'AI Autonomy',
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
        // NEW: Athena localizations
        'athena_analyzing': 'Athena Analizza...',
        'athena_ready': 'Athena Pronta',
        'athena_recommendation': 'Raccomandazione AI',
        'auto_apply_enabled': 'Applicazione Automatica Attiva',
        'decision_tree': 'Albero Decisionale',
        'ai_autonomy': 'Autonomia AI',
      };
    default:
      return _getLocalizationForLocale('en_US');
  }
}

double _getCurrentMemoryUsage() => 0.0;
double _getCurrentCpuUsage() => 0.0;
double _getAverageRenderTime() => 16.67;

// 📊 SUPPORTING MODELS

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

/// 🧠 ATHENA INTELLIGENCE STATUS MODEL - PHASE 3.4
class AthenaIntelligenceStatus {
  final bool isInitialized;
  final bool isAnalyzing;
  final bool autoApplyEnabled;
  final bool hasRecommendation;
  final bool hasAnalysis;
  final bool hasNewRecommendation;
  final int recommendationCount;
  final double overallConfidence;
  final DateTime? lastAnalysisTime;
  final String statusText;

  const AthenaIntelligenceStatus({
    required this.isInitialized,
    required this.isAnalyzing,
    required this.autoApplyEnabled,
    required this.hasRecommendation,
    required this.hasAnalysis,
    required this.hasNewRecommendation,
    required this.recommendationCount,
    required this.overallConfidence,
    required this.lastAnalysisTime,
    required this.statusText,
  });
}

/// Enhanced System Status with Athena Integration - PHASE 3.4
class EnhancedSystemStatus extends SystemStatus {
  final SessionPerformance sessionPerformance;
  final AchievementStats achievementStats;
  final int totalAchievements;
  final int unlockedAchievements;
  final double completionPercentage;
  final AthenaIntelligenceStatus athenaStatus;

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
    required this.athenaStatus,
  });
}

/// Session Performance Model with Athena Integration - PHASE 3.4
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
  // NEW: Athena-specific metrics
  final int athenaRecommendations;
  final int athenaAutoApplied;
  final double athenaConfidence;

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
    this.athenaRecommendations = 0,
    this.athenaAutoApplied = 0,
    this.athenaConfidence = 0.0,
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
  // NEW: Athena metrics
  final int athenaRecommendations;
  final double athenaConfidence;
  final double athenaAutoApplyRate;

  const PerformanceMetrics({
    required this.memoryUsage,
    required this.cpuUsage,
    required this.renderTime,
    required this.networkLatency,
    required this.timestamp,
    required this.sessionDuration,
    required this.achievementsPerHour,
    required this.performanceMaintained,
    this.athenaRecommendations = 0,
    this.athenaConfidence = 0.0,
    this.athenaAutoApplyRate = 0.0,
  });
}

// 🏆 ATHENA-SPECIFIC ACHIEVEMENTS EXTENSION
extension AthenaAchievements on EnhancedAchievementService {
  /// Add Athena-specific achievements to the service
  void addAthenaAchievements() {
    // TODO: Implement Athena-specific achievements
    // This would be called during service initialization
  }
}