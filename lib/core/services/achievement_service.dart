// 🏆 NEURONVAULT ACHIEVEMENT SERVICE
// lib/core/services/achievement_service.dart
// Enterprise-grade achievement system with neural luxury integration

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../state/state_models.dart'; // Contains Achievement models

/// 🏆 Achievement Service - Manages all achievement logic
class AchievementService extends ChangeNotifier {
  final SharedPreferences _prefs;
  final Logger _logger;

  static const String _storageKey = 'neuronvault_achievements';
  static const String _progressKey = 'neuronvault_achievement_progress';

  AchievementState _state = const AchievementState();
  final StreamController<AchievementNotification> _notificationController =
  StreamController<AchievementNotification>.broadcast();

  AchievementService({
    required SharedPreferences prefs,
    required Logger logger,
  }) : _prefs = prefs, _logger = logger {
    _initializeAchievements();
  }

  // 📊 Getters
  AchievementState get state => _state;
  Stream<AchievementNotification> get notificationStream => _notificationController.stream;

  /// 🚀 Initialize achievement system with predefined achievements
  Future<void> _initializeAchievements() async {
    try {
      _logger.i('🏆 Initializing Achievement System...');

      // Load saved state
      await _loadState();

      // Initialize predefined achievements if first run
      if (_state.achievements.isEmpty) {
        await _createDefaultAchievements();
      }

      // Update stats
      await _updateStats();

      _state = _state.copyWith(isInitialized: true);
      notifyListeners();

      _logger.i('✅ Achievement System initialized with ${_state.achievements.length} achievements');
    } catch (e) {
      _logger.e('❌ Failed to initialize Achievement System: $e');
    }
  }

  /// 📝 Create default neural luxury achievements
  Future<void> _createDefaultAchievements() async {
    final achievements = <String, Achievement>{};

    // 🚀 3D PARTICLE ACHIEVEMENTS
    achievements['first_particle_view'] = const Achievement(
      id: 'first_particle_view',
      title: 'Neural Awakening',
      description: 'Witnessed your first 3D neural particle system',
      category: AchievementCategory.particles,
      rarity: AchievementRarity.common,
      targetProgress: 1,
    );

    achievements['particle_interaction'] = const Achievement(
      id: 'particle_interaction',
      title: 'Particle Whisperer',
      description: 'Interacted with neural particles 50 times',
      category: AchievementCategory.particles,
      rarity: AchievementRarity.rare,
      targetProgress: 50,
    );

    achievements['all_particle_types'] = const Achievement(
      id: 'all_particle_types',
      title: 'Neural Architect',
      description: 'Experienced all 5 particle types (Neuron, Synapse, Electrical, Quantum, Data)',
      category: AchievementCategory.particles,
      rarity: AchievementRarity.epic,
      targetProgress: 5,
    );

    // 🧠 AI ORCHESTRATION ACHIEVEMENTS
    achievements['first_orchestration'] = const Achievement(
      id: 'first_orchestration',
      title: 'First Synthesis',
      description: 'Completed your first AI orchestration request',
      category: AchievementCategory.orchestration,
      rarity: AchievementRarity.common,
      targetProgress: 1,
    );

    achievements['multi_model_master'] = const Achievement(
      id: 'multi_model_master',
      title: 'AI Conductor',
      description: 'Used all 7 AI models successfully',
      category: AchievementCategory.orchestration,
      rarity: AchievementRarity.epic,
      targetProgress: 7,
    );

    achievements['strategy_explorer'] = const Achievement(
      id: 'strategy_explorer',
      title: 'Strategy Master',
      description: 'Tried all orchestration strategies',
      category: AchievementCategory.orchestration,
      rarity: AchievementRarity.rare,
      targetProgress: 6, // parallel, consensus, adaptive, sequential, cascade, weighted
    );

    achievements['orchestration_marathon'] = const Achievement(
      id: 'orchestration_marathon',
      title: 'Neural Marathon',
      description: 'Completed 100 orchestrations',
      category: AchievementCategory.orchestration,
      rarity: AchievementRarity.legendary,
      targetProgress: 100,
    );

    // 🎨 THEME ACHIEVEMENTS (6 themes)
    final themeNames = ['cosmos', 'matrix', 'sunset', 'ocean', 'midnight', 'aurora'];
    for (final theme in themeNames) {
      achievements['theme_$theme'] = Achievement(
        id: 'theme_$theme',
        title: '${theme.substring(0, 1).toUpperCase()}${theme.substring(1)} Explorer',
        description: 'Activated the $theme neural theme',
        category: AchievementCategory.themes,
        rarity: AchievementRarity.common,
        targetProgress: 1,
      );
    }

    achievements['theme_collector'] = const Achievement(
      id: 'theme_collector',
      title: 'Theme Master',
      description: 'Unlocked all 6 neural luxury themes',
      category: AchievementCategory.themes,
      rarity: AchievementRarity.legendary,
      targetProgress: 6,
    );

    achievements['theme_switcher'] = const Achievement(
      id: 'theme_switcher',
      title: 'Visual Shapeshifter',
      description: 'Changed themes 10 times in a session',
      category: AchievementCategory.themes,
      rarity: AchievementRarity.rare,
      targetProgress: 10,
    );

    // 🔊 SPATIAL AUDIO ACHIEVEMENTS
    achievements['audio_activation'] = const Achievement(
      id: 'audio_activation',
      title: 'Sound Pioneer',
      description: 'Activated spatial 3D audio system',
      category: AchievementCategory.audio,
      rarity: AchievementRarity.common,
      targetProgress: 1,
    );

    achievements['audio_customization'] = const Achievement(
      id: 'audio_customization',
      title: 'Audio Architect',
      description: 'Customized all 7 neural sound types',
      category: AchievementCategory.audio,
      rarity: AchievementRarity.epic,
      targetProgress: 7,
    );

    achievements['haptic_master'] = const Achievement(
      id: 'haptic_master',
      title: 'Haptic Master',
      description: 'Experienced 50 haptic feedback events',
      category: AchievementCategory.audio,
      rarity: AchievementRarity.rare,
      targetProgress: 50,
    );

    // 📊 MODEL PROFILING ACHIEVEMENTS
    achievements['profiling_first_use'] = const Achievement(
      id: 'profiling_first_use',
      title: 'Data Explorer',
      description: 'Opened the Model Profiling Dashboard',
      category: AchievementCategory.profiling,
      rarity: AchievementRarity.common,
      targetProgress: 1,
    );

    achievements['profiling_expert'] = const Achievement(
      id: 'profiling_expert',
      title: 'Profiling Expert',
      description: 'Analyzed performance metrics for all models',
      category: AchievementCategory.profiling,
      rarity: AchievementRarity.epic,
      targetProgress: 7,
    );

    // 🌟 EXPLORATION ACHIEVEMENTS
    achievements['feature_explorer'] = const Achievement(
      id: 'feature_explorer',
      title: 'Feature Explorer',
      description: 'Used all 4 revolutionary features (Particles, Profiling, Audio, Themes)',
      category: AchievementCategory.exploration,
      rarity: AchievementRarity.legendary,
      targetProgress: 4,
    );

    achievements['speed_demon'] = const Achievement(
      id: 'speed_demon',
      title: 'Speed Demon',
      description: 'Maintained 60 FPS for 10 minutes straight',
      category: AchievementCategory.exploration,
      rarity: AchievementRarity.epic,
      targetProgress: 600, // 600 seconds = 10 minutes
      isHidden: true,
    );

    achievements['daily_user'] = const Achievement(
      id: 'daily_user',
      title: 'Neural Devotee',
      description: 'Used NeuronVault for 7 consecutive days',
      category: AchievementCategory.exploration,
      rarity: AchievementRarity.legendary,
      targetProgress: 7,
      isHidden: true,
    );

    _state = _state.copyWith(achievements: achievements);
    await _saveState();
  }

  /// 🎯 Track achievement progress
  Future<void> trackProgress(String achievementId, {int increment = 1, Map<String, dynamic>? data}) async {
    if (!_state.achievements.containsKey(achievementId)) {
      _logger.w('⚠️ Achievement not found: $achievementId');
      return;
    }

    final achievement = _state.achievements[achievementId]!;
    if (achievement.isUnlocked) return; // Already unlocked

    final currentProgress = _state.progress[achievementId] ??
        AchievementProgress(achievementId: achievementId, targetValue: achievement.targetProgress);

    final newProgress = currentProgress.copyWith(
      currentValue: (currentProgress.currentValue + increment).clamp(0, achievement.targetProgress),
      lastUpdated: DateTime.now(),
      progressData: data ?? currentProgress.progressData,
    );

    // Update progress
    final newProgressMap = Map<String, AchievementProgress>.from(_state.progress);
    newProgressMap[achievementId] = newProgress;

    // Update achievement current progress
    final updatedAchievement = achievement.copyWith(currentProgress: newProgress.currentValue);
    final newAchievements = Map<String, Achievement>.from(_state.achievements);
    newAchievements[achievementId] = updatedAchievement;

    _state = _state.copyWith(
      progress: newProgressMap,
      achievements: newAchievements,
    );

    // Check if achievement is now unlocked
    if (newProgress.currentValue >= achievement.targetProgress && !achievement.isUnlocked) {
      await _unlockAchievement(achievementId);
    }

    await _saveState();
    notifyListeners();
  }

  /// 🏆 Unlock achievement
  Future<void> _unlockAchievement(String achievementId) async {
    final achievement = _state.achievements[achievementId];
    if (achievement == null || achievement.isUnlocked) return;

    final unlockedAchievement = achievement.copyWith(
      isUnlocked: true,
      unlockedAt: DateTime.now(),
    );

    final newAchievements = Map<String, Achievement>.from(_state.achievements);
    newAchievements[achievementId] = unlockedAchievement;

    // Create notification
    final notification = AchievementNotification(
      id: 'notif_${achievementId}_${DateTime.now().millisecondsSinceEpoch}',
      achievement: unlockedAchievement,
      timestamp: DateTime.now(),
    );

    final newNotifications = List<AchievementNotification>.from(_state.notifications);
    newNotifications.add(notification);

    _state = _state.copyWith(
      achievements: newAchievements,
      notifications: newNotifications,
    );

    // Emit notification
    _notificationController.add(notification);

    // Update stats
    await _updateStats();

    _logger.i('🏆 Achievement unlocked: ${unlockedAchievement.title}');
    await _saveState();
    notifyListeners();
  }

  /// 📊 Update achievement statistics
  Future<void> _updateStats() async {
    final achievements = _state.achievements.values.toList();
    final unlocked = achievements.where((a) => a.isUnlocked).toList();

    final stats = AchievementStats(
      totalAchievements: achievements.length,
      unlockedAchievements: unlocked.length,
      commonUnlocked: unlocked.where((a) => a.rarity == AchievementRarity.common).length,
      rareUnlocked: unlocked.where((a) => a.rarity == AchievementRarity.rare).length,
      epicUnlocked: unlocked.where((a) => a.rarity == AchievementRarity.epic).length,
      legendaryUnlocked: unlocked.where((a) => a.rarity == AchievementRarity.legendary).length,
      completionPercentage: achievements.isNotEmpty ? (unlocked.length / achievements.length * 100) : 0.0,
      lastAchievementDate: unlocked.isNotEmpty ?
      unlocked.map((a) => a.unlockedAt!).reduce((a, b) => a.isAfter(b) ? a : b) : null,
    );

    _state = _state.copyWith(stats: stats);
  }

  /// 🔄 Mark notification as shown
  Future<void> markNotificationShown(String notificationId) async {
    final notifications = _state.notifications.map((n) =>
    n.id == notificationId ? n.copyWith(isShown: true) : n
    ).toList();

    _state = _state.copyWith(notifications: notifications);
    await _saveState();
    notifyListeners();
  }

  /// 🎮 Toggle notifications
  Future<void> toggleNotifications(bool enabled) async {
    _state = _state.copyWith(showNotifications: enabled);
    await _saveState();
    notifyListeners();
  }

  /// 💾 Save state to storage
  Future<void> _saveState() async {
    try {
      final achievementJson = _state.achievements.map((key, value) =>
          MapEntry(key, value.toJson()));
      final progressJson = _state.progress.map((key, value) =>
          MapEntry(key, value.toJson()));

      await _prefs.setString(_storageKey, jsonEncode(achievementJson));
      await _prefs.setString(_progressKey, jsonEncode(progressJson));
    } catch (e) {
      _logger.e('❌ Failed to save achievement state: $e');
    }
  }

  /// 📂 Load state from storage
  Future<void> _loadState() async {
    try {
      final achievementData = _prefs.getString(_storageKey);
      final progressData = _prefs.getString(_progressKey);

      if (achievementData != null) {
        final achievementJson = jsonDecode(achievementData) as Map<String, dynamic>;
        final achievements = achievementJson.map((key, value) =>
            MapEntry(key, Achievement.fromJson(value as Map<String, dynamic>)));

        Map<String, AchievementProgress> progress = {};
        if (progressData != null) {
          final progressJson = jsonDecode(progressData) as Map<String, dynamic>;
          progress = progressJson.map((key, value) =>
              MapEntry(key, AchievementProgress.fromJson(value as Map<String, dynamic>)));
        }

        _state = _state.copyWith(
          achievements: achievements,
          progress: progress,
        );
      }
    } catch (e) {
      _logger.e('❌ Failed to load achievement state: $e');
    }
  }

  /// 🧹 Cleanup
  @override
  void dispose() {
    _notificationController.close();
    super.dispose();
  }

  // 🎯 HELPER METHODS FOR COMMON TRACKING EVENTS

  /// Track particle system interactions
  Future<void> trackParticleInteraction() async {
    await trackProgress('first_particle_view');
    await trackProgress('particle_interaction');
  }

  /// Track particle type discovery
  Future<void> trackParticleType(String particleType) async {
    await trackProgress('all_particle_types', data: {'particleType': particleType});
  }

  /// Track AI orchestration completion
  Future<void> trackOrchestration(List<String> modelsUsed, String strategy) async {
    await trackProgress('first_orchestration');
    await trackProgress('orchestration_marathon');

    // Track models used
    for (final model in modelsUsed) {
      if (['claude', 'gpt', 'deepseek', 'gemini', 'mistral', 'llama', 'ollama'].contains(model)) {
        await trackProgress('multi_model_master');
      }
    }

    // Track strategy usage
    await trackProgress('strategy_explorer', data: {'strategy': strategy});
  }

  /// Track theme activation
  Future<void> trackThemeActivation(String themeName) async {
    await trackProgress('theme_$themeName');
    await trackProgress('theme_collector');
    await trackProgress('theme_switcher');
  }

  /// Track audio system usage
  Future<void> trackAudioActivation() async {
    await trackProgress('audio_activation');
  }

  /// Track haptic feedback
  Future<void> trackHapticFeedback() async {
    await trackProgress('haptic_master');
  }

  /// Track profiling dashboard usage
  Future<void> trackProfilingUsage() async {
    await trackProgress('profiling_first_use');
    await trackProgress('profiling_expert');
  }

  /// Track feature exploration
  Future<void> trackFeatureUsage(String feature) async {
    await trackProgress('feature_explorer', data: {'feature': feature});
  }

  /// Track performance achievement
  Future<void> trackHighPerformance() async {
    await trackProgress('speed_demon');
  }

  /// Track daily usage
  Future<void> trackDailyUsage() async {
    await trackProgress('daily_user');
  }
}