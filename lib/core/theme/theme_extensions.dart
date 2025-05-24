// lib/core/theme/theme_extensions.dart - VERSIONE PULITA
import 'package:flutter/material.dart';
import 'app_theme.dart';

/// 🎨 HIGH CONTRAST THEME per accessibility
class HighContrastTheme {
  static ThemeData getHighContrastTheme(ThemeData baseTheme) {
    return baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        // Ultra high contrast colors
        primary: const Color(0xFFFFFFFF),
        onPrimary: const Color(0xFF000000),
        secondary: const Color(0xFFFFFF00),
        onSecondary: const Color(0xFF000000),
        surface: const Color(0xFF000000),
        onSurface: const Color(0xFFFFFFFF),
        background: const Color(0xFF000000),
        onBackground: const Color(0xFFFFFFFF),
        error: const Color(0xFFFF0000),
        onError: const Color(0xFFFFFFFF),
      ),

      // Enhanced focus indicators
      focusColor: const Color(0xFFFFFFFF),

      // High contrast dividers
      dividerColor: const Color(0xFFFFFFFF),

      // Enhanced text theme
      textTheme: baseTheme.textTheme.copyWith(
        headlineLarge: baseTheme.textTheme.headlineLarge?.copyWith(
          color: const Color(0xFFFFFFFF),
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(
          color: const Color(0xFFFFFFFF),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 🎨 NEURAL THEME EXTENSION
extension NeuralThemeExtension on ThemeData {
  /// Ottieni colori neural
  Color get neuralPrimary => NeuronColors.primary;
  Color get neuralSecondary => NeuronColors.secondary;
  Color get neuralBackground => NeuronColors.background;

  /// Ottieni spacing
  double get spacingXS => NeuronSpacing.xs;
  double get spacingSM => NeuronSpacing.sm;
  double get spacingMD => NeuronSpacing.md;
  double get spacingLG => NeuronSpacing.lg;
  double get spacingXL => NeuronSpacing.xl;

  /// Ottieni radius
  double get radiusXS => NeuronRadius.xs;
  double get radiusSM => NeuronRadius.sm;
  double get radiusMD => NeuronRadius.md;
  double get radiusLG => NeuronRadius.lg;
  double get radiusXL => NeuronRadius.xl;

  /// Ottieni shadows
  List<BoxShadow> get shadowSubtle => NeuronShadows.subtle;
  List<BoxShadow> get shadowElevated => NeuronShadows.elevated;
  List<BoxShadow> get shadowNeural => NeuronShadows.neural;
}