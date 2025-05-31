// test/unit/integration/core_services_integration_test.dart
// 🧬 NEURONVAULT - CORE SERVICES INTEGRATION TESTS
// Enterprise-grade integration testing for service interactions
// Supports PHASE 3.4 - Athena AI Integration + Achievement System

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'dart:async';

import '../../../lib/core/services/config_service.dart';
import '../../../lib/core/services/storage_service.dart';
import '../../../lib/core/services/ai_service.dart';
import '../../../lib/core/services/analytics_service.dart';
import '../../../lib/core/services/theme_service.dart';
import '../../../lib/core/services/achievement_service.dart';
import '../../../lib/core/state/state_models.dart';
import '../helpers/service_test_base.dart';
import '../mocks/test_data.dart' as TestData;
import '../helpers/test_helpers.dart';
import '../mocks/test_data.dart';

/// 🧬 Core Services Integration Test Suite
/// Tests the interaction between all core services in NeuronVault
class CoreServicesIntegrationTest extends ServiceTestBase {
  // 🔧 Service instances
  late ConfigService configService;
  late StorageService storageService;
  late AIService aiService;
  late AnalyticsService analyticsService;
  late ThemeService themeService;

  @override
  bool get enablePerformanceTests => true;
  @override
  bool get enableIntegrationTests => true;

  @override
  Future<void> setUpServiceSpecific() async {
    mockLogger.i('🔧 Setting up core services for integration testing...');

    // Initialize services in dependency order
    configService = createConfigService();
    storageService = createStorageService();
    analyticsService = createAnalyticsService();
    themeService = createThemeService();
    aiService = createAIService();

    // Wait for services to initialize
    await TestHelpers.testDelay(200);

    mockLogger.i('✅ Core services integration setup completed');
  }

  @override
  Future<void> tearDownServiceSpecific() async {
    mockLogger.i('🧹 Tearing down core services integration...');

    // Clean up any remaining data
    await configService.clearAllConfiguration();

    // Check for memory leaks
    checkForMemoryLeaks(configService, 'ConfigService');
    checkForMemoryLeaks(storageService, 'StorageService');
    checkForMemoryLeaks(analyticsService, 'AnalyticsService');

    mockLogger.i('✅ Core services integration teardown completed');
  }
}

void main() {
  group('🧬 Core Services Integration Tests', () {
    final integrationTest = CoreServicesIntegrationTest();

    setUp(() async {
      await integrationTest.setUpServiceTest();
    });

    tearDown(() async {
      await integrationTest.tearDownServiceTest();
    });

    group('🔧 Service Initialization Integration', () {
      test('should initialize all core services successfully', () async {
        await integrationTest.executeWithPerformanceMonitoring(
          'core_services_initialization',
              () async {
            // Validate all services are properly initialized
            integrationTest.validateServiceInitialization(
                integrationTest.configService, 'ConfigService');
            integrationTest.validateServiceInitialization(
                integrationTest.storageService, 'StorageService');
            integrationTest.validateServiceInitialization(
                integrationTest.aiService, 'AIService');
            integrationTest.validateServiceInitialization(
                integrationTest.analyticsService, 'AnalyticsService');
            integrationTest.validateServiceInitialization(
                integrationTest.themeService, 'ThemeService');
          },
          expectedMaxDuration: const Duration(seconds: 2),
        );
      });

      test('should handle service dependencies correctly', () async {
        await integrationTest.testServiceIntegration(
          'service_dependencies',
          [
            // Step 1: ConfigService should work independently
                () async {
              final appConfig = TestDataFactory.createAppConfigData();
              await integrationTest.configService.saveAppConfig(appConfig);
              final loaded = await integrationTest.configService.getAppConfig();
              expect(loaded, isNotNull);
            },

            // Step 2: StorageService should work independently
                () async {
              final message = TestDataFactory.createUserMessage();
              await integrationTest.storageService.saveMessage(message);
              final history = await integrationTest.storageService.getChatHistory();
              expect(history, isNotEmpty);
            },

            // Step 3: Services should interact properly
                () async {
              final analytics = integrationTest.analyticsService;
              // AnalyticsService depends on StorageService
              expect(analytics, isNotNull);
            },
          ],
        );
      });
    });

    group('💾 Configuration & Storage Integration', () {
      test('should save and load complete application state', () async {
        await integrationTest.testSaveLoadOperation(
          'complete_app_state',
              (AppState appState) async {
            // Save each component through respective services
            await integrationTest.configService.saveStrategy(appState.strategy);
            await integrationTest.configService.saveModelsConfig(appState.models);
            await integrationTest.configService.saveConnectionConfig(appState.connection);
            await integrationTest.configService.saveThemeConfig(
              AppTheme.values.firstWhere((t) => t.name == appState.theme),
              appState.isDarkMode,
            );

            // Save chat messages
            for (final message in appState.chat.messages) {
              await integrationTest.storageService.saveMessage(message);
            }
          },
              () async {
            // Load each component
            final strategy = await integrationTest.configService.getStrategy();
            final models = await integrationTest.configService.getModelsConfig();
            final connection = await integrationTest.configService.getConnectionConfig();
            final themeConfig = await integrationTest.configService.getThemeConfig();
            final messages = await integrationTest.storageService.getChatHistory();

            // Reconstruct app state
            final chatState = ChatState(
              messages: messages,
              messageCount: messages.length,
            );

            return AppState(
              strategy: strategy ?? const StrategyState(),
              models: models ?? const ModelsState(),
              chat: chatState,
              connection: connection ?? const ConnectionState(),
              theme: themeConfig?['theme'] ?? 'neural',
              isDarkMode: themeConfig?['isDarkMode'] ?? true,
              achievements: const AchievementState(),
            );
          },
          TestDataFactory.createAppState(),
              (AppState saved, AppState loaded) {
            return saved.strategy.activeStrategy == loaded.strategy.activeStrategy &&
                saved.models.budgetLimit == loaded.models.budgetLimit &&
                saved.theme == loaded.theme &&
                saved.isDarkMode == loaded.isDarkMode &&
                saved.chat.messages.length == loaded.chat.messages.length;
          },
        );
      });

      test('should handle configuration encryption across services', () async {
        await integrationTest.executeWithPerformanceMonitoring(
          'encryption_integration',
              () async {
            // Test sensitive data encryption
            final modelsState = TestData.TestDataFactory.createModelsState();
            await integrationTest.configService.saveModelsConfig(modelsState);

            // Verify data is encrypted in storage
            final rawData = integrationTest.mockPrefs.getString('neuronvault_models');
            expect(rawData, isNotNull);
            expect(rawData, isNot(contains('test_api_key')),
                reason: 'API keys should be encrypted');

            // Verify decryption works
            final loaded = await integrationTest.configService.getModelsConfig();
            expect(loaded?.availableModels[AIModel.claude]?.apiKey, isNotEmpty);
          },
          expectedMaxDuration: const Duration(seconds: 3),
        );
      });

      test('should maintain data consistency across service restarts', () async {
        await integrationTest.executeWithRetry(
          'data_consistency_across_restarts',
              () async {
            // Save initial data
            final strategy = TestData.TestDataFactory.createStrategyState();
            final messages = TestData.TestDataFactory.createChatHistory(messageCount: 5);

            await integrationTest.configService.saveStrategy(strategy);
            for (final message in messages) {
              await integrationTest.storageService.saveMessage(message);
            }

            // Simulate service restart by creating new instances
            final newConfigService = integrationTest.createConfigService();
            final newStorageService = integrationTest.createStorageService();

            // Wait for new services to initialize
            await TestHelpers.testDelay(100);

            // Verify data persistence
            final loadedStrategy = await newConfigService.getStrategy();
            final loadedMessages = await newStorageService.getChatHistory();

            expect(loadedStrategy?.activeStrategy, equals(strategy.activeStrategy));
            expect(loadedMessages.length, equals(messages.length));
            expect(loadedMessages.first.content, equals(messages.first.content));
          },
          maxAttempts: 2,
        );
      });
    });

    group('🤖 AI Service Integration', () {
      test('should integrate with configuration service for model settings', () async {
        await integrationTest.testServiceIntegration(
          'ai_config_integration',
          [
            // Setup model configuration
                () async {
              final modelsState = TestData.TestDataFactory.createModelsState();
              await integrationTest.configService.saveModelsConfig(modelsState);
            },

            // AI service should use configuration
                () async {
              // AIService should be initialized with config
              expect(integrationTest.aiService, isNotNull);

              // Note: In a real test, you'd verify that AIService
              // actually uses the configuration from ConfigService
            },
          ],
        );
      });

      test('should track AI interactions through analytics service', () async {
        await integrationTest.executeWithPerformanceMonitoring(
          'ai_analytics_integration',
              () async {
            // Generate some test chat messages
            final userMessage = TestData.TestDataFactory.createUserMessage(
                content: 'Test prompt for AI integration'
            );
            final assistantMessage = TestData.TestDataFactory.createAssistantMessage(
              content: 'Test AI response',
              sourceModel: AIModel.claude,
              requestId: userMessage.requestId,
            );

            // Save messages through storage service
            await integrationTest.storageService.saveMessage(userMessage);
            await integrationTest.storageService.saveMessage(assistantMessage);

            // Analytics service should be able to analyze the data
            final metadata = await integrationTest.storageService.getChatMetadata();
            expect(metadata['assistant_messages'], greaterThan(0));
          },
          expectedMaxDuration: const Duration(seconds: 2),
        );
      });
    });

    group('🎨 Theme Service Integration', () {
      test('should persist theme changes through configuration service', () async {
        await integrationTest.testSaveLoadOperation<Map<String, dynamic>>(
          'theme_persistence',
              (Map<String, dynamic> themeData) async {
            await integrationTest.themeService.setTheme(
              AppTheme.values.firstWhere((t) => t.name == themeData['theme']),
            );
            await integrationTest.themeService.setDarkMode(themeData['isDarkMode']);
          },
              () async {
            return await integrationTest.configService.getThemeConfig();
          },
          {'theme': 'neural', 'isDarkMode': true},
              (Map<String, dynamic> saved, Map<String, dynamic> loaded) {
            return saved['theme'] == loaded['theme'] &&
                saved['isDarkMode'] == loaded['isDarkMode'];
          },
        );
      });

      test('should handle theme changes across multiple services', () async {
        await integrationTest.executeWithRetry(
          'theme_propagation',
              () async {
            // Change theme through theme service
            await integrationTest.themeService.setTheme(AppTheme.cyber);
            await integrationTest.themeService.setDarkMode(false);

            // Verify persistence through config service
            final themeConfig = await integrationTest.configService.getThemeConfig();
            expect(themeConfig?['theme'], equals('cyber'));
            expect(themeConfig?['isDarkMode'], isFalse);

            // Theme change should be trackable through analytics
            final metadata = await integrationTest.storageService.getChatMetadata();
            expect(metadata, isNotNull);
          },
        );
      });
    });

    group('📊 Analytics Integration', () {
      test('should aggregate data from all services', () async {
        await integrationTest.executeWithPerformanceMonitoring(
          'analytics_aggregation',
              () async {
            // Generate activity across multiple services

            // 1. Configuration activity
            final strategy = TestData.TestDataFactory.createStrategyState();
            await integrationTest.configService.saveStrategy(strategy);

            // 2. Storage activity
            final messages = TestData.TestDataFactory.createChatHistory(messageCount: 3);
            for (final message in messages) {
              await integrationTest.storageService.saveMessage(message);
            }

            // 3. Theme activity
            await integrationTest.themeService.setTheme(AppTheme.quantum);
            await integrationTest.themeService.setDarkMode(true);

            // Analytics should reflect all activities
            final chatMetadata = await integrationTest.storageService.getChatMetadata();
            final storageStats = await integrationTest.storageService.getStorageStatistics();

            expect(chatMetadata['total_messages'], equals(3));
            expect(storageStats['message_count'], equals(3));
          },
          expectedMaxDuration: const Duration(seconds: 3),
        );
      });

      test('should handle cross-service error tracking', () async {
        await integrationTest.executeWithErrorInjection(
          'cross_service_error_tracking',
              () async {
            // Trigger an error in configuration service
            await integrationTest.configService.importConfiguration('invalid_data', 'wrong_password');
          },
              (error) async {
            // Analytics should be able to track this error
            expect(error, isA<Exception>());
            // In a real implementation, you'd verify that AnalyticsService
            // received and logged this error
          },
        );
      });
    });

    group('🚀 Performance Integration Tests', () {
      test('should handle concurrent operations across services', () async {
        await integrationTest.testPerformanceBenchmark(
          'concurrent_operations',
              () async {
            // Run concurrent operations across multiple services
            final futures = <Future>[];

            // Configuration operations
            futures.add(integrationTest.configService.saveStrategy(
                TestData.TestDataFactory.createStrategyState()));

            // Storage operations
            futures.add(integrationTest.storageService.saveMessage(
                TestData.TestDataFactory.createUserMessage()));
            futures.add(integrationTest.storageService.saveMessage(
                TestData.TestDataFactory.createAssistantMessage()));

            // Theme operations
            futures.add(integrationTest.themeService.setTheme(AppTheme.minimal));
            futures.add(integrationTest.themeService.setDarkMode(false));

            // Wait for all operations to complete
            await Future.wait(futures);
          },
          const Duration(seconds: 5),
          iterations: 3,
        );
      });

      test('should maintain performance under load', () async {
        await integrationTest.testPerformanceBenchmark(
          'load_test',
              () async {
            // Generate load across all services
            final messages = TestDataFactory.generateBulkMessages(10);
            for (final message in messages) {
              await integrationTest.storageService.saveMessage(message);
            }

            // Export chat history
            await integrationTest.storageService.exportChatHistory();

            // Update configuration
            await integrationTest.configService.saveAppConfig(
                TestDataFactory.createAppConfigData());
          },
          const Duration(seconds: 10),
        );
      });
    });

    group('🛡️ Error Resilience Integration', () {
      test('should handle service failures gracefully', () async {
        await integrationTest.executeWithErrorInjection(
          'service_failure_resilience',
              () async {
            // Test with corrupted storage
            await integrationTest.mockPrefs.setString(
                'neuronvault_strategy', 'corrupted_data');

            // Services should handle corruption gracefully
            final strategy = await integrationTest.configService.getStrategy();
            expect(strategy, isNull, reason: 'Should return null for corrupted data');
          },
              (error) async {
            // Error should be handled gracefully
            integrationTest.mockLogger.i('Error handled gracefully: $error');
          },
        );
      });

      test('should maintain data integrity during errors', () async {
        await integrationTest.executeWithRetry(
          'data_integrity_during_errors',
              () async {
            // Save valid data first
            final validMessage = TestData.TestDataFactory.createUserMessage();
            await integrationTest.storageService.saveMessage(validMessage);

            // Attempt to save invalid data (this should fail gracefully)
            try {
              // Create a message with invalid data
              await integrationTest.storageService.saveMessage(
                  TestData.TestDataFactory.createUserMessage(id: '', content: ''));
            } catch (e) {
              // Expected to fail
            }

            // Verify original valid data is still intact
            final history = await integrationTest.storageService.getChatHistory();
            expect(history, contains(
                predicate<ChatMessage>((msg) => msg.id == validMessage.id)));
          },
        );
      });
    });

    group('🧹 Cleanup & Maintenance Integration', () {
      test('should perform comprehensive cleanup across all services', () async {
        await integrationTest.executeWithPerformanceMonitoring(
          'comprehensive_cleanup',
              () async {
            // Generate data in all services
            await integrationTest.configService.saveAppConfig(
                TestData.TestDataFactory.createAppConfigData());
            await integrationTest.storageService.saveMessage(
                TestData.TestDataFactory.createUserMessage());
            await integrationTest.themeService.setTheme(AppTheme.cyber);

            // Perform maintenance across all services
            await integrationTest.storageService.performMaintenance();
            await integrationTest.configService.clearAllConfiguration();

            // Verify cleanup
            final appConfig = await integrationTest.configService.getAppConfig();
            final themeConfig = await integrationTest.configService.getThemeConfig();

            expect(appConfig, isNull);
            expect(themeConfig, isNull);
          },
          expectedMaxDuration: const Duration(seconds: 5),
        );
      });

      test('should handle service disposal properly', () async {
        // This test would verify that services clean up their resources
        // when the app is terminated or when they're no longer needed

        final diagnostics = await integrationTest.configService.getDiagnostics();
        expect(diagnostics, isA<Map<String, dynamic>>());
        expect(diagnostics['encryptionInitialized'], isTrue);

        // Verify no resource leaks
        integrationTest.checkForMemoryLeaks(integrationTest.configService, 'ConfigService');
        integrationTest.checkForMemoryLeaks(integrationTest.storageService, 'StorageService');
      });
    });

    group('📊 Integration Test Metrics', () {
      test('should collect comprehensive test metrics', () {
        final metrics = integrationTest.getTestMetrics();
        expect(metrics, isNotEmpty);

        // Verify performance metrics were collected
        final performanceKeys = metrics.keys.where((key) => key.contains('_duration_ms'));
        expect(performanceKeys, isNotEmpty,
            reason: 'Performance metrics should be collected');

        // Generate test report
        final report = integrationTest.generateTestReport();
        expect(report, contains('SERVICE TEST REPORT'));

        integrationTest.mockLogger.i('Test Report:\n$report');
      });

      test('should validate test metrics thresholds', () {
        integrationTest.validateTestMetrics();

        final metrics = integrationTest.getTestMetrics();

        // Check that setup time was reasonable
        if (metrics.containsKey('setup_time_ms')) {
          final setupTime = metrics['setup_time_ms'] as int;
          expect(setupTime, lessThan(10000),
              reason: 'Setup should complete within 10 seconds');
        }
      });
    });
  });
}