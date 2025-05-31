// test/unit/integration/providers_integration_test.dart
// 🎯 NEURONVAULT - PROVIDERS INTEGRATION TESTS
// Enterprise-grade Riverpod provider testing with complete ecosystem validation
// Supports PHASE 3.4 - Athena AI Integration + Achievement System + WebSocket Orchestration

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'dart:async';

import '../../../lib/core/providers/providers_main.dart';
import '../../../lib/core/state/state_models.dart';
import '../../../lib/core/services/config_service.dart';
import '../../../lib/core/services/storage_service.dart';
import '../../../lib/core/services/achievement_service.dart';
import '../../../lib/core/controllers/chat_controller.dart';
import '../helpers/service_test_base.dart';
import '../mocks/test_data.dart';
import '../mocks/mock_services.dart';
import '../helpers/test_helpers.dart';

/// 🎯 Providers Integration Test Suite
/// Tests the complete Riverpod provider ecosystem including:
/// - Core infrastructure providers
/// - Service providers
/// - Controller providers
/// - Computed providers
/// - Stream providers
/// - Athena AI providers (PHASE 3.4)
/// - Achievement system providers (PHASE 3.3)
class ProvidersIntegrationTest extends ServiceTestBase {
  // 🏗️ Test container
  late ProviderContainer container;

  // 📊 Test subscriptions for cleanup
  final List<ProviderSubscription> _providerSubscriptions = [];
  final List<ProviderListenable> _providersToTest = [];

  @override
  bool get enablePerformanceTests => true;
  @override
  bool get enableIntegrationTests => true;

  @override
  Future<void> setUpServiceSpecific() async {
    mockLogger.i('🎯 Setting up providers integration testing environment...');

    // Create test provider container with overrides
    container = ProviderContainer(
      overrides: [
        // Override core infrastructure
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        secureStorageProvider.overrideWithValue(mockSecureStorage),
        loggerProvider.overrideWithValue(mockLogger),
      ],
    );

    // Initialize core providers list for testing
    _providersToTest.addAll([
      // Core infrastructure
      loggerProvider,
      configServiceProvider,
      storageServiceProvider,

      // AI services
      aiServiceProvider,
      analyticsServiceProvider,

      // Theme and UI
      themeServiceProvider,
      currentThemeProvider,
      isDarkModeProvider,

      // WebSocket orchestration
      webSocketOrchestrationServiceProvider,
      activeModelsProvider,
      currentStrategyProvider,

      // Achievement system
      enhancedAchievementServiceProvider,
      achievementStateProvider,
      achievementStatsProvider,

      // Athena AI system (PHASE 3.4)
      miniLLMAnalyzerServiceProvider,
      athenaIntelligenceServiceProvider,
      athenaControllerProvider,
      athenaEnabledProvider,
    ]);

    mockLogger.i('✅ Providers integration setup completed');
  }

  @override
  Future<void> tearDownServiceSpecific() async {
    mockLogger.i('🧹 Tearing down providers integration...');

    // Cancel all provider subscriptions
    for (final subscription in _providerSubscriptions) {
      subscription.close();
    }
    _providerSubscriptions.clear();

    // Dispose container
    container.dispose();

    mockLogger.i('✅ Providers integration teardown completed');
  }

  /// 🔍 Helper method to read provider safely
  T readProvider<T>(ProviderListenable<T> provider) {
    return container.read(provider);
  }

  /// 📡 Helper method to listen to provider changes
  void listenToProvider<T>(
      ProviderListenable<T> provider,
      void Function(T? previous, T next) listener,
      ) {
    final providerSubscription = container.listen<T>(
      provider,
      listener,
      fireImmediately: false,
    );

    _providerSubscriptions.add(providerSubscription);
  }
}

void main() {
  group('🎯 Providers Integration Tests', () {
    final integrationTest = ProvidersIntegrationTest();

    setUp(() async {
      await integrationTest.setUpServiceTest();
    });

    tearDown(() async {
      await integrationTest.tearDownServiceTest();
    });

    group('🏗️ Core Infrastructure Providers', () {
      test('should initialize core infrastructure providers correctly', () async {
        await integrationTest.executeWithPerformanceMonitoring(
          'core_infrastructure_initialization',
              () async {
            // Test logger provider
            final logger = integrationTest.readProvider(loggerProvider);
            expect(logger, isA<Logger>());

            // Test shared preferences provider
            final prefs = integrationTest.readProvider(sharedPreferencesProvider);
            expect(prefs, isA<SharedPreferences>());

            // Test secure storage provider
            final secureStorage = integrationTest.readProvider(secureStorageProvider);
            expect(secureStorage, isA<FlutterSecureStorage>());

            integrationTest.mockLogger.i('✅ Core infrastructure providers initialized');
          },
          expectedMaxDuration: const Duration(seconds: 1),
        );
      });

      test('should handle provider dependencies correctly', () async {
        await integrationTest.testServiceIntegration(
          'provider_dependencies',
          [
            // ConfigService depends on SharedPreferences and SecureStorage
                () async {
              final configService = integrationTest.readProvider(configServiceProvider);
              expect(configService, isA<ConfigService>());
            },

            // StorageService depends on SharedPreferences and SecureStorage
                () async {
              final storageService = integrationTest.readProvider(storageServiceProvider);
              expect(storageService, isA<StorageService>());
            },

            // AIService depends on ConfigService and StorageService
                () async {
              final aiService = integrationTest.readProvider(aiServiceProvider);
              expect(aiService, isNotNull);
            },
          ],
        );
      });
    });

    group('🤖 AI & Orchestration Providers', () {
      test('should manage orchestration state correctly', () async {
        await integrationTest.executeWithPerformanceMonitoring(
          'orchestration_state_management',
              () async {
            // Test active models provider
            final activeModels = integrationTest.readProvider(activeModelsProvider);
            expect(activeModels, isA<List<String>>());
            expect(activeModels, isNotEmpty);

            // Test current strategy provider
            final strategy = integrationTest.readProvider(currentStrategyProvider);
            expect(strategy, isA<String>());
            expect(OrchestrationStrategy.values.map((e) => e.name), contains(strategy));

            // Test model weights provider
            final weights = integrationTest.readProvider(modelWeightsProvider);
            expect(weights, isA<Map<String, double>>());
            expect(weights, isNotEmpty);

            integrationTest.mockLogger.i('✅ Orchestration providers working correctly');
          },
          expectedMaxDuration: const Duration(seconds: 2),
        );
      });

      test('should handle orchestration state changes', () async {
        await integrationTest.executeWithRetry(
          'orchestration_state_changes',
              () async {
            // Change active models
            final modelsNotifier = integrationTest.container.read(activeModelsProvider.notifier);
            modelsNotifier.state = ['claude', 'gpt'];

            // Verify change
            final updatedModels = integrationTest.readProvider(activeModelsProvider);
            expect(updatedModels, equals(['claude', 'gpt']));

            // Change strategy
            final strategyNotifier = integrationTest.container.read(currentStrategyProvider.notifier);
            strategyNotifier.state = OrchestrationStrategy.consensus.name;

            // Verify change
            final updatedStrategy = integrationTest.readProvider(currentStrategyProvider);
            expect(updatedStrategy, equals(OrchestrationStrategy.consensus.name));
          },
        );
      });

      test('should handle WebSocket orchestration service', () async {
        await integrationTest.executeWithPerformanceMonitoring(
          'websocket_orchestration_service',
              () async {
            final orchestrationService = integrationTest.readProvider(
                webSocketOrchestrationServiceProvider);
            expect(orchestrationService, isNotNull);

            // Test orchestration status providers
            final isActive = integrationTest.readProvider(isOrchestrationActiveProvider);
            expect(isActive, isA<bool>());

            integrationTest.mockLogger.i('✅ WebSocket orchestration service provider working');
          },
          expectedMaxDuration: const Duration(seconds: 3),
        );
      });
    });

    group('🏆 Achievement System Providers (PHASE 3.3)', () {
      test('should initialize achievement system providers', () async {
        await integrationTest.executeWithPerformanceMonitoring(
          'achievement_system_initialization',
              () async {
            // Test enhanced achievement service
            final achievementService = integrationTest.readProvider(
                enhancedAchievementServiceProvider);
            expect(achievementService, isA<EnhancedAchievementService>());

            // Test achievement state provider
            final achievementState = integrationTest.readProvider(achievementStateProvider);
            expect(achievementState, isA<AchievementState>());

            // Test achievement stats provider
            final stats = integrationTest.readProvider(achievementStatsProvider);
            expect(stats, isA<AchievementStats>());

            integrationTest.mockLogger.i('✅ Achievement system providers initialized');
          },
          expectedMaxDuration: const Duration(seconds: 2),
        );
      });

      test('should handle achievement operations through providers', () async {
        await integrationTest.testServiceIntegration(
          'achievement_operations',
          [
            // Test achievement retrieval by category
                () async {
              final explorationAchievements = integrationTest.readProvider(
                  achievementsByCategoryProvider(AchievementCategory.exploration));
              expect(explorationAchievements, isA<List<Achievement>>());
            },

            // Test achievement progress tracking
                () async {
              final unlockedAchievements = integrationTest.readProvider(
                  unlockedAchievementsProvider);
              expect(unlockedAchievements, isA<List<Achievement>>());
            },

            // Test session performance
                () async {
              final sessionPerformance = integrationTest.readProvider(
                  sessionPerformanceProvider);
              expect(sessionPerformance, isA<SessionPerformance>());
            },
          ],
        );
      });

      test('should track achievement notifications correctly', () async {
        await integrationTest.executeWithRetry(
          'achievement_notifications',
              () async {
            // Test pending notifications provider
            final pendingNotifications = integrationTest.readProvider(
                pendingNotificationsProvider);
            expect(pendingNotifications, isA<List<AchievementNotification>>());

            // Test overall completion provider
            final completion = integrationTest.readProvider(overallCompletionProvider);
            expect(completion, isA<double>());
            expect(completion, greaterThanOrEqualTo(0.0));
            expect(completion, lessThanOrEqualTo(100.0));
          },
        );
      });
    });

    group('🧠 Athena AI Providers (PHASE 3.4)', () {
      test('should initialize Athena AI providers', () async {
        await integrationTest.executeWithPerformanceMonitoring(
          'athena_ai_initialization',
              () async {
            // Test Mini-LLM Analyzer Service
            final miniLLMService = integrationTest.readProvider(
                miniLLMAnalyzerServiceProvider);
            expect(miniLLMService, isNotNull);

            // Test Athena Intelligence Service
            final athenaService = integrationTest.readProvider(
                athenaIntelligenceServiceProvider);
            expect(athenaService, isNotNull);

            // Test Athena Controller
            final athenaController = integrationTest.readProvider(
                athenaControllerProvider);
            expect(athenaController, isNotNull);

            integrationTest.mockLogger.i('✅ Athena AI providers initialized');
          },
          expectedMaxDuration: const Duration(seconds: 3),
        );
      });

      test('should manage Athena state correctly', () async {
        await integrationTest.testServiceIntegration(
          'athena_state_management',
          [
            // Test Athena enabled state
                () async {
              final athenaEnabled = integrationTest.readProvider(athenaEnabledProvider);
              expect(athenaEnabled, isA<bool>());
            },

            // Test Athena UI state
                () async {
              final athenaUIState = integrationTest.readProvider(athenaUIStateProvider);
              expect(athenaUIState, isA<AthenaUIState>());
            },

            // Test Athena analytics
                () async {
              final athenaStats = integrationTest.readProvider(athenaStatisticsProvider);
              expect(athenaStats, isA<Map<String, dynamic>>());
            },
          ],
        );
      });

      test('should handle Athena decision tracking', () async {
        await integrationTest.executeWithRetry(
          'athena_decision_tracking',
              () async {
            // Test decision count provider
            final decisionCount = integrationTest.readProvider(athenaDecisionCountProvider);
            expect(decisionCount, isA<int>());
            expect(decisionCount, greaterThanOrEqualTo(0));

            // Test average confidence provider
            final avgConfidence = integrationTest.readProvider(athenaAverageConfidenceProvider);
            expect(avgConfidence, isA<double>());
            expect(avgConfidence, greaterThanOrEqualTo(0.0));
            expect(avgConfidence, lessThanOrEqualTo(1.0));

            // Test confidence distribution
            final distribution = integrationTest.readProvider(
                athenaConfidenceDistributionProvider);
            expect(distribution, isA<Map<String, int>>());
          },
        );
      });
    });

    group('🎨 Theme & UI Providers', () {
      test('should manage theme state correctly', () async {
        await integrationTest.executeWithPerformanceMonitoring(
          'theme_state_management',
              () async {
            // Test current theme provider
            final currentTheme = integrationTest.readProvider(currentThemeProvider);
            expect(currentTheme, isA<AppTheme>());

            // Test dark mode provider
            final isDarkMode = integrationTest.readProvider(isDarkModeProvider);
            expect(isDarkMode, isA<bool>());

            // Test adaptive layout provider
            final layout = integrationTest.readProvider(adaptiveLayoutProvider);
            expect(layout, isA<LayoutBreakpoint>());

            integrationTest.mockLogger.i('✅ Theme providers working correctly');
          },
          expectedMaxDuration: const Duration(seconds: 1),
        );
      });

      test('should handle theme changes', () async {
        await integrationTest.executeWithRetry(
          'theme_changes',
              () async {
            // Change theme
            final themeNotifier = integrationTest.container.read(currentThemeProvider.notifier);
            themeNotifier.state = AppTheme.cyber;

            // Verify change
            final updatedTheme = integrationTest.readProvider(currentThemeProvider);
            expect(updatedTheme, equals(AppTheme.cyber));

            // Change dark mode
            final darkModeNotifier = integrationTest.container.read(isDarkModeProvider.notifier);
            darkModeNotifier.state = false;

            // Verify change
            final updatedDarkMode = integrationTest.readProvider(isDarkModeProvider);
            expect(updatedDarkMode, isFalse);
          },
        );
      });
    });

    group('💬 Chat & Communication Providers', () {
      test('should handle chat controller provider', () async {
        await integrationTest.executeWithPerformanceMonitoring(
          'chat_controller_provider',
              () async {
            // Test chat controller provider
            final chatController = integrationTest.readProvider(chatControllerProvider);
            expect(chatController, isA<ChatState>());

            // Test computed chat providers
            final messages = integrationTest.readProvider(chatMessagesProvider);
            expect(messages, isA<List<ChatMessage>>());

            final isGenerating = integrationTest.readProvider(isGeneratingProvider);
            expect(isGenerating, isA<bool>());

            final canSendMessage = integrationTest.readProvider(canSendMessageProvider);
            expect(canSendMessage, isA<bool>());

            integrationTest.mockLogger.i('✅ Chat providers working correctly');
          },
          expectedMaxDuration: const Duration(seconds: 2),
        );
      });
    });

    group('📊 System Status & Analytics Providers', () {
      test('should provide comprehensive system status', () async {
        await integrationTest.executeWithPerformanceMonitoring(
          'system_status_providers',
              () async {
            // Test enhanced system status (with achievements + Athena)
            final enhancedStatus = integrationTest.readProvider(
                enhancedSystemStatusProvider);
            expect(enhancedStatus, isA<EnhancedSystemStatusV2>());

            // Verify intelligence score calculation
            expect(enhancedStatus.intelligenceScore, greaterThanOrEqualTo(0.0));
            expect(enhancedStatus.intelligenceScore, lessThanOrEqualTo(1.0));

            // Test overall health provider
            final overallHealth = integrationTest.readProvider(overallHealthProvider);
            expect(overallHealth, isA<AppHealth>());

            // Test app ready provider
            final appReady = integrationTest.readProvider(appReadyProvider);
            expect(appReady, isA<bool>());

            integrationTest.mockLogger.i('✅ System status providers working correctly');
          },
          expectedMaxDuration: const Duration(seconds: 3),
        );
      });

      test('should handle performance metrics stream', () async {
        await integrationTest.testStreamOperations(
          'performance_metrics_stream',
          integrationTest.readProvider(performanceMetricsProvider.stream),
          expectedEventCount: 1,
          timeout: const Duration(seconds: 10),
        );
      });
    });

    group('🔄 Async & Stream Providers', () {
      test('should handle initialization provider', () async {
        await integrationTest.executeWithPerformanceMonitoring(
          'initialization_provider',
              () async {
            final initFuture = integrationTest.readProvider(initializationProvider);
            expect(initFuture, isA<AsyncValue<bool>>());

            // If already completed, verify it succeeded
            initFuture.whenData((success) {
              expect(success, isTrue, reason: 'Initialization should succeed');
            });
          },
          expectedMaxDuration: const Duration(seconds: 5),
        );
      });

      test('should handle orchestration stream providers', () async {
        await integrationTest.executeWithRetry(
          'orchestration_streams',
              () async {
            // Test individual responses stream provider
            final individualResponses = integrationTest.readProvider(
                individualResponsesProvider);
            expect(individualResponses, isA<AsyncValue<List>>());

            // Test synthesized response stream provider
            final synthesizedResponse = integrationTest.readProvider(
                synthesizedResponseProvider);
            expect(synthesizedResponse, isA<AsyncValue<String>>());

            // Test orchestration progress stream provider
            final orchestrationProgress = integrationTest.readProvider(
                orchestrationProgressProvider);
            expect(orchestrationProgress, isA<AsyncValue>());
          },
        );
      });

      test('should handle achievement notification stream', () async {
        await integrationTest.executeWithRetry(
          'achievement_notification_stream',
              () async {
            final notificationStream = integrationTest.readProvider(
                achievementNotificationStreamProvider);
            expect(notificationStream, isA<AsyncValue<AchievementNotification>>());
          },
        );
      });
    });

    group('🌍 Localization & Configuration Providers', () {
      test('should handle localization providers', () async {
        await integrationTest.executeWithPerformanceMonitoring(
          'localization_providers',
              () async {
            // Test current locale provider
            final locale = integrationTest.readProvider(currentLocaleProvider);
            expect(locale, isA<String>());

            // Test localization provider
            final localization = integrationTest.readProvider(localizationProvider);
            expect(localization, isA<Map<String, String>>());
            expect(localization, isNotEmpty);

            integrationTest.mockLogger.i('✅ Localization providers working correctly');
          },
          expectedMaxDuration: const Duration(seconds: 1),
        );
      });
    });

    group('🚀 Provider Performance & Load Tests', () {
      test('should handle concurrent provider access', () async {
        await integrationTest.testPerformanceBenchmark(
          'concurrent_provider_access',
              () async {
            // Access multiple providers concurrently
            final futures = <Future>[];

            // Core providers
            futures.add(Future.microtask(() =>
                integrationTest.readProvider(configServiceProvider)));
            futures.add(Future.microtask(() =>
                integrationTest.readProvider(storageServiceProvider)));

            // Achievement providers
            futures.add(Future.microtask(() =>
                integrationTest.readProvider(achievementStatsProvider)));
            futures.add(Future.microtask(() =>
                integrationTest.readProvider(totalPointsProvider)));

            // Athena providers
            futures.add(Future.microtask(() =>
                integrationTest.readProvider(athenaEnabledProvider)));
            futures.add(Future.microtask(() =>
                integrationTest.readProvider(athenaStatisticsProvider)));

            // UI providers
            futures.add(Future.microtask(() =>
                integrationTest.readProvider(currentThemeProvider)));
            futures.add(Future.microtask(() =>
                integrationTest.readProvider(enhancedSystemStatusProvider)));

            await Future.wait(futures);
          },
          const Duration(seconds: 3),
          iterations: 5,
        );
      });

      test('should handle provider state changes under load', () async {
        await integrationTest.testPerformanceBenchmark(
          'provider_state_changes_load',
              () async {
            // Perform multiple state changes rapidly
            final themeNotifier = integrationTest.container.read(currentThemeProvider.notifier);
            final darkModeNotifier = integrationTest.container.read(isDarkModeProvider.notifier);
            final modelsNotifier = integrationTest.container.read(activeModelsProvider.notifier);

            for (int i = 0; i < 10; i++) {
              themeNotifier.state = AppTheme.values[i % AppTheme.values.length];
              darkModeNotifier.state = i % 2 == 0;
              modelsNotifier.state = i % 2 == 0
                  ? ['claude', 'gpt']
                  : ['claude', 'gpt', 'gemini'];

              // Small delay to prevent overwhelming
              await Future.delayed(const Duration(milliseconds: 10));
            }
          },
          const Duration(seconds: 5),
        );
      });
    });

    group('🛡️ Provider Error Handling', () {
      test('should handle provider disposal gracefully', () async {
        await integrationTest.executeWithErrorInjection(
          'provider_disposal',
              () async {
            // Create a new container
            final testContainer = ProviderContainer(
              overrides: [
                sharedPreferencesProvider.overrideWithValue(integrationTest.mockPrefs),
                loggerProvider.overrideWithValue(integrationTest.mockLogger),
              ],
            );

            // Read some providers
            testContainer.read(configServiceProvider);
            testContainer.read(enhancedAchievementServiceProvider);

            // Dispose the container
            testContainer.dispose();
          },
              (error) async {
            // Should not throw errors during disposal
            fail('Provider disposal should not throw errors: $error');
          },
        );
      });

      test('should handle provider override errors', () async {
        await integrationTest.executeWithErrorInjection(
          'provider_override_errors',
              () async {
            // Try to create container with invalid overrides
            final invalidContainer = ProviderContainer(
              overrides: [
                // This might cause issues if not handled properly
                sharedPreferencesProvider.overrideWith((ref) =>
                throw Exception('Test override error')),
              ],
            );

            try {
              invalidContainer.read(configServiceProvider);
            } finally {
              invalidContainer.dispose();
            }
          },
              (error) async {
            // Error should be handled gracefully
            expect(error, isA<Exception>());
            integrationTest.mockLogger.w('Provider override error handled: $error');
          },
        );
      });
    });

    group('📊 Provider Integration Test Metrics', () {
      test('should collect provider-specific metrics', () {
        final metrics = integrationTest.getTestMetrics();
        expect(metrics, isNotEmpty);

        // Verify provider-specific performance metrics
        final providerKeys = metrics.keys.where((key) =>
        key.contains('provider') || key.contains('orchestration') || key.contains('athena'));
        expect(providerKeys, isNotEmpty,
            reason: 'Provider-specific metrics should be collected');

        integrationTest.mockLogger.i('Provider metrics collected: ${providerKeys.length} entries');
      });

      test('should validate provider ecosystem health', () {
        // Validate that all critical providers are working
        expect(() => integrationTest.readProvider(loggerProvider), returnsNormally);
        expect(() => integrationTest.readProvider(configServiceProvider), returnsNormally);
        expect(() => integrationTest.readProvider(storageServiceProvider), returnsNormally);
        expect(() => integrationTest.readProvider(enhancedAchievementServiceProvider), returnsNormally);
        expect(() => integrationTest.readProvider(athenaEnabledProvider), returnsNormally);

        // Generate comprehensive test report
        final report = integrationTest.generateTestReport();
        expect(report, contains('PROVIDERS'));

        integrationTest.mockLogger.i('Provider ecosystem health validated');
      });
    });
  });
}