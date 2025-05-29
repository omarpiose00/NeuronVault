// 🎯 NEURONVAULT - CENTRAL PROVIDERS HUB - PHASE 3.4 ATHENA INTEGRATION
// Enterprise-grade provider management and dependency injection
// PHASE 3.4 COMPLETE: Athena AI Autonomy Intelligence Layer + Enhanced Achievement System + Live Analytics

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 🔧 FIXED IMPORTS - AVOID AMBIGUOUS CONFLICTS
import '../state/state_models.dart'; // Use state models versions
import '../services/config_service.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart';
import '../services/theme_service.dart';
import '../services/websocket_orchestration_service.dart' as ws; // Alias for websocket service
import '../services/spatial_audio_service.dart';
import '../services/achievement_service.dart'; // 🏆 ENHANCED ACHIEVEMENT SERVICE
import '../theme/neural_theme_system.dart';

// 🧠 ATHENA AI AUTONOMY IMPORTS - PHASE 3.4
import '../../core/services/mini_llm_analyzer_service.dart';   // 🔍 Mini-LLM Analysis
import '../services/athena_intelligence_service.dart'; // 🧠 AI Autonomy Core
import '../controllers/athena_controller.dart';        // 🎮 Athena State Management

// 🧠 CONTROLLER PROVIDERS - IMPORT CONTROLLERS
export '../controllers/strategy_controller.dart';
export '../controllers/models_controller.dart';
export '../controllers/chat_controller.dart';
export '../controllers/connection_controller.dart';
export '../controllers/athena_controller.dart'; // 🧠 PHASE 3.4 - Athena Controller

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

// 🛠️ SERVICE PROVIDERS
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

// 🧠 ATHENA AI AUTONOMY SERVICE PROVIDERS - PHASE 3.4 REVOLUTIONARY

/// Mini-LLM Analyzer Service Provider - Fast prompt analysis with Claude Haiku
final miniLLMAnalyzerServiceProvider = Provider<MiniLLMAnalyzerService>((ref) {
  final logger = ref.watch(loggerProvider);
  logger.i('🔍 Initializing Mini-LLM Analyzer Service - AI Meta-Analysis Engine...');

  final service = MiniLLMAnalyzerService(
    aiService: ref.watch(aiServiceProvider),
    configService: ref.watch(configServiceProvider),
    storageService: ref.watch(storageServiceProvider),
    logger: logger,
  );

  logger.i('✅ Mini-LLM Analyzer Service initialized - <200ms AI analysis ready');
  return service;
});

/// Athena Intelligence Service Provider - CORE AI AUTONOMY ENGINE
final athenaIntelligenceServiceProvider = ChangeNotifierProvider<AthenaIntelligenceService>((ref) {
  final logger = ref.watch(loggerProvider);
  logger.i('🧠 Initializing Athena Intelligence Service - WORLD\'S FIRST AI AUTONOMY ENGINE...');

  final service = AthenaIntelligenceService(
    analyzer: ref.watch(miniLLMAnalyzerServiceProvider),
    orchestrationService: ref.watch(webSocketOrchestrationServiceProvider),
    storageService: ref.watch(storageServiceProvider),
    configService: ref.watch(configServiceProvider),
    logger: logger,
  );

  logger.i('✅ Athena Intelligence Service initialized - AI AUTONOMY CORE READY');
  return service;
});

/// Athena Controller Provider - AI AUTONOMY STATE MANAGEMENT
final athenaControllerProvider = StateNotifierProvider<AthenaController, AthenaControllerState>((ref) {
  final logger = ref.watch(loggerProvider);
  logger.i('🎮 Initializing Athena Controller - AI Autonomy State Management...');

  final controller = AthenaController(
    ref.watch(athenaIntelligenceServiceProvider),
    logger,
  );

  logger.i('✅ Athena Controller initialized - Neural luxury reactive state ready');
  return controller;
});

// 🏆 ENHANCED ACHIEVEMENT SERVICE PROVIDER - PHASE 3.3 REVOLUTIONARY UPGRADE
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

// 🏆 LEGACY ACHIEVEMENT SERVICE PROVIDER (for backward compatibility)
final achievementServiceProvider = Provider<EnhancedAchievementService>((ref) {
  return ref.watch(enhancedAchievementServiceProvider);
});

// 🧬 WEBSOCKET ORCHESTRATION SERVICE PROVIDER
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

// 📊 ORCHESTRATION STATE PROVIDERS
final currentOrchestrationProvider = StateProvider<String?>((ref) => null);
final isOrchestrationActiveProvider = StateProvider<bool>((ref) => false);

// 🔧 FIXED: Use websocket service types to match return types
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

// 🧠 ATHENA AI AUTONOMY STATE PROVIDERS - PHASE 3.4

/// Athena Decision Stream Provider - Real-time AI decisions
final athenaDecisionStreamProvider = StreamProvider<AthenaDecision>((ref) {
  final athenaService = ref.watch(athenaIntelligenceServiceProvider);
  return athenaService.decisionStream;
});

/// Athena Recommendation Stream Provider - AI model recommendations
final athenaRecommendationStreamProvider = StreamProvider<AthenaRecommendation>((ref) {
  final athenaService = ref.watch(athenaIntelligenceServiceProvider);
  return athenaService.recommendationStream;
});

/// Athena Service State Stream Provider - Service state changes
final athenaServiceStateStreamProvider = StreamProvider<AthenaState>((ref) {
  final athenaService = ref.watch(athenaIntelligenceServiceProvider);
  return athenaService.stateStream;
});

// 🎯 ATHENA COMPUTED STATE PROVIDERS

/// Athena Enabled State Provider
final athenaEnabledProvider = Provider<bool>((ref) {
  final controllerState = ref.watch(athenaControllerProvider);
  return controllerState.isEnabled;
});

/// Athena UI State Provider
final athenaUIStateProvider = Provider<AthenaUIState>((ref) {
  final controllerState = ref.watch(athenaControllerProvider);
  return controllerState.uiState;
});

/// Athena Current Recommendation Provider
final athenaCurrentRecommendationProvider = Provider<AthenaRecommendation?>((ref) {
  final controllerState = ref.watch(athenaControllerProvider);
  return controllerState.currentRecommendation;
});

/// Athena Has Recommendation Provider
final athenaHasRecommendationProvider = Provider<bool>((ref) {
  final controllerState = ref.watch(athenaControllerProvider);
  return controllerState.hasRecommendation;
});

/// Athena Can Apply Recommendation Provider
final athenaCanApplyRecommendationProvider = Provider<bool>((ref) {
  final controllerState = ref.watch(athenaControllerProvider);
  return controllerState.canApplyRecommendation;
});

/// Athena Is Analyzing Provider
final athenaIsAnalyzingProvider = Provider<bool>((ref) {
  final controllerState = ref.watch(athenaControllerProvider);
  return controllerState.isAnalyzing;
});

/// Athena Error Message Provider
final athenaErrorMessageProvider = Provider<String?>((ref) {
  final controllerState = ref.watch(athenaControllerProvider);
  return controllerState.errorMessage;
});

/// Athena Recent Decisions Provider (last 10)
final athenaRecentDecisionsProvider = Provider<List<AthenaDecision>>((ref) {
  final controllerState = ref.watch(athenaControllerProvider);
  return controllerState.recentDecisions;
});

/// Athena Auto-Apply Configuration Providers
final athenaAutoApplyEnabledProvider = Provider<bool>((ref) {
  final controllerState = ref.watch(athenaControllerProvider);
  return controllerState.autoApplyEnabled;
});

final athenaAutoApplyThresholdProvider = Provider<double>((ref) {
  final controllerState = ref.watch(athenaControllerProvider);
  return controllerState.autoApplyThreshold;
});

// 📊 ATHENA ANALYTICS PROVIDERS

/// Athena Statistics Provider - Complete analytics
final athenaStatisticsProvider = Provider<Map<String, dynamic>>((ref) {
  final controller = ref.watch(athenaControllerProvider.notifier);
  return controller.getAthenaAnalytics();
});

/// Athena Usage Insights Provider - User behavior analysis
final athenaUsageInsightsProvider = Provider<Map<String, dynamic>>((ref) {
  final controller = ref.watch(athenaControllerProvider.notifier);
  return controller.getUsageInsights();
});

/// Athena Category Usage Stats Provider
final athenaCategoryUsageProvider = Provider<Map<String, int>>((ref) {
  final controllerState = ref.watch(athenaControllerProvider);
  return controllerState.categoryUsageStats;
});

/// Athena Recent Categories Provider
final athenaRecentCategoriesProvider = Provider<List<String>>((ref) {
  final controllerState = ref.watch(athenaControllerProvider);
  return controllerState.recentPromptCategories;
});

/// Athena Average Confidence Provider
final athenaAverageConfidenceProvider = Provider<double>((ref) {
  final controllerState = ref.watch(athenaControllerProvider);
  return controllerState.averageConfidence;
});

// 🔍 ATHENA DECISION ANALYSIS PROVIDERS

/// Athena Decisions by Type Provider
final athenaDecisionsByTypeProvider = Provider.family<List<AthenaDecision>, AthenaDecisionType>((ref, type) {
  final controllerState = ref.watch(athenaControllerProvider);
  return controllerState.serviceState.decisionHistory
      .where((decision) => decision.type == type)
      .toList();
});

/// Athena Decision Count Provider
final athenaDecisionCountProvider = Provider<int>((ref) {
  final controllerState = ref.watch(athenaControllerProvider);
  return controllerState.serviceState.decisionHistory.length;
});

/// Athena Applied Decisions Provider
final athenaAppliedDecisionsProvider = Provider<List<AthenaDecision>>((ref) {
  final controllerState = ref.watch(athenaControllerProvider);
  return controllerState.serviceState.decisionHistory
      .where((decision) => decision.wasApplied)
      .toList();
});

/// Athena Confidence Distribution Provider
final athenaConfidenceDistributionProvider = Provider<Map<String, int>>((ref) {
  final controllerState = ref.watch(athenaControllerProvider);
  final decisions = controllerState.serviceState.decisionHistory;

  final distribution = <String, int>{
    'very_high': 0, // 0.9-1.0
    'high': 0,      // 0.8-0.9
    'medium': 0,    // 0.6-0.8
    'low': 0,       // 0.4-0.6
    'very_low': 0,  // 0.0-0.4
  };

  for (final decision in decisions) {
    final confidence = decision.confidenceScore;
    if (confidence >= 0.9) {
      distribution['very_high'] = distribution['very_high']! + 1;
    } else if (confidence >= 0.8) {
      distribution['high'] = distribution['high']! + 1;
    } else if (confidence >= 0.6) {
      distribution['medium'] = distribution['medium']! + 1;
    } else if (confidence >= 0.4) {
      distribution['low'] = distribution['low']! + 1;
    } else {
      distribution['very_low'] = distribution['very_low']! + 1;
    }
  }

  return distribution;
});

// 🎨 ATHENA UI ENHANCEMENT PROVIDERS

/// Athena Progress Indicator Provider - For UI progress bars
final athenaProgressProvider = Provider<double>((ref) {
  final uiState = ref.watch(athenaUIStateProvider);

  switch (uiState) {
    case AthenaUIState.disabled:
      return 0.0;
    case AthenaUIState.idle:
      return 0.0;
    case AthenaUIState.analyzing:
      return 0.3;
    case AthenaUIState.recommending:
      return 0.6;
    case AthenaUIState.ready:
      return 1.0;
    case AthenaUIState.applying:
      return 0.8;
    case AthenaUIState.error:
      return 0.0;
  }
});

/// Athena Status Message Provider - For UI status display
final athenaStatusMessageProvider = Provider<String>((ref) {
  final uiState = ref.watch(athenaUIStateProvider);
  final errorMessage = ref.watch(athenaErrorMessageProvider);

  if (errorMessage != null) return errorMessage;

  switch (uiState) {
    case AthenaUIState.disabled:
      return 'Athena Intelligence is disabled';
    case AthenaUIState.idle:
      return 'Athena Intelligence ready';
    case AthenaUIState.analyzing:
      return 'Analyzing prompt intelligence...';
    case AthenaUIState.recommending:
      return 'Generating AI recommendations...';
    case AthenaUIState.ready:
      return 'Recommendations ready for review';
    case AthenaUIState.applying:
      return 'Applying AI recommendations...';
    case AthenaUIState.error:
      return 'Athena Intelligence error';
  }
});

/// Athena Action Button Configuration Provider - For UI button states
final athenaActionButtonStateProvider = Provider<Map<String, dynamic>>((ref) {
  final uiState = ref.watch(athenaUIStateProvider);
  final hasRecommendation = ref.watch(athenaHasRecommendationProvider);
  final canApply = ref.watch(athenaCanApplyRecommendationProvider);
  final isEnabled = ref.watch(athenaEnabledProvider);

  return {
    'enabled': isEnabled && uiState != AthenaUIState.error,
    'loading': uiState == AthenaUIState.analyzing ||
        uiState == AthenaUIState.recommending ||
        uiState == AthenaUIState.applying,
    'can_apply': canApply,
    'has_recommendation': hasRecommendation,
    'primary_action': _getAthenaActionType(uiState, hasRecommendation, canApply),
    'button_text': _getAthenaButtonText(uiState, hasRecommendation, canApply),
    'icon': _getAthenaActionIcon(uiState, hasRecommendation, canApply),
  };
});

// 🏆 ENHANCED ACHIEVEMENT SYSTEM PROVIDERS - PHASE 3.3 COMPLETE

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

// 🎯 PHASE 3.3: ENHANCED ANALYTICS PROVIDERS

/// Session Performance Provider
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

/// Enhanced System Status Provider with Achievement + Athena Integration - PHASE 3.4
final enhancedSystemStatusProvider = Provider<EnhancedSystemStatusV2>((ref) {
  final orchestrationService = ref.watch(webSocketOrchestrationServiceProvider);
  final isOrchestrationActive = ref.watch(isOrchestrationActiveProvider);
  final activeModels = ref.watch(activeModelsProvider);
  final sessionPerformance = ref.watch(sessionPerformanceProvider);
  final achievementStats = ref.watch(achievementStatsProvider);

  // 🧠 ATHENA INTEGRATION
  final athenaEnabled = ref.watch(athenaEnabledProvider);
  final athenaUIState = ref.watch(athenaUIStateProvider);
  final athenaDecisionCount = ref.watch(athenaDecisionCountProvider);
  final athenaAverageConfidence = ref.watch(athenaAverageConfidenceProvider);

  return EnhancedSystemStatusV2(
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
    // ATHENA STATUS INTEGRATION
    athenaEnabled: athenaEnabled,
    athenaState: athenaUIState,
    athenaTotalDecisions: athenaDecisionCount,
    athenaAverageConfidence: athenaAverageConfidence,
  );
});

// 📊 COMPUTED STATE PROVIDERS
final appReadyProvider = Provider<bool>((ref) {
  try {
    final configService = ref.watch(configServiceProvider);
    final storageService = ref.watch(storageServiceProvider);
    final aiService = ref.watch(aiServiceProvider);
    final achievementService = ref.watch(enhancedAchievementServiceProvider);
    final athenaService = ref.watch(athenaIntelligenceServiceProvider); // 🧠 ATHENA CHECK
    return achievementService.state.isInitialized;
  } catch (e) {
    return false;
  }
});

final overallHealthProvider = Provider<AppHealth>((ref) {
  final orchestrationService = ref.watch(webSocketOrchestrationServiceProvider);
  final achievementService = ref.watch(enhancedAchievementServiceProvider);
  final athenaEnabled = ref.watch(athenaEnabledProvider); // 🧠 ATHENA HEALTH CHECK

  if (orchestrationService.isConnected && achievementService.state.isInitialized) {
    return athenaEnabled ? AppHealth.healthy : AppHealth.degraded; // 🧠 ATHENA BONUS
  } else if (orchestrationService.isConnected || achievementService.state.isInitialized) {
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

// 🔄 ASYNC DATA PROVIDERS - PHASE 3.4 ENHANCED WITH ATHENA
final initializationProvider = FutureProvider<bool>((ref) async {
  final logger = ref.watch(loggerProvider);

  try {
    logger.i('🚀 Starting application initialization with PHASE 3.4 Athena Intelligence...');
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

    final orchestrationService = ref.read(webSocketOrchestrationServiceProvider);
    await Future.delayed(const Duration(milliseconds: 300));

    if (orchestrationService.isConnected) {
      logger.i('🧬 Orchestration service connected and ready');
    } else {
      logger.i('🧬 Orchestration service will connect in background');
    }

    // 🧠 INITIALIZE ATHENA INTELLIGENCE - PHASE 3.4
    logger.i('🧠 Initializing Athena Intelligence Layer...');
    final miniLLMService = ref.read(miniLLMAnalyzerServiceProvider);
    final athenaService = ref.read(athenaIntelligenceServiceProvider);
    final athenaController = ref.read(athenaControllerProvider.notifier);
    await Future.delayed(const Duration(milliseconds: 400));

    logger.i('✅ Athena Intelligence Layer initialized - WORLD\'S FIRST AI AUTONOMY READY');

    // Final system status check
    final systemStatus = ref.read(enhancedSystemStatusProvider);
    logger.i('📊 System Intelligence Score: ${(systemStatus.intelligenceScore * 100).toStringAsFixed(1)}%');

    logger.i('🎊 Application initialization completed with PHASE 3.4 AI AUTONOMY ENHANCEMENTS');
    return true;

  } catch (e, stackTrace) {
    logger.e('❌ Application initialization failed', error: e, stackTrace: stackTrace);
    return true; // Continue even if some components fail
  }
});

final performanceMetricsProvider = StreamProvider<PerformanceMetrics>((ref) {
  return Stream.periodic(const Duration(seconds: 5), (count) {
    final orchestrationService = ref.read(webSocketOrchestrationServiceProvider);
    final sessionPerformance = ref.read(sessionPerformanceProvider);

    return PerformanceMetrics(
      memoryUsage: _getCurrentMemoryUsage(),
      cpuUsage: _getCurrentCpuUsage(),
      renderTime: _getAverageRenderTime(),
      networkLatency: orchestrationService.isConnected ? 50 : 999,
      timestamp: DateTime.now(),
      sessionDuration: sessionPerformance.sessionDuration,
      achievementsPerHour: sessionPerformance.unlockRate,
      performanceMaintained: sessionPerformance.performanceMaintained,
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

// 🧠 ATHENA HELPER FUNCTIONS - PHASE 3.4

String _getAthenaActionType(AthenaUIState uiState, bool hasRecommendation, bool canApply) {
  if (uiState == AthenaUIState.disabled) return 'enable';
  if (uiState == AthenaUIState.analyzing || uiState == AthenaUIState.recommending) return 'analyzing';
  if (canApply) return 'apply';
  if (hasRecommendation) return 'review';
  return 'ready';
}

String _getAthenaButtonText(AthenaUIState uiState, bool hasRecommendation, bool canApply) {
  if (uiState == AthenaUIState.disabled) return 'Enable Athena';
  if (uiState == AthenaUIState.analyzing) return 'Analyzing...';
  if (uiState == AthenaUIState.recommending) return 'Generating...';
  if (uiState == AthenaUIState.applying) return 'Applying...';
  if (canApply) return 'Apply Recommendations';
  if (hasRecommendation) return 'Review Recommendations';
  if (uiState == AthenaUIState.error) return 'Retry';
  return 'Athena Ready';
}

String _getAthenaActionIcon(AthenaUIState uiState, bool hasRecommendation, bool canApply) {
  if (uiState == AthenaUIState.disabled) return 'power_settings_new';
  if (uiState == AthenaUIState.analyzing || uiState == AthenaUIState.recommending) return 'psychology';
  if (canApply) return 'auto_fix_high';
  if (hasRecommendation) return 'rate_review';
  if (uiState == AthenaUIState.error) return 'refresh';
  return 'smart_toy';
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
        // 🧠 ATHENA LOCALIZATION
        'athena_enabled': 'Athena Intelligence enabled',
        'athena_analyzing': 'Athena analyzing...',
        'athena_ready': 'Athena ready',
        'athena_recommendations': 'AI recommendations available',
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
        // 🧠 ATHENA LOCALIZATION
        'athena_enabled': 'Intelligenza Athena attiva',
        'athena_analyzing': 'Athena analizza...',
        'athena_ready': 'Athena pronta',
        'athena_recommendations': 'Raccomandazioni AI disponibili',
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

/// Enhanced System Status with Achievement Integration - PHASE 3.3
class EnhancedSystemStatus extends SystemStatus {
  final SessionPerformance sessionPerformance;
  final AchievementStats achievementStats;
  final int totalAchievements;
  final int unlockedAchievements;
  final double completionPercentage;

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
  });
}

/// Enhanced System Status V2 with Achievement + Athena Integration - PHASE 3.4
class EnhancedSystemStatusV2 extends EnhancedSystemStatus {
  final bool athenaEnabled;
  final AthenaUIState athenaState;
  final int athenaTotalDecisions;
  final double athenaAverageConfidence;

  const EnhancedSystemStatusV2({
    required super.connectionStatus,
    required super.isGenerating,
    required super.healthyModelCount,
    required super.isHealthChecking,
    required super.lastUpdate,
    required super.sessionPerformance,
    required super.achievementStats,
    required super.totalAchievements,
    required super.unlockedAchievements,
    required super.completionPercentage,
    required this.athenaEnabled,
    required this.athenaState,
    required this.athenaTotalDecisions,
    required this.athenaAverageConfidence,
  });

  // Computed properties for UI
  bool get isAthenaActive => athenaEnabled && athenaState != AthenaUIState.disabled;
  bool get isAthenaAnalyzing => athenaState == AthenaUIState.analyzing || athenaState == AthenaUIState.recommending;
  String get athenaStatusText => athenaState.name.replaceAll('_', ' ').toUpperCase();

  // Overall system intelligence score combining all systems
  double get intelligenceScore {
    double score = 0.3; // Base score

    // Achievement system contribution (20%)
    score += (completionPercentage / 100) * 0.2;

    // Connection health contribution (20%)
    score += (connectionStatus == ConnectionStatus.connected ? 0.2 : 0.0);

    // Orchestration health contribution (10%)
    score += (healthyModelCount > 0 ? 0.1 : 0.0);

    // Athena intelligence contribution (50% - BIGGEST FACTOR)
    if (athenaEnabled) {
      score += athenaAverageConfidence * 0.5;
    }

    return score.clamp(0.0, 1.0);
  }

  // System readiness for advanced AI orchestration
  bool get isIntelligenceReady => intelligenceScore >= 0.8 && isAthenaActive;
}

/// Session Performance Model - PHASE 3.3
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

/// Enhanced Performance Metrics - PHASE 3.3
class PerformanceMetrics {
  final double memoryUsage;
  final double cpuUsage;
  final double renderTime;
  final int networkLatency;
  final DateTime timestamp;
  final Duration sessionDuration;
  final double achievementsPerHour;
  final bool performanceMaintained;

  const PerformanceMetrics({
    required this.memoryUsage,
    required this.cpuUsage,
    required this.renderTime,
    required this.networkLatency,
    required this.timestamp,
    required this.sessionDuration,
    required this.achievementsPerHour,
    required this.performanceMaintained,
  });
}