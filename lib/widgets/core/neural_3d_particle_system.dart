// 🧬 NEURAL 3D PARTICLE SYSTEM - ENHANCED VERSION
// lib/widgets/core/neural_3d_particle_system.dart
// Revolutionary 3D-like particle effects with AI orchestration integration

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

import '../../core/providers/providers_main.dart';
import '../../core/services/spatial_audio_service.dart'; // NEW IMPORT
import '../../core/theme/neural_theme_system.dart'; // NEW IMPORT

/// 🌟 3D Neural Particle System Widget
class Neural3DParticleSystem extends ConsumerStatefulWidget {
  final Size size;
  final bool isActive;
  final double intensity;
  final Color primaryColor;
  final Color secondaryColor;
  final NeuralThemeData? neuralTheme; // NEW PARAMETER

  const Neural3DParticleSystem({
    super.key,
    required this.size,
    this.isActive = true,
    this.intensity = 1.0,
    this.primaryColor = const Color(0xFF6366F1),
    this.secondaryColor = const Color(0xFF8B5CF6),
    this.neuralTheme, // NEW PARAMETER
  });

  @override
  ConsumerState<Neural3DParticleSystem> createState() => _Neural3DParticleSystemState();
}

class _Neural3DParticleSystemState extends ConsumerState<Neural3DParticleSystem>
    with TickerProviderStateMixin {

  late AnimationController _masterController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;

  late Animation<double> _masterAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  final List<Neural3DParticle> _particles = [];
  final List<NeuralConnection> _connections = [];

  // Performance tracking
  int _frameCount = 0;
  DateTime _lastFpsCheck = DateTime.now();
  double _currentFps = 60.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticleSystem();
    _startFpsCounter();
  }

  void _initializeAnimations() {
    // Master timeline - 20 second loop
    _masterController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _masterAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(_masterController);

    // Pulse for AI activity
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2)
        .animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // 3D rotation effect
    _rotationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(_rotationController);

    // Start animations
    _masterController.repeat();
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  void _generateParticleSystem() {
    final random = math.Random();
    _particles.clear();
    _connections.clear();

    // Generate 3D-positioned particles
    const particleCount = 150;
    for (int i = 0; i < particleCount; i++) {
      _particles.add(Neural3DParticle(
        id: i,
        position: Vector3(
          random.nextDouble() * widget.size.width,
          random.nextDouble() * widget.size.height,
          random.nextDouble() * 500 - 250, // Z depth: -250 to +250
        ),
        velocity: Vector3(
          (random.nextDouble() - 0.5) * 0.8,
          (random.nextDouble() - 0.5) * 0.8,
          (random.nextDouble() - 0.5) * 0.3,
        ),
        size: 1.0 + random.nextDouble() * 4.0,
        baseOpacity: 0.15 + random.nextDouble() * 0.4,
        particleType: NeuralParticleType.values[random.nextInt(NeuralParticleType.values.length)],
        phase: random.nextDouble() * math.pi * 2,
        rotationSpeed: (random.nextDouble() - 0.5) * 0.02,
        pulseCycle: random.nextDouble() * 5.0,
      ));
    }

    // Generate connections between nearby particles
    _generateNeuralConnections();
  }

  void _generateNeuralConnections() {
    _connections.clear();
    const maxDistance = 120.0;
    const maxConnections = 300;

    for (int i = 0; i < _particles.length; i++) {
      for (int j = i + 1; j < _particles.length; j++) {
        if (_connections.length >= maxConnections) break;

        final distance = _particles[i].position.distanceTo(_particles[j].position);
        if (distance < maxDistance) {
          _connections.add(NeuralConnection(
            fromParticle: i,
            toParticle: j,
            strength: (maxDistance - distance) / maxDistance,
            pulsePhase: math.Random().nextDouble() * math.pi * 2,
          ));
        }
      }
    }
  }

  void _startFpsCounter() {
    // Performance monitoring
    _masterController.addListener(() {
      _frameCount++;
      final now = DateTime.now();
      if (now.difference(_lastFpsCheck).inMilliseconds >= 1000) {
        setState(() {
          _currentFps = _frameCount / (now.difference(_lastFpsCheck).inMilliseconds / 1000);
          _frameCount = 0;
          _lastFpsCheck = now;
        });
      }
    });
  }

  @override
  void didUpdateWidget(Neural3DParticleSystem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.size != widget.size) {
      _generateParticleSystem();
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch AI orchestration state for reactive effects
    final orchestrationService = ref.watch(webSocketOrchestrationServiceProvider);
    final isOrchestrationActive = ref.watch(isOrchestrationActiveProvider);
    final activeModels = ref.watch(activeModelsProvider);
    final spatialAudioService = ref.watch(spatialAudioServiceProvider); // NEW AUDIO SERVICE

    // Use passed theme or default to cosmos
    final neuralTheme = widget.neuralTheme ?? NeuralThemeData.cosmos();

    return AnimatedBuilder(
      animation: Listenable.merge([
        _masterAnimation,
        _pulseAnimation,
        _rotationAnimation,
      ]),
      builder: (context, child) {
        return CustomPaint(
          painter: Neural3DParticlesPainter(
            particles: _particles,
            connections: _connections,
            masterProgress: _masterAnimation.value,
            pulseValue: _pulseAnimation.value,
            rotationValue: _rotationAnimation.value,
            size: widget.size,
            primaryColor: neuralTheme.colors.primary, // USE THEME COLORS
            secondaryColor: neuralTheme.colors.secondary, // USE THEME COLORS
            intensity: widget.intensity,
            isAIActive: isOrchestrationActive,
            activeModelCount: activeModels.length,
            isConnected: orchestrationService.isConnected,
            currentFps: _currentFps,
            spatialAudioService: spatialAudioService, // PASS AUDIO SERVICE
            neuralTheme: neuralTheme, // PASS THEME DATA
          ),
          size: widget.size,
        );
      },
    );
  }
}

/// 🧬 3D Neural Particle Data Model
class Neural3DParticle {
  final int id;
  Vector3 position;
  Vector3 velocity;
  double size;
  double baseOpacity;
  NeuralParticleType particleType;
  double phase;
  double rotationSpeed;
  double pulseCycle;

  // 3D rotation state
  double rotationX = 0.0;
  double rotationY = 0.0;
  double rotationZ = 0.0;

  Neural3DParticle({
    required this.id,
    required this.position,
    required this.velocity,
    required this.size,
    required this.baseOpacity,
    required this.particleType,
    required this.phase,
    required this.rotationSpeed,
    required this.pulseCycle,
  });

  void update(double deltaTime) {
    // Update position
    position = position.add(velocity);

    // Update rotations
    rotationX += rotationSpeed * deltaTime;
    rotationY += rotationSpeed * 0.7 * deltaTime;
    rotationZ += rotationSpeed * 0.5 * deltaTime;

    // Update phase
    phase += deltaTime * 0.5;
  }

  // 3D to 2D projection with perspective
  Offset project2D(Size screenSize, double cameraZ) {
    final perspective = cameraZ / (cameraZ + position.z);
    return Offset(
      (position.x - screenSize.width / 2) * perspective + screenSize.width / 2,
      (position.y - screenSize.height / 2) * perspective + screenSize.height / 2,
    );
  }

  double getScaledSize(double cameraZ) {
    final perspective = cameraZ / (cameraZ + position.z);
    return size * perspective;
  }
}

/// 🔗 Neural Connection Between Particles
class NeuralConnection {
  final int fromParticle;
  final int toParticle;
  final double strength;
  final double pulsePhase;

  NeuralConnection({
    required this.fromParticle,
    required this.toParticle,
    required this.strength,
    required this.pulsePhase,
  });
}

/// 🎨 3D Vector Math
class Vector3 {
  final double x;
  final double y;
  final double z;

  const Vector3(this.x, this.y, this.z);

  Vector3 add(Vector3 other) => Vector3(x + other.x, y + other.y, z + other.z);
  Vector3 subtract(Vector3 other) => Vector3(x - other.x, y - other.y, z - other.z);
  Vector3 multiply(double scalar) => Vector3(x * scalar, y * scalar, z * scalar);

  double distanceTo(Vector3 other) {
    final dx = x - other.x;
    final dy = y - other.y;
    final dz = z - other.z;
    return math.sqrt(dx * dx + dy * dy + dz * dz);
  }

  double get magnitude => math.sqrt(x * x + y * y + z * z);
  Vector3 get normalized {
    final mag = magnitude;
    return mag > 0 ? Vector3(x / mag, y / mag, z / mag) : Vector3(0, 0, 0);
  }
}

/// 🎯 Neural Particle Types
enum NeuralParticleType {
  neuron,      // Main neural nodes
  synapse,     // Connection points
  electrical,  // Electric impulses
  quantum,     // Quantum effects
  data,        // Data packets
}

/// 🎨 3D Neural Particles Painter - THE MAGIC HAPPENS HERE
class Neural3DParticlesPainter extends CustomPainter {
  final List<Neural3DParticle> particles;
  final List<NeuralConnection> connections;
  final double masterProgress;
  final double pulseValue;
  final double rotationValue;
  final Size size;
  final Color primaryColor;
  final Color secondaryColor;
  final double intensity;
  final bool isAIActive;
  final int activeModelCount;
  final bool isConnected;
  final double currentFps;
  final SpatialAudioService spatialAudioService; // NEW AUDIO SERVICE
  final NeuralThemeData neuralTheme; // NEW THEME DATA

  // 3D Camera settings
  static const double cameraZ = 400.0;
  static const double fov = 60.0;

  // Audio timing control
  static int _lastAudioFrame = 0;
  static final List<int> _recentAudioEvents = [];

  Neural3DParticlesPainter({
    required this.particles,
    required this.connections,
    required this.masterProgress,
    required this.pulseValue,
    required this.rotationValue,
    required this.size,
    required this.primaryColor,
    required this.secondaryColor,
    required this.intensity,
    required this.isAIActive,
    required this.activeModelCount,
    required this.isConnected,
    required this.currentFps,
    required this.spatialAudioService, // NEW PARAMETER
    required this.neuralTheme, // NEW PARAMETER
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Performance check - reduce particles if FPS drops
    final performanceMultiplier = (currentFps > 45) ? 1.0 : 0.6;

    // Apply theme-based background
    _drawThemedBackground(canvas, size);

    // Update particle positions
    _updateParticles();

    // Draw neural connections first (behind particles)
    _drawNeuralConnections(canvas, size, performanceMultiplier);

    // Draw 3D particles with depth sorting
    _draw3DParticles(canvas, size, performanceMultiplier);

    // Draw AI activity overlay effects
    if (isAIActive) {
      _drawAIActivityEffects(canvas, size);
      _triggerAIActivityAudio(); // NEW AUDIO TRIGGER
    }

    // Trigger particle-based audio events
    _triggerParticleAudio();

    // Draw performance indicator (debug mode)
    if (currentFps < 50) {
      _drawPerformanceWarning(canvas, size);
    }
  }

  /// 🎨 Draw Themed Background
  void _drawThemedBackground(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = neuralTheme.gradients.background.createShader(rect);

    canvas.drawRect(rect, paint);
  }

  /// 🔊 Trigger AI Activity Audio Events
  void _triggerAIActivityAudio() {
    if (!spatialAudioService.isEnabled || !spatialAudioService.isInitialized) return;

    final currentFrame = (masterProgress * 1000).round();

    // Trigger orchestration start sound (once per session)
    if (isAIActive && !_recentAudioEvents.contains(999)) {
      spatialAudioService.playOrchestrationStart();
      _recentAudioEvents.add(999);

      // Clear the event after 30 seconds
      Future.delayed(const Duration(seconds: 30), () {
        _recentAudioEvents.remove(999);
      });
    }

    // Trigger AI thinking sounds for active models
    if (currentFrame % 180 == 0) { // Every 3 seconds at 60fps
      for (int i = 0; i < activeModelCount; i++) {
        final angle = (i / activeModelCount) * 2 * math.pi;
        const radius = 100.0;
        final position = SpatialPosition(
          x: size.width / 2 + math.cos(angle) * radius,
          y: size.height / 2 + math.sin(angle) * radius,
          z: math.sin(masterProgress * math.pi * 2) * 50,
        );

        spatialAudioService.playAIThinking('model_$i', position);
      }
    }
  }

  /// 🧠 Trigger Particle-Based Audio Events
  void _triggerParticleAudio() {
    if (!spatialAudioService.isEnabled || !spatialAudioService.isInitialized) return;

    final currentFrame = (masterProgress * 1000).round();

    // Limit audio events to prevent overload
    if (currentFrame - _lastAudioFrame < 10) return; // Max 6 events per second

    // Trigger neuron firing sounds for active particles
    if (currentFrame % 120 == 0) { // Every 2 seconds
      final activeParticles = particles.where((p) =>
      p.particleType == NeuralParticleType.neuron &&
          _isParticleVisible(p)
      ).take(3).toList(); // Limit to 3 particles

      for (final particle in activeParticles) {
        final pos2D = particle.project2D(size, cameraZ);
        final position = SpatialPosition.fromOffset(pos2D, z: particle.position.z);
        spatialAudioService.playNeuronActivity(position);
      }
    }

    // Trigger synapse connection sounds
    if (currentFrame % 200 == 0 && connections.isNotEmpty) { // Every ~3.3 seconds
      final connection = connections[currentFrame % connections.length];
      if (connection.fromParticle < particles.length &&
          connection.toParticle < particles.length) {

        final fromParticle = particles[connection.fromParticle];
        final toParticle = particles[connection.toParticle];

        if (_isParticleVisible(fromParticle) || _isParticleVisible(toParticle)) {
          final fromPos2D = fromParticle.project2D(size, cameraZ);
          final toPos2D = toParticle.project2D(size, cameraZ);

          final fromPos = SpatialPosition.fromOffset(fromPos2D, z: fromParticle.position.z);
          final toPos = SpatialPosition.fromOffset(toPos2D, z: toParticle.position.z);

          spatialAudioService.playSynapseConnection(fromPos, toPos);
        }
      }
    }

    // Trigger data flow sounds for data particles
    if (currentFrame % 300 == 0) { // Every 5 seconds
      final dataParticles = particles.where((p) =>
      p.particleType == NeuralParticleType.data &&
          _isParticleVisible(p)
      ).take(2).toList();

      for (final particle in dataParticles) {
        final pos2D = particle.project2D(size, cameraZ);
        final position = SpatialPosition.fromOffset(pos2D, z: particle.position.z);
        spatialAudioService.playDataFlow(position);
      }
    }

    _lastAudioFrame = currentFrame;
  }

  /// 🔍 Check if Particle is Visible
  bool _isParticleVisible(Neural3DParticle particle) {
    final pos2D = particle.project2D(size, cameraZ);
    return _isPointVisible(pos2D, size);
  }

  void _updateParticles() {
    for (final particle in particles) {
      particle.update(0.016); // 60 FPS delta time

      // Boundary wrapping with 3D considerations
      if (particle.position.x < -50) {
        particle.position = Vector3(size.width + 50, particle.position.y, particle.position.z);
      } else if (particle.position.x > size.width + 50) {
        particle.position = Vector3(-50, particle.position.y, particle.position.z);
      }

      if (particle.position.y < -50) {
        particle.position = Vector3(particle.position.x, size.height + 50, particle.position.z);
      } else if (particle.position.y > size.height + 50) {
        particle.position = Vector3(particle.position.x, -50, particle.position.z);
      }

      // Z-axis wrapping
      if (particle.position.z < -300) {
        particle.position = Vector3(particle.position.x, particle.position.y, 300);
      } else if (particle.position.z > 300) {
        particle.position = Vector3(particle.position.x, particle.position.y, -300);
      }
    }
  }

  void _drawNeuralConnections(Canvas canvas, Size size, double performanceMultiplier) {
    final connectionPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Reduce connections if performance is low
    final maxConnections = (connections.length * performanceMultiplier).round();

    for (int i = 0; i < math.min(connections.length, maxConnections); i++) {
      final connection = connections[i];
      final fromParticle = particles[connection.fromParticle];
      final toParticle = particles[connection.toParticle];

      // Project 3D positions to 2D
      final fromPos = fromParticle.project2D(size, cameraZ);
      final toPos = toParticle.project2D(size, cameraZ);

      // Check if connection is visible
      if (!_isPointVisible(fromPos, size) && !_isPointVisible(toPos, size)) continue;

      // Calculate connection opacity based on distance and activity
      final baseOpacity = connection.strength * 0.3;
      final pulseEffect = math.sin(masterProgress * math.pi * 2 + connection.pulsePhase) * 0.5 + 0.5;
      final aiBoost = isAIActive ? 0.4 : 0.0;
      final opacity = (baseOpacity + pulseEffect * 0.2 + aiBoost) * intensity;

      // Color interpolation based on AI activity
      final connectionColor = Color.lerp(
        neuralTheme.colors.connectionActive.withOpacity(opacity),
        neuralTheme.colors.connectionInactive.withOpacity(opacity),
        pulseEffect,
      )!;

      connectionPaint.color = connectionColor;

      // Draw pulsing connection line
      final path = Path();
      path.moveTo(fromPos.dx, fromPos.dy);

      // Add slight curve for organic feel
      final midPoint = Offset(
        (fromPos.dx + toPos.dx) / 2 + math.sin(masterProgress * math.pi + i) * 5,
        (fromPos.dy + toPos.dy) / 2 + math.cos(masterProgress * math.pi + i) * 5,
      );

      path.quadraticBezierTo(midPoint.dx, midPoint.dy, toPos.dx, toPos.dy);
      canvas.drawPath(path, connectionPaint);

      // Draw pulse dots along connection
      if (isAIActive && i % 3 == 0) {
        _drawConnectionPulse(canvas, fromPos, toPos, connection, pulseEffect);
      }
    }
  }

  void _draw3DParticles(Canvas canvas, Size size, double performanceMultiplier) {
    // Sort particles by Z-depth for proper 3D rendering
    final sortedParticles = List<Neural3DParticle>.from(particles);
    sortedParticles.sort((a, b) => b.position.z.compareTo(a.position.z));

    // Reduce particles if performance is low
    final maxParticles = (sortedParticles.length * performanceMultiplier).round();

    for (int i = 0; i < math.min(sortedParticles.length, maxParticles); i++) {
      final particle = sortedParticles[i];

      // Project to 2D with perspective
      final pos2D = particle.project2D(size, cameraZ);
      if (!_isPointVisible(pos2D, size)) continue;

      // Calculate scaled size based on depth
      final scaledSize = particle.getScaledSize(cameraZ);
      if (scaledSize < 0.5) continue; // Skip tiny particles

      // Calculate dynamic opacity
      final depthFactor = math.max(0.1, (cameraZ + particle.position.z) / (cameraZ * 2));
      final pulseEffect = math.sin(masterProgress * math.pi * 2 + particle.phase) * 0.5 + 0.5;
      final aiBoost = isAIActive ? (0.3 + pulseValue * 0.2) : 0.0;
      final opacity = (particle.baseOpacity * depthFactor + aiBoost) * intensity;

      // Draw particle based on type
      _drawTypedParticle(canvas, particle, pos2D, scaledSize, opacity, pulseEffect);
    }
  }

  void _drawTypedParticle(Canvas canvas, Neural3DParticle particle, Offset pos,
      double size, double opacity, double pulseEffect) {
    final paint = Paint()..style = PaintingStyle.fill;

    switch (particle.particleType) {
      case NeuralParticleType.neuron:
      // Main neural node with gradient
        paint.shader = ui.Gradient.radial(
          pos,
          size,
          [
            neuralTheme.colors.particleNeuron.withOpacity(opacity),
            neuralTheme.colors.particleNeuron.withOpacity(opacity * 0.3),
          ],
        );
        canvas.drawCircle(pos, size, paint);

        // Neural glow
        paint.shader = ui.Gradient.radial(
          pos,
          size * 2,
          [
            neuralTheme.colors.neuralGlow.withOpacity(opacity * 0.1),
            Colors.transparent,
          ],
        );
        canvas.drawCircle(pos, size * 2, paint);
        break;

      case NeuralParticleType.synapse:
      // Synaptic connection point
        paint.color = neuralTheme.colors.particleSynapse.withOpacity(opacity);
        canvas.drawCircle(pos, size * 0.7, paint);

        // Synaptic spark
        if (pulseEffect > 0.7) {
          paint.color = Colors.white.withOpacity(opacity * 0.8);
          canvas.drawCircle(pos, size * 0.3, paint);
        }
        break;

      case NeuralParticleType.electrical:
      // Electric impulse
        paint.color = Color.lerp(neuralTheme.colors.accent, Colors.white, pulseEffect)!.withOpacity(opacity);
        canvas.drawCircle(pos, size * (0.5 + pulseEffect * 0.5), paint);

        // Electric trails
        _drawElectricTrails(canvas, pos, size, opacity, particle.rotationX);
        break;

      case NeuralParticleType.quantum:
      // Quantum particle with uncertainty
        final quantumSize = size * (0.8 + math.sin(particle.phase * 3) * 0.4);
        paint.color = neuralTheme.colors.primary.withOpacity(opacity * (0.6 + pulseEffect * 0.4));
        canvas.drawCircle(pos, quantumSize, paint);

        // Quantum interference pattern
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1.0;
        paint.color = neuralTheme.colors.secondary.withOpacity(opacity * 0.3);
        canvas.drawCircle(pos, quantumSize * 1.5, paint);
        break;

      case NeuralParticleType.data:
      // Data packet
        paint.color = Color.lerp(neuralTheme.colors.particleData, neuralTheme.colors.accent, pulseEffect)!.withOpacity(opacity);
        final rect = Rect.fromCenter(center: pos, width: size * 1.2, height: size * 0.8);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(size * 0.2)), paint);

        // Data flow indicator
        paint.color = Colors.white.withOpacity(opacity * 0.6);
        final dataRect = Rect.fromCenter(center: pos, width: size * 0.8, height: size * 0.4);
        canvas.drawRRect(RRect.fromRectAndRadius(dataRect, Radius.circular(size * 0.1)), paint);
        break;
    }
  }

  void _drawElectricTrails(Canvas canvas, Offset center, double size, double opacity, double rotation) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.cyan.withOpacity(opacity * 0.6);

    for (int i = 0; i < 3; i++) {
      final angle = rotation + (i * math.pi * 2 / 3);
      final start = center + Offset(math.cos(angle) * size, math.sin(angle) * size);
      final end = center + Offset(math.cos(angle) * size * 2, math.sin(angle) * size * 2);
      canvas.drawLine(start, end, paint);
    }
  }

  void _drawConnectionPulse(Canvas canvas, Offset from, Offset to,
      NeuralConnection connection, double pulseEffect) {
    final pulsePos = Offset.lerp(from, to, pulseEffect)!;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.8);

    canvas.drawCircle(pulsePos, 2.0, paint);
  }

  void _drawAIActivityEffects(Canvas canvas, Size size) {
    // AI orchestration visual feedback
    final center = Offset(size.width / 2, size.height / 2);

    // Orchestration energy rings
    for (int i = 0; i < activeModelCount; i++) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = Color.lerp(primaryColor, secondaryColor, i / activeModelCount)!
            .withOpacity(0.3 * pulseValue);

      final radius = 50.0 + i * 30.0 + pulseValue * 20.0;
      canvas.drawCircle(center, radius, paint);
    }

    // Central orchestration core
    final corePaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        30.0 * pulseValue,
        [
          Colors.white.withOpacity(0.8),
          primaryColor.withOpacity(0.4),
          Colors.transparent,
        ],
      );

    canvas.drawCircle(center, 30.0 * pulseValue, corePaint);
  }

  void _drawPerformanceWarning(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(10, 10, 200, 30);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(5)), paint);

    // Performance warning text would be drawn by parent widget
  }

  bool _isPointVisible(Offset point, Size size) {
    return point.dx >= -50 && point.dx <= size.width + 50 &&
        point.dy >= -50 && point.dy <= size.height + 50;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}