// 🎯 NEURONVAULT - CENTRAL PROVIDERS HUB - IMPORT CONFLICTS FIXED
// Enterprise-grade provider management and dependency injection
// Part of PHASE 2.5 - QUANTUM STATE MANAGEMENT + ACHIEVEMENT SYSTEM

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
import '../services/achievement_service.dart'; // 🏆 ACHIEVEMENT SERVICE
import '../theme/neural_theme_system.dart';

// 🧠 CONTROLLER PROVIDERS - IMPORT CONTROLLERS
export '../controllers/strategy_controller.dart';
export '../controllers/models_controller.dart';
export '../controllers/chat_controller.dart';
export '../controllers/connection_controller.dart';

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

// 🏆 ACHIEVEMENT SERVICE PROVIDER
final achievementServiceProvider = ChangeNotifierProvider<AchievementService>((ref) {
  final logger = ref.watch(loggerProvider);
  final sharedPreferences = ref.watch(sharedPreferencesProvider);

  logger.i('🏆 Initializing Achievement Service...');

  final service = AchievementService(
    prefs: sharedPreferences,
    logger: logger,
  );

  logger.i('✅ Achievement Service initialized successfully');
  return service;
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

// 🏆 ACHIEVEMENT SYSTEM PROVIDERS
final achievementStateProvider = Provider<AchievementState>((ref) {
  final service = ref.watch(achievementServiceProvider);
  return service.state;
});

final unlockedAchievementsProvider = Provider<List<Achievement>>((ref) {
  final state = ref.watch(achievementStateProvider);
  return state.unlockedAchievements;
});

final achievementStatsProvider = Provider<AchievementStats>((ref) {
  final state = ref.watch(achievementStateProvider);
  return state.stats;
});

final pendingNotificationsProvider = Provider<List<AchievementNotification>>((ref) {
  final state = ref.watch(achievementStateProvider);
  return state.pendingNotifications;
});

final achievementProgressProvider = Provider.family<AchievementProgress?, String>((ref, achievementId) {
  final state = ref.watch(achievementStateProvider);
  return state.progress[achievementId];
});

final achievementByIdProvider = Provider.family<Achievement?, String>((ref, achievementId) {
  final state = ref.watch(achievementStateProvider);
  return state.achievements[achievementId];
});

final achievementsByCategoryProvider = Provider.family<List<Achievement>, AchievementCategory>((ref, category) {
  final state = ref.watch(achievementStateProvider);
  return state.visibleAchievements.where((a) => a.category == category).toList()
    ..sort((a, b) => a.rarity.index.compareTo(b.rarity.index));
});

final categoryStatsProvider = Provider.family<Map<AchievementRarity, int>, AchievementCategory>((ref, category) {
  final achievements = ref.watch(achievementsByCategoryProvider(category));
  final unlocked = achievements.where((a) => a.isUnlocked).toList();

  return {
    AchievementRarity.common: unlocked.where((a) => a.rarity == AchievementRarity.common).length,
    AchievementRarity.rare: unlocked.where((a) => a.rarity == AchievementRarity.rare).length,
    AchievementRarity.epic: unlocked.where((a) => a.rarity == AchievementRarity.epic).length,
    AchievementRarity.legendary: unlocked.where((a) => a.rarity == AchievementRarity.legendary).length,
  };
});

final achievementNotificationStreamProvider = StreamProvider<AchievementNotification>((ref) {
  final service = ref.watch(achievementServiceProvider);
  return service.notificationStream;
});

final overallCompletionProvider = Provider<double>((ref) {
  final state = ref.watch(achievementStateProvider);
  return state.stats.completionPercentage;
});

final totalPointsProvider = Provider<int>((ref) {
  final state = ref.watch(achievementStateProvider);
  return state.totalPoints;
});

final recentAchievementsProvider = Provider<List<Achievement>>((ref) {
  final state = ref.watch(achievementStateProvider);
  return state.recentlyUnlocked.take(5).toList();
});

final achievementTrackerProvider = Provider<AchievementService>((ref) {
  return ref.watch(achievementServiceProvider);
});

// 📊 COMPUTED STATE PROVIDERS
final appReadyProvider = Provider<bool>((ref) {
  try {
    final configService = ref.watch(configServiceProvider);
    final storageService = ref.watch(storageServiceProvider);
    final aiService = ref.watch(aiServiceProvider);
    return true;
  } catch (e) {
    return false;
  }
});

final overallHealthProvider = Provider<AppHealth>((ref) {
  final orchestrationService = ref.watch(webSocketOrchestrationServiceProvider);
  if (orchestrationService.isConnected) {
    return AppHealth.healthy;
  } else {
    return AppHealth.degraded;
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

// 🔄 ASYNC DATA PROVIDERS
final initializationProvider = FutureProvider<bool>((ref) async {
  final logger = ref.watch(loggerProvider);

  try {
    logger.i('🚀 Starting application initialization...');
    await Future.delayed(const Duration(milliseconds: 100));

    final configService = ref.read(configServiceProvider);
    final storageService = ref.read(storageServiceProvider);
    final aiService = ref.read(aiServiceProvider);

    logger.i('✅ Core services initialized successfully');

    final orchestrationService = ref.read(webSocketOrchestrationServiceProvider);
    await Future.delayed(const Duration(milliseconds: 500));

    if (orchestrationService.isConnected) {
      logger.i('🧬 Orchestration service connected and ready');
    } else {
      logger.i('🧬 Orchestration service will connect in background');
    }

    logger.i('✅ Application initialization completed');
    return true;

  } catch (e, stackTrace) {
    logger.e('❌ Application initialization failed', error: e, stackTrace: stackTrace);
    return true;
  }
});

final performanceMetricsProvider = StreamProvider<PerformanceMetrics>((ref) {
  return Stream.periodic(const Duration(seconds: 5), (count) {
    final orchestrationService = ref.read(webSocketOrchestrationServiceProvider);

    return PerformanceMetrics(
      memoryUsage: _getCurrentMemoryUsage(),
      cpuUsage: _getCurrentCpuUsage(),
      renderTime: _getAverageRenderTime(),
      networkLatency: orchestrationService.isConnected ? 50 : 999,
      timestamp: DateTime.now(),
    );
  });
});

// 🔧 UTILITY FUNCTIONS
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

class PerformanceMetrics {
  final double memoryUsage;
  final double cpuUsage;
  final double renderTime;
  final int networkLatency;
  final DateTime timestamp;

  const PerformanceMetrics({
    required this.memoryUsage,
    required this.cpuUsage,
    required this.renderTime,
    required this.networkLatency,
    required this.timestamp,
  });
}