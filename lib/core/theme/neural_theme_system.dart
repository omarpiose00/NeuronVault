// 🎨 NEURAL THEME SYSTEM - 6 LUXURY THEMES
// lib/core/theme/neural_theme_system.dart
// Revolutionary theme system with 6 distinct neural luxury experiences

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

/// 🌟 Neural Theme System - Master Controller
class NeuralThemeSystem {
  static final NeuralThemeSystem _instance = NeuralThemeSystem._internal();
  factory NeuralThemeSystem() => _instance;
  NeuralThemeSystem._internal();

  NeuralThemeData _currentTheme = NeuralThemeData.cosmos();

  NeuralThemeData get currentTheme => _currentTheme;

  void setTheme(NeuralThemeType themeType) {
    switch (themeType) {
      case NeuralThemeType.cosmos:
        _currentTheme = NeuralThemeData.cosmos();
        break;
      case NeuralThemeType.matrix:
        _currentTheme = NeuralThemeData.matrix();
        break;
      case NeuralThemeType.sunset:
        _currentTheme = NeuralThemeData.sunset();
        break;
      case NeuralThemeType.ocean:
        _currentTheme = NeuralThemeData.ocean();
        break;
      case NeuralThemeType.midnight:
        _currentTheme = NeuralThemeData.midnight();
        break;
      case NeuralThemeType.aurora:
        _currentTheme = NeuralThemeData.aurora();
        break;
    }
  }

  List<NeuralThemePreset> getAllThemes() {
    return [
      NeuralThemePreset(
        type: NeuralThemeType.cosmos,
        name: 'Cosmos',
        description: 'Deep space neural networks',
        icon: Icons.auto_awesome,
        previewColors: [
          const Color(0xFF6366F1),
          const Color(0xFF8B5CF6),
          const Color(0xFF3B82F6),
        ],
      ),
      NeuralThemePreset(
        type: NeuralThemeType.matrix,
        name: 'Matrix',
        description: 'Digital reality simulation',
        icon: Icons.code,
        previewColors: [
          const Color(0xFF10B981),
          const Color(0xFF34D399),
          const Color(0xFF059669),
        ],
      ),
      NeuralThemePreset(
        type: NeuralThemeType.sunset,
        name: 'Sunset',
        description: 'Warm neural symphony',
        icon: Icons.wb_sunny,
        previewColors: [
          const Color(0xFFF59E0B),
          const Color(0xFFEF4444),
          const Color(0xFFFB7185),
        ],
      ),
      NeuralThemePreset(
        type: NeuralThemeType.ocean,
        name: 'Ocean',
        description: 'Deep sea intelligence',
        icon: Icons.waves,
        previewColors: [
          const Color(0xFF0EA5E9),
          const Color(0xFF06B6D4),
          const Color(0xFF3B82F6),
        ],
      ),
      NeuralThemePreset(
        type: NeuralThemeType.midnight,
        name: 'Midnight',
        description: 'Dark neural elegance',
        icon: Icons.dark_mode,
        previewColors: [
          const Color(0xFF6366F1),
          const Color(0xFF1F2937),
          const Color(0xFF374151),
        ],
      ),
      NeuralThemePreset(
        type: NeuralThemeType.aurora,
        name: 'Aurora',
        description: 'Northern lights neural',
        icon: Icons.gradient,
        previewColors: [
          const Color(0xFF34D399),
          const Color(0xFF3B82F6),
          const Color(0xFFA855F7),
        ],
      ),
    ];
  }
}

/// 🎨 Neural Theme Types
enum NeuralThemeType {
  cosmos,
  matrix,
  sunset,
  ocean,
  midnight,
  aurora,
}

/// 🌟 Neural Theme Data - Complete Theme Definition
class NeuralThemeData {
  final String name;
  final NeuralThemeType type;
  final NeuralColorPalette colors;
  final NeuralGradients gradients;
  final NeuralParticleConfig particleConfig;
  final NeuralAnimationConfig animationConfig;

  NeuralThemeData({
    required this.name,
    required this.type,
    required this.colors,
    required this.gradients,
    required this.particleConfig,
    required this.animationConfig,
  });

  /// 🌌 Cosmos Theme - Deep Space Neural Networks
  factory NeuralThemeData.cosmos() {
    return NeuralThemeData(
      name: 'Cosmos',
      type: NeuralThemeType.cosmos,
      colors: NeuralColorPalette(
        primary: const Color(0xFF6366F1),
        secondary: const Color(0xFF8B5CF6),
        accent: const Color(0xFF3B82F6),
        background: const Color(0xFF0F0F23),
        surface: const Color(0xFF1A1B35),
        onSurface: const Color(0xFFE2E8F0),
        neuralGlow: const Color(0xFF6366F1),
        connectionActive: const Color(0xFF10B981),
        connectionInactive: const Color(0xFF6B7280),
        particleNeuron: const Color(0xFF6366F1),
        particleSynapse: const Color(0xFF8B5CF6),
        particleData: const Color(0xFF3B82F6),
      ),
      gradients: NeuralGradients(
        background: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F0F23),
            Color(0xFF1A1B35),
            Color(0xFF0F0F23),
          ],
        ),
        neuralFlow: const LinearGradient(
          colors: [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
            Color(0xFF3B82F6),
          ],
        ),
        panel: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x40191A35),
            Color(0x20191A35),
          ],
        ),
      ),
      particleConfig: NeuralParticleConfig(
        density: 1.0,
        speed: 1.0,
        connectionOpacity: 0.3,
        glowIntensity: 0.8,
        pulseBehavior: NeuralPulseBehavior.cosmic,
      ),
      animationConfig: NeuralAnimationConfig(
        transitionDuration: const Duration(milliseconds: 800),
        pulseSpeed: 2.0,
        flowSpeed: 1.0,
      ),
    );
  }

  /// 🔋 Matrix Theme - Digital Reality Simulation
  factory NeuralThemeData.matrix() {
    return NeuralThemeData(
      name: 'Matrix',
      type: NeuralThemeType.matrix,
      colors: NeuralColorPalette(
        primary: const Color(0xFF10B981),
        secondary: const Color(0xFF34D399),
        accent: const Color(0xFF059669),
        background: const Color(0xFF000000),
        surface: const Color(0xFF0D1117),
        onSurface: const Color(0xFF00FF41),
        neuralGlow: const Color(0xFF10B981),
        connectionActive: const Color(0xFF34D399),
        connectionInactive: const Color(0xFF1F2937),
        particleNeuron: const Color(0xFF10B981),
        particleSynapse: const Color(0xFF34D399),
        particleData: const Color(0xFF00FF41),
      ),
      gradients: NeuralGradients(
        background: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF000000),
            Color(0xFF0D1117),
            Color(0xFF000000),
          ],
        ),
        neuralFlow: const LinearGradient(
          colors: [
            Color(0xFF10B981),
            Color(0xFF34D399),
            Color(0xFF00FF41),
          ],
        ),
        panel: const LinearGradient(
          colors: [
            Color(0x40001100),
            Color(0x20001100),
          ],
        ),
      ),
      particleConfig: NeuralParticleConfig(
        density: 1.2,
        speed: 1.5,
        connectionOpacity: 0.4,
        glowIntensity: 1.0,
        pulseBehavior: NeuralPulseBehavior.digital,
      ),
      animationConfig: NeuralAnimationConfig(
        transitionDuration: const Duration(milliseconds: 600),
        pulseSpeed: 3.0,
        flowSpeed: 2.0,
      ),
    );
  }

  /// 🌅 Sunset Theme - Warm Neural Symphony
  factory NeuralThemeData.sunset() {
    return NeuralThemeData(
      name: 'Sunset',
      type: NeuralThemeType.sunset,
      colors: NeuralColorPalette(
        primary: const Color(0xFFF59E0B),
        secondary: const Color(0xFFEF4444),
        accent: const Color(0xFFFB7185),
        background: const Color(0xFF1F1611),
        surface: const Color(0xFF2D1B1A),
        onSurface: const Color(0xFFFED7AA),
        neuralGlow: const Color(0xFFF59E0B),
        connectionActive: const Color(0xFFEF4444),
        connectionInactive: const Color(0xFF92400E),
        particleNeuron: const Color(0xFFF59E0B),
        particleSynapse: const Color(0xFFEF4444),
        particleData: const Color(0xFFFB7185),
      ),
      gradients: NeuralGradients(
        background: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF1F1611),
            Color(0xFF2D1B1A),
            Color(0xFF1F1611),
          ],
        ),
        neuralFlow: const LinearGradient(
          colors: [
            Color(0xFFF59E0B),
            Color(0xFFEF4444),
            Color(0xFFFB7185),
          ],
        ),
        panel: const LinearGradient(
          colors: [
            Color(0x40331100),
            Color(0x20331100),
          ],
        ),
      ),
      particleConfig: NeuralParticleConfig(
        density: 0.8,
        speed: 0.8,
        connectionOpacity: 0.35,
        glowIntensity: 0.9,
        pulseBehavior: NeuralPulseBehavior.warm,
      ),
      animationConfig: NeuralAnimationConfig(
        transitionDuration: const Duration(milliseconds: 1000),
        pulseSpeed: 1.5,
        flowSpeed: 0.8,
      ),
    );
  }

  /// 🌊 Ocean Theme - Deep Sea Intelligence
  factory NeuralThemeData.ocean() {
    return NeuralThemeData(
      name: 'Ocean',
      type: NeuralThemeType.ocean,
      colors: NeuralColorPalette(
        primary: const Color(0xFF0EA5E9),
        secondary: const Color(0xFF06B6D4),
        accent: const Color(0xFF3B82F6),
        background: const Color(0xFF0C1526),
        surface: const Color(0xFF1E2A3A),
        onSurface: const Color(0xFFBAE6FD),
        neuralGlow: const Color(0xFF0EA5E9),
        connectionActive: const Color(0xFF06B6D4),
        connectionInactive: const Color(0xFF1E40AF),
        particleNeuron: const Color(0xFF0EA5E9),
        particleSynapse: const Color(0xFF06B6D4),
        particleData: const Color(0xFF3B82F6),
      ),
      gradients: NeuralGradients(
        background: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0C1526),
            Color(0xFF1E2A3A),
            Color(0xFF0C1526),
          ],
        ),
        neuralFlow: const LinearGradient(
          colors: [
            Color(0xFF0EA5E9),
            Color(0xFF06B6D4),
            Color(0xFF3B82F6),
          ],
        ),
        panel: const LinearGradient(
          colors: [
            Color(0x40002244),
            Color(0x20002244),
          ],
        ),
      ),
      particleConfig: NeuralParticleConfig(
        density: 0.9,
        speed: 0.7,
        connectionOpacity: 0.4,
        glowIntensity: 0.7,
        pulseBehavior: NeuralPulseBehavior.fluid,
      ),
      animationConfig: NeuralAnimationConfig(
        transitionDuration: const Duration(milliseconds: 1200),
        pulseSpeed: 1.2,
        flowSpeed: 0.6,
      ),
    );
  }

  /// 🌙 Midnight Theme - Dark Neural Elegance
  factory NeuralThemeData.midnight() {
    return NeuralThemeData(
      name: 'Midnight',
      type: NeuralThemeType.midnight,
      colors: NeuralColorPalette(
        primary: const Color(0xFF6366F1),
        secondary: const Color(0xFF1F2937),
        accent: const Color(0xFF374151),
        background: const Color(0xFF000000),
        surface: const Color(0xFF111827),
        onSurface: const Color(0xFFF9FAFB),
        neuralGlow: const Color(0xFF6366F1),
        connectionActive: const Color(0xFF9CA3AF),
        connectionInactive: const Color(0xFF374151),
        particleNeuron: const Color(0xFF6366F1),
        particleSynapse: const Color(0xFF9CA3AF),
        particleData: const Color(0xFF374151),
      ),
      gradients: NeuralGradients(
        background: const LinearGradient(
          colors: [
            Color(0xFF000000),
            Color(0xFF111827),
          ],
        ),
        neuralFlow: const LinearGradient(
          colors: [
            Color(0xFF6366F1),
            Color(0xFF9CA3AF),
            Color(0xFF374151),
          ],
        ),
        panel: const LinearGradient(
          colors: [
            Color(0x40111827),
            Color(0x20111827),
          ],
        ),
      ),
      particleConfig: NeuralParticleConfig(
        density: 0.6,
        speed: 0.5,
        connectionOpacity: 0.2,
        glowIntensity: 0.6,
        pulseBehavior: NeuralPulseBehavior.subtle,
      ),
      animationConfig: NeuralAnimationConfig(
        transitionDuration: const Duration(milliseconds: 1000),
        pulseSpeed: 1.0,
        flowSpeed: 0.5,
      ),
    );
  }

  /// 🌈 Aurora Theme - Northern Lights Neural
  factory NeuralThemeData.aurora() {
    return NeuralThemeData(
      name: 'Aurora',
      type: NeuralThemeType.aurora,
      colors: NeuralColorPalette(
        primary: const Color(0xFF34D399),
        secondary: const Color(0xFF3B82F6),
        accent: const Color(0xFFA855F7),
        background: const Color(0xFF0F1419),
        surface: const Color(0xFF1A202C),
        onSurface: const Color(0xFFE2E8F0),
        neuralGlow: const Color(0xFF34D399),
        connectionActive: const Color(0xFF3B82F6),
        connectionInactive: const Color(0xFF4A5568),
        particleNeuron: const Color(0xFF34D399),
        particleSynapse: const Color(0xFF3B82F6),
        particleData: const Color(0xFFA855F7),
      ),
      gradients: NeuralGradients(
        background: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F1419),
            Color(0xFF1A202C),
            Color(0xFF0F1419),
          ],
        ),
        neuralFlow: const LinearGradient(
          colors: [
            Color(0xFF34D399),
            Color(0xFF3B82F6),
            Color(0xFFA855F7),
          ],
        ),
        panel: const LinearGradient(
          colors: [
            Color(0x401A202C),
            Color(0x201A202C),
          ],
        ),
      ),
      particleConfig: NeuralParticleConfig(
        density: 1.1,
        speed: 1.3,
        connectionOpacity: 0.45,
        glowIntensity: 1.2,
        pulseBehavior: NeuralPulseBehavior.aurora,
      ),
      animationConfig: NeuralAnimationConfig(
        transitionDuration: const Duration(milliseconds: 900),
        pulseSpeed: 2.5,
        flowSpeed: 1.5,
      ),
    );
  }
}

/// 🎨 Neural Color Palette
class NeuralColorPalette {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color onSurface;
  final Color neuralGlow;
  final Color connectionActive;
  final Color connectionInactive;
  final Color particleNeuron;
  final Color particleSynapse;
  final Color particleData;

  NeuralColorPalette({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.onSurface,
    required this.neuralGlow,
    required this.connectionActive,
    required this.connectionInactive,
    required this.particleNeuron,
    required this.particleSynapse,
    required this.particleData,
  });
}

/// 🌈 Neural Gradients
class NeuralGradients {
  final LinearGradient background;
  final LinearGradient neuralFlow;
  final LinearGradient panel;

  NeuralGradients({
    required this.background,
    required this.neuralFlow,
    required this.panel,
  });
}

/// ⚙️ Neural Particle Configuration
class NeuralParticleConfig {
  final double density;
  final double speed;
  final double connectionOpacity;
  final double glowIntensity;
  final NeuralPulseBehavior pulseBehavior;

  NeuralParticleConfig({
    required this.density,
    required this.speed,
    required this.connectionOpacity,
    required this.glowIntensity,
    required this.pulseBehavior,
  });
}

/// 💫 Neural Pulse Behaviors
enum NeuralPulseBehavior {
  cosmic,    // Slow, deep space pulsing
  digital,   // Fast, matrix-like pulses
  warm,      // Gentle, sunset waves
  fluid,     // Ocean-like flowing
  subtle,    // Minimal, elegant
  aurora,    // Dynamic, northern lights
}

/// ⚡ Neural Animation Configuration
class NeuralAnimationConfig {
  final Duration transitionDuration;
  final double pulseSpeed;
  final double flowSpeed;

  NeuralAnimationConfig({
    required this.transitionDuration,
    required this.pulseSpeed,
    required this.flowSpeed,
  });
}

/// 🎨 Neural Theme Preset for UI
class NeuralThemePreset {
  final NeuralThemeType type;
  final String name;
  final String description;
  final IconData icon;
  final List<Color> previewColors;

  NeuralThemePreset({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.previewColors,
  });
}