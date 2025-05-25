// lib/core/design_system.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🎨 NEURON VAULT DESIGN SYSTEM
/// Sistema di design moderno per l'app NeuronVault
class NeuralDesignSystem {
  // 🌈 PRIMARY GRADIENT
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF6366F1), // Indigo-500
      Color(0xFF8B5CF6), // Violet-500
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🌈 SECONDARY GRADIENT
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [
      Color(0xFF10B981), // Emerald-500
      Color(0xFF06B6D4), // Cyan-500
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🌈 ACCENT GRADIENT
  static const LinearGradient accentGradient = LinearGradient(
    colors: [
      Color(0xFFF59E0B), // Amber-500
      Color(0xFFEF4444), // Red-500
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// 📊 DESIGN SYSTEM DATA
/// Contenitore immutabile per tutti i dati del design system
class DesignSystemData {
  final NeuronColors colors;
  final NeuronTypography typography;
  final NeuronSpacing spacing;
  final NeuronEffects effects;
  final bool isDarkMode;
  final bool isHighContrast;

  const DesignSystemData({
    required this.colors,
    required this.typography,
    required this.spacing,
    required this.effects,
    required this.isDarkMode,
    required this.isHighContrast,
  });

  /// 🎨 Create copy with modifications
  DesignSystemData copyWith({
    NeuronColors? colors,
    NeuronTypography? typography,
    NeuronSpacing? spacing,
    NeuronEffects? effects,
    bool? isDarkMode,
    bool? isHighContrast,
  }) {
    return DesignSystemData(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      spacing: spacing ?? this.spacing,
      effects: effects ?? this.effects,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isHighContrast: isHighContrast ?? this.isHighContrast,
    );
  }
}

/// 🎨 NEURON COLORS
/// Palette colori moderna per NeuronVault
class NeuronColors {
  final ColorScheme colorScheme;
  final Color neuralPrimary;
  final Color neuralSecondary;
  final Color neuralAccent;
  final Color connectionGreen;
  final Color connectionRed;
  final Color connectionOrange;
  final Color aiProcessing;
  final Color tokenWarning;
  final Color tokenDanger;

  const NeuronColors({
    required this.colorScheme,
    required this.neuralPrimary,
    required this.neuralSecondary,
    required this.neuralAccent,
    required this.connectionGreen,
    required this.connectionRed,
    required this.connectionOrange,
    required this.aiProcessing,
    required this.tokenWarning,
    required this.tokenDanger,
  });

  /// 🌟 Standard Color Palette
  static const NeuronColors standard = NeuronColors(
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF6366F1), // Indigo
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFF10B981), // Emerald
      onSecondary: Color(0xFFFFFFFF),
      tertiary: Color(0xFFF59E0B), // Amber
      onTertiary: Color(0xFF000000),
      surface: Color(0xFF111827), // Gray-900
      onSurface: Color(0xFFF9FAFB), // Gray-50
      surfaceContainer: Color(0xFF1F2937), // Gray-800
      outline: Color(0xFF6B7280), // Gray-500
      error: Color(0xFFEF4444), // Red-500
      onError: Color(0xFFFFFFFF),
    ),
    neuralPrimary: Color(0xFF6366F1),
    neuralSecondary: Color(0xFF8B5CF6),
    neuralAccent: Color(0xFF06B6D4),
    connectionGreen: Color(0xFF10B981),
    connectionRed: Color(0xFFEF4444),
    connectionOrange: Color(0xFFF59E0B),
    aiProcessing: Color(0xFF8B5CF6),
    tokenWarning: Color(0xFFF59E0B),
    tokenDanger: Color(0xFFEF4444),
  );

  /// 🔆 High Contrast Color Palette
  static const NeuronColors highContrast = NeuronColors(
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF7C3AED), // More vibrant purple
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFF059669), // Darker green
      onSecondary: Color(0xFFFFFFFF),
      tertiary: Color(0xFFD97706), // Darker amber
      onTertiary: Color(0xFFFFFFFF),
      surface: Color(0xFF000000), // Pure black
      onSurface: Color(0xFFFFFFFF), // Pure white
      surfaceContainer: Color(0xFF1F1F1F), // Dark gray
      outline: Color(0xFF888888), // Medium gray
      error: Color(0xFFDC2626), // Darker red
      onError: Color(0xFFFFFFFF),
    ),
    neuralPrimary: Color(0xFF7C3AED),
    neuralSecondary: Color(0xFF9333EA),
    neuralAccent: Color(0xFF0891B2),
    connectionGreen: Color(0xFF059669),
    connectionRed: Color(0xFFDC2626),
    connectionOrange: Color(0xFFD97706),
    aiProcessing: Color(0xFF9333EA),
    tokenWarning: Color(0xFFD97706),
    tokenDanger: Color(0xFFDC2626),
  );
}

/// ✏️ NEURON TYPOGRAPHY
/// Sistema tipografico moderno con Google Fonts
class NeuronTypography {
  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle body1;
  final TextStyle body2;
  final TextStyle caption;
  final TextStyle button;
  final TextStyle mono;

  const NeuronTypography({
    required this.h1,
    required this.h2,
    required this.h3,
    required this.body1,
    required this.body2,
    required this.caption,
    required this.button,
    required this.mono,
  });

  /// 📝 Standard Typography con Google Fonts
  static NeuronTypography get standard => NeuronTypography(
    h1: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    h2: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
      height: 1.3,
    ),
    h3: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.4,
    ),
    body1: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.1,
      height: 1.5,
    ),
    body2: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
      height: 1.4,
    ),
    caption: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.3,
    ),
    button: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      height: 1.2,
    ),
    mono: GoogleFonts.jetBrainsMono(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.4,
    ),
  );
}

/// 📏 NEURON SPACING
/// Sistema di spaziature coerente
class NeuronSpacing {
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;

  const NeuronSpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
  });

  /// 📐 Standard Spacing
  static const NeuronSpacing standard = NeuronSpacing(
    xs: 4.0,
    sm: 8.0,
    md: 16.0,
    lg: 24.0,
    xl: 32.0,
    xxl: 48.0,
  );
}

/// ✨ NEURON EFFECTS
/// Effetti visuali moderni
class NeuronEffects {
  final BoxShadow cardShadow;
  final BoxShadow glowShadow;
  final BorderRadius borderRadius;
  final BorderRadius cardRadius;
  final Duration animationDuration;
  final Duration fastAnimation;
  final Duration slowAnimation;

  const NeuronEffects({
    required this.cardShadow,
    required this.glowShadow,
    required this.borderRadius,
    required this.cardRadius,
    required this.animationDuration,
    required this.fastAnimation,
    required this.slowAnimation,
  });

  /// 🌟 Standard Effects
  static const NeuronEffects standard = NeuronEffects(
    cardShadow: BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
    glowShadow: BoxShadow(
      color: Color(0x336366F1),
      blurRadius: 20,
      spreadRadius: 2,
    ),
    borderRadius: BorderRadius.all(Radius.circular(8)),
    cardRadius: BorderRadius.all(Radius.circular(12)),
    animationDuration: Duration(milliseconds: 300),
    fastAnimation: Duration(milliseconds: 150),
    slowAnimation: Duration(milliseconds: 500),
  );
}

/// 🎛️ DESIGN SYSTEM MANAGER
class DesignSystem {
  static DesignSystem? _instance;
  static DesignSystem get instance => _instance ??= DesignSystem._();
  DesignSystem._();

  // Theme Mode
  bool _isDarkMode = true;
  bool _isHighContrast = false;

  bool get isDarkMode => _isDarkMode;
  bool get isHighContrast => _isHighContrast;

  /// 🎯 Get Current Design System Data
  DesignSystemData get current => DesignSystemData(
    colors: _isHighContrast ? NeuronColors.highContrast : NeuronColors.standard,
    typography: NeuronTypography.standard,
    spacing: NeuronSpacing.standard,
    effects: NeuronEffects.standard,
    isDarkMode: _isDarkMode,
    isHighContrast: _isHighContrast,
  );

  /// 🔄 Toggle Dark Mode
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
  }

  /// 🔄 Toggle High Contrast
  void toggleHighContrast() {
    _isHighContrast = !_isHighContrast;
    HapticFeedback.selectionClick();
  }

  /// 🎨 Get Theme Data
  ThemeData get themeData => _buildThemeData();

  ThemeData _buildThemeData() {
    final colorScheme = _isHighContrast
        ? NeuronColors.highContrast.colorScheme
        : NeuronColors.standard.colorScheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(),
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

/// 📱 DESIGN SYSTEM EXTENSION
/// Extension per accesso facile al design system
extension DesignSystemExtension on BuildContext {
  DesignSystemData get ds => DesignSystem.instance.current;
}