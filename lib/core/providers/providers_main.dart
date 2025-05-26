// 🎯 NEURONVAULT - CENTRAL PROVIDERS HUB - CORRECTED FULL VERSION
// Enterprise-grade provider management and dependency injection
// Part of PHASE 2.5 - QUANTUM STATE MANAGEMENT - FIXED VERSION

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../state/state_models.dart'; // Contains OrchestrationStrategy enum
import '../services/config_service.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart';
import '../services/theme_service.dart';
import '../services/websocket_orchestration_service.dart'; // CORRECTED PATH
import '../services/spatial_audio_service.dart'; // NEW IMPORT
import '../theme/neural_theme_system.dart'; // NEW IMPORT

// 🧠 CONTROLLER PROVIDERS - IMPORT CONTROLLERS
// These import the actual controller providers from their files
export '../controllers/strategy_controller.dart';
export '../controllers/models_controller.dart';
export '../controllers/chat_controller.dart';
export '../controllers/connection_controller.dart';
import '../services/spatial_audio_service.dart';

final spatialAudioServiceProvider = Provider<SpatialAudioService>((ref) {
  // Initialize your spatial audio service.
  return SpatialAudioService();
});



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

// 🧬 WEBSOCKET ORCHESTRATION SERVICE PROVIDER - NEW & CORRECTED!
final webSocketOrchestrationServiceProvider = ChangeNotifierProvider<WebSocketOrchestrationService>((ref) {
  final logger = ref.watch(loggerProvider);

  logger.i('🧬 Initializing WebSocket Orchestration Service...');

  final service = WebSocketOrchestrationService();

  // Auto-connect when service is created (non-blocking)
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

// 📊 ORCHESTRATION STATE PROVIDERS - NEW!
final currentOrchestrationProvider = StateProvider<String?>((ref) => null);

final isOrchestrationActiveProvider = StateProvider<bool>((ref) => false);

final individualResponsesProvider = StreamProvider<List<AIResponse>>((ref) {
  final orchestrationService = ref.watch(webSocketOrchestrationServiceProvider);
  return orchestrationService.individualResponsesStream;
});

final synthesizedResponseProvider = StreamProvider<String>((ref) {
  final orchestrationService = ref.watch(webSocketOrchestrationServiceProvider);
  return orchestrationService.synthesizedResponseStream;
});

final orchestrationProgressProvider = StreamProvider<OrchestrationProgress>((ref) {
  final orchestrationService = ref.watch(webSocketOrchestrationServiceProvider);
  return orchestrationService.orchestrationProgressStream;
});

// 🧬 ORCHESTRATION CONFIGURATION PROVIDERS
final activeModelsProvider = StateProvider<List<String>>((ref) {
  return ['claude', 'gpt', 'deepseek', 'gemini']; // Default active models
});

// MODIFIED: currentStrategyProvider now stores a String
final currentStrategyProvider = StateProvider<String>((ref) {
  // Assumes OrchestrationStrategy enum has a .name property (standard in Dart 2.17+)
  // And OrchestrationStrategy.parallel is a valid enum member.
  // Ensure OrchestrationStrategy is imported (likely from state_models.dart)
  return OrchestrationStrategy.parallel.name; // Default strategy as a string
});

// NEW: availableStrategiesProvider provides a list of strategy names as Strings
final availableStrategiesProvider = Provider<List<String>>((ref) {
  // Assumes OrchestrationStrategy enum has .values and .name properties
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

// 📊 COMPUTED STATE PROVIDERS - ENHANCED WITH ORCHESTRATION
final appReadyProvider = Provider<bool>((ref) {
  // App is ready when core services are initialized
  // Orchestration connection is optional for app readiness
  try {
    final configService = ref.watch(configServiceProvider);
    final storageService = ref.watch(storageServiceProvider);
    final aiService = ref.watch(aiServiceProvider);

    // If we can access these services without error, app is ready
    return true;
  } catch (e) {
    return false;
  }
});

final overallHealthProvider = Provider<AppHealth>((ref) {
  final orchestrationService = ref.watch(webSocketOrchestrationServiceProvider);

  // Determine health based on orchestration connection
  if (orchestrationService.isConnected) {
    return AppHealth.healthy;
  } else {
    // App can still function without orchestration, so degraded not critical
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

// 🎨 THEME & UI PROVIDERS - MAINTAINED
final currentThemeProvider = StateProvider<AppTheme>((ref) {
  return AppTheme.neural;
});

// AppTheme enum for controller compatibility
enum AppTheme {
  neural,
  cyber,
  matrix,
  quantum,
}

final isDarkModeProvider = StateProvider<bool>((ref) {
  return true; // Default to dark mode
});

final adaptiveLayoutProvider = Provider<LayoutBreakpoint>((ref) {
  // This would be connected to MediaQuery in actual implementation
  return LayoutBreakpoint.desktop;
});

// 🌍 LOCALIZATION PROVIDERS - MAINTAINED
final currentLocaleProvider = StateProvider<String>((ref) {
  return 'en_US';
});

final localizationProvider = Provider<Map<String, String>>((ref) {
  final locale = ref.watch(currentLocaleProvider);
  return _getLocalizationForLocale(locale);
});

// 🔄 ASYNC DATA PROVIDERS - ENHANCED WITH ORCHESTRATION
final initializationProvider = FutureProvider<bool>((ref) async {
  final logger = ref.watch(loggerProvider);

  try {
    logger.i('🚀 Starting application initialization...');

    // Initialize services one by one to avoid circular dependencies
    await Future.delayed(const Duration(milliseconds: 100));

    // Initialize core services first
    final configService = ref.read(configServiceProvider);
    final storageService = ref.read(storageServiceProvider);
    final aiService = ref.read(aiServiceProvider);

    logger.i('✅ Core services initialized successfully');

    // Orchestration service initialization is handled separately and non-blocking
    final orchestrationService = ref.read(webSocketOrchestrationServiceProvider);

    // Give some time for orchestration service to attempt connection
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
    // Don't fail app initialization just because of orchestration issues
    return true; // App can still function
  }
});

// 📈 PERFORMANCE MONITORING PROVIDERS - ENHANCED
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

// 🔧 UTILITY FUNCTIONS - MAINTAINED
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
double _getAverageRenderTime() => 16.67; // 60 FPS

// 📊 SUPPORTING MODELS - MAINTAINED FOR CONTROLLER COMPATIBILITY
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

enum ConnectionStatus {
  connected,
  disconnected,
  connecting,
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