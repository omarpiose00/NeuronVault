// 🏆 NEURONVAULT ENHANCED ACHIEVEMENT SERVICE - PHASE 3.3 LUXURY ENHANCED
// lib/core/services/achievement_service.dart
// Revolutionary achievement system with neural luxury integration + Audio + Analytics

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../state/state_models.dart';

/// 🏆 Enhanced Achievement Service - PHASE 3.3 LUXURY ENHANCED
/// Revolutionary achievement system with neural luxury integration + Multi-stage celebrations
class EnhancedAchievementService extends ChangeNotifier {
  final SharedPreferences _prefs;
  final Logger _logger;

  static const String _storageKey = 'neuronvault_achievements_v3';
  static const String _progressKey = 'neuronvault_achievement_progress_v3';
  static const String _sessionsKey = 'neuronvault_sessions_v3';
  static const String _analyticsKey = 'neuronvault_analytics_v3';

  AchievementState _state = const AchievementState();
  final StreamController<AchievementNotification> _notificationController =
  StreamController<AchievementNotification>.broadcast();

  // 🎨 PHASE 3.3: ENHANCED TRACKING SYSTEMS
  late Timer _performanceTimer;
  late Timer _sessionTimer;
  int _currentSessionMinutes = 0;
  bool _maintainedHighPerformance = false;
  Map<String, int> _sessionStats = {};
  final Map<String, DateTime> _lastUsageTracking = {};

  // 🔊 PHASE 3.3: AUDIO INTEGRATION READY
  // AudioService? _audioService; // Will be injected later

  // 📊 PHASE 3.3: REAL-TIME ANALYTICS
  Map<String, dynamic> _liveAnalytics = {};
  List<AchievementEvent> _eventHistory = [];

  EnhancedAchievementService({
    required SharedPreferences prefs,
    required Logger logger,
  }) : _prefs = prefs, _logger = logger {
    _initializeEnhancedAchievements();
    _startPerformanceTracking();
    _startSessionTracking();
  }

  // 📊 Enhanced Getters
  AchievementState get state => _state;
  Stream<AchievementNotification> get notificationStream => _notificationController.stream;
  Map<String, dynamic> get liveAnalytics => _liveAnalytics;
  List<AchievementEvent> get eventHistory => _eventHistory;
  int get currentSessionMinutes => _currentSessionMinutes;
  Map<String, int> get sessionStats => _sessionStats;

  /// 🚀 Initialize enhanced achievement system
  Future<void> _initializeEnhancedAchievements() async {
    try {
      _logger.i('🏆 Initializing Enhanced Achievement System PHASE 3.3...');

      // Load enhanced state
      await _loadEnhancedState();

      // Initialize achievements if first run
      if (_state.achievements.isEmpty) {
        await _createEnhancedAchievements();
      }

      // Update live analytics
      await _updateLiveAnalytics();

      // Update stats
      await _updateEnhancedStats();

      _state = _state.copyWith(isInitialized: true);
      notifyListeners();

      _logger.i('✅ Enhanced Achievement System initialized with ${_state.achievements.length} achievements');
    } catch (e) {
      _logger.e('❌ Failed to initialize Enhanced Achievement System: $e');
    }
  }

  /// 📝 Create enhanced neural luxury achievements with PHASE 3.3 features
  Future<void> _createEnhancedAchievements() async {
    final achievements = <String, Achievement>{};

    // 🚀 3D PARTICLE ACHIEVEMENTS - ENHANCED
    achievements['neural_awakening'] = const Achievement(
      id: 'neural_awakening',
      title: 'Neural Awakening',
      description: 'Witnessed your first 3D neural particle system in all its glory',
      category: AchievementCategory.particles,
      rarity: AchievementRarity.common,
      targetProgress: 1,
    );

    achievements['particle_whisperer'] = const Achievement(
      id: 'particle_whisperer',
      title: 'Particle Whisperer',
      description: 'Interacted with neural particles 50 times - you speak their language',
      category: AchievementCategory.particles,
      rarity: AchievementRarity.rare,
      targetProgress: 50,
    );

    achievements['neural_architect'] = const Achievement(
      id: 'neural_architect',
      title: 'Neural Architect',
      description: 'Experienced all 5 particle types: Neuron, Synapse, Electrical, Quantum, Data',
      category: AchievementCategory.particles,
      rarity: AchievementRarity.epic,
      targetProgress: 5,
    );

    achievements['particle_master'] = const Achievement(
      id: 'particle_master',
      title: 'Particle Master',
      description: 'Maintained 60 FPS with 150+ particles for 5 minutes straight',
      category: AchievementCategory.particles,
      rarity: AchievementRarity.legendary,
      targetProgress: 300, // 5 minutes in seconds
      isHidden: true,
    );

    // 🧠 AI ORCHESTRATION ACHIEVEMENTS - ENHANCED
    achievements['first_synthesis'] = const Achievement(
      id: 'first_synthesis',
      title: 'First Synthesis',
      description: 'Completed your first AI orchestration request - welcome to the future',
      category: AchievementCategory.orchestration,
      rarity: AchievementRarity.common,
      targetProgress: 1,
    );

    achievements['ai_conductor'] = const Achievement(
      id: 'ai_conductor',
      title: 'AI Conductor',
      description: 'Successfully orchestrated all 7 AI models (Claude, GPT, Gemini, DeepSeek, Mistral, Llama, Ollama)',
      category: AchievementCategory.orchestration,
      rarity: AchievementRarity.epic,
      targetProgress: 7,
    );

    achievements['strategy_master'] = const Achievement(
      id: 'strategy_master',
      title: 'Strategy Master',
      description: 'Mastered all orchestration strategies: Parallel, Consensus, Adaptive, Sequential, Weighted',
      category: AchievementCategory.orchestration,
      rarity: AchievementRarity.rare,
      targetProgress: 5,
    );

    achievements['neural_marathon'] = const Achievement(
      id: 'neural_marathon',
      title: 'Neural Marathon',
      description: 'Completed 100 orchestrations - you are unstoppable',
      category: AchievementCategory.orchestration,
      rarity: AchievementRarity.legendary,
      targetProgress: 100,
    );

    achievements['speed_synthesizer'] = const Achievement(
      id: 'speed_synthesizer',
      title: 'Speed Synthesizer',
      description: 'Completed 10 orchestrations in under 5 minutes',
      category: AchievementCategory.orchestration,
      rarity: AchievementRarity.epic,
      targetProgress: 10,
      isHidden: true,
    );

    // 🎨 THEME ACHIEVEMENTS - ENHANCED WITH PHASE 3.3
    final themeData = [
      {'name': 'cosmos', 'display': 'Cosmos Explorer'},
      {'name': 'matrix', 'display': 'Matrix Diver'},
      {'name': 'sunset', 'display': 'Sunset Dreamer'},
      {'name': 'ocean', 'display': 'Ocean Voyager'},
      {'name': 'midnight', 'display': 'Midnight Walker'},
      {'name': 'aurora', 'display': 'Aurora Chaser'},
    ];

    for (final theme in themeData) {
      achievements['theme_${theme['name']}'] = Achievement(
        id: 'theme_${theme['name']}',
        title: theme['display'] as String,
        description: 'Activated the ${theme['name']} neural luxury theme',
        category: AchievementCategory.themes,
        rarity: AchievementRarity.common,
        targetProgress: 1,
      );
    }

    achievements['theme_collector'] = const Achievement(
      id: 'theme_collector',
      title: 'Theme Collector',
      description: 'Unlocked all 6 neural luxury themes - you have exquisite taste',
      category: AchievementCategory.themes,
      rarity: AchievementRarity.legendary,
      targetProgress: 6,
    );

    achievements['visual_shapeshifter'] = const Achievement(
      id: 'visual_shapeshifter',
      title: 'Visual Shapeshifter',
      description: 'Changed themes 25 times in a single session - a true artist',
      category: AchievementCategory.themes,
      rarity: AchievementRarity.rare,
      targetProgress: 25,
    );

    achievements['theme_marathon'] = const Achievement(
      id: 'theme_marathon',
      title: 'Theme Marathon',
      description: 'Spent 30+ minutes with each theme active',
      category: AchievementCategory.themes,
      rarity: AchievementRarity.epic,
      targetProgress: 6,
      isHidden: true,
    );

    // 🔊 SPATIAL AUDIO ACHIEVEMENTS - PHASE 3.3 ENHANCED
    achievements['sound_pioneer'] = const Achievement(
      id: 'sound_pioneer',
      title: 'Sound Pioneer',
      description: 'Activated the revolutionary 3D spatial audio system',
      category: AchievementCategory.audio,
      rarity: AchievementRarity.common,
      targetProgress: 1,
    );

    achievements['audio_architect'] = const Achievement(
      id: 'audio_architect',
      title: 'Audio Architect',
      description: 'Customized all 7 neural sound types to perfection',
      category: AchievementCategory.audio,
      rarity: AchievementRarity.epic,
      targetProgress: 7,
    );

    achievements['haptic_master'] = const Achievement(
      id: 'haptic_master',
      title: 'Haptic Master',
      description: 'Experienced 100 haptic feedback events - feel the neural energy',
      category: AchievementCategory.audio,
      rarity: AchievementRarity.rare,
      targetProgress: 100,
    );

    achievements['immersion_king'] = const Achievement(
      id: 'immersion_king',
      title: 'Immersion King',
      description: 'Used audio + haptic + particles simultaneously for 10 minutes',
      category: AchievementCategory.audio,
      rarity: AchievementRarity.legendary,
      targetProgress: 600, // 10 minutes in seconds
      isHidden: true,
    );

    // 📊 MODEL PROFILING ACHIEVEMENTS - ENHANCED
    achievements['data_explorer'] = const Achievement(
      id: 'data_explorer',
      title: 'Data Explorer',
      description: 'Opened the revolutionary Model Profiling Dashboard',
      category: AchievementCategory.profiling,
      rarity: AchievementRarity.common,
      targetProgress: 1,
    );

    achievements['profiling_expert'] = const Achievement(
      id: 'profiling_expert',
      title: 'Profiling Expert',
      description: 'Analyzed performance metrics for all 7 AI models',
      category: AchievementCategory.profiling,
      rarity: AchievementRarity.epic,
      targetProgress: 7,
    );

    achievements['performance_analyst'] = const Achievement(
      id: 'performance_analyst',
      title: 'Performance Analyst',
      description: 'Spent 60+ minutes analyzing model profiling data',
      category: AchievementCategory.profiling,
      rarity: AchievementRarity.rare,
      targetProgress: 3600, // 60 minutes in seconds
    );

    // 🌟 EXPLORATION ACHIEVEMENTS - PHASE 3.3 ENHANCED
    achievements['feature_explorer'] = const Achievement(
      id: 'feature_explorer',
      title: 'Feature Explorer',
      description: 'Used all 5 revolutionary features: Particles, Profiling, Audio, Themes, Achievements',
      category: AchievementCategory.exploration,
      rarity: AchievementRarity.legendary,
      targetProgress: 5,
    );

    achievements['speed_demon'] = const Achievement(
      id: 'speed_demon',
      title: 'Speed Demon',
      description: 'Maintained 60 FPS for 10 minutes straight - you have a beast machine',
      category: AchievementCategory.exploration,
      rarity: AchievementRarity.epic,
      targetProgress: 600, // 10 minutes in seconds
      isHidden: true,
    );

    achievements['neural_devotee'] = const Achievement(
      id: 'neural_devotee',
      title: 'Neural Devotee',
      description: 'Used NeuronVault for 7 consecutive days - dedication at its finest',
      category: AchievementCategory.exploration,
      rarity: AchievementRarity.legendary,
      targetProgress: 7,
      isHidden: true,
    );

    achievements['early_adopter'] = const Achievement(
      id: 'early_adopter',
      title: 'Early Adopter',
      description: 'One of the first 100 users to experience NeuronVault',
      category: AchievementCategory.exploration,
      rarity: AchievementRarity.legendary,
      targetProgress: 1,
      isHidden: true,
    );

    // 💫 PHASE 3.3: COMBO ACHIEVEMENTS
    achievements['perfect_orchestration'] = const Achievement(
      id: 'perfect_orchestration',
      title: 'Perfect Orchestration',
      description: 'Completed orchestration with all 7 models, all themes active, and perfect performance',
      category: AchievementCategory.orchestration,
      rarity: AchievementRarity.legendary,
      targetProgress: 1,
      isHidden: true,
    );

    achievements['luxury_connoisseur'] = const Achievement(
      id: 'luxury_connoisseur',
      title: 'Luxury Connoisseur',
      description: 'Experienced every aspect of neural luxury: particles, themes, audio, achievements',
      category: AchievementCategory.exploration,
      rarity: AchievementRarity.legendary,
      targetProgress: 4,
    );

    _state = _state.copyWith(achievements: achievements);
    await _saveEnhancedState();
  }

  /// 🎯 Enhanced achievement progress tracking with PHASE 3.3 features
  Future<void> trackEnhancedProgress(
      String achievementId, {
        int increment = 1,
        Map<String, dynamic>? data,
        bool playSound = true,
        bool triggerHaptic = true,
      }) async {
    if (!_state.achievements.containsKey(achievementId)) {
      _logger.w('⚠️ Achievement not found: $achievementId');
      return;
    }

    final achievement = _state.achievements[achievementId]!;
    if (achievement.isUnlocked) return;

    // Track event for analytics
    _recordAchievementEvent(achievementId, increment, data);

    final currentProgress = _state.progress[achievementId] ??
        AchievementProgress(achievementId: achievementId, targetValue: achievement.targetProgress);

    final newProgress = currentProgress.copyWith(
      currentValue: (currentProgress.currentValue + increment).clamp(0, achievement.targetProgress),
      lastUpdated: DateTime.now(),
      progressData: {...(currentProgress.progressData ?? {}), ...(data ?? {})},
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

    // Check for unlock
    if (newProgress.currentValue >= achievement.targetProgress && !achievement.isUnlocked) {
      await _unlockEnhancedAchievement(achievementId, playSound: playSound, triggerHaptic: triggerHaptic);
    }

    await _saveEnhancedState();
    await _updateLiveAnalytics();
    notifyListeners();
  }

  /// 🏆 Enhanced achievement unlock with PHASE 3.3 celebration
  Future<void> _unlockEnhancedAchievement(
      String achievementId, {
        bool playSound = true,
        bool triggerHaptic = true,
      }) async {
    final achievement = _state.achievements[achievementId];
    if (achievement == null || achievement.isUnlocked) return;

    final unlockedAchievement = achievement.copyWith(
      isUnlocked: true,
      unlockedAt: DateTime.now(),
    );

    final newAchievements = Map<String, Achievement>.from(_state.achievements);
    newAchievements[achievementId] = unlockedAchievement;

    // 🎊 PHASE 3.3: Create enhanced notification with celebration data
    final notification = AchievementNotification(
      id: 'notif_${achievementId}_${DateTime.now().millisecondsSinceEpoch}',
      achievement: unlockedAchievement,
      timestamp: DateTime.now(),
      displayDuration: _getDisplayDuration(unlockedAchievement.rarity),
    );

    final newNotifications = List<AchievementNotification>.from(_state.notifications);
    newNotifications.add(notification);

    _state = _state.copyWith(
      achievements: newAchievements,
      notifications: newNotifications,
    );

    // Emit enhanced notification
    _notificationController.add(notification);

    // Update stats and analytics
    await _updateEnhancedStats();
    await _updateLiveAnalytics();

    // Record major event
    _recordAchievementEvent('achievement_unlocked', 1, {
      'achievement_id': achievementId,
      'rarity': unlockedAchievement.rarity.name,
      'title': unlockedAchievement.title,
    });

    _logger.i('🏆 Enhanced Achievement unlocked: ${unlockedAchievement.title} (${unlockedAchievement.rarity.name})');
    await _saveEnhancedState();
    notifyListeners();
  }

  /// 📊 Update enhanced statistics with live analytics
  Future<void> _updateEnhancedStats() async {
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
      lastAchievementDate: unlocked.isNotEmpty
          ? unlocked.map((a) => a.unlockedAt!).reduce((a, b) => a.isAfter(b) ? a : b)
          : null,
      totalPoints: unlocked.fold(0, (sum, a) => sum + _getRarityPoints(a.rarity)),
      averageUnlockTime: _calculateAverageUnlockTime(unlocked),
      unlockRate: _calculateUnlockRate(),
      favoriteCategory: _getFavoriteCategory(),
      streakDays: _calculateStreakDays(),
    );

    _state = _state.copyWith(stats: stats);
  }

  /// 📊 Update live analytics
  Future<void> _updateLiveAnalytics() async {
    _liveAnalytics = {
      'session_duration': _currentSessionMinutes,
      'session_achievements': _sessionStats['achievements_unlocked'] ?? 0,
      'performance_maintained': _maintainedHighPerformance,
      'total_events': _eventHistory.length,
      'recent_activity': _eventHistory.take(10).map((e) => e.toJson()).toList(),
      'unlock_rate': _calculateUnlockRate(),
      'favorite_category': _getFavoriteCategory(),
      'streak_days': _calculateStreakDays(),
    };
  }

  /// 🎮 Performance tracking for achievements
  void _startPerformanceTracking() {
    _performanceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Track high performance maintenance
      _maintainedHighPerformance = true; // This would come from actual FPS monitoring

      if (_maintainedHighPerformance) {
        trackEnhancedProgress('speed_demon', playSound: false, triggerHaptic: false);
        trackEnhancedProgress('particle_master', playSound: false, triggerHaptic: false);
      }
    });
  }

  /// ⏰ Session tracking for achievements
  void _startSessionTracking() {
    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _currentSessionMinutes++;

      // Track daily usage
      final today = DateTime.now().toLocal();
      final todayKey = '${today.year}-${today.month}-${today.day}';
      _sessionStats[todayKey] = (_sessionStats[todayKey] ?? 0) + 1;

      // Update analytics
      _updateLiveAnalytics();
    });
  }

  /// 🎯 Record achievement event for analytics
  void _recordAchievementEvent(String achievementId, int increment, Map<String, dynamic>? data) {
    final event = AchievementEvent(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      achievementId: achievementId,
      eventType: 'progress',
      timestamp: DateTime.now(),
      increment: increment,
      data: data,
    );

    _eventHistory.insert(0, event);

    // Keep only last 1000 events
    if (_eventHistory.length > 1000) {
      _eventHistory = _eventHistory.take(1000).toList();
    }
  }

  // 🎯 HELPER METHODS FOR ENHANCED TRACKING

  /// Track particle interactions with enhanced data
  Future<void> trackParticleInteraction({String? particleType, double? intensity}) async {
    await trackEnhancedProgress('neural_awakening');
    await trackEnhancedProgress('particle_whisperer');

    if (particleType != null) {
      await trackEnhancedProgress('neural_architect', data: {'particle_type': particleType});
    }
  }

  /// Track AI orchestration with detailed metrics
  Future<void> trackOrchestration(List<String> modelsUsed, String strategy, {
    double? responseTime,
    int? tokenCount,
    double? qualityScore,
  }) async {
    await trackEnhancedProgress('first_synthesis');
    await trackEnhancedProgress('neural_marathon');

    if (responseTime != null && responseTime < 30) { // Under 30 seconds
      await trackEnhancedProgress('speed_synthesizer');
    }

    // Track models used
    for (final model in modelsUsed) {
      if (['claude', 'gpt', 'deepseek', 'gemini', 'mistral', 'llama', 'ollama'].contains(model)) {
        await trackEnhancedProgress('ai_conductor');
      }
    }

    // Track strategy usage
    await trackEnhancedProgress('strategy_master', data: {'strategy': strategy});

    // Session stats
    _sessionStats['orchestrations'] = (_sessionStats['orchestrations'] ?? 0) + 1;
  }

  /// Track theme activation with usage time
  Future<void> trackThemeActivation(String themeName, {Duration? usageDuration}) async {
    await trackEnhancedProgress('theme_$themeName');
    await trackEnhancedProgress('theme_collector');
    await trackEnhancedProgress('visual_shapeshifter');

    if (usageDuration != null && usageDuration.inMinutes >= 30) {
      await trackEnhancedProgress('theme_marathon');
    }
  }

  /// Track audio features with intensity
  Future<void> trackAudioActivation({String? soundType, bool? hapticEnabled}) async {
    await trackEnhancedProgress('sound_pioneer');

    if (soundType != null) {
      await trackEnhancedProgress('audio_architect', data: {'sound_type': soundType});
    }

    if (hapticEnabled == true) {
      await trackEnhancedProgress('haptic_master');
    }
  }

  /// Track profiling usage with time spent
  Future<void> trackProfilingUsage({Duration? timeSpent}) async {
    await trackEnhancedProgress('data_explorer');
    await trackEnhancedProgress('profiling_expert');

    if (timeSpent != null) {
      await trackEnhancedProgress('performance_analyst', increment: timeSpent.inSeconds);
    }
  }

  /// Track feature exploration
  Future<void> trackFeatureUsage(String feature) async {
    await trackEnhancedProgress('feature_explorer', data: {'feature': feature});
    await trackEnhancedProgress('luxury_connoisseur');
  }

  // 🎯 UTILITY METHODS

  Duration _getDisplayDuration(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return const Duration(seconds: 3);
      case AchievementRarity.rare:
        return const Duration(seconds: 4);
      case AchievementRarity.epic:
        return const Duration(seconds: 5);
      case AchievementRarity.legendary:
        return const Duration(seconds: 6);
    }
  }

  int _getRarityPoints(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return 10;
      case AchievementRarity.rare:
        return 25;
      case AchievementRarity.epic:
        return 50;
      case AchievementRarity.legendary:
        return 100;
    }
  }

  Duration? _calculateAverageUnlockTime(List<Achievement> unlockedAchievements) {
    if (unlockedAchievements.isEmpty) return null;

    final durations = unlockedAchievements
        .where((a) => a.unlockedAt != null)
        .map((a) => a.unlockedAt!)
        .toList();

    if (durations.isEmpty) return null;

    durations.sort();
    final totalMinutes = durations.last.difference(durations.first).inMinutes;
    return Duration(minutes: totalMinutes ~/ unlockedAchievements.length);
  }

  double _calculateUnlockRate() {
    if (_currentSessionMinutes == 0) return 0.0;
    final sessionAchievements = _sessionStats['achievements_unlocked'] ?? 0;
    return sessionAchievements / _currentSessionMinutes;
  }

  String _getFavoriteCategory() {
    final categoryStats = <AchievementCategory, int>{};

    for (final achievement in _state.achievements.values) {
      if (achievement.isUnlocked) {
        categoryStats[achievement.category] = (categoryStats[achievement.category] ?? 0) + 1;
      }
    }

    if (categoryStats.isEmpty) return 'none';

    final maxEntry = categoryStats.entries.reduce((a, b) => a.value > b.value ? a : b);
    return maxEntry.key.name;
  }

  int _calculateStreakDays() {
    // Calculate consecutive days of usage
    final today = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 30; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final dateKey = '${checkDate.year}-${checkDate.month}-${checkDate.day}';

      if (_sessionStats.containsKey(dateKey)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// 💾 Save enhanced state
  Future<void> _saveEnhancedState() async {
    try {
      final achievementJson = _state.achievements.map((key, value) => MapEntry(key, value.toJson()));
      final progressJson = _state.progress.map((key, value) => MapEntry(key, value.toJson()));

      await _prefs.setString(_storageKey, jsonEncode(achievementJson));
      await _prefs.setString(_progressKey, jsonEncode(progressJson));
      await _prefs.setString(_sessionsKey, jsonEncode(_sessionStats));
      await _prefs.setString(_analyticsKey, jsonEncode(_liveAnalytics));
    } catch (e) {
      _logger.e('❌ Failed to save enhanced achievement state: $e');
    }
  }

  /// 📂 Load enhanced state
  Future<void> _loadEnhancedState() async {
    try {
      final achievementData = _prefs.getString(_storageKey);
      final progressData = _prefs.getString(_progressKey);
      final sessionsData = _prefs.getString(_sessionsKey);
      final analyticsData = _prefs.getString(_analyticsKey);

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

        if (sessionsData != null) {
          _sessionStats = Map<String, int>.from(jsonDecode(sessionsData));
        }

        if (analyticsData != null) {
          _liveAnalytics = Map<String, dynamic>.from(jsonDecode(analyticsData));
        }

        _state = _state.copyWith(
          achievements: achievements,
          progress: progress,
        );
      }
    } catch (e) {
      _logger.e('❌ Failed to load enhanced achievement state: $e');
    }
  }

  /// 🧹 Mark notification as shown
  Future<void> markNotificationShown(String notificationId) async {
    final index = _state.notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final notification = _state.notifications[index];
      final updatedNotification = notification.copyWith(isShown: true);

      final newNotifications = List<AchievementNotification>.from(_state.notifications);
      newNotifications[index] = updatedNotification;

      _state = _state.copyWith(notifications: newNotifications);
      await _saveEnhancedState();
      notifyListeners();
    }
  }

  /// 🧹 Enhanced cleanup
  @override
  void dispose() {
    _performanceTimer.cancel();
    _sessionTimer.cancel();
    _notificationController.close();
    super.dispose();
  }
}

/// 📊 Achievement Event for analytics
class AchievementEvent {
  final String id;
  final String achievementId;
  final String eventType;
  final DateTime timestamp;
  final int increment;
  final Map<String, dynamic>? data;

  AchievementEvent({
    required this.id,
    required this.achievementId,
    required this.eventType,
    required this.timestamp,
    required this.increment,
    this.data,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'achievement_id': achievementId,
    'event_type': eventType,
    'timestamp': timestamp.toIso8601String(),
    'increment': increment,
    'data': data,
  };

  factory AchievementEvent.fromJson(Map<String, dynamic> json) => AchievementEvent(
    id: json['id'],
    achievementId: json['achievement_id'],
    eventType: json['event_type'],
    timestamp: DateTime.parse(json['timestamp']),
    increment: json['increment'],
    data: json['data'],
  );
}