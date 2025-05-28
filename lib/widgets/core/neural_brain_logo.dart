// lib/widgets/core/neural_brain_logo.dart
// 🧠 NEURAL BRAIN LOGO - ANIMATED LUXURY VERSION
// Uses your neuronvault_logo.png with incredible neural effects

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class NeuralBrainLogo extends StatefulWidget {
  final double size;
  final bool isConnected;
  final bool showConnections;
  final Color? primaryColor;
  final Color? secondaryColor;

  const NeuralBrainLogo({
    super.key,
    this.size = 80.0,
    this.isConnected = false,
    this.showConnections = true,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  State<NeuralBrainLogo> createState() => _NeuralBrainLogoState();
}

class _NeuralBrainLogoState extends State<NeuralBrainLogo>
    with TickerProviderStateMixin {

  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _connectionController;
  late AnimationController _glowController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _connectionAnimation;
  late Animation<double> _glowAnimation;

  // Neural connection points
  List<Offset> _connectionPoints = [];
  final List<NeuralConnection> _connections = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateConnectionPoints();
    _generateConnections();
  }

  void _initializeAnimations() {
    // Main pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Subtle rotation
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rotationController);

    // Neural connections pulse
    _connectionController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _connectionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _connectionController,
      curve: Curves.easeInOut,
    ));

    // Glow effect
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _connectionController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
  }

  void _generateConnectionPoints() {
    final center = Offset(widget.size / 2, widget.size / 2);
    final radius = widget.size * 0.35;

    _connectionPoints = List.generate(8, (index) {
      final angle = (index * math.pi * 2) / 8;
      return Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
    });
  }

  void _generateConnections() {
    _connections.clear();

    // Create neural connections between points
    for (int i = 0; i < _connectionPoints.length; i++) {
      for (int j = i + 1; j < _connectionPoints.length; j++) {
        // Only create some connections to avoid clutter
        if ((i + j) % 3 == 0) {
          _connections.add(NeuralConnection(
            start: _connectionPoints[i],
            end: _connectionPoints[j],
            intensity: 0.3 + (math.Random().nextDouble() * 0.7),
            phase: math.Random().nextDouble() * math.pi * 2,
          ));
        }
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _connectionController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.primaryColor ?? theme.colorScheme.primary;
    final secondaryColor = widget.secondaryColor ?? theme.colorScheme.secondary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseAnimation,
          _rotationAnimation,
          _connectionAnimation,
          _glowAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
              scale: _pulseAnimation.value,
              child: Transform.rotate(
                  angle: _rotationAnimation.value * 0.1, // Very subtle rotation
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                  // Outer glow effect
                  Container(
                  width: widget.size * 1.2,
                    height: widget.size * 1.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(
                              0.3 * _glowAnimation.value
                          ),
                          blurRadius: 30 * _glowAnimation.value,
                          spreadRadius: 5 * _glowAnimation.value,
                        ),
                        BoxShadow(
                          color: secondaryColor.withOpacity(
                              0.2 * _glowAnimation.value
                          ),
                          blurRadius: 50 * _glowAnimation.value,
                          spreadRadius: 10 * _glowAnimation.value,
                        ),
                      ],
                    ),
                  ),

                  // Neural connections
                  if (widget.showConnections)
              CustomPaint(
              size: Size(widget.size, widget.size),
          painter: NeuralConnectionsPainter(
          connections: _connections,
          animationValue: _connectionAnimation.value,
          primaryColor: primaryColor,
          isConnected: widget.isConnected,
          ),
          ),

          // Connection points
          if (widget.showConnections)
          ..._connectionPoints.asMap().entries.map((entry) {
          final index = entry.key;
          final point = entry.value;
          final phase = index * 0.2;

          return Positioned(
          left: point.dx - 3,
          top: point.dy - 3,
          child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primaryColor.withOpacity(
          0.6 + 0.4 * math.sin(_connectionAnimation.value * math.pi * 2 + phase)
          ),
          boxShadow: [
          BoxShadow(
          color: primaryColor.withOpacity(0.5),
          blurRadius: 4,
          spreadRadius: 1,
          ),
          ],
          ),
          ),
          );
          }),

          // Main logo container with glassmorphism
          Container(
          width: widget.size * 0.8,
          height: widget.size * 0.8,
          decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
          colors: [
          primaryColor.withOpacity(0.2),
          secondaryColor.withOpacity(0.1),
          Colors.transparent,
          ],
          stops: const [0.0, 0.7, 1.0],
          ),
          border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 1,
          ),
          ),
          child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.size * 0.4),
          child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
          decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
          ),
          child: Padding(
          padding: EdgeInsets.all(widget.size * 0.1),
          child: Image.asset(
          'assets/images/neuronvault_logo.png',
          width: widget.size * 0.6,
          height: widget.size * 0.6,
          fit: BoxFit.contain,
          ),
          ),
          ),
          ),
          ),
          ),

          // Activity indicator
          if (widget.isConnected)
          Positioned(
          bottom: 0,
          right: 0,
          child: Container(
          width: widget.size * 0.2,
          height: widget.size * 0.2,
          decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green,
          border: Border.all(
          color: Colors.white,
          width: 2,
          ),
          boxShadow: [
          BoxShadow(
          color: Colors.green.withOpacity(0.5),
          blurRadius: 8,
          spreadRadius: 2,
          ),
          ],
          ),
          ),
          ),
          ],
          ),
          ),
          );
        },
      ),
    );
  }
}

// Neural connection data class
class NeuralConnection {
  final Offset start;
  final Offset end;
  final double intensity;
  final double phase;

  NeuralConnection({
    required this.start,
    required this.end,
    required this.intensity,
    required this.phase,
  });
}

// Custom painter for neural connections
class NeuralConnectionsPainter extends CustomPainter {
  final List<NeuralConnection> connections;
  final double animationValue;
  final Color primaryColor;
  final bool isConnected;

  NeuralConnectionsPainter({
    required this.connections,
    required this.animationValue,
    required this.primaryColor,
    required this.isConnected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final connection in connections) {
      // Calculate animated opacity based on connection phase
      final phase = connection.phase + animationValue * math.pi * 2;
      final opacity = isConnected
          ? 0.3 + 0.4 * connection.intensity * math.sin(phase).abs()
          : 0.1 + 0.2 * connection.intensity * math.sin(phase).abs();

      paint.color = primaryColor.withOpacity(opacity);

      // Draw the connection line
      canvas.drawLine(connection.start, connection.end, paint);

      // Draw animated pulse along the line
      if (isConnected && opacity > 0.5) {
        final pulsePosition = (math.sin(phase) + 1) / 2;
        final pulsePoint = Offset.lerp(
          connection.start,
          connection.end,
          pulsePosition,
        )!;

        final pulsePaint = Paint()
          ..color = primaryColor.withOpacity(0.8)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(pulsePoint, 2, pulsePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}