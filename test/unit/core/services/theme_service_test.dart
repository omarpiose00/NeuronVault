import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:logger/logger.dart';
import '../../../../lib/core/services/theme_service.dart';
import '../../../../lib/core/services/config_service.dart';
import '../../../../lib/core/state/state_models.dart';
import '../../../unit/helpers/test_helpers.dart';
import '../../../unit/mocks/mock_services.dart';

void main() {
  group('🎨 ThemeService Tests', () {
    late ThemeService themeService;
    late MockConfigService mockConfigService;
    late Logger mockLogger;

    setUp(() {
      mockConfigService = MockConfigService();
      mockLogger = TestHelpers.createTestLogger();

      // CORREZIONE: Setup mock behavior specifico senza any matcher
      when(mockConfigService.getThemeConfig()).thenAnswer((_) async => null);

      // Stub per tutti i possibili temi e modalità
      for (final theme in AppTheme.values) {
        when(mockConfigService.saveThemeConfig(theme, true)).thenAnswer((_) async {});
        when(mockConfigService.saveThemeConfig(theme, false)).thenAnswer((_) async {});
      }

      themeService = ThemeService(
        configService: mockConfigService,
        logger: mockLogger,
      );
    });

    group('🚀 Initialization Tests', () {
      test('should initialize with default theme', () {
        expect(themeService.currentTheme, equals(AppTheme.neural));
        expect(themeService.isDarkMode, isTrue);
        expect(themeService.lightTheme, isA<ThemeData>());
        expect(themeService.darkTheme, isA<ThemeData>());
      });

      test('should load saved theme configuration', () async {
        when(mockConfigService.getThemeConfig()).thenAnswer((_) async => {
          'theme': 'quantum',
          'isDarkMode': false,
        });

        final newThemeService = ThemeService(
          configService: mockConfigService,
          logger: mockLogger,
        );

        // Wait for initialization
        await TestHelpers.testDelay(100);

        expect(newThemeService.currentTheme, equals(AppTheme.quantum));
        expect(newThemeService.isDarkMode, isFalse);
      });
    });

    group('🎨 Theme Switching Tests', () {
      test('should switch to different theme', () async {
        await themeService.setTheme(AppTheme.cyber);

        expect(themeService.currentTheme, equals(AppTheme.cyber));
        verify(mockConfigService.saveThemeConfig(AppTheme.cyber, true));
      });

      test('should not switch if same theme', () async {
        await themeService.setTheme(AppTheme.neural); // Already neural

        expect(themeService.currentTheme, equals(AppTheme.neural));
        // Should not call save since no change
      });

      test('should switch dark mode', () async {
        await themeService.setDarkMode(false);

        expect(themeService.isDarkMode, isFalse);
        verify(mockConfigService.saveThemeConfig(AppTheme.neural, false));
      });

      test('should not switch if same mode', () async {
        await themeService.setDarkMode(true); // Already true

        expect(themeService.isDarkMode, isTrue);
        // Should not call save since no change
      });
    });

    group('🎯 Theme Data Generation Tests', () {
      test('should generate valid light theme', () {
        final lightTheme = themeService.lightTheme;

        expect(lightTheme.brightness, equals(Brightness.light));
        expect(lightTheme.useMaterial3, isTrue);
        expect(lightTheme.colorScheme.brightness, equals(Brightness.light));
      });

      test('should generate valid dark theme', () {
        final darkTheme = themeService.darkTheme;

        expect(darkTheme.brightness, equals(Brightness.dark));
        expect(darkTheme.useMaterial3, isTrue);
        expect(darkTheme.colorScheme.brightness, equals(Brightness.dark));
      });

      test('should return current theme data based on mode', () {
        themeService.setDarkMode(true);
        final currentTheme = themeService.currentThemeData;
        expect(currentTheme.brightness, equals(Brightness.dark));

        themeService.setDarkMode(false);
        final newCurrentTheme = themeService.currentThemeData;
        expect(newCurrentTheme.brightness, equals(Brightness.light));
      });
    });

    group('🌈 Theme Extension Tests', () {
      test('should include neural theme extension', () {
        final theme = themeService.currentThemeData;
        final extension = theme.extension<NeuralThemeExtension>();

        expect(extension, isNotNull);
        expect(extension!.primaryGradient, isA<LinearGradient>());
        expect(extension.secondaryGradient, isA<LinearGradient>());
        expect(extension.accentGradient, isA<LinearGradient>());
      });

      test('should have different extensions for different themes', () async {
        final neuralTheme = themeService.currentThemeData;
        final neuralExtension = neuralTheme.extension<NeuralThemeExtension>();

        await themeService.setTheme(AppTheme.quantum);

        final quantumTheme = themeService.currentThemeData;
        final quantumExtension = quantumTheme.extension<NeuralThemeExtension>();

        expect(neuralExtension!.primaryGradient.colors.first,
            isNot(equals(quantumExtension!.primaryGradient.colors.first)));
      });
    });

    group('🎨 All Themes Validation Tests', () {
      test('should generate all available themes without errors', () async {
        for (final theme in AppTheme.values) {
          await themeService.setTheme(theme);

          expect(themeService.currentTheme, equals(theme));
          expect(themeService.lightTheme, isA<ThemeData>());
          expect(themeService.darkTheme, isA<ThemeData>());

          final config = themeService.getThemeConfig(theme);
          expect(config.name, isNotEmpty);
          expect(config.description, isNotEmpty);
        }
      });

      test('should have unique primary colors for each theme', () {
        final Set<Color> primaryColors = {};

        for (final theme in AppTheme.values) {
          final primaryColor = themeService.getPrimaryColor(theme);
          expect(primaryColors.contains(primaryColor), isFalse,
              reason: 'Theme $theme has duplicate primary color');
          primaryColors.add(primaryColor);
        }
      });
    });

    group('🔧 Utility Methods Tests', () {
      test('should get available themes', () {
        final themes = themeService.getAvailableThemes();

        expect(themes, equals(AppTheme.values));
        expect(themes.length, greaterThan(3));
      });

      test('should get theme names and descriptions', () {
        for (final theme in AppTheme.values) {
          final name = themeService.getThemeName(theme);
          final description = themeService.getThemeDescription(theme);

          expect(name, isNotEmpty);
          expect(description, isNotEmpty);
        }
      });

      test('should get theme colors', () {
        for (final theme in AppTheme.values) {
          final primary = themeService.getPrimaryColor(theme);
          final secondary = themeService.getSecondaryColor(theme);
          final accent = themeService.getAccentColor(theme);

          expect(primary, isA<Color>());
          expect(secondary, isA<Color>());
          expect(accent, isA<Color>());
        }
      });
    });

    group('🔄 Reset Tests', () {
      test('should reset to default theme', () async {
        // Change to non-default theme
        await themeService.setTheme(AppTheme.cyber);
        await themeService.setDarkMode(false);

        // Reset
        await themeService.resetToDefault();

        expect(themeService.currentTheme, equals(AppTheme.neural));
        expect(themeService.isDarkMode, isTrue);
      });
    });

    group('🔧 Error Handling Tests', () {
      test('should handle config service save errors gracefully', () async {
        // CORREZIONE: Setup specifico per questo test di errore
        when(mockConfigService.saveThemeConfig(AppTheme.quantum, true))
            .thenThrow(Exception('Save error'));

        expect(
              () => themeService.setTheme(AppTheme.quantum),
          throwsException,
        );
      });

      test('should handle config service load errors gracefully', () async {
        when(mockConfigService.getThemeConfig())
            .thenThrow(Exception('Load error'));

        // Should fall back to defaults
        final newThemeService = ThemeService(
          configService: mockConfigService,
          logger: mockLogger,
        );

        expect(newThemeService.currentTheme, equals(AppTheme.neural));
        expect(newThemeService.isDarkMode, isTrue);
      });
    });

    group('🎨 Theme Component Tests', () {
      test('should generate proper card theme', () {
        final theme = themeService.currentThemeData;

        expect(theme.cardTheme, isA<CardThemeData>());
        expect(theme.cardTheme.elevation, equals(0));
        expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
      });

      test('should generate proper button themes', () {
        final theme = themeService.currentThemeData;

        expect(theme.elevatedButtonTheme, isA<ElevatedButtonThemeData>());
        expect(theme.outlinedButtonTheme, isA<OutlinedButtonThemeData>());
        expect(theme.textButtonTheme, isA<TextButtonThemeData>());
      });

      test('should generate proper input decoration theme', () {
        final theme = themeService.currentThemeData;

        expect(theme.inputDecorationTheme, isA<InputDecorationTheme>());
        expect(theme.inputDecorationTheme.filled, isTrue);
      });
    });
  });
}