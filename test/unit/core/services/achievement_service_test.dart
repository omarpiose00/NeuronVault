// 🧪 test/unit/core/services/achievement_service_test.dart
// Enterprise-grade unit tests for EnhancedAchievementService - FULLY CORRECTED VERSION
// Modern Flutter testing best practices 2025

import 'dart:async';
import 'dart:convert';
import 'package:fake_async/fake_async.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import 'package:neuronvault/core/services/achievement_service.dart';
import 'package:neuronvault/core/state/state_models.dart';

// Assuming these are correctly located relative to the test file
// If these files are in a different location, adjust the import paths accordingly.
import '../../utils/test_helpers.dart';

// 🎭 Mock Classes
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockLogger extends Mock implements Logger {}

void main() {
  group('EnhancedAchievementService - Enterprise Tests (Fully Corrected)', () {
    late MockSharedPreferences mockPrefs;
    late MockLogger mockLogger;

    // Storage keys from the service
    const String storageKey = 'neuronvault_achievements_v3';
    const String progressKey = 'neuronvault_achievement_progress_v3';
    const String sessionsKey = 'neuronvault_sessions_v3';
    const String analyticsKey = 'neuronvault_analytics_v3';

    setUp(() async {
      setupTestEnvironment();

      mockPrefs = MockSharedPreferences();
      mockLogger = MockLogger();

      // Default mock behaviors
      when(() => mockPrefs.getString(any())).thenReturn(null);
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
      when(() => mockPrefs.getStringList(any())).thenReturn(null);
      when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);

      // Default logger mocks
      when(() => mockLogger.i(any())).thenReturn(null);
      when(() => mockLogger.e(any())).thenReturn(null);
      when(() => mockLogger.w(any())).thenReturn(null);
      when(() => mockLogger.d(any())).thenReturn(null);
      when(() => mockLogger.f(any())).thenReturn(null);
      when(() => mockLogger.t(any())).thenReturn(null);
    });

    tearDown(() {
      cleanupTestEnvironment();
      reset(mockPrefs);
      reset(mockLogger);
    });

    group('Constructor & Initialization', () {
      test('should initialize with correct dependencies and create achievements', () async {
        final service = EnhancedAchievementService(
          prefs: mockPrefs,
          logger: mockLogger,
        );
        await Future.delayed(const Duration(seconds: 1));

        expect(service.state.isInitialized, isTrue, reason: 'Service should be initialized after constructor and delay.');
        expect(service.state.achievements.length, greaterThan(20), reason: 'Should have more than 20 default achievements.');
        expect(service.state.achievements.containsKey('neural_awakening'), isTrue);
        verify(() => mockLogger.i(contains('Initializing Enhanced Achievement System'))).called(1);
        service.dispose();
      });

      test('should load existing state from SharedPreferences if available', () async {
        final achievementIdToTest = 'neural_awakening';
        final existingAchievementsMap = {
          achievementIdToTest: Achievement(
            id: achievementIdToTest,
            title: 'Neural Awakening',
            description: 'Test achievement',
            category: AchievementCategory.particles,
            rarity: AchievementRarity.common,
            isUnlocked: true,
            currentProgress: 1,
            targetProgress: 1,
            unlockedAt: DateTime.now(),
          ).toJson(),
        };

        final progressIdToTest = 'ai_conductor';
        final existingProgressMap = {
          progressIdToTest: AchievementProgress(
            achievementId: progressIdToTest,
            currentValue: 3,
            targetValue: 7,
            lastUpdated: DateTime.now(),
          ).toJson(),
        };

        final existingSessions = {
          '2025-01-15': 5,
          'achievements_unlocked': 3
        };
        final rawLoadedAnalyticsJson = {'some_loaded_analytic_key': 12345, 'another_key': 'value'};

        when(() => mockPrefs.getString(storageKey)).thenReturn(jsonEncode(existingAchievementsMap));
        when(() => mockPrefs.getString(progressKey)).thenReturn(jsonEncode(existingProgressMap));
        when(() => mockPrefs.getString(sessionsKey)).thenReturn(jsonEncode(existingSessions));
        when(() => mockPrefs.getString(analyticsKey)).thenReturn(jsonEncode(rawLoadedAnalyticsJson));

        final newService = EnhancedAchievementService(
          prefs: mockPrefs,
          logger: mockLogger,
        );
        await Future.delayed(const Duration(seconds: 1));

        expect(newService.state.achievements.containsKey(achievementIdToTest), isTrue);
        expect(newService.state.achievements[achievementIdToTest]?.isUnlocked, isTrue, reason: "Loaded achievement 'isUnlocked' state should be true.");
        expect(newService.state.progress.containsKey(progressIdToTest), isTrue);
        expect(newService.state.progress[progressIdToTest]?.currentValue, equals(3));
        expect(newService.sessionStats['2025-01-15'], equals(5));
        expect(newService.sessionStats['achievements_unlocked'], equals(3));
        expect(newService.liveAnalytics['session_achievements'], equals(3), reason: "Loaded 'achievements_unlocked' from sessionStats should be reflected as 'session_achievements' in liveAnalytics.");
        verify(() => mockPrefs.getString(analyticsKey)).called(1);
        expect(newService.liveAnalytics.containsKey('some_loaded_analytic_key'), isFalse, reason: 'Arbitrary loaded analytics keys should not persist in the recomputed liveAnalytics map.');

        newService.dispose();
      });

      test('should handle initialization errors gracefully when SharedPreferences throws', () async {
        when(() => mockPrefs.getString(any())).thenThrow(Exception('Storage error'));

        final errorService = EnhancedAchievementService(
          prefs: mockPrefs,
          logger: mockLogger,
        );
        await Future.delayed(const Duration(seconds: 1));

        expect(errorService.state.achievements.isNotEmpty, isTrue, reason: 'Should initialize with default achievements even if SharedPreferences load fails.');
        verify(() => mockLogger.e(contains('Failed to load enhanced achievement state'))).called(greaterThanOrEqualTo(1));
        errorService.dispose();
      });

      test('should start performance and session tracking timers', () async {
        final service = EnhancedAchievementService(prefs: mockPrefs, logger: mockLogger);
        await Future.delayed(const Duration(seconds: 2));

        expect(service.liveAnalytics, isA<Map<String, dynamic>>());
        expect(service.sessionStats, isA<Map<String, int>>());
        expect(service.currentSessionMinutes, greaterThanOrEqualTo(0));
        if (service.liveAnalytics.isNotEmpty) {
          expect(service.liveAnalytics.containsKey('session_duration'), isTrue);
        }
        service.dispose();
      });

      test('should initialize with correct achievement categories and rarities count', () async {
        final service = EnhancedAchievementService(prefs: mockPrefs, logger: mockLogger);
        await Future.delayed(const Duration(seconds: 1));

        final achievements = service.state.achievements.values;
        expect(achievements.length, greaterThan(20), reason: 'Service should define a list of achievements on init.');
        final categories = achievements.map((a) => a.category).toSet();
        expect(categories.length, equals(AchievementCategory.values.length), reason: 'All defined achievement categories should be represented.');
        final rarities = achievements.map((a) => a.rarity).toSet();
        expect(rarities.length, equals(AchievementRarity.values.length), reason: 'All defined achievement rarities should be represented.');
        expect(achievements.any((a) => a.isHidden), isTrue, reason: 'There should be at least one hidden achievement defined.');
        service.dispose();
      });
    });

    group('Core Progress Tracking', () {
      late EnhancedAchievementService service;

      setUp(() async {
        service = EnhancedAchievementService(prefs: mockPrefs, logger: mockLogger);
        await Future.delayed(const Duration(milliseconds: 500));
      });

      tearDown(() {
        service.dispose();
      });

      test('should increment achievement progress correctly', () async {
        final achievementId = 'particle_whisperer';
        final initialProgress = service.state.achievements[achievementId]!.currentProgress;
        final incrementAmount = 5;
        await service.trackEnhancedProgress(achievementId, increment: incrementAmount);
        expect(service.state.achievements[achievementId]!.currentProgress, equals(initialProgress + incrementAmount));
      });

      test('should unlock achievement when target progress reached', () async {
        final achievementId = 'neural_awakening';
        expect(service.state.achievements[achievementId]!.isUnlocked, isFalse, reason: 'Achievement should not be unlocked initially.');
        final notificationCompleter = Completer<AchievementNotification>();
        late StreamSubscription subscription;
        subscription = service.notificationStream.listen((notification) {
          if (notification.achievement.id == achievementId) {
            if (!notificationCompleter.isCompleted) notificationCompleter.complete(notification);
          }
        });
        await service.trackEnhancedProgress(achievementId);
        final notification = await notificationCompleter.future.timeout(const Duration(seconds: 5), onTimeout: () {
          subscription.cancel();
          fail("Timeout waiting for '$achievementId' unlock notification");
        });
        subscription.cancel();
        expect(notification.achievement.id, equals(achievementId));
        expect(notification.achievement.isUnlocked, isTrue);
        expect(service.state.achievements[achievementId]!.isUnlocked, isTrue);
        expect(service.state.achievements[achievementId]!.unlockedAt, isNotNull);
      });

      test('should not progress already unlocked achievements', () async {
        final achievementId = 'neural_awakening';
        await service.trackEnhancedProgress(achievementId);
        expect(service.state.achievements[achievementId]!.isUnlocked, isTrue, reason: 'Achievement should be unlocked first.');
        final progressAfterUnlock = service.state.achievements[achievementId]!.currentProgress;
        await service.trackEnhancedProgress(achievementId, increment: 5);
        expect(service.state.achievements[achievementId]!.currentProgress, equals(progressAfterUnlock));
      });

      test('should respect max progress limits (clamp to target)', () async {
        final achievementId = 'particle_whisperer';
        final targetProgress = service.state.achievements[achievementId]!.targetProgress;
        await service.trackEnhancedProgress(achievementId, increment: 1000);
        expect(service.state.achievements[achievementId]!.currentProgress, equals(targetProgress));
        expect(service.state.achievements[achievementId]!.isUnlocked, isTrue, reason: 'Achievement should be unlocked when target is reached.');
      });

      test('should handle non-existent achievement IDs gracefully', () async {
        final nonExistentId = 'non_existent_achievement_id';
        await service.trackEnhancedProgress(nonExistentId);
        verify(() => mockLogger.w(contains('Achievement not found: $nonExistentId'))).called(1);
        expect(service.state.achievements.containsKey(nonExistentId), isFalse);
      });

      test('should update analytics after progress tracking', () async {
        final initialEventCount = service.eventHistory.length;
        final initialTotalEventsInAnalytics = service.liveAnalytics['total_events'] ?? 0;
        await service.trackEnhancedProgress('neural_awakening');
        expect(service.eventHistory.length, greaterThan(initialEventCount), reason: 'Event history should grow.');
        expect(service.liveAnalytics['total_events'], greaterThan(initialTotalEventsInAnalytics), reason: 'Total events in live analytics should increase.');
      });

      test('should persist state to SharedPreferences after tracking progress', () async {
        final achievementId = 'neural_awakening';
        await service.trackEnhancedProgress(achievementId);
        verify(() => mockPrefs.setString(storageKey, any(that: contains(achievementId)))).called(greaterThan(0));
        verify(() => mockPrefs.setString(progressKey, any(that: contains(achievementId)))).called(greaterThan(0));
        verify(() => mockPrefs.setString(analyticsKey, any())).called(greaterThan(0));
      });

      test('should handle progress tracking with custom data', () async {
        final achievementId = 'particle_whisperer';
        final customData = {'source': 'test_case', 'value': 42};
        final initialProgress = service.state.achievements[achievementId]!.currentProgress;
        final increment = 2;
        await service.trackEnhancedProgress(achievementId, increment: increment, data: customData);
        expect(service.state.achievements[achievementId]!.currentProgress, equals(initialProgress + increment));
        expect(service.eventHistory.isNotEmpty, isTrue);
        final relevantEvent = service.eventHistory.firstWhere(
              (e) => e.achievementId == achievementId && e.eventType == 'progress' && e.data != null,
          orElse: () => throw StateError('Event with custom data for $achievementId not found'),
        );
        expect(relevantEvent.data, equals(customData));
        final progressObject = service.state.progress[achievementId];
        expect(progressObject, isNotNull);
        expect(progressObject!.progressData, containsPair('source', 'test_case'));
        expect(progressObject.progressData, containsPair('value', 42));
      });
    });

    group('Specialized Tracking Methods', () {
      late EnhancedAchievementService service;
      setUp(() async {
        service = EnhancedAchievementService(prefs: mockPrefs, logger: mockLogger);
        await Future.delayed(const Duration(milliseconds: 500));
      });
      tearDown(() { service.dispose(); });

      test('trackParticleInteraction should update particle-related achievements', () async {
        await service.trackParticleInteraction(particleType: 'neuron', intensity: 0.8);
        expect(service.state.achievements['neural_awakening']!.isUnlocked, isTrue);
        expect(service.state.achievements['particle_whisperer']!.currentProgress, equals(1));
        expect(service.state.achievements['neural_architect']!.currentProgress, equals(1));
      });

      test('trackOrchestration should handle models, strategy, and metrics correctly', () async {
        final models = ['claude', 'gpt', 'gemini'];
        final strategy = 'parallel';
        await service.trackOrchestration(models, strategy, responseTime: 25.0, tokenCount: 150, qualityScore: 0.95);
        expect(service.state.achievements['first_synthesis']!.isUnlocked, isTrue);
        expect(service.state.achievements['neural_marathon']!.currentProgress, equals(1));
        expect(service.state.achievements['ai_conductor']!.currentProgress, equals(models.length));
        expect(service.state.achievements['strategy_master']!.currentProgress, equals(1));
        expect(service.state.achievements['speed_synthesizer']!.currentProgress, equals(1));
        expect(service.sessionStats['orchestrations'], equals(1));
      });

      test('trackThemeActivation should progress theme achievements correctly', () async {
        final themeName = 'cosmos';
        await service.trackThemeActivation(themeName, usageDuration: const Duration(minutes: 35));
        expect(service.state.achievements['theme_$themeName']!.isUnlocked, isTrue);
        expect(service.state.achievements['theme_collector']!.currentProgress, equals(1));
        expect(service.state.achievements['visual_shapeshifter']!.currentProgress, equals(1));
        expect(service.state.achievements['theme_marathon']!.currentProgress, equals(1));
      });

      test('trackAudioActivation should progress audio and haptic achievements', () async {
        await service.trackAudioActivation(soundType: 'neural_fire', hapticEnabled: true);
        expect(service.state.achievements['sound_pioneer']!.isUnlocked, isTrue);
        expect(service.state.achievements['audio_architect']!.currentProgress, equals(1));
        expect(service.state.achievements['haptic_master']!.currentProgress, equals(1));
      });

      test('trackProfilingUsage should increment profiling achievements based on time', () async {
        final timeSpent = const Duration(hours: 1);
        await service.trackProfilingUsage(timeSpent: timeSpent);
        expect(service.state.achievements['data_explorer']!.isUnlocked, isTrue);
        expect(service.state.achievements['profiling_expert']!.currentProgress, equals(1));
        expect(service.state.achievements['performance_analyst']!.currentProgress, equals(timeSpent.inSeconds));
      });

      test('trackFeatureUsage should progress exploration achievements', () async {
        await service.trackFeatureUsage('particles');
        await service.trackFeatureUsage('themes');
        await service.trackFeatureUsage('audio');
        expect(service.state.achievements['feature_explorer']!.currentProgress, equals(3));
        expect(service.state.achievements['luxury_connoisseur']!.currentProgress, equals(3));
      });

      test('should record multiple events in event history for specialized tracking methods', () async {
        final initialEventCount = service.eventHistory.length;
        await service.trackParticleInteraction();
        await service.trackOrchestration(['claude'], 'sequential');
        await service.trackThemeActivation('matrix');
        expect(service.eventHistory.length, greaterThan(initialEventCount + 5));
      });
    });

    group('Notification Management', () {
      late EnhancedAchievementService service;
      setUp(() async {
        service = EnhancedAchievementService(prefs: mockPrefs, logger: mockLogger);
        await Future.delayed(const Duration(milliseconds: 500));
      });
      tearDown(() { service.dispose(); });

      test('markNotificationShown should update notification status in state', () async {
        final achievementId = 'neural_awakening';
        AchievementNotification? receivedNotification;
        final completer = Completer<void>();
        final subscription = service.notificationStream.listen((notification) {
          if (notification.achievement.id == achievementId) {
            receivedNotification = notification;
            if (!completer.isCompleted) completer.complete();
          }
        });
        await service.trackEnhancedProgress(achievementId);
        await completer.future.timeout(const Duration(seconds: 1), onTimeout: () => fail('Notification for $achievementId not received'));
        subscription.cancel();
        expect(receivedNotification, isNotNull);
        expect(receivedNotification!.isShown, isFalse);
        expect(service.state.notifications.any((n) => n.id == receivedNotification!.id && !n.isShown), isTrue);
        await service.markNotificationShown(receivedNotification!.id);
        final updatedNotificationInState = service.state.notifications.firstWhere((n) => n.id == receivedNotification!.id);
        expect(updatedNotificationInState.isShown, isTrue);
      });

      test('markNotificationShown should handle invalid notification IDs gracefully', () async {
        final initialNotificationsState = List<AchievementNotification>.from(service.state.notifications);
        final invalidNotificationId = 'this_id_does_not_exist';
        await service.markNotificationShown(invalidNotificationId);
        expect(service.state.notifications.length, equals(initialNotificationsState.length));
        for (int i = 0; i < initialNotificationsState.length; i++) {
          expect(service.state.notifications[i].isShown, equals(initialNotificationsState[i].isShown));
        }
      });

      test('notificationStream should emit notifications with correct display duration based on rarity', () async {
        final achievementId = 'neural_awakening'; // Common
        AchievementNotification? receivedNotification;
        final completer = Completer<void>();
        final subscription = service.notificationStream.listen((notification) {
          if (notification.achievement.id == achievementId) {
            receivedNotification = notification;
            if (!completer.isCompleted) completer.complete();
          }
        });
        await service.trackEnhancedProgress(achievementId);
        await completer.future.timeout(const Duration(seconds: 1), onTimeout: () => fail('Notification for $achievementId not received'));
        subscription.cancel();
        expect(receivedNotification, isNotNull);
        expect(receivedNotification!.displayDuration, equals(const Duration(seconds: 3)));
      });
    });

    group('State & Analytics Getters', () {
      late EnhancedAchievementService service;
      setUp(() async {
        service = EnhancedAchievementService(prefs: mockPrefs, logger: mockLogger);
        await Future.delayed(const Duration(milliseconds: 500));
      });
      tearDown(() { service.dispose(); });

      test('state getter should return current achievement state', () {
        final currentState = service.state;
        expect(currentState, isA<AchievementState>());
        expect(currentState.isInitialized, isTrue);
        expect(currentState.achievements, isNotEmpty);
        expect(currentState.stats, isA<AchievementStats>());
      });

      test('liveAnalytics getter should return updated analytics data after an action', () async {
        await service.trackEnhancedProgress('neural_awakening');
        final analytics = service.liveAnalytics;
        expect(analytics, isA<Map<String, dynamic>>());
        expect(analytics.containsKey('session_duration'), isTrue);
        expect(analytics.containsKey('total_events'), isTrue);
        expect(analytics['total_events'], greaterThan(0));
      });

      test('eventHistory getter should return recorded events correctly', () async {
        final achievementId = 'neural_awakening';
        await service.trackEnhancedProgress(achievementId);
        expect(service.eventHistory, isA<List<AchievementEvent>>());
        expect(service.eventHistory.isNotEmpty, isTrue);
        final progressEvent = service.eventHistory.firstWhere(
              (event) => event.achievementId == achievementId && event.eventType == 'progress',
          orElse: () => throw StateError('Progress event for $achievementId not found.'),
        );
        expect(progressEvent.increment, equals(1));
        final unlockEvent = service.eventHistory.firstWhere(
              (event) => event.achievementId == 'achievement_unlocked' && event.data != null && event.data!['achievement_id'] == achievementId,
          orElse: () => throw StateError('Unlock event for $achievementId not found.'),
        );
        expect(unlockEvent.data!['title'], equals(service.state.achievements[achievementId]!.title));
      });

      test('currentSessionMinutes should track session time (approximated)', () {
        fakeAsync((async) {
          final service = EnhancedAchievementService(prefs: mockPrefs, logger: mockLogger);
          async.elapse(const Duration(minutes: 1));
          expect(service.currentSessionMinutes, greaterThanOrEqualTo(1));
          service.dispose();
        });
      });


      test('sessionStats should track various session metrics like orchestrations', () async {
        await service.trackOrchestration(['claude'], 'parallel');
        expect(service.sessionStats, isA<Map<String, int>>());
        expect(service.sessionStats['orchestrations'], equals(1));
      });

      test('notificationStream should be a broadcast stream', () {
        expect(service.notificationStream.isBroadcast, isTrue);
      });
    });

    group('Persistence Behavior', () {
      late EnhancedAchievementService service;
      setUp(() async {
        service = EnhancedAchievementService(prefs: mockPrefs, logger: mockLogger);
        await Future.delayed(const Duration(milliseconds: 500));
      });
      tearDown(() { service.dispose(); });

      test('should save state to SharedPreferences on progress updates', () async {
        await service.trackEnhancedProgress('neural_awakening');
        verify(() => mockPrefs.setString(storageKey, any())).called(greaterThanOrEqualTo(1)); // Adjusted from greaterThan(0)
        verify(() => mockPrefs.setString(progressKey, any())).called(greaterThanOrEqualTo(1));
        verify(() => mockPrefs.setString(analyticsKey, any())).called(greaterThanOrEqualTo(1));
        verify(() => mockPrefs.setString(sessionsKey, any())).called(greaterThanOrEqualTo(1));
      });

      // ========= MODIFIED TEST FOR FAILURE 1 (Unexpected number of calls) =========
      test('should use correct storage keys for different data types during save', () async {
        // This action (unlocking 'neural_awakening') calls _saveEnhancedState twice directly.
        // Background timers might also call _saveEnhancedState.
        await service.trackEnhancedProgress('neural_awakening');

        const int minExpectedDirectSavesFromUnlock = 2;

        verify(() => mockPrefs.setString(storageKey, any())).called(greaterThanOrEqualTo(minExpectedDirectSavesFromUnlock));
        verify(() => mockPrefs.setString(progressKey, any())).called(greaterThanOrEqualTo(minExpectedDirectSavesFromUnlock));
        verify(() => mockPrefs.setString(sessionsKey, any())).called(greaterThanOrEqualTo(minExpectedDirectSavesFromUnlock));
        verify(() => mockPrefs.setString(analyticsKey, any())).called(greaterThanOrEqualTo(minExpectedDirectSavesFromUnlock));
      });
      // ========= END OF MODIFIED TEST FOR FAILURE 1 =========


      test('should handle SharedPreferences save failures gracefully', () async {
        when(() => mockPrefs.setString(any(), any())).thenThrow(Exception('Simulated SharedPreferences write failure'));
        await service.trackEnhancedProgress('neural_awakening');
        verify(() => mockLogger.e(contains('Failed to save enhanced achievement state'))).called(greaterThanOrEqualTo(1));
      });

      test('should load state correctly on service restart (simulated by re-creation)', () async {
        await service.trackEnhancedProgress('neural_awakening');
        await service.trackEnhancedProgress('particle_whisperer', increment: 5);
        final capturedAchievementJson = verify(() => mockPrefs.setString(storageKey, captureAny())).captured.last as String;
        final capturedProgressJson = verify(() => mockPrefs.setString(progressKey, captureAny())).captured.last as String;
        final capturedSessionsJson = verify(() => mockPrefs.setString(sessionsKey, captureAny())).captured.last as String;
        final capturedAnalyticsJson = verify(() => mockPrefs.setString(analyticsKey, captureAny())).captured.last as String;
        service.dispose();

        when(() => mockPrefs.getString(storageKey)).thenReturn(capturedAchievementJson);
        when(() => mockPrefs.getString(progressKey)).thenReturn(capturedProgressJson);
        when(() => mockPrefs.getString(sessionsKey)).thenReturn(capturedSessionsJson);
        when(() => mockPrefs.getString(analyticsKey)).thenReturn(capturedAnalyticsJson);

        final newService = EnhancedAchievementService(prefs: mockPrefs, logger: mockLogger);
        await Future.delayed(const Duration(milliseconds: 500));

        expect(newService.state.achievements['neural_awakening']!.isUnlocked, isTrue);
        expect(newService.state.achievements['particle_whisperer']!.currentProgress, equals(5));
        expect(newService.state.achievements['particle_whisperer']!.isUnlocked, isFalse);
        newService.dispose();
      });
    });

    group('Resource Management & Disposal', () {
      test('dispose should prevent further notifications', () async {
        final testService = EnhancedAchievementService(prefs: mockPrefs, logger: mockLogger);
        await Future.delayed(const Duration(milliseconds: 100));
        bool notificationReceived = false;
        final StreamSubscription subscription = testService.notificationStream.listen((_) {
          notificationReceived = true;
        });
        testService.dispose();
        try {
          await testService.trackEnhancedProgress('neural_awakening');
        } catch (e) {
          expect(e, isA<StateError>());
          expect(e.toString(), contains('Cannot add new events after calling close'));
        }
        await Future.delayed(Duration.zero);
        expect(notificationReceived, isFalse, reason: 'Notification stream should not emit after dispose');
        await subscription.cancel();
      });

      test('should prevent state changes after disposal', () async {
        // For this test to PASS, EnhancedAchievementService.trackEnhancedProgress
        // MUST be modified to include `if (_isDisposed) return;` at the beginning.
        final testService = EnhancedAchievementService(prefs: mockPrefs, logger: mockLogger);
        await Future.delayed(const Duration(milliseconds: 100));

        final achievementId = 'neural_awakening';
        final initialAchievement = testService.state.achievements[achievementId];
        expect(initialAchievement, isNotNull, reason: "Test setup: '$achievementId' must exist.");
        final initialProgress = initialAchievement!.currentProgress;
        final initialUnlockState = initialAchievement.isUnlocked;

        testService.dispose();

        try {
          await testService.trackEnhancedProgress(achievementId);
        } catch (e) {
          expect(e, isA<StateError>(), reason: 'If service not fully patched for dispose checks before notification, may throw StateError.');
        }

        expect(
            testService.state.achievements[achievementId]!.currentProgress,
            equals(initialProgress),
            reason: 'Progress should not change after dispose. Requires `if (_isDisposed) return;` in trackEnhancedProgress.'
        );
        expect(
            testService.state.achievements[achievementId]!.isUnlocked,
            equals(initialUnlockState),
            reason: 'Unlock state should not change after dispose. Requires `if (_isDisposed) return;` in trackEnhancedProgress.'
        );
      });

      test('dispose should be idempotent (safe to call multiple times)', () async {
        final testService = EnhancedAchievementService(prefs: mockPrefs, logger: mockLogger);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(() {
          testService.dispose();
          testService.dispose();
          testService.dispose();
        }, returnsNormally, reason: 'dispose() should be safe to call multiple times without error.');
      });
    });

    group('Edge Cases & Error Scenarios', () {
      late EnhancedAchievementService service;
      setUp(() async {
        service = EnhancedAchievementService(prefs: mockPrefs, logger: mockLogger);
        await Future.delayed(const Duration(milliseconds: 500));
      });
      tearDown(() { service.dispose(); });

      test('should handle large increment values without overflow and clamp to target', () async {
        final achievementId = 'particle_whisperer';
        final targetProgress = service.state.achievements[achievementId]!.targetProgress;
        await service.trackEnhancedProgress(achievementId, increment: 999999);
        expect(service.state.achievements[achievementId]!.currentProgress, equals(targetProgress));
        expect(service.state.achievements[achievementId]!.isUnlocked, isTrue);
      });

      test('should handle negative increment values (clamped to 0)', () async {
        final achievementId = 'particle_whisperer';
        await service.trackEnhancedProgress(achievementId, increment: 5);
        expect(service.state.achievements[achievementId]!.currentProgress, equals(5));
        await service.trackEnhancedProgress(achievementId, increment: -10);
        expect(service.state.achievements[achievementId]!.currentProgress, equals(0));
      });

      test('should handle multiple simultaneous (non-awaited) progress updates correctly', () async {
        final concurrentService = EnhancedAchievementService(prefs: mockPrefs, logger: mockLogger);
        await Future.delayed(const Duration(milliseconds: 100));
        final List<Future<void>> futures = [
          concurrentService.trackEnhancedProgress('neural_awakening'),
          concurrentService.trackEnhancedProgress('particle_whisperer', increment: 3),
          concurrentService.trackEnhancedProgress('first_synthesis'),
        ];
        await Future.wait(futures);
        expect(concurrentService.state.achievements['neural_awakening']!.isUnlocked, isTrue);
        expect(concurrentService.state.achievements['particle_whisperer']!.currentProgress, equals(3));
        expect(concurrentService.state.achievements['first_synthesis']!.isUnlocked, isTrue);
        concurrentService.dispose();
      });

      test('should handle malformed saved data gracefully during load', () async {
        when(() => mockPrefs.getString(storageKey)).thenReturn('{"invalid_json_structure":malformed}');
        when(() => mockPrefs.getString(progressKey)).thenReturn('this_is_not_json_at_all');
        final errorLoadService = EnhancedAchievementService(prefs: mockPrefs, logger: mockLogger);
        await Future.delayed(const Duration(milliseconds: 500));
        expect(errorLoadService.state.achievements.isNotEmpty, isTrue);
        expect(errorLoadService.state.progress.isEmpty, isTrue);
        verify(() => mockLogger.e(contains('Failed to load enhanced achievement state'))).called(greaterThanOrEqualTo(1));
        errorLoadService.dispose();
      });

      test('should limit event history to prevent memory issues (e.g., to 1000 events)', () async {
        for (int i = 0; i < 1050; i++) {
          await service.trackEnhancedProgress('neural_marathon', increment: 0);
        }
        expect(service.eventHistory.length, lessThanOrEqualTo(1000));
      });

      test('should handle concurrent achievement unlocks correctly with notifications', () async {
        final concurrentUnlockService = EnhancedAchievementService(prefs: mockPrefs, logger: mockLogger);
        await Future.delayed(const Duration(milliseconds: 100));
        final receivedNotifications = <AchievementNotification>[];
        final neuralAwakeningCompleter = Completer<void>();
        final firstSynthesisCompleter = Completer<void>();
        final subscription = concurrentUnlockService.notificationStream.listen((notification) {
          receivedNotifications.add(notification);
          if (notification.achievement.id == 'neural_awakening' && !neuralAwakeningCompleter.isCompleted) {
            neuralAwakeningCompleter.complete();
          }
          if (notification.achievement.id == 'first_synthesis' && !firstSynthesisCompleter.isCompleted) {
            firstSynthesisCompleter.complete();
          }
        });
        await Future.wait([
          concurrentUnlockService.trackEnhancedProgress('neural_awakening'),
          concurrentUnlockService.trackEnhancedProgress('first_synthesis'),
        ]);
        await Future.wait([
          neuralAwakeningCompleter.future.timeout(const Duration(seconds: 3)),
          firstSynthesisCompleter.future.timeout(const Duration(seconds: 3)),
        ]).catchError((e) => fail('Timeout waiting for concurrent unlock notifications: $e'));
        expect(receivedNotifications.length, greaterThanOrEqualTo(2));
        expect(receivedNotifications.any((n) => n.achievement.id == 'neural_awakening'), isTrue);
        expect(receivedNotifications.any((n) => n.achievement.id == 'first_synthesis'), isTrue);
        expect(concurrentUnlockService.state.achievements['neural_awakening']!.isUnlocked, isTrue);
        expect(concurrentUnlockService.state.achievements['first_synthesis']!.isUnlocked, isTrue);
        await subscription.cancel();
        concurrentUnlockService.dispose();
      });
    });

    group('Achievement Statistics Validation', () {
      late EnhancedAchievementService service;
      setUp(() async {
        service = EnhancedAchievementService(prefs: mockPrefs, logger: mockLogger);
        await Future.delayed(const Duration(milliseconds: 500));
      });
      tearDown(() { service.dispose(); });

      test('should calculate completion percentage correctly after unlocking achievements', () async {
        final totalAchievements = service.state.achievements.length;
        expect(totalAchievements, greaterThan(0));
        await service.trackEnhancedProgress('neural_awakening');
        final statsAfterOneUnlock = service.state.stats;
        expect(statsAfterOneUnlock.unlockedAchievements, equals(1));
        expect(statsAfterOneUnlock.completionPercentage, closeTo((1 / totalAchievements * 100), 0.01));
        await service.trackEnhancedProgress('first_synthesis');
        final statsAfterTwoUnlocks = service.state.stats;
        expect(statsAfterTwoUnlocks.unlockedAchievements, equals(2));
        expect(statsAfterTwoUnlocks.completionPercentage, closeTo((2 / totalAchievements * 100), 0.01));
      });

      test('should track points correctly by rarity upon unlocking', () async {
        await service.trackEnhancedProgress('neural_awakening'); // Common (10 points)
        await service.trackEnhancedProgress('particle_whisperer', increment: 50); // Rare (25 points), target 50
        final stats = service.state.stats;
        expect(stats.totalPoints, equals(10 + 25));
        expect(stats.commonUnlocked, equals(1));
        expect(stats.rareUnlocked, equals(1));
        expect(stats.epicUnlocked, equals(0));
      });

      test('should maintain accurate category statistics (reflected in favoriteCategory)', () async {
        await service.trackParticleInteraction(); // Unlocks 'neural_awakening' (particles)
        await service.trackOrchestration(['claude'], 'parallel'); // Unlocks 'first_synthesis' (orchestration)
        await service.trackEnhancedProgress('particle_whisperer', increment: 50); // particles
        final stats = service.state.stats;
        expect(stats.favoriteCategory, equals(AchievementCategory.particles.name));
      });
    });
  });
}