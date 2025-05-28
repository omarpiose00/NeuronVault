// lib/core/theme/app_theme.dart - SISTEMA TEMA UNIFICATO CON CLASSI COMPLETE
import 'package:flutter/material.dart';

/// 🎨 NEURON VAULT THEME SYSTEM - Sistema completo unificato
class AppTheme {
  static ThemeData getTheme(String currentTheme, bool isDarkMode) {
    // Personalizza la logica in base ai tuoi temi
    if (isDarkMode) {
      return ThemeData.dark();
    } else {
      return ThemeData.light();
    }
  }
}
class NeuronVaultTheme {
  static ThemeData get lightTheme => _buildLightTheme();
  static ThemeData get darkTheme => _buildDarkTheme();

  static ThemeData _buildLightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: NeuronColors.primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Inter',
      textTheme: NeuronTypography.textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: NeuronColors.primary, width: 2.0),
        ),
      ),
    );
  }

  static ThemeData _buildDarkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: NeuronColors.primary,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Inter',
      textTheme: NeuronTypography.textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

/// 🎨 NEURON COLORS - Palette completa
class NeuronColors {
  // Impedisce istanziazione
  NeuronColors._();

  // Primary Neural Purple
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryVariant = Color(0xFF4F46E5);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Secondary Vault Gold
  static const Color secondary = Color(0xFFD97757);
  static const Color secondaryVariant = Color(0xFFB85C3A);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Surface Colors
  static const Color surface = Color(0xFFFAFAFA);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color onSurface = Color(0xFF1F2937);
  static const Color onSurfaceVariant = Color(0xFF6B7280);

  // Background
  static const Color background = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF1F2937);

  // Utility
  static const Color error = Color(0xFFEF4444);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color outline = Color(0xFFE5E7EB);
  static const Color shadow = Color(0x1A000000);

  // Special Neural Colors
  static const Color brainBlue = Color(0xFF3B82F6);
  static const Color aiGreen = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
}

/// ✏️ NEURON TYPOGRAPHY - Sistema tipografico completo
class NeuronTypography {
  // Impedisce istanziazione
  NeuronTypography._();

  static const TextTheme textTheme = TextTheme(
    // Headlines
    headlineLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: NeuronColors.onSurface,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 28,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: NeuronColors.onSurface,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 24,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: NeuronColors.onSurface,
    ),

    // Titles
    titleLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 22,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: NeuronColors.onSurface,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: NeuronColors.onSurface,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: NeuronColors.onSurface,
    ),

    // Body
    bodyLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: NeuronColors.onSurface,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: NeuronColors.onSurface,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: NeuronColors.onSurface,
    ),

    // Labels
    labelLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: NeuronColors.onSurface,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: NeuronColors.onSurface,
    ),
    labelSmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: NeuronColors.onSurface,
    ),
  );
}

/// 📏 NEURON SPACING - Sistema di spaziatura
class NeuronSpacing {
  // Impedisce istanziazione
  NeuronSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// 🔘 NEURON RADIUS - Sistema border radius
class NeuronRadius {
  // Impedisce istanziazione
  NeuronRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double pill = 1000.0;
}

/// 🌟 NEURON SHADOWS - Sistema di ombre
class NeuronShadows {
  // Impedisce istanziazione
  NeuronShadows._();

  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> neural = [
    BoxShadow(
      color: Color(0x336366F1),
      blurRadius: 20,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];
}

/// 📱 NEURON BREAKPOINTS - Sistema responsive
class NeuronBreakpoints {
  // Impedisce istanziazione
  NeuronBreakpoints._();

  static const double mobile = 576;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double wide = 1440;
  static const double ultraWide = 1920;
  static const double max = 2560;
}

/// ⏱️ NEURON DURATIONS - Sistema animazioni
class NeuronDurations {
  // Impedisce istanziazione
  NeuronDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}