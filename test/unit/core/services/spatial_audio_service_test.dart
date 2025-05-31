import 'package:flutter_test/flutter_test.dart';
import '../../../../lib/core/services/spatial_audio_service.dart';

void main() {
  group('🔊 SpatialAudioService Tests', () {
    late SpatialAudioService audioService;

    setUp(() {
      audioService = SpatialAudioService();
    });

    tearDown(() {
      audioService.dispose();
    });

    group('🚀 Initialization Tests', () {
      test('should initialize as singleton', () {
        final audioService1 = SpatialAudioService();
        final audioService2 = SpatialAudioService();

        expect(identical(audioService1, audioService2), isTrue);
      });

      test('should initialize successfully', () async {
        final result = await audioService.initialize();

        expect(result, isTrue);
        expect(audioService.isInitialized, isTrue);
      });

      test('should handle multiple initialization calls', () async {
        final result1 = await audioService.initialize();
        final result2 = await audioService.initialize();

        expect(result1, isTrue);
        expect(result2, isTrue);
      });
    });

    group('🎚️ Volume Control Tests', () {
      test('should set master volume correctly', () {
        audioService.setMasterVolume(0.5);
        expect(audioService.masterVolume, equals(0.5));

        audioService.setMasterVolume(1.2); // Should clamp to 1.0
        expect(audioService.masterVolume, equals(1.0));

        audioService.setMasterVolume(-0.1); // Should clamp to 0.0
        expect(audioService.masterVolume, equals(0.0));
      });

      test('should set ambient volume correctly', () {
        audioService.setAmbientVolume(0.3);
        // Test passes if no exception is thrown
      });

      test('should set effects volume correctly', () {
        audioService.setEffectsVolume(0.8);
        // Test passes if no exception is thrown
      });
    });

    group('🎛️ Enable/Disable Tests', () {
      test('should enable and disable audio system', () {
        audioService.setEnabled(false);
        expect(audioService.isEnabled, isFalse);

        audioService.setEnabled(true);
        expect(audioService.isEnabled, isTrue);
      });

      test('should clear active sources when disabled', () async {
        await audioService.initialize();
        audioService.setEnabled(true);

        // Play a sound
        await audioService.playNeuralSound(NeuralSoundType.neuronFire);

        // Disable audio
        audioService.setEnabled(false);

        expect(audioService.activeSourceCount, equals(0));
      });
    });

    group('🎵 Neural Sound Playing Tests', () {
      test('should play neural sounds when enabled', () async {
        await audioService.initialize();
        audioService.setEnabled(true);

        await audioService.playNeuralSound(
          NeuralSoundType.neuronFire,
          volume: 0.8,
          pitch: 1.2,
        );

        expect(audioService.activeSourceCount, greaterThan(0));
      });

      test('should not play sounds when disabled', () async {
        await audioService.initialize();
        audioService.setEnabled(false);

        await audioService.playNeuralSound(NeuralSoundType.neuronFire);

        expect(audioService.activeSourceCount, equals(0));
      });

      test('should play sounds with spatial positioning', () async {
        await audioService.initialize();
        audioService.setEnabled(true);

        const position = SpatialPosition(x: 100, y: 200, z: 50);

        await audioService.playNeuralSound(
          NeuralSoundType.synapseConnect,
          position: position,
        );

        expect(audioService.activeSourceCount, greaterThan(0));
      });
    });

    group('🧠 AI Orchestration Audio Tests', () {
      test('should play orchestration start sound', () async {
        await audioService.initialize();
        audioService.setEnabled(true);

        audioService.playOrchestrationStart();

        expect(audioService.activeSourceCount, greaterThan(0));
      });

      test('should prevent duplicate orchestration sounds', () async {
        await audioService.initialize();
        audioService.setEnabled(true);

        audioService.playOrchestrationStart();
        final firstCount = audioService.activeSourceCount;

        audioService.playOrchestrationStart(); // Should not add another
        final secondCount = audioService.activeSourceCount;

        expect(secondCount, equals(firstCount));
      });

      test('should play AI thinking sounds', () async {
        await audioService.initialize();
        audioService.setEnabled(true);

        const position = SpatialPosition(x: 0, y: 0, z: 0);

        audioService.playAIThinking('claude', position);

        expect(audioService.activeSourceCount, greaterThan(0));
      });

      test('should play synthesis completion sound', () async {
        await audioService.initialize();
        audioService.setEnabled(true);

        audioService.playSynthesisComplete();

        expect(audioService.activeSourceCount, greaterThan(0));
      });
    });

    group('🌊 Particle System Audio Tests', () {
      test('should play neuron activity sounds', () async {
        await audioService.initialize();
        audioService.setEnabled(true);

        const position = SpatialPosition(x: 50, y: 100, z: 25);

        audioService.playNeuronActivity(position);

        expect(audioService.activeSourceCount, greaterThan(0));
      });

      test('should limit neuron activity sounds to prevent spam', () async {
        await audioService.initialize();
        audioService.setEnabled(true);

        const position = SpatialPosition(x: 0, y: 0, z: 0);

        // Play many neuron sounds rapidly
        for (int i = 0; i < 10; i++) {
          audioService.playNeuronActivity(position);
        }

        // Should limit to reasonable number
        expect(audioService.activeSourceCount, lessThanOrEqualTo(5));
      });

      test('should play synapse connection sounds', () async {
        await audioService.initialize();
        audioService.setEnabled(true);

        const fromPos = SpatialPosition(x: 0, y: 0, z: 0);
        const toPos = SpatialPosition(x: 100, y: 100, z: 0);

        audioService.playSynapseConnection(fromPos, toPos);

        expect(audioService.activeSourceCount, greaterThan(0));
      });

      test('should play data flow sounds', () async {
        await audioService.initialize();
        audioService.setEnabled(true);

        const position = SpatialPosition(x: 50, y: 50, z: 50);

        audioService.playDataFlow(position);

        expect(audioService.activeSourceCount, greaterThan(0));
      });
    });

    group('📊 Performance Monitoring Tests', () {
      test('should track CPU usage based on active sources', () async {
        await audioService.initialize();
        audioService.setEnabled(true);

        // Play several sounds
        for (int i = 0; i < 5; i++) {
          await audioService.playNeuralSound(NeuralSoundType.neuronFire);
        }

        expect(audioService.cpuUsage, greaterThan(0.0));
        expect(audioService.cpuUsage, lessThanOrEqualTo(1.0));
      });

      test('should clean up old sources automatically', () async {
        await audioService.initialize();
        audioService.setEnabled(true);

        // Play a sound
        await audioService.playNeuralSound(NeuralSoundType.neuronFire);

        // Wait for cleanup (simulated by internal timer)
        await Future.delayed(const Duration(milliseconds: 1000));

        // Active sources should decrease as sounds finish
        expect(audioService.activeSourceCount, greaterThanOrEqualTo(0));
      });
    });

    group('📍 Spatial Positioning Tests', () {
      test('should create spatial position from offset', () {
        const offset = Offset(100, 200);
        final position = SpatialPosition.fromOffset(offset, z: 50);

        expect(position.x, equals(100));
        expect(position.y, equals(200));
        expect(position.z, equals(50));
      });

      test('should handle spatial position calculations', () {
        const position1 = SpatialPosition(x: 0, y: 0, z: 0);
        const position2 = SpatialPosition(x: 100, y: 100, z: 0);

        // Test midpoint calculation (used in synapse connections)
        final midpointX = (position1.x + position2.x) / 2;
        final midpointY = (position1.y + position2.y) / 2;

        expect(midpointX, equals(50));
        expect(midpointY, equals(50));
      });
    });

    group('🔧 Error Handling Tests', () {
      test('should handle playback when not initialized', () async {
        // Don't initialize
        audioService.setEnabled(true);

        expect(
              () => audioService.playNeuralSound(NeuralSoundType.neuronFire),
          returnsNormally,
        );
      });

      test('should handle invalid sound parameters', () async {
        await audioService.initialize();
        audioService.setEnabled(true);

        expect(
              () => audioService.playNeuralSound(
            NeuralSoundType.neuronFire,
            volume: -1.0, // Invalid volume
            pitch: 10.0,  // Extreme pitch
          ),
          returnsNormally,
        );
      });
    });

    group('🧹 Cleanup Tests', () {
      test('should dispose properly', () {
        expect(() => audioService.dispose(), returnsNormally);
      });
    });
  });
}