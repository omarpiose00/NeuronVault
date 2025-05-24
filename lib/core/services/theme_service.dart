// 🎨 NEURONVAULT - DYNAMIC THEME SERVICE
// Enterprise-grade theme management and customization
// Part of PHASE 2.5 - QUANTUM STATE MANAGEMENT

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../state/state_models.dart';
import 'config_service.dart';

class ThemeService {
  final ConfigService _configService;
  final Logger _logger;
  
  // 🎨 THEME CONFIGURATIONS
  static const Map<AppTheme, ThemeConfig> _themeConfigs = {
    AppTheme.neural: ThemeConfig(
      name: 'Neural',
      description: 'Deep neural network inspired theme with electric blues',
      primaryColor: Color(0xFF0066FF),
      secondaryColor: Color(0xFF00D4FF),
      accentColor: Color(0xFFFF6B00),
      backgroundColor: Color(0xFF0A0A0F),
      surfaceColor: Color(0xFF1A1A25),
      errorColor: Color(0xFFFF4444),
      successColor: Color(0xFF00FF88),
      warningColor: Color(0xFFFFAA00),
    ),
    AppTheme.quantum: ThemeConfig(
      name: 'Quantum',
      description: 'Quantum computing inspired theme with purple gradients',
      primaryColor: Color(0xFF8B5CF6),
      secondaryColor: Color(0xFFA855F7),
      accentColor: Color(0xFF06FFA5),
      backgroundColor: Color(0xFF0F0A1A),
      surfaceColor: Color(0xFF1E1B2E),
      errorColor: Color(0xFFEF4444),
      successColor: Color(0xFF10B981),
      warningColor: Color(0xFFF59E0B),
    ),
    AppTheme.cyber: ThemeConfig(
      name: 'Cyber',
      description: 'Cyberpunk aesthetic with neon greens and magentas',
      primaryColor: Color(0xFF00FF9F),
      secondaryColor: Color(0xFFFF0080),
      accentColor: Color(0xFFFFFF00),
      backgroundColor: Color(0xFF000A0A),
      surfaceColor: Color(0xFF001A1A),
      errorColor: Color(0xFFFF0040),
      successColor: Color(0xFF00FF9F),
      warningColor: Color(0xFFFFAA00),
    ),
    AppTheme.minimal: ThemeConfig(
      name: 'Minimal',
      description: 'Clean minimal design with subtle grays',
      primaryColor: Color(0xFF2563EB),
      secondaryColor: Color(0xFF64748B),
      accentColor: Color(0xFF0EA5E9),
      backgroundColor: Color(0xFF0F172A),
      surfaceColor: Color(0xFF1E293B),
      errorColor: Color(0xFFDC2626),
      successColor: Color(0xFF059669),
      warningColor: Color(0xFFD97706),
    ),
  };

  // 🌓 CURRENT THEME STATE
  AppTheme _currentTheme = AppTheme.neural;
  bool _isDarkMode = true;
  ThemeData? _cachedLightTheme;
  ThemeData? _cachedDarkTheme;

  ThemeService({
    required ConfigService configService,
    required Logger logger,
  }) : _configService = configService,
       _logger = logger {
    _initializeTheme();
  }

  // 🚀 INITIALIZATION
  Future<void> _initializeTheme() async {
    try {
      _logger.d('🎨 Initializing Theme Service...');
      
      final themeConfig = await _configService.getThemeConfig();
      if (themeConfig != null) {
        _currentTheme = AppTheme.values.firstWhere(
          (theme) => theme.name == themeConfig['theme'],
          orElse: () => AppTheme.neural,
        );
        _isDarkMode = themeConfig['isDarkMode'] ?? true;
      }
      
      // Pre-generate themes for performance
      await _generateThemes();
      
      _logger.i('✅ Theme Service initialized: ${_currentTheme.name} (${_isDarkMode ? 'Dark' : 'Light'})');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to initialize theme', error: e, stackTrace: stackTrace);
      _setDefaultTheme();
    }
  }

  void _setDefaultTheme() {
    _currentTheme = AppTheme.neural;
    _isDarkMode = true;
    _generateThemes();
  }

  // 🎨 THEME GENERATION
  Future<void> _generateThemes() async {
    try {
      _logger.d('🎨 Generating themes for ${_currentTheme.name}...');
      
      final config = _themeConfigs[_currentTheme]!;
      
      _cachedLightTheme = _buildLightTheme(config);
      _cachedDarkTheme = _buildDarkTheme(config);
      
      _logger.d('✅ Themes generated successfully');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to generate themes', error: e, stackTrace: stackTrace);
    }
  }

  ThemeData _buildLightTheme(ThemeConfig config) {
    final colorScheme = ColorScheme.light(
      primary: config.primaryColor,
      secondary: config.secondaryColor,
      tertiary: config.accentColor,
      background: Colors.white,
      surface: const Color(0xFFF8FAFC),
      error: config.errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: const Color(0xFF1E293B),
      onSurface: const Color(0xFF334155),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      
      // 🔤 TYPOGRAPHY
      textTheme: _buildTextTheme(colorScheme, Brightness.light),
      
      // 🎨 COMPONENT THEMES
      appBarTheme: _buildAppBarTheme(colorScheme, Brightness.light),
      cardTheme: _buildCardTheme(colorScheme, Brightness.light),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colorScheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme),
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme),
      dialogTheme: _buildDialogTheme(colorScheme, Brightness.light),
      bottomSheetTheme: _buildBottomSheetTheme(colorScheme, Brightness.light),
      
      // 🎯 VISUAL DENSITY
      visualDensity: VisualDensity.adaptivePlatformDensity,
      
      // 🎨 EXTENSIONS
      extensions: [
        NeuralThemeExtension(
          primaryGradient: _buildPrimaryGradient(config),
          secondaryGradient: _buildSecondaryGradient(config),
          accentGradient: _buildAccentGradient(config),
          successColor: config.successColor,
          warningColor: config.warningColor,
          glassSurface: Colors.white.withOpacity(0.1),
          neuralPulse: config.primaryColor.withOpacity(0.3),
        ),
      ],
    );
  }

  ThemeData _buildDarkTheme(ThemeConfig config) {
    final colorScheme = ColorScheme.dark(
      primary: config.primaryColor,
      secondary: config.secondaryColor,
      tertiary: config.accentColor,
      background: config.backgroundColor,
      surface: config.surfaceColor,
      error: config.errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.white.withOpacity(0.9),
      onSurface: Colors.white.withOpacity(0.8),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      
      // 🔤 TYPOGRAPHY
      textTheme: _buildTextTheme(colorScheme, Brightness.dark),
      
      // 🎨 COMPONENT THEMES
      appBarTheme: _buildAppBarTheme(colorScheme, Brightness.dark),
      cardTheme: _buildCardTheme(colorScheme, Brightness.dark),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colorScheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme),
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme),
      dialogTheme: _buildDialogTheme(colorScheme, Brightness.dark),
      bottomSheetTheme: _buildBottomSheetTheme(colorScheme, Brightness.dark),
      
      // 🎯 VISUAL DENSITY
      visualDensity: VisualDensity.adaptivePlatformDensity,
      
      // 🎨 EXTENSIONS
      extensions: [
        NeuralThemeExtension(
          primaryGradient: _buildPrimaryGradient(config),
          secondaryGradient: _buildSecondaryGradient(config),
          accentGradient: _buildAccentGradient(config),
          successColor: config.successColor,
          warningColor: config.warningColor,
          glassSurface: Colors.white.withOpacity(0.05),
          neuralPulse: config.primaryColor.withOpacity(0.2),
        ),
      ],
    );
  }

  // 🔤 TYPOGRAPHY THEME
  TextTheme _buildTextTheme(ColorScheme colorScheme, Brightness brightness) {
    final baseColor = brightness == Brightness.dark 
        ? Colors.white.withOpacity(0.9)
        : const Color(0xFF1E293B);
    
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        color: baseColor,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
        color: baseColor,
        letterSpacing: -0.25,
      ),
      displaySmall: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineLarge: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleLarge: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleMedium: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      titleSmall: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        color: baseColor.withOpacity(0.8),
      ),
      bodyLarge: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
        color: baseColor,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.normal,
        color: baseColor.withOpacity(0.8),
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontSize: 10.0,
        fontWeight: FontWeight.normal,
        color: baseColor.withOpacity(0.6),
        height: 1.3,
      ),
      labelLarge: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 0.5,
      ),
      labelMedium: TextStyle(
        fontSize: 10.0,
        fontWeight: FontWeight.w500,
        color: baseColor.withOpacity(0.8),
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontSize: 8.0,
        fontWeight: FontWeight.w500,
        color: baseColor.withOpacity(0.6),
        letterSpacing: 0.5,
      ),
    );
  }

  // 🎨 COMPONENT THEME BUILDERS
  AppBarTheme _buildAppBarTheme(ColorScheme colorScheme, Brightness brightness) {
    return AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onBackground,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        color: colorScheme.onBackground,
      ),
    );
  }

  CardTheme _buildCardTheme(ColorScheme colorScheme, Brightness brightness) {
    return CardTheme(
      color: colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
    );
  }

  ElevatedButtonThemeData _buildElevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  OutlinedButtonThemeData _buildOutlinedButtonTheme(ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  TextButtonThemeData _buildTextButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  InputDecorationTheme _buildInputDecorationTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  DialogTheme _buildDialogTheme(ColorScheme colorScheme, Brightness brightness) {
    return DialogTheme(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
    );
  }

  BottomSheetThemeData _buildBottomSheetTheme(ColorScheme colorScheme, Brightness brightness) {
    return BottomSheetThemeData(
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      elevation: 8,
    );
  }

  // 🌈 GRADIENT BUILDERS
  LinearGradient _buildPrimaryGradient(ThemeConfig config) {
    return LinearGradient(
      colors: [
        config.primaryColor,
        config.primaryColor.withOpacity(0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  LinearGradient _buildSecondaryGradient(ThemeConfig config) {
    return LinearGradient(
      colors: [
        config.secondaryColor,
        config.secondaryColor.withOpacity(0.7),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  LinearGradient _buildAccentGradient(ThemeConfig config) {
    return LinearGradient(
      colors: [
        config.accentColor,
        config.accentColor.withOpacity(0.6),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // 🎯 PUBLIC API
  AppTheme get currentTheme => _currentTheme;
  bool get isDarkMode => _isDarkMode;
  ThemeData get lightTheme => _cachedLightTheme ?? ThemeData.light();
  ThemeData get darkTheme => _cachedDarkTheme ?? ThemeData.dark();
  ThemeData get currentThemeData => _isDarkMode ? darkTheme : lightTheme;

  // 🔄 THEME SWITCHING
  Future<void> setTheme(AppTheme theme) async {
    if (_currentTheme == theme) return;
    
    try {
      _logger.i('🎨 Switching theme to: ${theme.name}');
      
      _currentTheme = theme;
      await _generateThemes();
      await _saveThemeConfig();
      
      _logger.i('✅ Theme switched successfully');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to switch theme', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode == isDark) return;
    
    try {
      _logger.i('🌓 Switching to ${isDark ? 'dark' : 'light'} mode');
      
      _isDarkMode = isDark;
      await _saveThemeConfig();
      
      _logger.i('✅ Theme mode switched successfully');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to switch theme mode', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> _saveThemeConfig() async {
    try {
      await _configService.saveThemeConfig(_currentTheme, _isDarkMode);
    } catch (e) {
      _logger.w('⚠️ Failed to save theme config: $e');
    }
  }

  // 🎨 THEME UTILITIES
  List<AppTheme> getAvailableThemes() => AppTheme.values;
  
  ThemeConfig getThemeConfig(AppTheme theme) => _themeConfigs[theme]!;
  
  String getThemeName(AppTheme theme) => _themeConfigs[theme]!.name;
  
  String getThemeDescription(AppTheme theme) => _themeConfigs[theme]!.description;

  Color getPrimaryColor([AppTheme? theme]) => 
      _themeConfigs[theme ?? _currentTheme]!.primaryColor;
  
  Color getSecondaryColor([AppTheme? theme]) => 
      _themeConfigs[theme ?? _currentTheme]!.secondaryColor;
  
  Color getAccentColor([AppTheme? theme]) => 
      _themeConfigs[theme ?? _currentTheme]!.accentColor;

  // 🔄 RESET
  Future<void> resetToDefault() async {
    try {
      _logger.i('🔄 Resetting theme to default...');
      
      _setDefaultTheme();
      await _saveThemeConfig();
      
      _logger.i('✅ Theme reset to default');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to reset theme', error: e, stackTrace: stackTrace);
    }
  }
}

// 🎨 THEME CONFIGURATION CLASS
class ThemeConfig {
  final String name;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color errorColor;
  final Color successColor;
  final Color warningColor;

  const ThemeConfig({
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.errorColor,
    required this.successColor,
    required this.warningColor,
  });
}

// 🎨 NEURAL THEME EXTENSION
class NeuralThemeExtension extends ThemeExtension<NeuralThemeExtension> {
  final LinearGradient primaryGradient;
  final LinearGradient secondaryGradient;
  final LinearGradient accentGradient;
  final Color successColor;
  final Color warningColor;
  final Color glassSurface;
  final Color neuralPulse;

  const NeuralThemeExtension({
    required this.primaryGradient,
    required this.secondaryGradient,
    required this.accentGradient,
    required this.successColor,
    required this.warningColor,
    required this.glassSurface,
    required this.neuralPulse,
  });

  @override
  NeuralThemeExtension copyWith({
    LinearGradient? primaryGradient,
    LinearGradient? secondaryGradient,
    LinearGradient? accentGradient,
    Color? successColor,
    Color? warningColor,
    Color? glassSurface,
    Color? neuralPulse,
  }) {
    return NeuralThemeExtension(
      primaryGradient: primaryGradient ?? this.primaryGradient,
      secondaryGradient: secondaryGradient ?? this.secondaryGradient,
      accentGradient: accentGradient ?? this.accentGradient,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      glassSurface: glassSurface ?? this.glassSurface,
      neuralPulse: neuralPulse ?? this.neuralPulse,
    );
  }

  @override
  NeuralThemeExtension lerp(ThemeExtension<NeuralThemeExtension>? other, double t) {
    if (other is! NeuralThemeExtension) {
      return this;
    }
    
    return NeuralThemeExtension(
      primaryGradient: LinearGradient.lerp(primaryGradient, other.primaryGradient, t)!,
      secondaryGradient: LinearGradient.lerp(secondaryGradient, other.secondaryGradient, t)!,
      accentGradient: LinearGradient.lerp(accentGradient, other.accentGradient, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      glassSurface: Color.lerp(glassSurface, other.glassSurface, t)!,
      neuralPulse: Color.lerp(neuralPulse, other.neuralPulse, t)!,
    );
  }
}