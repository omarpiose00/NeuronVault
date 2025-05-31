import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:neuronvault/core/services/achievement_service.dart';
import 'package:neuronvault/core/state/state_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

// Import corretti
import '../../mocks/mock_services.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('🏆 EnhancedAchievementService Tests', () {
    late EnhancedAchievementService achievementService;
    late SharedPreferences prefs;
    late MockLogger mockLogger;
    late String validAchievementId;
    late String bulkAchievementId;

    setUp(() async {
      // CORREZIONE: Usa SharedPreferences reale con mock values (più affidabile)
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();

      mockLogger = MockLogger();

      achievementService = EnhancedAchievementService(
        prefs: prefs,
        logger: mockLogger,
      );

      // Attesa esplicita per l'inizializzazione
      await TestHelpers.waitForCondition(
            () => achievementService.state.isInitialized,
        timeout: Duration(seconds: 3),
        timeoutMessage: 'Achievement service initialization timed out',
      );

      // Ottieni un ID di achievement valido che non sia hidden
      validAchievementId = achievementService.state.achievements.values
          .firstWhere((a) => !a.isHidden && a.targetProgress == 1)
          .id;

      // Ottieni un ID per bulk tracking
      bulkAchievementId = achievementService.state.achievements.values
          .firstWhere((a) => a.targetProgress > 1000).id;
    });

    tearDown(() async {
      // Ferma i servizi di tracking prima della disposizione
      achievementService.dispose();

      // Attendi che tutte le operazioni asincrone siano completate
      await Future.delayed(const Duration(milliseconds: 500));
    });

    group('📋 Initialization Tests', () {
      test('should initialize with default achievements', () {
        expect(achievementService.state.isInitialized, isTrue);
        expect(achievementService.state.achievements.isNotEmpty, isTrue);
        expect(achievementService.state.achievements.length, 31);
      });

      test('should have all achievement categories', () {
        final categories = achievementService.state.achievements.values
            .map((a) => a.category)
            .toSet();

        expect(categories, contains(AchievementCategory.particles));
        expect(categories, contains(AchievementCategory.orchestration));
        expect(categories, contains(AchievementCategory.themes));
        expect(categories, contains(AchievementCategory.audio));
        expect(categories, contains(AchievementCategory.profiling));
        expect(categories, contains(AchievementCategory.exploration));
      });
    });

    group('🎯 Progress Tracking Tests', () {
      test('should track progress correctly', () async {
        final initialProgress = achievementService.state.achievements[validAchievementId]!.currentProgress;

        await achievementService.trackEnhancedProgress(validAchievementId);

        final updatedAchievement = achievementService.state.achievements[validAchievementId]!;
        expect(updatedAchievement.currentProgress, greaterThan(initialProgress));
      });

      test('should unlock achievement when target reached', () async {
        final target = achievementService.state.achievements[validAchievementId]!.targetProgress;

        // Raggiungi il target
        for (int i = 0; i < target; i++) {
          await achievementService.trackEnhancedProgress(validAchievementId);
        }

        final achievement = achievementService.state.achievements[validAchievementId]!;
        expect(achievement.isUnlocked, isTrue);
        expect(achievement.unlockedAt, isNotNull);
      });

      test('should not exceed target progress', () async {
        final target = achievementService.state.achievements[validAchievementId]!.targetProgress;

        // Track multiple times
        for (int i = 0; i < target + 5; i++) {
          await achievementService.trackEnhancedProgress(validAchievementId);
        }

        final achievement = achievementService.state.achievements[validAchievementId]!;
        expect(achievement.currentProgress, equals(target));
      });
    });

    group('🎊 Notification System Tests', () {
      test('should emit notification on achievement unlock', () async {
        // Configura l'aspettativa PRIMA di sbloccare
        final expectFuture = expectLater(
          achievementService.notificationStream,
          emitsThrough(isA<AchievementNotification>()),
        );

        // Sblocca l'achievement
        final target = achievementService.state.achievements[validAchievementId]!.targetProgress;
        for (int i = 0; i < target; i++) {
          await achievementService.trackEnhancedProgress(validAchievementId);
        }

        await expectFuture;
      });

      test('should create notification with correct data', () async {
        // Configura l'aspettativa PRIMA di sbloccare
        final expectFuture = expectLater(
          achievementService.notificationStream,
          emitsThrough(predicate<AchievementNotification>(
                  (notification) => notification.achievement.id == validAchievementId
          )),
        );

        // Sblocca l'achievement
        final target = achievementService.state.achievements[validAchievementId]!.targetProgress;
        for (int i = 0; i < target; i++) {
          await achievementService.trackEnhancedProgress(validAchievementId);
        }

        await expectFuture;
      });
    });

    group('📊 Analytics Tests', () {
      test('should update live analytics', () {
        final analytics = achievementService.liveAnalytics;
        expect(analytics, isA<Map<String, dynamic>>());
        expect(analytics['session_duration'], isA<int>());
        expect(analytics['total_events'], isA<int>());
      });

      test('should track event history', () async {
        final initialCount = achievementService.eventHistory.length;

        await achievementService.trackEnhancedProgress(validAchievementId);

        // Verifica che ci sia almeno un evento con l'ID corretto
        expect(
            achievementService.eventHistory.any(
                    (event) => event.achievementId == validAchievementId
            ),
            isTrue
        );
      });
    });

    group('🎮 Specific Feature Tracking Tests', () {
      test('should track particle interactions', () async {
        // Usa un achievement specifico per particelle
        final particleAchievementId = 'neural_awakening';
        final initialProgress = achievementService.state.achievements[particleAchievementId]!.currentProgress;

        await achievementService.trackParticleInteraction(
          particleType: 'neuron',
          intensity: 0.8,
        );

        final updatedProgress = achievementService.state.achievements[particleAchievementId]!.currentProgress;
        expect(updatedProgress, greaterThan(initialProgress));
      });

      test('should track orchestration with models', () async {
        // Usa un achievement specifico per orchestrazione
        final orchestrationAchievementId = 'first_synthesis';
        final initialProgress = achievementService.state.achievements[orchestrationAchievementId]!.currentProgress;

        await achievementService.trackOrchestration(
          ['claude', 'gpt', 'deepseek'],
          'parallel',
          responseTime: 25.0,
          qualityScore: 0.9,
        );

        final updatedProgress = achievementService.state.achievements[orchestrationAchievementId]!.currentProgress;
        expect(updatedProgress, greaterThan(initialProgress));
      });

      test('should track theme activation', () async {
        const themeName = 'cosmos';
        // Usa un achievement specifico per temi
        final themeAchievementId = 'theme_$themeName';
        final initialProgress = achievementService.state.achievements[themeAchievementId]!.currentProgress;

        await achievementService.trackThemeActivation(
          themeName,
          usageDuration: const Duration(minutes: 35),
        );

        final updatedProgress = achievementService.state.achievements[themeAchievementId]!.currentProgress;
        expect(updatedProgress, greaterThan(initialProgress));
      });
    });

    group('🔧 Error Handling Tests', () {
      test('should handle invalid achievement ID gracefully', () async {
        await achievementService.trackEnhancedProgress('invalid_id');
        // Verifica che non ci siano eccezioni
        expect(true, isTrue);
      });

      test('should handle notification marking errors', () async {
        achievementService.markNotificationShown('invalid_id');
        // Verifica che non ci siano eccezioni
        expect(true, isTrue);
      });
    });

    group('🧹 Memory Management Tests', () {
      test('should limit event history size', () async {
        for (int i = 0; i < 1100; i++) {
          await achievementService.trackEnhancedProgress(bulkAchievementId);
        }

        expect(achievementService.eventHistory.length, equals(1000));
      });

      test('should dispose properly', () async {
        // Attendi per operazioni pendenti prima della disposizione
        await Future.delayed(const Duration(milliseconds: 200));
        achievementService.dispose();
        // Verifica che non ci siano eccezioni
        expect(true, isTrue);
      });
    });
  });
}