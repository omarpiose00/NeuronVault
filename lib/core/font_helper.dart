// lib/core/font_helper.dart - VERSIONE SEMPLIFICATA SENZA GOOGLE FONTS
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

/// 🔤 FONT HELPER - Utility per gestione fonts senza dipendenze esterne
class FontHelper {
  /// Sistema di font utilizzati nell'app
  static const String primaryFont = 'Inter';
  static const String codeFont = 'JetBrains Mono';
  static const String fallbackFont = 'Roboto';

  /// Verifica se il font è disponibile
  static bool isFontAvailable(String fontFamily) {
    // Semplice check per i font che sappiamo essere disponibili
    switch (fontFamily) {
      case 'Inter':
      case 'JetBrains Mono':
      case 'Roboto':
      case 'Material Icons':
        return true;
      default:
        return false;
    }
  }

  /// Ottieni il font migliore disponibile
  static String getBestAvailableFont({bool isCode = false}) {
    if (isCode) {
      return isFontAvailable(codeFont) ? codeFont : fallbackFont;
    }
    return isFontAvailable(primaryFont) ? primaryFont : fallbackFont;
  }

  /// Text styles ottimizzati per accessibility
  static TextStyle getAccessibleTextStyle(TextStyle baseStyle) {
    return baseStyle.copyWith(
      // Garantisce contrasto minimo WCAG AA
      color: baseStyle.color ?? NeuronColors.onSurface,
      fontWeight: FontWeight.w500, // Migliora leggibilità
      letterSpacing: 0.5, // Migliora spaziatura per dyslexic users
    );
  }

  /// Typography styles con fallback
  static TextStyle get headlineLarge => TextStyle(
    fontFamily: getBestAvailableFont(),
    fontSize: 32,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: NeuronColors.onSurface,
  );

  static TextStyle get headlineMedium => TextStyle(
    fontFamily: getBestAvailableFont(),
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: NeuronColors.onSurface,
  );

  static TextStyle get headlineSmall => TextStyle(
    fontFamily: getBestAvailableFont(),
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: NeuronColors.onSurface,
  );

  static TextStyle get titleLarge => TextStyle(
    fontFamily: getBestAvailableFont(),
    fontSize: 22,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: NeuronColors.onSurface,
  );

  static TextStyle get titleMedium => TextStyle(
    fontFamily: getBestAvailableFont(),
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    color: NeuronColors.onSurface,
  );

  static TextStyle get titleSmall => TextStyle(
    fontFamily: getBestAvailableFont(),
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: NeuronColors.onSurface,
  );

  static TextStyle get bodyLarge => TextStyle(
    fontFamily: getBestAvailableFont(),
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: NeuronColors.onSurface,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: getBestAvailableFont(),
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: NeuronColors.onSurface,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: getBestAvailableFont(),
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: NeuronColors.onSurface,
  );

  static TextStyle get labelLarge => TextStyle(
    fontFamily: getBestAvailableFont(),
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: NeuronColors.onSurface,
  );

  static TextStyle get labelMedium => TextStyle(
    fontFamily: getBestAvailableFont(),
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: NeuronColors.onSurface,
  );

  static TextStyle get labelSmall => TextStyle(
    fontFamily: getBestAvailableFont(),
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: NeuronColors.onSurface,
  );

  /// Code text style
  static TextStyle get codeText => TextStyle(
    fontFamily: getBestAvailableFont(isCode: true),
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: NeuronColors.onSurface,
  );

  /// Text styles con colori specifici per context
  static TextStyle get primaryText => bodyLarge.copyWith(
    color: NeuronColors.primary,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get secondaryText => bodyMedium.copyWith(
    color: NeuronColors.secondary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get errorText => bodyMedium.copyWith(
    color: NeuronColors.error,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get successText => bodyMedium.copyWith(
    color: NeuronColors.aiGreen,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get warningText => bodyMedium.copyWith(
    color: NeuronColors.warning,
    fontWeight: FontWeight.w500,
  );
}