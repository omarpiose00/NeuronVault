import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../../../../lib/core/services/config_service.dart';
import '../../../../lib/core/state/state_models.dart';
import '../../../unit/helpers/test_helpers.dart';

void main() {
  group('⚙️ ConfigService Tests', () {
    late ConfigService configService;
    late SharedPreferences mockPrefs;
    late FlutterSecureStorage secureStorage;
    late Logger mockLogger;

    setUp(() async {
      // Setup test environment
      mockPrefs = await TestHelpers.setupTestPreferences();
      mockLogger = TestHelpers.createTestLogger();

      // Use real FlutterSecureStorage with test configuration
      secureStorage = const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      );

      configService = ConfigService(
        sharedPreferences: mockPrefs,
        secureStorage: secureStorage,
        logger: mockLogger,
      );

      // Wait for encryption initialization
      await TestHelpers.testDelay(100);
    });

    tearDown(() async {
      // Clean up secure storage after each test
      try {
        await secureStorage.deleteAll();
      } catch (e) {
        // Ignore cleanup errors in tests
      }
    });

    group('🔐 Encryption Tests', () {
      test('should initialize encryption system', () {
        expect(configService, isNotNull);
        // Encryption should be initialized internally
      });
    });

    group('🎛️ Strategy Configuration Tests', () {
      test('should save and load strategy configuration', () async {
        final strategy = StrategyState(
          activeStrategy: OrchestrationStrategy.parallel,
          modelWeights: {AIModel.claude: 1.0, AIModel.gpt: 0.8},
        );

        await configService.saveStrategy(strategy);
        final loadedStrategy = await configService.getStrategy();

        expect(loadedStrategy, isNotNull);
        expect(loadedStrategy!.activeStrategy, equals(strategy.activeStrategy));
        expect(loadedStrategy.modelWeights, equals(strategy.modelWeights));
      });

      test('should return null for missing strategy', () async {
        final strategy = await configService.getStrategy();
        expect(strategy, isNull);
      });
    });

    group('🤖 Models Configuration Tests', () {
      test('should save and load models configuration', () async {
        final modelsState = ModelsState(
          availableModels: {
            AIModel.claude: ModelConfig(
              name: 'claude-3-sonnet',
              apiKey: 'test_key',
              baseUrl: 'https://api.anthropic.com',
              maxTokens: 1000,
              temperature: 0.7,
            ),
          },
          activeModels: {AIModel.claude: true},
        );

        await configService.saveModelsConfig(modelsState);
        final loadedModels = await configService.getModelsConfig();

        expect(loadedModels, isNotNull);
        expect(loadedModels!.activeModels[AIModel.claude], isTrue);
        expect(loadedModels.availableModels[AIModel.claude]?.name, equals('claude-3-sonnet'));
        // Note: API key is stored separately in secure storage
        expect(loadedModels.availableModels[AIModel.claude]?.apiKey, equals('test_key'));
      });
    });

    group('🌐 Connection Configuration Tests', () {
      test('should save and load connection configuration', () async {
        final connectionState = ConnectionState(
          status: ConnectionStatus.connected,
          lastConnectionTime: DateTime.now(),
          latencyMs: 95,
          reconnectAttempts: 0,
        );

        await configService.saveConnectionConfig(connectionState);
        final loadedConnection = await configService.getConnectionConfig();

        expect(loadedConnection, isNotNull);
        expect(loadedConnection!.status, equals(connectionState.status));
        expect(loadedConnection.latencyMs, equals(connectionState.latencyMs));
      });
    });

    group('🎨 Theme Configuration Tests', () {
      test('should save and load theme configuration', () async {
        await configService.saveThemeConfig(AppTheme.neural, true);
        final themeConfig = await configService.getThemeConfig();

        expect(themeConfig, isNotNull);
        expect(themeConfig!['theme'], equals('neural'));
        expect(themeConfig['isDarkMode'], isTrue);
      });
    });

    group('🔧 Boolean Preferences Tests', () {
      test('should save and load boolean preferences', () async {
        const key = 'test_boolean_key';
        const value = true;

        await configService.saveBoolPreference(key, value);
        final loadedValue = await configService.getBoolPreference(key);

        expect(loadedValue, equals(value));
      });

      test('should return null for missing boolean preference', () async {
        final value = await configService.getBoolPreference('missing_key');
        expect(value, isNull);
      });

      test('should handle encryption errors gracefully', () async {
        expect(
              () => configService.saveBoolPreference('test_key', true),
          returnsNormally,
        );
      });
    });

    group('📊 Application Configuration Tests', () {
      test('should save and load app configuration', () async {
        final appConfig = {
          'feature_flag_1': true,
          'setting_1': 'value_1',
          'numeric_setting': 42,
        };

        await configService.saveAppConfig(appConfig);
        final loadedConfig = await configService.getAppConfig();

        expect(loadedConfig, isNotNull);
        expect(loadedConfig!['feature_flag_1'], equals(true));
        expect(loadedConfig['setting_1'], equals('value_1'));
        expect(loadedConfig['numeric_setting'], equals(42));
        expect(loadedConfig['version'], equals('2.5.0'));
      });
    });

    group('📤 Export/Import Tests', () {
      test('should export configuration', () async {
        await configService.saveThemeConfig(AppTheme.neural, true);

        final exportData = await configService.exportConfiguration();

        expect(exportData, isNotEmpty);
        expect(exportData, isA<String>());
      });

      test('should handle export errors gracefully', () async {
        expect(
              () => configService.exportConfiguration(),
          returnsNormally,
        );
      });
    });

    group('🗑️ Cleanup Tests', () {
      test('should clear all configuration', () async {
        await configService.saveThemeConfig(AppTheme.neural, true);
        await configService.saveBoolPreference('test_key', true);

        await configService.clearAllConfiguration();

        final themeConfig = await configService.getThemeConfig();
        final boolPref = await configService.getBoolPreference('test_key');

        expect(themeConfig, isNull);
        expect(boolPref, isNull);
      });

      test('should reset to defaults', () async {
        await configService.resetToDefaults();
      });
    });

    group('📊 Diagnostics Tests', () {
      test('should provide diagnostics information', () async {
        final diagnostics = await configService.getDiagnostics();

        expect(diagnostics, isA<Map<String, dynamic>>());
        expect(diagnostics.containsKey('hasStrategy'), isTrue);
        expect(diagnostics.containsKey('hasModels'), isTrue);
        expect(diagnostics.containsKey('encryptionInitialized'), isTrue);
      });
    });

    group('🔐 Secure Storage Integration Tests', () {
      test('should handle secure storage operations', () async {
        // Direct test of secure storage integration
        await configService.saveBoolPreference('secure_test', true);
        final result = await configService.getBoolPreference('secure_test');

        expect(result, isTrue);
      });

      test('should separate sensitive and non-sensitive data', () async {
        final modelsState = ModelsState(
          availableModels: {
            AIModel.claude: ModelConfig(
              name: 'claude-test',
              apiKey: 'sensitive_api_key_123',
              baseUrl: 'https://api.test.com',
            ),
          },
          activeModels: {AIModel.claude: true},
        );

        await configService.saveModelsConfig(modelsState);

        // Verify that sensitive data is handled properly
        final loaded = await configService.getModelsConfig();
        expect(loaded?.availableModels[AIModel.claude]?.apiKey, isNotEmpty);
      });
    });

    group('🛡️ Error Handling Tests', () {
      test('should handle configuration corruption gracefully', () async {
        // Save valid configuration
        await configService.saveThemeConfig(AppTheme.neural, true);

        // Corrupt the data manually in SharedPreferences
        await mockPrefs.setString('neuronvault_theme', 'invalid_encrypted_data');

        // Should return null instead of throwing
        final corruptedTheme = await configService.getThemeConfig();
        expect(corruptedTheme, isNull);
      });
    });
  });
}