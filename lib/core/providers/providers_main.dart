// 🎯 NEURONVAULT - CENTRAL PROVIDERS HUB
// Enterprise-grade provider management and dependency injection
// Part of PHASE 2.5 - QUANTUM STATE MANAGEMENT

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../state/models.dart';
import '../services/config_service.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart';
import '../services/theme_service.dart';
import '../controllers/strategy_controller.dart';
import '../controllers/models_controller.dart';
import '../controllers/chat_controller.dart';
import '../controllers/connection_controller.dart';

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
    lOptions: LinuxOptions(
      encryptKey: true,
    ),
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

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService(
    configService: ref.watch(configServiceProvider),
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

// 🧠 APPLICATION STATE PROVIDERS
// (Already defined in individual controller files, re-exported here for convenience)

// Strategy Controller
export '../controllers/strategy_controller.dart' show 
    strategyControllerProvider,
    activeStrategyProvider,
    modelWeightsProvider,
    isStrategyProcessingProvider,
    strategyConfigurationProvider,
    activeModelCountProvider;

// Models Controller  
export '../controllers/models_controller.dart' show
    modelsControllerProvider,
    availableModelsProvider,
    activeModelsProvider,
    modelHealthProvider,
    budgetUsageProvider,
    isOverBudgetProvider,
    healthyModelsCountProvider,
    isHealthCheckingProvider;

// Chat Controller
export '../controllers/chat_controller.dart' show
    chatControllerProvider,
    chatMessagesProvider,
    currentInputProvider,
    isGeneratingProvider,
    isTypingProvider,
    canSendMessageProvider,
    messageCountProvider,
    lastMessageTimeProvider,
    userMessageCountProvider,
    assistantMessageCountProvider;

// Connection Controller
export '../controllers/connection_controller.dart' show
    connectionControllerProvider,
    connectionStatusProvider,
    isConnectedProvider,
    connectionLatencyProvider,
    connectionErrorProvider,
    canReconnectProvider,
    reconnectAttemptsProvider,
    connectionMessageStreamProvider;

// 📊 COMPUTED STATE PROVIDERS
final appReadyProvider = Provider<bool>((ref) {
  final isConnected = ref.watch(isConnectedProvider);
  final hasActiveModels = ref.watch(activeModelCountProvider) > 0;
  final isConfigured = ref.watch(strategyConfigurationProvider);
  
  return isConnected && hasActiveModels && isConfigured;
});

final overallHealthProvider = Provider<AppHealth>((ref) {
  final isConnected = ref.watch(isConnectedProvider);
  final healthyModels = ref.watch(healthyModelsCountProvider);
  final totalModels = ref.watch(availableModelsProvider).length;
  final latency = ref.watch(connectionLatencyProvider);
  final isOverBudget = ref.watch(isOverBudgetProvider);
  
  if (!isConnected) {
    return AppHealth.critical;
  }
  
  if (isOverBudget || healthyModels == 0) {
    return AppHealth.unhealthy;
  }
  
  if (healthyModels < totalModels / 2 || latency > 2000) {
    return AppHealth.degraded;
  }
  
  return AppHealth.healthy;
});

final systemStatusProvider = Provider<SystemStatus>((ref) {
  final connectionStatus = ref.watch(connectionStatusProvider);
  final isGenerating = ref.watch(isGeneratingProvider);
  final healthyModels = ref.watch(healthyModelsCountProvider);
  final isHealthChecking = ref.watch(isHealthCheckingProvider);
  
  return SystemStatus(
    connectionStatus: connectionStatus,
    isGenerating: isGenerating,
    healthyModelCount: healthyModels,
    isHealthChecking: isHealthChecking,
    lastUpdate: DateTime.now(),
  );
});

// 🎨 THEME & UI PROVIDERS
final currentThemeProvider = StateProvider<AppTheme>((ref) {
  return AppTheme.neural;
});

final isDarkModeProvider = StateProvider<bool>((ref) {
  return true; // Default to dark mode
});

final adaptiveLayoutProvider = Provider<LayoutBreakpoint>((ref) {
  // This would be connected to MediaQuery in actual implementation
  return LayoutBreakpoint.desktop;
});

// 🌍 LOCALIZATION PROVIDERS
final currentLocaleProvider = StateProvider<String>((ref) {
  return 'en_US';
});

final localizationProvider = Provider<Map<String, String>>((ref) {
  final locale = ref.watch(currentLocaleProvider);
  // In real implementation, this would load localization files
  return _getLocalizationForLocale(locale);
});

// 🔄 ASYNC DATA PROVIDERS
final initializationProvider = FutureProvider<bool>((ref) async {
  final logger = ref.watch(loggerProvider);
  
  try {
    logger.i('🚀 Starting application initialization...');
    
    // Initialize all controllers in sequence
    final strategyController = ref.read(strategyControllerProvider.notifier);
    final modelsController = ref.read(modelsControllerProvider.notifier);
    final connectionController = ref.read(connectionControllerProvider.notifier);
    
    // Wait for core initialization
    await Future.wait([
      // Strategy and models are initialized in their constructors
      Future.value(),
    ]);
    
    logger.i('✅ Application initialization completed');
    return true;
    
  } catch (e, stackTrace) {
    logger.e('❌ Application initialization failed', error: e, stackTrace: stackTrace);
    return false;
  }
});

// 📈 PERFORMANCE MONITORING PROVIDERS
final performanceMetricsProvider = StreamProvider<PerformanceMetrics>((ref) {
  return Stream.periodic(const Duration(seconds: 5), (count) {
    return PerformanceMetrics(
      memoryUsage: _getCurrentMemoryUsage(),
      cpuUsage: _getCurrentCpuUsage(),
      renderTime: _getAverageRenderTime(),
      networkLatency: ref.read(connectionLatencyProvider),
      timestamp: DateTime.now(),
    );
  });
});

// 🔧 UTILITY FUNCTIONS
Map<String, String> _getLocalizationForLocale(String locale) {
  // Simplified localization - in real app this would load from files
  switch (locale) {
    case 'en_US':
      return {
        'app_title': 'NeuronVault',
        'connecting': 'Connecting...',
        'connected': 'Connected',
        'disconnected': 'Disconnected',
        'error': 'Error',
        // Add more translations...
      };
    case 'it_IT':
      return {
        'app_title': 'NeuronVault',
        'connecting': 'Connettendo...',
        'connected': 'Connesso',
        'disconnected': 'Disconnesso',
        'error': 'Errore',
        // Add more translations...
      };
    default:
      return _getLocalizationForLocale('en_US');
  }
}

double _getCurrentMemoryUsage() {
  // In real implementation, this would get actual memory usage
  return 0.0;
}

double _getCurrentCpuUsage() {
  // In real implementation, this would get actual CPU usage
  return 0.0;
}

double _getAverageRenderTime() {
  // In real implementation, this would track frame render times
  return 16.67; // 60 FPS
}

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
  final DateTime lastUpdate;

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