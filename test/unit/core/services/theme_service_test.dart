// 🎨 NEURONVAULT - THEME SERVICE COMPLETE TEST SUITE
// Enterprise-grade testing with 100% public method coverage
// Part of PHASE 2.5 - QUANTUM STATE MANAGEMENT TESTING

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

import 'package:neuronvault/core/services/theme_service.dart';
import 'package:neuronvault/core/services/config_service.dart';
import 'package:neuronvault/core/state/state_models.dart';

// 🧪 MOCKS
class MockConfigService extends Mock implements ConfigService {}
class MockLogger extends Mock implements Logger {}

// 🎯 FALLBACK VALUES
class FakeAppTheme extends Fake {
  final AppTheme theme = AppTheme.neural;
}

void main() {
  group('🎨 ThemeService Tests', () {
    late ThemeService themeService;
    late MockConfigService mockConfigService;
    late MockLogger mockLogger;

    // 📋 TEST SETUP
    setUpAll(() {
      // Register fallback values for enums
      registerFallbackValue(FakeAppTheme());
      registerFallbackValue(AppTheme.neural);
    });

    setUp(() {
      mockConfigService = MockConfigService();
      mockLogger = MockLogger();

      // Default mock setup
      when(() => mockConfigService.getThemeConfig())
          .thenAnswer((_) async => null);
      when(() => mockConfigService.saveThemeConfig(any(), any()))
          .thenAnswer((_) async {});

      // Logger mock setup - allow any calls with any parameters
      when(() => mockLogger.d(any(), time: any(named: 'time'), error: any(named: 'error'), stackTrace: any(named: 'stackTrace')))
          .thenReturn(null);
      when(() => mockLogger.i(any(), time: any(named: 'time'), error: any(named: 'error'), stackTrace: any(named: 'stackTrace')))
          .thenReturn(null);
      when(() => mockLogger.w(any(), time: any(named: 'time'), error: any(named: 'error'), stackTrace: any(named: 'stackTrace')))
          .thenReturn(null);
      when(() => mockLogger.e(any(), error: any(named: 'error'), stackTrace: any(named: 'stackTrace'), time: any(named: 'time')))
          .thenReturn(null);
    });

    tearDown(() {
      reset(mockConfigService);
      reset(mockLogger);
    });

    // 🏗️ INITIALIZATION TESTS
    group('🚀 Initialization', () {
      test('should initialize with default values when no saved config', () async {
        // Arrange
        when(() => mockConfigService.getThemeConfig())
            .thenAnswer((_) async => null);

        // Act
        themeService = ThemeService(
          configService: mockConfigService,
          logger: mockLogger,
        );

        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(themeService.currentTheme, AppTheme.neural);
        expect(themeService.isDarkMode, true);
        expect(themeService.currentThemeData, isNotNull);
        expect(themeService.lightTheme, isNotNull);
        expect(themeService.darkTheme, isNotNull);

        verify(() => mockConfigService.getThemeConfig()).called(1);
      });

      test('should initialize with saved theme config', () async {
        // Arrange
        final savedConfig = {
          'theme': 'quantum',
          'isDarkMode': false,
        };
        when(() => mockConfigService.getThemeConfig())
            .thenAnswer((_) async => savedConfig);

        // Act
        themeService = ThemeService(
          configService: mockConfigService,
          logger: mockLogger,
        );

        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(themeService.currentTheme, AppTheme.quantum);
        expect(themeService.isDarkMode, false);

        verify(() => mockConfigService.getThemeConfig()).called(1);
      });

      test('should handle initialization error gracefully', () async {
        // Arrange
        when(() => mockConfigService.getThemeConfig())
            .thenThrow(Exception('Config error'));

        // Act
        themeService = ThemeService(
          configService: mockConfigService,
          logger: mockLogger,
        );

        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - should fall back to defaults
        expect(themeService.currentTheme, AppTheme.neural);
        expect(themeService.isDarkMode, true);

        verify(() => mockLogger.e(
          '❌ Failed to initialize theme',
          error: any(named: 'error'),
          stackTrace: any(named: 'stackTrace'),
        )).called(1);
      });

      test('should handle invalid saved theme gracefully', () async {
        // Arrange
        final invalidConfig = {
          'theme': 'invalid_theme',
          'isDarkMode': true,
        };
        when(() => mockConfigService.getThemeConfig())
            .thenAnswer((_) async => invalidConfig);

        // Act
        themeService = ThemeService(
          configService: mockConfigService,
          logger: mockLogger,
        );

        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - should fall back to neural theme
        expect(themeService.currentTheme, AppTheme.neural);
        expect(themeService.isDarkMode, true);
      });
    });

    // 🎨 THEME SWITCHING TESTS
    group('🔄 Theme Switching', () {
      setUp(() async {
        themeService = ThemeService(
          configService: mockConfigService,
          logger: mockLogger,
        );
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('should change theme successfully', () async {
        // Arrange
        expect(themeService.currentTheme, AppTheme.neural);

        // Act
        await themeService.setTheme(AppTheme.quantum);

        // Assert
        expect(themeService.currentTheme, AppTheme.quantum);
        verify(() => mockConfigService.saveThemeConfig(AppTheme.quantum, true)).called(1);
      });

      test('should not change theme if same theme is selected', () async {
        // Arrange
        expect(themeService.currentTheme, AppTheme.neural);

        // Act
        await themeService.setTheme(AppTheme.neural);

        // Assert
        expect(themeService.currentTheme, AppTheme.neural);
        // Should not save config if no change
        verifyNever(() => mockConfigService.saveThemeConfig(any(), any()));
      });

      test('should handle theme switching error gracefully', () async {
        // Arrange
        when(() => mockConfigService.saveThemeConfig(any(), any()))
            .thenThrow(Exception('Save error'));

        // Act - Should not throw, error is caught internally
        await themeService.setTheme(AppTheme.cyber);

        // Assert - Theme should change in memory even if save fails
        expect(themeService.currentTheme, AppTheme.cyber);
        verify(() => mockConfigService.saveThemeConfig(AppTheme.cyber, true)).called(1);
      });

      test('should change dark mode successfully', () async {
        // Arrange
        expect(themeService.isDarkMode, true);

        // Act
        await themeService.setDarkMode(false);

        // Assert
        expect(themeService.isDarkMode, false);
        verify(() => mockConfigService.saveThemeConfig(AppTheme.neural, false)).called(1);
      });

      test('should not change dark mode if same value', () async {
        // Arrange
        expect(themeService.isDarkMode, true);

        // Act
        await themeService.setDarkMode(true);

        // Assert
        expect(themeService.isDarkMode, true);
        verifyNever(() => mockConfigService.saveThemeConfig(any(), any()));
      });

      test('should handle dark mode switching error gracefully', () async {
        // Arrange
        when(() => mockConfigService.saveThemeConfig(any(), any()))
            .thenThrow(Exception('Save error'));

        // Act - Should not throw, error is caught internally
        await themeService.setDarkMode(false);

        // Assert - Mode should change in memory even if save fails
        expect(themeService.isDarkMode, false);
        verify(() => mockConfigService.saveThemeConfig(AppTheme.neural, false)).called(1);
      });
    });

    // 📊 THEME DATA TESTS
    group('📊 Theme Data Access', () {
      setUp(() async {
        themeService = ThemeService(
          configService: mockConfigService,
          logger: mockLogger,
        );
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('should return correct current theme data', () {
        // Act & Assert
        final themeData = themeService.currentThemeData;
        expect(themeData, isNotNull);
        expect(themeData.brightness, Brightness.dark); // Default is dark mode
      });

      test('should return light theme data', () {
        // Act & Assert
        final lightTheme = themeService.lightTheme;
        expect(lightTheme, isNotNull);
        expect(lightTheme.brightness, Brightness.light);
      });

      test('should return dark theme data', () {
        // Act & Assert
        final darkTheme = themeService.darkTheme;
        expect(darkTheme, isNotNull);
        expect(darkTheme.brightness, Brightness.dark);
      });

      test('should return correct current theme data after mode change', () async {
        // Arrange
        expect(themeService.isDarkMode, true);

        // Act
        await themeService.setDarkMode(false);

        // Assert
        final themeData = themeService.currentThemeData;
        expect(themeData.brightness, Brightness.light);
      });
    });

    // 🎯 THEME UTILITIES TESTS
    group('🎯 Theme Utilities', () {
      setUp(() async {
        themeService = ThemeService(
          configService: mockConfigService,
          logger: mockLogger,
        );
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('should return all available themes', () {
        // Act
        final themes = themeService.getAvailableThemes();

        // Assert
        expect(themes, equals(AppTheme.values));
        expect(themes.length, 4);
        expect(themes, contains(AppTheme.neural));
        expect(themes, contains(AppTheme.quantum));
        expect(themes, contains(AppTheme.cyber));
        expect(themes, contains(AppTheme.minimal));
      });

      test('should return theme config for neural theme', () {
        // Act
        final config = themeService.getThemeConfig(AppTheme.neural);

        // Assert
        expect(config, isNotNull);
        expect(config.name, 'Neural');
        expect(config.description, 'Deep neural network inspired theme with electric blues');
        expect(config.primaryColor, const Color(0xFF0066FF));
      });

      test('should return theme config for quantum theme', () {
        // Act
        final config = themeService.getThemeConfig(AppTheme.quantum);

        // Assert
        expect(config, isNotNull);
        expect(config.name, 'Quantum');
        expect(config.description, 'Quantum computing inspired theme with purple gradients');
        expect(config.primaryColor, const Color(0xFF8B5CF6));
      });

      test('should return theme name', () {
        // Act & Assert
        expect(themeService.getThemeName(AppTheme.neural), 'Neural');
        expect(themeService.getThemeName(AppTheme.quantum), 'Quantum');
        expect(themeService.getThemeName(AppTheme.cyber), 'Cyber');
        expect(themeService.getThemeName(AppTheme.minimal), 'Minimal');
      });

      test('should return theme description', () {
        // Act & Assert
        expect(
          themeService.getThemeDescription(AppTheme.neural),
          'Deep neural network inspired theme with electric blues',
        );
        expect(
          themeService.getThemeDescription(AppTheme.quantum),
          'Quantum computing inspired theme with purple gradients',
        );
      });

      test('should return primary color for current theme', () {
        // Act
        final color = themeService.getPrimaryColor();

        // Assert
        expect(color, const Color(0xFF0066FF)); // Neural theme primary
      });

      test('should return primary color for specific theme', () {
        // Act
        final color = themeService.getPrimaryColor(AppTheme.quantum);

        // Assert
        expect(color, const Color(0xFF8B5CF6)); // Quantum theme primary
      });

      test('should return secondary color for current theme', () {
        // Act
        final color = themeService.getSecondaryColor();

        // Assert
        expect(color, const Color(0xFF00D4FF)); // Neural theme secondary
      });

      test('should return secondary color for specific theme', () {
        // Act
        final color = themeService.getSecondaryColor(AppTheme.cyber);

        // Assert
        expect(color, const Color(0xFFFF0080)); // Cyber theme secondary
      });

      test('should return accent color for current theme', () {
        // Act
        final color = themeService.getAccentColor();

        // Assert
        expect(color, const Color(0xFFFF6B00)); // Neural theme accent
      });

      test('should return accent color for specific theme', () {
        // Act
        final color = themeService.getAccentColor(AppTheme.minimal);

        // Assert
        expect(color, const Color(0xFF0EA5E9)); // Minimal theme accent
      });
    });

    // 🔄 RESET FUNCTIONALITY TESTS
    group('🔄 Reset Functionality', () {
      setUp(() async {
        themeService = ThemeService(
          configService: mockConfigService,
          logger: mockLogger,
        );
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('should reset to default theme successfully', () async {
        // Arrange - Change theme first
        await themeService.setTheme(AppTheme.cyber);
        await themeService.setDarkMode(false);
        expect(themeService.currentTheme, AppTheme.cyber);
        expect(themeService.isDarkMode, false);

        // Act
        await themeService.resetToDefault();

        // Assert
        expect(themeService.currentTheme, AppTheme.neural);
        expect(themeService.isDarkMode, true);

        verify(() => mockConfigService.saveThemeConfig(AppTheme.neural, true)).called(1);
      });

      test('should handle reset error gracefully', () async {
        // Arrange
        when(() => mockConfigService.saveThemeConfig(any(), any()))
            .thenThrow(Exception('Save error'));

        // Act
        await themeService.resetToDefault();

        // Assert - Should still reset in memory even if save fails
        expect(themeService.currentTheme, AppTheme.neural);
        expect(themeService.isDarkMode, true);

        // Should have attempted to save the config
        verify(() => mockConfigService.saveThemeConfig(AppTheme.neural, true)).called(1);
      });
    });

    // 🎨 THEME EXTENSION TESTS
    group('🎨 Theme Extensions', () {
      setUp(() async {
        themeService = ThemeService(
          configService: mockConfigService,
          logger: mockLogger,
        );
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('should have neural theme extension in dark theme', () {
        // Act
        final darkTheme = themeService.darkTheme;
        final extension = darkTheme.extension<NeuralThemeExtension>();

        // Assert
        expect(extension, isNotNull);
        expect(extension!.primaryGradient, isNotNull);
        expect(extension.secondaryGradient, isNotNull);
        expect(extension.accentGradient, isNotNull);
        expect(extension.successColor, isNotNull);
        expect(extension.warningColor, isNotNull);
        expect(extension.glassSurface, isNotNull);
        expect(extension.neuralPulse, isNotNull);
      });

      test('should have neural theme extension in light theme', () {
        // Act
        final lightTheme = themeService.lightTheme;
        final extension = lightTheme.extension<NeuralThemeExtension>();

        // Assert
        expect(extension, isNotNull);
        expect(extension!.primaryGradient, isNotNull);
        expect(extension.secondaryGradient, isNotNull);
        expect(extension.accentGradient, isNotNull);
      });

      test('should have different glass surface opacity for light and dark themes', () {
        // Act
        final lightExtension = themeService.lightTheme.extension<NeuralThemeExtension>();
        final darkExtension = themeService.darkTheme.extension<NeuralThemeExtension>();

        // Assert - Use closeTo for floating point comparison
        expect(lightExtension!.glassSurface.opacity, closeTo(0.1, 0.01));
        expect(darkExtension!.glassSurface.opacity, closeTo(0.05, 0.01));
      });
    });

    // 🔧 SAVE CONFIG ERROR HANDLING TESTS
    group('🔧 Save Config Error Handling', () {
      setUp(() async {
        themeService = ThemeService(
          configService: mockConfigService,
          logger: mockLogger,
        );
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('should change theme in memory even when save config fails', () async {
        // Arrange
        when(() => mockConfigService.saveThemeConfig(any(), any()))
            .thenThrow(Exception('Network error'));

        // Act - Should not throw, error is caught internally
        await themeService.setTheme(AppTheme.quantum);

        // Assert - Theme should change in memory even if save fails
        expect(themeService.currentTheme, AppTheme.quantum);
        verify(() => mockConfigService.saveThemeConfig(AppTheme.quantum, true)).called(1);
      });
    });

    // 🎯 INTEGRATION TESTS
    group('🎯 Integration Tests', () {
      setUp(() async {
        themeService = ThemeService(
          configService: mockConfigService,
          logger: mockLogger,
        );
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('should maintain theme consistency across multiple operations', () async {
        // Act - Perform multiple theme operations
        await themeService.setTheme(AppTheme.quantum);
        await themeService.setDarkMode(false);

        // Assert
        expect(themeService.currentTheme, AppTheme.quantum);
        expect(themeService.isDarkMode, false);
        expect(themeService.currentThemeData.brightness, Brightness.light);
        expect(themeService.getPrimaryColor(), const Color(0xFF8B5CF6));

        // Reset and verify
        await themeService.resetToDefault();
        expect(themeService.currentTheme, AppTheme.neural);
        expect(themeService.isDarkMode, true);
        expect(themeService.getPrimaryColor(), const Color(0xFF0066FF));
      });

      test('should handle rapid theme switching', () async {
        // Act - Rapid theme changes
        await themeService.setTheme(AppTheme.quantum);
        await themeService.setTheme(AppTheme.cyber);
        await themeService.setTheme(AppTheme.minimal);

        // Assert - Should end up with the last theme
        expect(themeService.currentTheme, AppTheme.minimal);
        expect(themeService.getPrimaryColor(), const Color(0xFF2563EB));

        // Verify save was called for each change
        verify(() => mockConfigService.saveThemeConfig(AppTheme.quantum, true)).called(1);
        verify(() => mockConfigService.saveThemeConfig(AppTheme.cyber, true)).called(1);
        verify(() => mockConfigService.saveThemeConfig(AppTheme.minimal, true)).called(1);
      });
    });
  });
}