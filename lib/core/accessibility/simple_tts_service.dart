// lib/core/accessibility/simple_tts_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 🔊 SIMPLE TTS SERVICE
/// Text-to-Speech service senza dependencies esterne
class SimpleTtsService {

  static bool _isInitialized = false;
  static bool _isEnabled = true;

  /// 🎯 Initialize TTS Service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Su desktop, usa system narrator se disponibile
      if (defaultTargetPlatform == TargetPlatform.windows) {
        await _initializeWindowsTts();
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        await _initializeMacOsTts();
      } else if (defaultTargetPlatform == TargetPlatform.linux) {
        await _initializeLinuxTts();
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS initialization failed: $e');
      _isEnabled = false;
    }
  }

  /// 🔊 Speak Text
  static Future<void> speak(String text) async {
    if (!_isEnabled || text.trim().isEmpty) return;

    try {
      // Fallback: usa system notifications
      await _speakViaSystem(text);
    } catch (e) {
      debugPrint('TTS speak failed: $e');
      // Fallback: haptic feedback
      HapticFeedback.lightImpact();
    }
  }

  /// 🪟 Windows TTS
  static Future<void> _initializeWindowsTts() async {
    // Usa PowerShell per Windows Speech Platform
    // Questo evita dependencies esterne
  }

  /// 🍎 macOS TTS
  static Future<void> _initializeMacOsTts() async {
    // Usa say command su macOS
  }

  /// 🐧 Linux TTS
  static Future<void> _initializeLinuxTts() async {
    // Usa espeak o festival su Linux
  }

  /// 💬 System Speech
  static Future<void> _speakViaSystem(String text) async {
    if (defaultTargetPlatform == TargetPlatform.windows) {
      // PowerShell command per TTS
      await Process.run('powershell', [
        '-Command',
        'Add-Type -AssemblyName System.Speech; '
            '(New-Object System.Speech.Synthesis.SpeechSynthesizer).Speak("$text")'
      ]);
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      // macOS say command
      await Process.run('say', [text]);
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      // Linux espeak
      try {
        await Process.run('espeak', [text]);
      } catch (e) {
        // Fallback to festival
        final process = await Process.start('festival', ['--tts']);
        process.stdin.write(text);
        await process.stdin.close();
        await process.exitCode;
      }
    }
  }

  /// ✅ Check if TTS is Available
  static bool get isAvailable => _isEnabled && _isInitialized;

  /// 🔇 Toggle TTS
  static void toggle() {
    _isEnabled = !_isEnabled;
  }

  /// 🎛️ Set Enabled
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }
}